import 'dart:async';

import 'package:goose/goose.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

/// [testMigration] creates a new `migration`-specific test case with the given
/// [description].
///
/// [testMigration] will handle running the migration's up and
/// down methods.
///
/// [testMigration] also ensures that the migration will always
/// happen in the order of `up` first and then try revert through the `down`
/// method to ensure that the migration can be reverted.
///
/// [create] should create and return the `migration` that is to be tested.
///
/// [setupUp] is an optional callback which is invoked before the [Migration.up]
/// is called and can be used for setting up the migration's required data
/// for that method. For common set up code, prefer to use [setUp] from
/// `package:test/test.dart`.
///
/// [verifyUp] is an optional callback which is invoked after the [Migration.up]
/// was called and can be used for additional verification/assertions.
/// [verifyUp] is called with the `migration` returned by [create].
///
/// [setupDown] is an optional callback which is invoked before the
/// [Migration.down] is called and can be used for setting up the migration's
/// required data for that method. For common set up code, prefer to use
/// [setUp] from `package:test/test.dart`.
///
/// [verifyDown] is an optional callback which is invoked after the
/// [Migration.down] was called and can be used for additional
/// verification/assertions. [verifyDown] is called with the `migration`
/// returned by [create].
///
/// [tags] is an optional argument and if it is passed, it declares user-defined
/// tags that are applied to the test. These tags can be used to select or skip
/// the test on the command line, or to do bulk test configuration.
///
/// ```dart
/// import 'package:goose/goose.dart';
/// import 'package:goose_test/goose_test.dart';
/// import 'package:test/test.dart';
///
/// class MyMigration extends Migration {
///   MyMigration(this.storage)
///       : super('my_migration', description: 'A simple migration');
///
///   final Map<String, dynamic> storage;
///
///   @override
///   Future<void> down() async => storage.clear();
///
///   @override
///   Future<void> up() async => storage['migrated'] = true;
/// }
///
/// void main() {
///   group('MyMigration', () {
///     late Map<String, dynamic> storage;
///     setUp(() => storage = {});
///
///     testMigration(
///       'executes correctly',
///       create: () => MyMigration(storage),
///       verifyUp: (_) => expect(storage['migrated'], isTrue),
///       verifyDown: (_) => expect(storage.isEmpty, isTrue),
///     );
///   });
/// }
/// ```
@isTest
Future<void> testMigration<T extends Migration>(
  String description, {
  required FutureOr<T> Function() create,
  required FutureOr<void> Function(T) verifyUp,
  required FutureOr<void> Function(T) verifyDown,
  FutureOr<void> Function()? setupUp,
  FutureOr<void> Function()? setupDown,
  dynamic tags,
}) async {
  test(
    description,
    () async {
      final migration = await create();

      await setupUp?.call();
      await migration.up();
      await verifyUp(migration);

      await setupDown?.call();
      await migration.down();
      await verifyDown(migration);
    },
    tags: tags,
  );
}
