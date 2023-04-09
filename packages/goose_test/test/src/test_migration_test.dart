import 'package:goose/goose.dart';
import 'package:goose_test/goose_test.dart';
import 'package:test/test.dart';

class _Migration extends Migration {
  _Migration({
    required this.onUp,
    required this.onDown,
  }) : super('test_migration');

  void Function() onUp;

  void Function() onDown;

  @override
  Future<void> up() async => onUp();

  @override
  Future<void> down() async => onDown();
}

void main() {
  group('testMigration', () {
    late bool downCalled;
    late bool upCalled;

    setUp(() {
      downCalled = false;
      upCalled = false;
    });

    testMigration(
      'calls setupUp and up first and then setupDown and down',
      create: () => _Migration(
        onUp: () => upCalled = true,
        onDown: () => downCalled = true,
      ),
      setupUp: () {
        expect(upCalled, isFalse);
        expect(downCalled, isFalse);
      },
      verifyUp: (_) {
        expect(upCalled, isTrue);
        expect(downCalled, isFalse);
      },
      setupDown: () {
        expect(upCalled, isTrue);
        expect(downCalled, isFalse);
      },
      verifyDown: (_) {
        expect(upCalled, isTrue);
        expect(downCalled, isTrue);
      },
    );
  });
}
