/// Enum to define different dialog sizes for responsive dialogs.
///
/// UX Design Principles:
/// - Progressive scaling with consistent increments
/// - Mobile-first approach with natural bottom sheet behavior
/// - Desktop dialogs maintain comfortable aspect ratios
/// - Width and height scale proportionally for visual harmony
enum DialogSize {
  min,

  small,

  medium,

  large,

  xLarge,

  max;

  /// Returns the width ratio for desktop dialogs
  /// Progressive scaling: 0.4 → 0.6 → 0.75 → 0.85 → 0.90
  double get desktopWidthRatio {
    switch (this) {
      case DialogSize.min:
        return 0; // Natural width based on content
      case DialogSize.small:
        return 0.4; // Focused content width
      case DialogSize.medium:
        return 0.6; // Comfortable reading width
      case DialogSize.large:
        return 0.75; // Immersive but not overwhelming
      case DialogSize.xLarge:
        return 0.85; // Near-fullscreen with breathing room
      case DialogSize.max:
        return 0.90; // Almost fullscreen with padding
    }
  }

  /// Returns the height ratio for desktop dialogs
  /// Scales proportionally with width for consistent aspect ratios
  double get desktopHeightRatio {
    switch (this) {
      case DialogSize.min:
        return 0; // Natural height based on content
      case DialogSize.small:
        return 0.30; // Compact but not cramped
      case DialogSize.medium:
        return 0.50; // Balanced content area
      case DialogSize.large:
        return 0.65; // Substantial content space
      case DialogSize.xLarge:
        return 0.75; // Maximum focused area
      case DialogSize.max:
        return 0.85; // Near-fullscreen with system chrome visible
    }
  }

  /// Returns the maximum width constraint for desktop dialogs
  /// Scales logically with dialog purpose and content density
  double get maxDesktopWidth {
    switch (this) {
      case DialogSize.min:
        return double.infinity; // Content-determined width
      case DialogSize.small:
        return 480; // Focused interactions (like mobile screens)
      case DialogSize.medium:
        return 720; // Comfortable reading width (paper-like)
      case DialogSize.large:
        return 1024; // Tablet-like width for complex content
      case DialogSize.xLarge:
        return 1280; // Wide desktop interactions
      case DialogSize.max:
        return 1440; // Near-fullscreen with padding
    }
  }

  /// Returns the initial child size for mobile bottom sheets
  /// Progressive scaling with natural mobile interaction patterns
  double get mobileInitialSizeRatio {
    switch (this) {
      case DialogSize.min:
        return 0; // Uses native AlertDialog behavior
      case DialogSize.small:
        return 0.25; // Quick peek - 25% screen height
      case DialogSize.medium:
        return 0.50; // Half screen - common mobile pattern
      case DialogSize.large:
        return 0.70; // Major interaction area
      case DialogSize.xLarge:
        return 0.85; // Immersive but not fullscreen
      case DialogSize.max:
        return 0.95; // Near-fullscreen for maximum focus
    }
  }

  /// Returns the minimum child size for mobile bottom sheets
  /// Ensures users can always dismiss the dialog
  double get mobileMinSizeRatio {
    switch (this) {
      case DialogSize.min:
        return 0; // Native behavior
      case DialogSize.small:
        return 0.15; // Minimum touchable area
      case DialogSize.medium:
        return 0.25; // Quarter screen minimum
      case DialogSize.large:
        return 0.40; // Significant content area
      case DialogSize.xLarge:
        return 0.60; // Major interaction minimum
      case DialogSize.max:
        return 0.70; // Large content minimum
    }
  }

  /// Returns the maximum child size for mobile bottom sheets
  /// Progressive scaling with logical maximums based on use case
  double get mobileMaxSizeRatio {
    switch (this) {
      case DialogSize.min:
        return double.infinity; // Uses native AlertDialog behavior
      case DialogSize.small:
        return 0.40; // Quick interactions only
      case DialogSize.medium:
        return 0.65; // Standard content limit
      case DialogSize.large:
        return 0.80; // Substantial content area
      case DialogSize.xLarge:
        return 0.90; // Near-fullscreen interactions
      case DialogSize.max:
        return 0.95; // Maximum immersion with system chrome
    }
  }
}
