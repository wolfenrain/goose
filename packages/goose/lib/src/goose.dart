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
      await _goUp(_migrations.indexOf(migration), migration).then(_emitState);
    }
  }

  /// Migrate down all the way or [to] a specific migration.
  Future<void> down({String? to}) async {
    final migrations = await _getDownMigrations(to: to);
    for (var i = migrations.length - 1; i >= 0; i--) {
      final migration = migrations.elementAt(i);
      await _goDown(_migrations.indexOf(migration), migration).then(_emitState);
    }
  }

  Future<List<Migration>> _getUpMigrations({String? to}) async {
    var upTo = _migrations.indexWhere((e) => e.name == to) + 1;
    if (upTo <= 0) upTo = _migrations.length;
    final migrationKey = await _retrieve() ?? 0;
    if (migrationKey > upTo) return [];
    return _migrations.getRange(migrationKey, upTo).toList();
  }

  Future<List<Migration>> _getDownMigrations({String? to}) async {
    var downTo = _migrations.indexWhere((e) => e.name == to) + 1;
    downTo = downTo <= 0 ? 0 : downTo;
    final migrationKey = await _retrieve() ?? 0;
    if (migrationKey < downTo) return [];
    return _migrations.getRange(downTo, migrationKey).toList();
  }

  /// We store the index first because if the migration up fails we are at least
  /// able to call it's down to fix any potential issues.
  Future<void> _goUp(int index, Migration migration) =>
      _store(index + 1).then((_) => migration.up());

  /// We migrate down first and then store the index to ensure that we don't get
  /// into a state that wasn't properly reverted.
  Future<void> _goDown(int index, Migration migration) =>
      migration.down().then((_) => _store(index));

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
