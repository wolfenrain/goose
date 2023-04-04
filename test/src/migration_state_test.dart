// ignore_for_file: prefer_const_constructors
import 'package:goose/goose.dart';
import 'package:test/test.dart';

void main() {
  group('$MigrationState', () {
    test('can be instantiated', () {
      expect(
        MigrationState('test', 'description', isMigrated: true),
        isNotNull,
      );
    });

    test('are equal', () {
      final state = MigrationState('test', 'description', isMigrated: true);
      expect(
        state,
        equals(MigrationState('test', 'description', isMigrated: true)),
      );
    });

    test('has equal hash code', () {
      final state = MigrationState('test', 'description', isMigrated: true);
      expect(
        state.hashCode,
        equals(
          Object.hashAll([state.name, state.description, state.isMigrated]),
        ),
      );
    });

    test('toString', () {
      final state = MigrationState('test', 'description', isMigrated: true);
      expect(
        state.toString(),
        equals(
          '''MigrationState(name: "test", description: "description" isMigrated: true)''',
        ),
      );
    });
  });
}
