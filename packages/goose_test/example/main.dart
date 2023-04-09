import 'package:goose/goose.dart';
import 'package:goose_test/goose_test.dart';
import 'package:test/test.dart';

class MyMigration extends Migration {
  MyMigration(this.storage)
      : super('my_migration', description: 'A simple migration');

  final Map<String, dynamic> storage;

  @override
  Future<void> down() async => storage.clear();

  @override
  Future<void> up() async => storage['migrated'] = true;
}

void main() {
  group('MyMigration', () {
    late Map<String, dynamic> storage;
    setUp(() => storage = {});

    testMigration(
      'executes correctly',
      create: () => MyMigration(storage),
      verifyUp: (_) => expect(storage['migrated'], isTrue),
      verifyDown: (_) => expect(storage.isEmpty, isTrue),
    );
  });
}
