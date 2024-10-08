import 'dart:async';

import 'package:goose/goose.dart';

/// {@template goose}
/// Behold! The mighty Goose!
///
/// This goose will handle migrating up and down the [migrations].
/// {@endtemplate}
class Goose {
  /// {@macro goose}
  Goose({
    required List<Migration> migrations,
    required Future<void> Function(int index) store,
    required Future<int?> Function() retrieve,
  })  : _migrations = migrations,
        _store = store,
        _retrieve = retrieve;

  final List<Migration> _migrations;

  final Future<void> Function(int index) _store;

  final Future<int?> Function() _retrieve;

  /// Emits whenever the migration state changes.
  Stream<List<MigrationState>> get migrations => _streamController.stream;
  final _streamController = StreamController<List<MigrationState>>.broadcast();

  /// Retrieve the current state of all the migrations.
  Future<List<MigrationState>> getMigrationState() async {
    final index = await _retrieve() ?? 0;
    return _migrations
        .mapIndexed(
          (i, m) =>
              MigrationState(m.name, m.description, isMigrated: i < index),
        )
        .toList();
  }

  /// Returns true if there are migrations to go up to.
  Future<bool> canUp() => _getUpMigrations().then((v) => v.isNotEmpty);

  /// Returns true if there are migrations to go down to.
  Future<bool> canDown() => _getDownMigrations().then((v) => v.isNotEmpty);

  /// Migrate up all the way or [to] a specific migration.
  Future<void> up({String? to}) async {
    final migrations = await _getUpMigrations(to: to);
    for (var i = 0; i < migrations.length; i++) {
      final migration = migrations.elementAt(i);
      await _goUp(_migrations.indexOf(migration) + 1, migration)
          .then(_emitState);
    }
  }

  /// Migrate down all the way or [to] a specific migration.
  Future<void> down({String? to}) async {
    final migrations = await _getDownMigrations(to: to);
    for (var i = migrations.length - 1; i >= 0; i--) {
      final migration = migrations.elementAt(i);
      await _goDown(_migrations.indexOf(migration) + 1, migration)
          .then(_emitState);
    }
  }

  Future<List<Migration>> _getUpMigrations({String? to}) async {
    var end = _migrations.length;
    if (to != null) {
      end = _migrations.indexWhere((e) => e.name == to) + 1;
      if (end == 0) {
        throw Exception('No migration found with name "$to"');
      }
    }

    final migrationKey = await _retrieve() ?? 0;
    if (migrationKey >= end) return [];
    return _migrations.getRange(migrationKey, end).toList();
  }

  Future<List<Migration>> _getDownMigrations({String? to}) async {
    var start = 0;
    if (to != null) {
      start = _migrations.indexWhere((e) => e.name == to) + 1;
      if (start == 0) {
        throw Exception('No migration found with name "$to"');
      }
    }

    final migrationKey = await _retrieve() ?? 0;
    if (migrationKey < start) return [];
    return _migrations.getRange(start, migrationKey).toList();
  }

  Future<void> _goUp(int index, Migration migration) async {
    await migration.up();
    await _store(index);
  }

  Future<void> _goDown(int index, Migration migration) async {
    await migration.down();
    await _store(index - 1);
  }

  Future<void> _emitState(void _) =>
      getMigrationState().then(_streamController.add);
}

extension<E> on List<E> {
  /// Maps each element and its index to a new value.
  ///
  /// Taken from package:collection
  Iterable<R> mapIndexed<R>(R Function(int index, E element) convert) sync* {
    for (var index = 0; index < length; index++) {
      yield convert(index, this[index]);
    }
  }
}
