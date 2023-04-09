import 'package:goose/goose.dart';

class FixingMigration extends Migration {
  FixingMigration() : super('fixing', description: 'Fixing migration');

  @override
  Future<void> down() => Future.delayed(const Duration(seconds: 1));

  @override
  Future<void> up() => Future.delayed(const Duration(seconds: 1));
}
