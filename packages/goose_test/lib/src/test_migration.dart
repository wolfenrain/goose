import 'dart:async';

import 'package:goose/goose.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

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
