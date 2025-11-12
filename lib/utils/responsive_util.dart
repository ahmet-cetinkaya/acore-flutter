import 'package:flutter/material.dart';

/// Standard breakpoint values in logical pixels
class ResponsiveBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 900.0;
  static const double desktop = 1200.0;
}

/// Device type enumeration for responsive design
enum ResponsiveDeviceType {
  mobile,
  tablet,
  desktop,
}

/// Layout type for different responsive scenarios
enum ResponsiveLayoutType {
  compact,
  normal,
  expanded,
}

/// Landscape layout strategy enumeration
enum LandscapeLayoutStrategy {
  portrait, // Portrait mode
  standard, // Standard landscape (aspect ratio ~1.3-1.5)
  compact, // Compact landscape (limited height)
  wide, // Wide landscape (aspect ratio ~1.5-2.0)
  ultraWide, // Ultra-wide landscape (aspect ratio > 2.0)
}

/// Responsive utility for dynamic breakpoint calculation and device adaptation
/// Provides centralized responsive design logic for date picker components
class ResponsiveUtil {
  /// Get device type based on screen width
  static ResponsiveDeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < ResponsiveBreakpoints.mobile) {
      return ResponsiveDeviceType.mobile;
    } else if (screenWidth < ResponsiveBreakpoints.tablet) {
      return ResponsiveDeviceType.tablet;
    } else {
      return ResponsiveDeviceType.desktop;
    }
  }

  /// Get layout type based on screen width
  static ResponsiveLayoutType getLayoutType(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return ResponsiveLayoutType.compact;
      case ResponsiveDeviceType.tablet:
        return ResponsiveLayoutType.normal;
      case ResponsiveDeviceType.desktop:
        return ResponsiveLayoutType.expanded;
    }
  }

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == ResponsiveDeviceType.mobile;
  }

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == ResponsiveDeviceType.tablet;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == ResponsiveDeviceType.desktop;
  }

  /// Check if layout should be compact (mobile)
  static bool isCompactLayout(BuildContext context) {
    return getLayoutType(context) == ResponsiveLayoutType.compact;
  }

  /// Check if layout should be expanded (desktop/tablet)
  static bool isExpandedLayout(BuildContext context) {
    return getLayoutType(context) != ResponsiveLayoutType.compact;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get responsive value based on layout type
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return mobile;
      case ResponsiveDeviceType.tablet:
        return tablet ?? mobile;
      case ResponsiveDeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive value with compact/normal/expanded layout types
  static T getResponsiveLayoutValue<T>({
    required BuildContext context,
    required T compact,
    T? normal,
    T? expanded,
  }) {
    final layoutType = getLayoutType(context);

    switch (layoutType) {
      case ResponsiveLayoutType.compact:
        return compact;
      case ResponsiveLayoutType.normal:
        return normal ?? compact;
      case ResponsiveLayoutType.expanded:
        return expanded ?? normal ?? compact;
    }
  }

  /// Calculate dialog width based on screen size and device type
  static double calculateDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return screenWidth * 0.95; // 95% of screen width for mobile
      case ResponsiveDeviceType.tablet:
        return (screenWidth * 0.6).clamp(400.0, 600.0); // 60% width for tablet
      case ResponsiveDeviceType.desktop:
        return (screenWidth * 0.4).clamp(400.0, 800.0); // 40% width for desktop
    }
  }

  /// Calculate dialog height based on screen size and orientation
  static double calculateDialogHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return screenHeight * 0.9; // 90% height in landscape
    } else {
      return screenHeight * 0.8; // 80% height in portrait
    }
  }

  /// Check if landscape mode requires layout adaptation (limited height)
  static bool requiresLandscapeAdaptation(BuildContext context) {
    final isLandscapeMode = isLandscape(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final aspectRatio = screenWidth / screenHeight;

    // Require adaptation if landscape with limited vertical space
    return isLandscapeMode && (aspectRatio > 1.5 || screenHeight < 600);
  }

  /// Get adaptive layout strategy for landscape orientation
  static LandscapeLayoutStrategy getLandscapeLayoutStrategy(BuildContext context) {
    if (!isLandscape(context)) {
      return LandscapeLayoutStrategy.portrait;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final aspectRatio = screenWidth / screenHeight;

    if (aspectRatio > 2.0) {
      return LandscapeLayoutStrategy.ultraWide;
    } else if (aspectRatio > 1.5) {
      return LandscapeLayoutStrategy.wide;
    } else if (requiresLandscapeAdaptation(context)) {
      return LandscapeLayoutStrategy.compact;
    } else {
      return LandscapeLayoutStrategy.standard;
    }
  }

  /// Get responsive spacing optimized for landscape orientation
  static double getLandscapeSpacing(
    BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
    double landscapeReduction = 0.7,
  }) {
    final baseSpacing = getSpacing(context, mobile: mobile, tablet: tablet, desktop: desktop);

    if (requiresLandscapeAdaptation(context)) {
      return baseSpacing * landscapeReduction; // Reduce spacing in landscape
    }

    return baseSpacing;
  }

  /// Calculate optimal calendar layout for landscape mode
  static CalendarLayoutConfig calculateCalendarLayout(BuildContext context) {
    final isLandscapeMode = isLandscape(context);
    final strategy = getLandscapeLayoutStrategy(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLandscapeMode && strategy != LandscapeLayoutStrategy.portrait) {
      // Landscape: optimize for wider layout, potentially side-by-side
      switch (strategy) {
        case LandscapeLayoutStrategy.ultraWide:
          return CalendarLayoutConfig(
            maxWidth: screenWidth * 0.7,
            maxHeight: screenHeight * 0.8,
            columns: 3, // Multi-column layout for very wide screens
            compactMode: true,
          );
        case LandscapeLayoutStrategy.wide:
          return CalendarLayoutConfig(
            maxWidth: screenWidth * 0.6,
            maxHeight: screenHeight * 0.85,
            columns: 2, // Two-column for wide screens
            compactMode: true,
          );
        case LandscapeLayoutStrategy.compact:
          return CalendarLayoutConfig(
            maxWidth: screenWidth * 0.9,
            maxHeight: screenHeight * 0.75,
            columns: 1, // Single column but compressed
            compactMode: true,
          );
        case LandscapeLayoutStrategy.standard:
          return CalendarLayoutConfig(
            maxWidth: screenWidth * 0.5,
            maxHeight: screenHeight * 0.9,
            columns: 1,
            compactMode: false,
          );
        case LandscapeLayoutStrategy.portrait:
          return CalendarLayoutConfig(
            maxWidth: screenWidth * 0.95,
            maxHeight: screenHeight * 0.8,
            columns: 1,
            compactMode: false,
          );
      }
    }

    // Portrait: standard layout
    return CalendarLayoutConfig(
      maxWidth: ResponsiveCalendarConstants.calendarWidth(context),
      maxHeight: screenHeight * 0.8,
      columns: 1,
      compactMode: false,
    );
  }

  /// Get responsive dialog configuration optimized for orientation
  static DialogConfig getDialogConfig(BuildContext context) {
    final strategy = getLandscapeLayoutStrategy(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    switch (strategy) {
      case LandscapeLayoutStrategy.ultraWide:
        return DialogConfig(
          width: screenWidth * 0.7,
          height: screenHeight * 0.8,
          useHorizontalLayout: true,
          padding: EdgeInsets.all(getLandscapeSpacing(context)),
        );
      case LandscapeLayoutStrategy.wide:
        return DialogConfig(
          width: screenWidth * 0.6,
          height: screenHeight * 0.85,
          useHorizontalLayout: true,
          padding: EdgeInsets.all(getLandscapeSpacing(context)),
        );
      case LandscapeLayoutStrategy.compact:
        return DialogConfig(
          width: screenWidth * 0.9,
          height: screenHeight * 0.75,
          useHorizontalLayout: false,
          padding: EdgeInsets.all(getLandscapeSpacing(context)),
        );
      case LandscapeLayoutStrategy.standard:
        return DialogConfig(
          width: calculateDialogWidth(context),
          height: screenHeight * 0.9,
          useHorizontalLayout: false,
          padding: EdgeInsets.all(getSpacing(context)),
        );
      case LandscapeLayoutStrategy.portrait:
        return DialogConfig(
          width: calculateDialogWidth(context),
          height: calculateDialogHeight(context),
          useHorizontalLayout: false,
          padding: EdgeInsets.all(getSpacing(context)),
        );
    }
  }

  /// Get responsive spacing based on device type
  static double getSpacing(
    BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive font size
  static double getFontSize(
    BuildContext context, {
    double mobile = 14.0,
    double tablet = 16.0,
    double desktop = 18.0,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive icon size
  static double getIconSize(
    BuildContext context, {
    double mobile = 20.0,
    double tablet = 24.0,
    double desktop = 28.0,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive border radius
  static double getBorderRadius(
    BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets mobile = const EdgeInsets.all(8.0),
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? tablet ?? mobile * 2.0,
    );
  }

  /// Calculate responsive item count for grids/lists based on screen width
  static int calculateResponsiveItemCount(
    BuildContext context, {
    int mobileCount = 1,
    int tabletCount = 2,
    int desktopCount = 3,
    double itemWidth = 120.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxItems = (screenWidth / itemWidth).floor();

    return getResponsiveValue(
      context: context,
      mobile: mobileCount,
      tablet: tabletCount,
      desktop: desktopCount,
    ).clamp(1, maxItems);
  }
}

/// Get device-specific design constants for calendar widgets
class ResponsiveCalendarConstants {
  static double dayWidth(BuildContext context) {
    return ResponsiveUtil.getResponsiveValue(
      context: context,
      mobile: 44.0,
      tablet: 48.0,
      desktop: 52.0,
    );
  }

  static double controlsHeight(BuildContext context) {
    return ResponsiveUtil.getResponsiveValue(
      context: context,
      mobile: 36.0,
      tablet: 40.0,
      desktop: 44.0,
    );
  }

  static double calendarWidth(BuildContext context) {
    return ResponsiveUtil.getResponsiveValue(
      context: context,
      mobile: 350.0,
      tablet: 420.0,
      desktop: 480.0,
    );
  }
}

/// Get device-specific design constants for time widgets
class ResponsiveTimeConstants {
  static double pickerHeight(BuildContext context) {
    return ResponsiveUtil.getResponsiveValue(
      context: context,
      mobile: 200.0,
      tablet: 250.0,
      desktop: 300.0,
    );
  }

  static double wheelItemHeight(BuildContext context) {
    return ResponsiveUtil.getResponsiveValue(
      context: context,
      mobile: 32.0,
      tablet: 40.0,
      desktop: 48.0,
    );
  }
}

/// Configuration for calendar layout in different orientations
class CalendarLayoutConfig {
  final double maxWidth;
  final double maxHeight;
  final int columns;
  final bool compactMode;

  const CalendarLayoutConfig({
    required this.maxWidth,
    required this.maxHeight,
    required this.columns,
    required this.compactMode,
  });

  @override
  String toString() {
    return 'CalendarLayoutConfig(maxWidth: $maxWidth, maxHeight: $maxHeight, columns: $columns, compactMode: $compactMode)';
  }
}

/// Configuration for dialog layout in different orientations
class DialogConfig {
  final double width;
  final double height;
  final bool useHorizontalLayout;
  final EdgeInsets padding;

  const DialogConfig({
    required this.width,
    required this.height,
    required this.useHorizontalLayout,
    required this.padding,
  });

  @override
  String toString() {
    return 'DialogConfig(width: $width, height: $height, horizontalLayout: $useHorizontalLayout, padding: $padding)';
  }
}
