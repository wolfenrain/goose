// ignore_for_file: prefer_const_constructors
import 'package:goose/goose.dart';
import 'package:test/test.dart';

class _TestMigration extends Migration {
  _TestMigration(super.name, {super.description});

  @override
  Future<void> down() {
    throw UnimplementedError();
  }

  @override
  Future<void> up() {
    throw UnimplementedError();
  }
}

void main() {
  group('$Migration', () {
    test('can be instantiated', () {
      final migration = _TestMigration('test');

      expect(migration.name, equals('test'));
      expect(migration.description, equals('test'));
    });

    test('can be instantiated with description', () {
      final migration = _TestMigration('test', description: 'description');

      expect(migration.name, equals('test'));
      expect(migration.description, equals('description'));
    });
  });
}
