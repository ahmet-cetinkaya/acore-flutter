/// Enum to define different dialog sizes for responsive dialogs.
enum DialogSize {
  /// Minimum dialog size - uses default Dialog behavior
  /// Desktop: Default Dialog sizing (content-based)
  /// Mobile: Default Dialog sizing (content-based)
  /// Perfect for AlertDialogs and confirmation steps - no size constraints applied
  min,

  /// Small dialog size
  small,

  /// Medium dialog size (default)
  medium,

  /// Large dialog size
  large,

  /// Extra Large dialog size - 90% height for mobile
  xLarge,

  /// Fullscreen dialog size
  max;

  /// Returns the width ratio for desktop dialogs
  double get desktopWidthRatio {
    switch (this) {
      case DialogSize.min:
        return 0; // No width constraint for min size
      case DialogSize.small:
        return 0.5;
      case DialogSize.medium:
        return 0.7;
      case DialogSize.large:
        return 0.8;
      case DialogSize.xLarge:
        return 0.9;
      case DialogSize.max:
        return 0.95;
    }
  }

  /// Returns the height ratio for desktop dialogs
  double get desktopHeightRatio {
    switch (this) {
      case DialogSize.min:
        return 0; // No height constraint for min size
      case DialogSize.small:
        return 0.4;
      case DialogSize.medium:
        return 0.7;
      case DialogSize.large:
        return 0.8;
      case DialogSize.xLarge:
        return 0.9;
      case DialogSize.max:
        return 0.95;
    }
  }

  /// Returns the maximum width constraint for desktop dialogs
  double get maxDesktopWidth {
    switch (this) {
      case DialogSize.min:
        return double.infinity; // No max width for min size
      case DialogSize.small:
        return 600;
      case DialogSize.medium:
        return 900;
      case DialogSize.large:
        return 1200;
      case DialogSize.xLarge:
        return 1400;
      case DialogSize.max:
        return double.infinity;
    }
  }

  /// Returns the initial child size for mobile bottom sheets
  double get mobileInitialSizeRatio {
    switch (this) {
      case DialogSize.min:
        return 0; // No initial size for min size
      case DialogSize.small:
        return 0.2;
      case DialogSize.medium:
        return 0.7;
      case DialogSize.large:
        return 0.95;
      case DialogSize.xLarge:
        return 0.9;
      case DialogSize.max:
        return 0.95; // Match max height ratio to prevent constraints error
    }
  }

  /// Returns the minimum child size for mobile bottom sheets
  double get mobileMinSizeRatio {
    return 0.1; // Minimum size for all mobile dialogs
  }

  /// Returns the maximum child size for mobile bottom sheets
  double get mobileMaxSizeRatio {
    switch (this) {
      case DialogSize.min:
        return double.infinity; // Let min size expand as needed (it uses showDialog usually)
      case DialogSize.small:
        return 0.5; // Restrict small to half screen
      case DialogSize.medium:
        return 0.6; // Restrict medium to 60% screen (prevent full screen expansion)
      case DialogSize.large:
      case DialogSize.xLarge:
      case DialogSize.max:
        return 0.95; // Allow large dialogs to go almost full screen
    }
  }
}
