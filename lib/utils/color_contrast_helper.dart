import 'dart:math';
import 'package:flutter/material.dart';

class ColorContrastHelper {
  static Color getContrastingTextColor(Color backgroundColor, {Color? lightColor, Color? darkColor}) {
    final preferredLightColor = lightColor ?? Colors.white;
    final preferredDarkColor = darkColor ?? Colors.black;

    final double contrastWithBlack = calculateContrastRatio(preferredDarkColor, backgroundColor);
    final double contrastWithWhite = calculateContrastRatio(preferredLightColor, backgroundColor);

    final bool blackMeets = contrastWithBlack >= 4.5;
    final bool whiteMeets = contrastWithWhite >= 4.5;

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

  static double calculateContrastRatio(Color color1, Color color2) {
    double luminance1 = _calculateLuminance(color1);
    double luminance2 = _calculateLuminance(color2);

    double lighter = max(luminance1, luminance2);
    double darker = min(luminance1, luminance2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }

  static double _calculateLuminance(Color color) {
    double r = color.r / 255.0;
    double g = color.g / 255.0;
    double b = color.b / 255.0;

    r = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4).toDouble();
    g = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4).toDouble();
    b = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static Color getAccessibleColor(
    Color backgroundColor, {
    Color? preferredColor,
    List<Color>? candidateColors,
  }) {
    if (preferredColor != null && meetsWCAGAA(preferredColor, backgroundColor)) {
      return preferredColor;
    }

    if (candidateColors != null) {
      for (Color candidate in candidateColors) {
        if (meetsWCAGAA(candidate, backgroundColor)) {
          return candidate;
        }
      }
    }

    return getContrastingTextColor(backgroundColor);
  }
}
