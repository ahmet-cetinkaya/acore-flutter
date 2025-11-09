import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for consistent haptic feedback across date/time picker components
class HapticFeedbackUtil {
  /// Trigger haptic feedback for better mobile experience
  ///
  /// This method provides consistent haptic feedback across all picker components
  /// with proper platform detection and error handling.
  static void triggerHapticFeedback(BuildContext context) {
    try {
      // Only trigger haptic feedback on mobile platforms
      if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Ignore haptic feedback errors - should not crash the app
    }
  }

  /// Trigger medium haptic feedback for more significant interactions
  static void triggerMediumHapticFeedback(BuildContext context) {
    try {
      // Only trigger haptic feedback on mobile platforms
      if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Ignore haptic feedback errors - should not crash the app
    }
  }

  /// Trigger heavy haptic feedback for important confirmations
  static void triggerHeavyHapticFeedback(BuildContext context) {
    try {
      // Only trigger haptic feedback on mobile platforms
      if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Ignore haptic feedback errors - should not crash the app
    }
  }

  /// Trigger selection haptic feedback for standard interactions
  static void triggerSelectionFeedback(BuildContext context) {
    try {
      // Only trigger haptic feedback on mobile platforms
      if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      // Ignore haptic feedback errors - should not crash the app
    }
  }
}
