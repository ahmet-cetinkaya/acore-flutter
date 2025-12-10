import 'dart:io';

/// Platform type enum
enum PlatformType {
  android,
  ios,
  windows,
  macos,
  linux,
  web,
  unknown;

  String get typeName {
    switch (this) {
      case PlatformType.android:
        return 'android';
      case PlatformType.ios:
        return 'ios';
      case PlatformType.windows:
        return 'windows';
      case PlatformType.macos:
        return 'macos';
      case PlatformType.linux:
        return 'linux';
      case PlatformType.web:
        return 'web';
      case PlatformType.unknown:
        return 'unknown';
    }
  }
}

/// Platform information class
class PlatformInfo {
  final PlatformType type;
  final String typeName;

  PlatformInfo({required this.type}) : typeName = type.typeName;
}

/// Platform detection utilities.
class PlatformUtils {
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isWeb => identical(0, 0.0); // Compile-time web detection

  /// Gets platform information including type
  static Future<PlatformInfo?> getPlatformType() async {
    try {
      PlatformType platformType;

      if (isWeb) {
        platformType = PlatformType.web;
      } else if (Platform.isAndroid) {
        platformType = PlatformType.android;
      } else if (Platform.isIOS) {
        platformType = PlatformType.ios;
      } else if (Platform.isWindows) {
        platformType = PlatformType.windows;
      } else if (Platform.isMacOS) {
        platformType = PlatformType.macos;
      } else if (Platform.isLinux) {
        platformType = PlatformType.linux;
      } else {
        platformType = PlatformType.unknown;
      }

      return PlatformInfo(type: platformType);
    } catch (e) {
      return null;
    }
  }
}
