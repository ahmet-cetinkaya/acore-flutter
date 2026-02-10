import 'package:flutter/material.dart';

/// Constants for date time picker components
class DateTimePickerConstants {
  static const double size2XSmall = 4.0;
  static const double sizeSmall = 8.0;
  static const double sizeMedium = 12.0;
  static const double sizeLarge = 16.0;

  static const double containerBorderRadius = 15.0;

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getSurface0Color(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }
}
