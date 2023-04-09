/// {@template migration_state}
/// Describe the state of a migration.
/// {@endtemplate}
class MigrationState {
  /// {@macro migration_state}
  const MigrationState(this.name, this.description, {required this.isMigrated});

  /// The name of the migration.
  final String name;

  /// The description of the migration.
  final String description;

  /// If it was migrated or not.
  final bool isMigrated;

  @override
  int get hashCode => Object.hashAll([name, description, isMigrated]);

  @override
  bool operator ==(Object other) {
    if (other is! MigrationState) return false;
    return other.name == name &&
        other.description == description &&
        other.isMigrated == isMigrated;
  }

  @override
  String toString() =>
      '''MigrationState(name: "$name", description: "$description" isMigrated: $isMigrated)''';
}
