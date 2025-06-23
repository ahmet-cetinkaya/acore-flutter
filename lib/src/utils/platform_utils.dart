import 'dart:io';

/// Platform detection utilities.
class PlatformUtils {
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isWeb => identical(0, 0.0); // Compile-time web detection
}
