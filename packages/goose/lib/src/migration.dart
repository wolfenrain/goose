/// {@template migration}
/// Base class for migrations.
/// {@endtemplate}
abstract class Migration {
  /// {@macro migration}
  const Migration(
    this.name, {
    String? description,
  }) : description = description ?? name;

  /// The unique name of this migration.
  final String name;

  /// The description of this migration, defaults to [name].
  final String description;

  /// Called when migrating down.
  Future<void> down();

  /// Called when migrating up.
  Future<void> up();
}
