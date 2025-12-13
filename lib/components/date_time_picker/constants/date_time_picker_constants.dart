import 'package:flutter/material.dart';

/// Constants for date time picker components
/// These values match the main app's AppTheme for consistency
/// Updated to match QuickAddTaskDialog styling while keeping package self-contained
class DateTimePickerConstants {
  // Spacing constants - matching AppTheme values for consistency
  static const double size2XSmall = 4.0;
  static const double sizeSmall = 8.0;
  static const double sizeMedium = 12.0;
  static const double sizeLarge = 16.0; // Updated from 24.0 to match AppTheme.sizeLarge

  // Border radius constants - matching AppTheme values
  static const double containerBorderRadius = 15.0; // Updated from 12.0 to match AppTheme.containerBorderRadius

  // Surface colors - these are theme-dependent, so we'll use theme colors
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getSurface0Color(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }
}
