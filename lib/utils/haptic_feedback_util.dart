import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for consistent haptic feedback across date/time picker components
class HapticFeedbackUtil {
  static DateTime? _lastFeedbackTime;
  static const Duration _minFeedbackInterval = Duration(milliseconds: 100);

  /// Trigger haptic feedback for better mobile experience
  ///
  /// This method provides consistent haptic feedback across all picker components
  /// with proper platform detection and error handling.
  ///
  /// Includes frequency limiting to prevent spam and improve performance.
  static void triggerHapticFeedback(BuildContext context) {
    // Check if enough time has passed since last feedback
    final now = DateTime.now();
    if (_lastFeedbackTime != null && now.difference(_lastFeedbackTime!) < _minFeedbackInterval) {
      return; // Skip feedback to prevent spam
    }

    _lastFeedbackTime = now;

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
  ///
  /// Includes frequency limiting to prevent spam and improve performance.
  static void triggerMediumHapticFeedback(BuildContext context) {
    // Check if enough time has passed since last feedback
    final now = DateTime.now();
    if (_lastFeedbackTime != null && now.difference(_lastFeedbackTime!) < _minFeedbackInterval) {
      return; // Skip feedback to prevent spam
    }

    _lastFeedbackTime = now;

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
  ///
  /// Heavy feedback uses a longer minimum interval to avoid overwhelming users.
  static void triggerHeavyHapticFeedback(BuildContext context) {
    // Use a longer interval for heavy feedback
    const heavyFeedbackInterval = Duration(milliseconds: 200);

    final now = DateTime.now();
    if (_lastFeedbackTime != null && now.difference(_lastFeedbackTime!) < heavyFeedbackInterval) {
      return; // Skip feedback to prevent spam
    }

    _lastFeedbackTime = now;

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
  ///
  /// Includes frequency limiting to prevent spam and improve performance.
  static void triggerSelectionFeedback(BuildContext context) {
    // Check if enough time has passed since last feedback
    final now = DateTime.now();
    if (_lastFeedbackTime != null && now.difference(_lastFeedbackTime!) < _minFeedbackInterval) {
      return; // Skip feedback to prevent spam
    }

    _lastFeedbackTime = now;

    try {
      // Only trigger haptic feedback on mobile platforms
      if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      // Ignore haptic feedback errors - should not crash the app
    }
  }

  /// Reset the haptic feedback timer (useful for testing or when starting new interactions)
  static void resetFeedbackTimer() {
    _lastFeedbackTime = null;
  }

  /// Check if haptic feedback is currently throttled
  static bool get isFeedbackThrottled {
    if (_lastFeedbackTime == null) return false;
    return DateTime.now().difference(_lastFeedbackTime!) < _minFeedbackInterval;
  }
}
