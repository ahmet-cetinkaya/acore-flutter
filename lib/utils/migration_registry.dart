import 'semantic_version.dart';

/// Represents a single migration step between two versions.
class MigrationStep {
  final SemanticVersion fromVersion;
  final SemanticVersion toVersion;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> data) migrationFunction;
  final String description;

  const MigrationStep({
    required this.fromVersion,
    required this.toVersion,
    required this.migrationFunction,
    required this.description,
  });
}

/// Generic migration registry for data migration between versions.
class MigrationRegistry {
  final List<MigrationStep> _migrationSteps = [];

  /// Registers a migration step from one version to another.
  void registerMigration({
    required String fromVersion,
    required String toVersion,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic> data) migrationFunction,
    required String description,
  }) {
    final fromSemVer = SemanticVersion.parse(fromVersion);
    final toSemVer = SemanticVersion.parse(toVersion);

    _migrationSteps.add(MigrationStep(
      fromVersion: fromSemVer,
      toVersion: toSemVer,
      migrationFunction: migrationFunction,
      description: description,
    ));

    _migrationSteps.sort((a, b) => a.fromVersion.compareTo(b.fromVersion));
  }

  /// Gets migration steps needed to migrate from source to target version.
  List<MigrationStep> getMigrationPath(SemanticVersion sourceVersion, SemanticVersion targetVersion) {
    if (sourceVersion >= targetVersion) {
      return [];
    }

    final requiredMigrations = <MigrationStep>[];
    SemanticVersion currentVersion = sourceVersion;

    while (currentVersion < targetVersion) {
      final nextMigration = _findNextMigration(currentVersion, targetVersion);
      if (nextMigration == null) break;

      requiredMigrations.add(nextMigration);
      currentVersion = nextMigration.toVersion;
    }

    return requiredMigrations;
  }

  MigrationStep? _findNextMigration(SemanticVersion currentVersion, SemanticVersion targetVersion) {
    return _migrationSteps
            .where((step) => step.fromVersion == currentVersion && step.toVersion <= targetVersion)
            .isNotEmpty
        ? _migrationSteps.where((step) => step.fromVersion == currentVersion && step.toVersion <= targetVersion).first
        : null;
  }

  /// Checks if any migrations are needed between two versions.
  bool isMigrationNeeded(SemanticVersion sourceVersion, SemanticVersion targetVersion) {
    return getMigrationPath(sourceVersion, targetVersion).isNotEmpty;
  }

  /// Gets all registered migration steps.
  List<MigrationStep> get registeredMigrations => List.unmodifiable(_migrationSteps);

  /// Clears all registered migrations.
  void clear() {
    _migrationSteps.clear();
  }
}
