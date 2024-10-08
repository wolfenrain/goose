// ignore_for_file: prefer_const_constructors
import 'package:goose/goose.dart';
import 'package:test/test.dart';

class _TestMigration extends Migration {
  _TestMigration(
    int i, {
    required this.downCalled,
    required this.upCalled,
  }) : super('$i');

  final void Function() downCalled;
  final void Function() upCalled;

  @override
  Future<void> down() async => downCalled();

  @override
  Future<void> up() async => upCalled();
}

void main() {
  group('$Goose', () {
    late Goose goose;
    late int? currentIndex;
    late int upCalled;
    late int downCalled;

    setUp(() {
      currentIndex = null;
      upCalled = 0;
      downCalled = 0;
      goose = Goose(
        migrations: [
          for (var i = 0; i < 10; i++)
            _TestMigration(
              i,
              downCalled: () => downCalled++,
              upCalled: () => upCalled++,
            ),
        ],
        store: (index) async => currentIndex = index,
        retrieve: () async => currentIndex,
      );
    });

    group('canUp', () {
      test('returns true if we have not migrated yet', () {
        expect(goose.canUp(), completion(isTrue));
      });

      test('returns true if we are partially migrated', () {
        currentIndex = 5;
        expect(goose.canUp(), completion(isTrue));
      });

      test('returns false if we have fully migrated', () {
        currentIndex = 10;
        expect(goose.canUp(), completion(isFalse));
      });
    });

    group('canDown', () {
      test('returns false if we have not migrated yet', () {
        expect(goose.canDown(), completion(isFalse));
      });

      test('returns true if we are partially migrated', () {
        currentIndex = 5;
        expect(goose.canDown(), completion(isTrue));
      });

      test('returns true if we have fully migrated', () {
        currentIndex = 10;
        expect(goose.canDown(), completion(isTrue));
      });
    });

    group('up', () {
      test('can migrate fully up if we have not migrated yet', () async {
        await goose.up();

        expect(currentIndex, equals(10));
        expect(upCalled, equals(10));
        expect(downCalled, equals(0));
      });

      test('can migrate fully up if we are partially migrated', () async {
        currentIndex = 5;
        await goose.up();

        expect(currentIndex, equals(10));
        expect(upCalled, equals(5));
        expect(downCalled, equals(0));
      });

      test('can migrate partially up to a migration', () async {
        currentIndex = 2;
        await goose.up(to: '5');

        expect(currentIndex, equals(6));
        expect(upCalled, equals(4));
        expect(downCalled, equals(0));
      });

      test('can migrate one up', () async {
        currentIndex = 2;
        await goose.up(to: '2');

        expect(currentIndex, equals(3));
        expect(upCalled, equals(1));
        expect(downCalled, equals(0));
      });

      test('does not migrate if we are already passed the migration', () async {
        currentIndex = 5;
        await goose.up(to: '2');

        expect(currentIndex, equals(currentIndex));
        expect(upCalled, equals(0));
        expect(downCalled, equals(0));
      });

      test('throws exception with an unknown migration name', () async {
        await expectLater(goose.up(to: '1337'), throwsException);
      });
    });

    group('down', () {
      test('can migrate fully down if we have migrated', () async {
        currentIndex = 10;
        await goose.down();

        expect(currentIndex, equals(0));
        expect(upCalled, equals(0));
        expect(downCalled, equals(10));
      });

      test('can migrate fully down if we are partially migrated', () async {
        currentIndex = 5;
        await goose.down();

        expect(currentIndex, equals(0));
        expect(upCalled, equals(0));
        expect(downCalled, equals(5));
      });

      test('can migrate partially down to a migration', () async {
        currentIndex = 5;
        await goose.down(to: '2');

        expect(currentIndex, equals(3));
        expect(upCalled, equals(0));
        expect(downCalled, equals(2));
      });

      test('can migrate one down', () async {
        currentIndex = 3;
        await goose.down(to: '1');

        expect(currentIndex, equals(2));
        expect(upCalled, equals(0));
        expect(downCalled, equals(1));
      });

      test('does not migrate if we are already passed the migration', () async {
        currentIndex = 2;
        await goose.down(to: '5');

        expect(currentIndex, equals(2));
        expect(upCalled, equals(0));
        expect(downCalled, equals(0));
      });

      test('throws exception with an unknown migration name', () async {
        await expectLater(goose.down(to: '1337'), throwsException);
      });
    });

    test('retrieves current migration state', () async {
      late List<MigrationState> state;

      await goose.up(to: '5');
      state = await goose.getMigrationState();
      expect(
        state,
        equals([
          for (var i = 0; i < 10; i++)
            MigrationState('$i', '$i', isMigrated: i <= 5),
        ]),
      );

      await goose.up(to: '7');
      state = await goose.getMigrationState();
      expect(
        state,
        equals([
          for (var i = 0; i < 10; i++)
            MigrationState('$i', '$i', isMigrated: i <= 7),
        ]),
      );

      await goose.down(to: '2');
      state = await goose.getMigrationState();
      expect(
        state,
        equals([
          for (var i = 0; i < 10; i++)
            MigrationState('$i', '$i', isMigrated: i <= 2),
        ]),
      );
    });

    test('emits migration state when it changes', () async {
      late List<MigrationState> state;
      goose.migrations.listen((event) => state = event);

      await goose.up(to: '5');
      await Future<void>.delayed(Duration.zero);
      expect(
        state,
        equals([
          for (var i = 0; i < 10; i++)
            MigrationState('$i', '$i', isMigrated: i <= 5),
        ]),
      );

      await goose.up(to: '7');
      await Future<void>.delayed(Duration.zero);
      expect(
        state,
        equals([
          for (var i = 0; i < 10; i++)
            MigrationState('$i', '$i', isMigrated: i <= 7),
        ]),
      );

      await goose.down(to: '2');
      await Future<void>.delayed(Duration.zero);
      expect(
        state,
        equals([
          for (var i = 0; i < 10; i++)
            MigrationState('$i', '$i', isMigrated: i <= 2),
        ]),
      );
    });
  });
}
