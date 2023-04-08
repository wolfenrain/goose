import 'package:goose/goose.dart';

class InitialMigration extends Migration {
  InitialMigration() : super('initial', description: 'Initial migration');

  @override
  Future<void> down() => Future.delayed(const Duration(seconds: 1));

  @override
  Future<void> up() => Future.delayed(const Duration(seconds: 1));
}
