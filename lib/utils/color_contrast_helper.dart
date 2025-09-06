import 'dart:math';
import 'package:flutter/material.dart';

/// A utility class for calculating color contrast and ensuring accessibility
class ColorContrastHelper {
  /// Calculates the appropriate text color for a given background color
  /// to ensure proper contrast ratio for accessibility
  static Color getContrastingTextColor(Color backgroundColor, {Color? lightColor, Color? darkColor}) {
    final preferredLightColor = lightColor ?? Colors.white;
    final preferredDarkColor = darkColor ?? Colors.black;

    // Calculate contrast ratio with black and white text
    final double contrastWithBlack = calculateContrastRatio(preferredDarkColor, backgroundColor);
    final double contrastWithWhite = calculateContrastRatio(preferredLightColor, backgroundColor);

    // Determine if the contrast ratios meet the WCAG AA minimum (4.5 for normal text)
    final bool blackMeets = contrastWithBlack >= 4.5;
    final bool whiteMeets = contrastWithWhite >= 4.5;

    // 1. Prefer the text color(s) that meet the WCAG requirement.
    // 2. If both meet, choose the one with the higher ratio.
    // 3. If neither meet, fall back to the one with the higher ratio anyway.
    if (blackMeets && whiteMeets) {
      return contrastWithBlack >= contrastWithWhite ? preferredDarkColor : preferredLightColor;
    } else if (blackMeets) {
      return preferredDarkColor;
    } else if (whiteMeets) {
      return preferredLightColor;
    } else {
      return contrastWithBlack >= contrastWithWhite ? preferredDarkColor : preferredLightColor;
    }
  }

  /// Calculates the contrast ratio between two colors
  /// Returns a value between 1 and 21, where 21 is the highest contrast
  static double calculateContrastRatio(Color color1, Color color2) {
    double luminance1 = _calculateLuminance(color1);
    double luminance2 = _calculateLuminance(color2);

    // Ensure the lighter color is in the numerator
    double lighter = max(luminance1, luminance2);
    double darker = min(luminance1, luminance2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks if the contrast ratio meets WCAG AA standards (4.5:1 for normal text)
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Checks if the contrast ratio meets WCAG AAA standards (7:1 for normal text)
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }

  /// Calculates the relative luminance of a color using the WCAG formula
  static double _calculateLuminance(Color color) {
    // Convert RGB values to relative values (0-1)
    double r = color.r / 255.0;
    double g = color.g / 255.0;
    double b = color.b / 255.0;

    // Apply gamma correction
    r = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4).toDouble();
    g = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4).toDouble();
    b = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4).toDouble();

    // Calculate relative luminance
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Gets a color that provides good contrast against the given background
  /// Optionally specify preferred colors to try first
  static Color getAccessibleColor(
    Color backgroundColor, {
    Color? preferredColor,
    List<Color>? candidateColors,
  }) {
    // If a preferred color is provided and it has good contrast, use it
    if (preferredColor != null && meetsWCAGAA(preferredColor, backgroundColor)) {
      return preferredColor;
    }

    // Try candidate colors if provided
    if (candidateColors != null) {
      for (Color candidate in candidateColors) {
        if (meetsWCAGAA(candidate, backgroundColor)) {
          return candidate;
        }
      }
    }

    // Fall back to basic contrast calculation
    return getContrastingTextColor(backgroundColor);
  }
}
