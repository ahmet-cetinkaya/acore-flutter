import 'package:flutter/material.dart';

/// Shared design constants for Date Time Picker components
/// mimicking AppTheme values from the main app.
class DateTimePickerDesign {
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;

  static const double radiusLarge = 15.0; // AppTheme.containerBorderRadius

  static const double borderWidth = 1.0;

  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0; // AppTheme.fontSizeLarge
  static const double fontSizeXLarge = 20.0; // AppTheme.fontSizeXLarge

  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
}

/// A styled icon container used in Date Time Picker dialogs.
/// Mimics the StyledIcon component from the main app.
class StyledIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const StyledIcon(
    this.icon, {
    required this.isActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Approximate AppTheme.surface2 using colorScheme.surfaceContainerLow if available (Flutter 3.22+)
    // or fallback to surface with elevation overlay or a slightly different shade.
    // Using surfaceContainerLow is the modern Material 3 way for "Surface 2".
    // If not available (older Flutter), use surface.
    final surface2 = theme.colorScheme.surfaceContainerLow;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : surface2,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        size: DateTimePickerDesign.iconSizeMedium,
      ),
    );
  }
}
