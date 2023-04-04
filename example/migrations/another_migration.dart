import 'package:goose/goose.dart';

class AnotherMigration extends Migration {
  AnotherMigration() : super('another', description: 'Another migration');

  @override
  Future<void> down() => Future.delayed(const Duration(seconds: 1));

  @override
  Future<void> up() => Future.delayed(const Duration(seconds: 1));
}
