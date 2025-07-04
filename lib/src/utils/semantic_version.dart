import 'package:equatable/equatable.dart';

/// Represents a semantic version following the Semantic Versioning specification.
class SemanticVersion extends Equatable {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;
  final String? build;

  const SemanticVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease,
    this.build,
  });

  /// Parses a version string into a SemanticVersion instance.
  ///
  /// Supports formats: "1.0.0", "1.2.3-alpha", "1.2.3-alpha+build.1"
  factory SemanticVersion.parse(String version) {
    // Remove 'v' prefix if present
    if (version.startsWith('v')) {
      version = version.substring(1);
    }

    // Split by '+' to separate build metadata
    final buildSplit = version.split('+');
    final versionWithoutBuild = buildSplit[0];
    final build = buildSplit.length > 1 ? buildSplit[1] : null;

    // Split by '-' to separate pre-release
    final preReleaseSplit = versionWithoutBuild.split('-');
    final versionCore = preReleaseSplit[0];
    final preRelease = preReleaseSplit.length > 1 ? preReleaseSplit.skip(1).join('-') : null;

    // Parse major.minor.patch
    final parts = versionCore.split('.');
    if (parts.length < 3) {
      // Pad with zeros if needed
      while (parts.length < 3) {
        parts.add('0');
      }
    }

    try {
      final major = int.parse(parts[0]);
      final minor = int.parse(parts[1]);
      final patch = int.parse(parts[2]);

      return SemanticVersion(
        major: major,
        minor: minor,
        patch: patch,
        preRelease: preRelease,
        build: build,
      );
    } catch (e) {
      throw FormatException('Invalid semantic version format: $version');
    }
  }

  /// Compares this version with another version.
  int compareTo(SemanticVersion other) {
    // Compare major version
    if (major != other.major) {
      return major.compareTo(other.major);
    }

    // Compare minor version
    if (minor != other.minor) {
      return minor.compareTo(other.minor);
    }

    // Compare patch version
    if (patch != other.patch) {
      return patch.compareTo(other.patch);
    }

    // Compare pre-release versions
    if (preRelease == null && other.preRelease == null) {
      return 0; // Both are release versions
    }

    if (preRelease == null && other.preRelease != null) {
      return 1; // Release version is greater than pre-release
    }

    if (preRelease != null && other.preRelease == null) {
      return -1; // Pre-release version is less than release
    }

    // Both have pre-release, compare lexically
    return preRelease!.compareTo(other.preRelease!);
  }

  bool operator <(SemanticVersion other) => compareTo(other) < 0;
  bool operator <=(SemanticVersion other) => compareTo(other) <= 0;
  bool operator >(SemanticVersion other) => compareTo(other) > 0;
  bool operator >=(SemanticVersion other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SemanticVersion && compareTo(other) == 0;
  }

  @override
  int get hashCode => Object.hash(major, minor, patch, preRelease);

  /// Returns string representation of the version.
  @override
  String toString() {
    final buffer = StringBuffer('$major.$minor.$patch');
    if (preRelease != null) {
      buffer.write('-$preRelease');
    }
    if (build != null) {
      buffer.write('+$build');
    }
    return buffer.toString();
  }

  /// Returns the version without pre-release and build metadata.
  String get coreVersion => '$major.$minor.$patch';

  /// Returns true if this is a pre-release version.
  bool get isPreRelease => preRelease != null;

  @override
  List<Object?> get props => [major, minor, patch, preRelease];
}
