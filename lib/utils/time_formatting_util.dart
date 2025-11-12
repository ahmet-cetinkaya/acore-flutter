import 'package:flutter/material.dart';

/// Utility class for consistent time formatting across date/time picker components
class TimeFormattingUtil {
  /// Format time using MaterialLocalizations for proper locale support
  ///
  /// This method replaces manual time formatting to ensure consistent
  /// locale-specific formatting (AM/PM strings, spacing, etc.)
  static String formatTimeOfDay(BuildContext context, int hour, int minute) {
    final localizations = MaterialLocalizations.of(context);
    final use24Hour = MediaQuery.of(context).alwaysUse24HourFormat;

    return localizations.formatTimeOfDay(
      TimeOfDay(hour: hour, minute: minute),
      alwaysUse24HourFormat: use24Hour,
    );
  }

  /// Format TimeOfDay object using MaterialLocalizations
  static String formatTime(BuildContext context, TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    final use24Hour = MediaQuery.of(context).alwaysUse24HourFormat;

    return localizations.formatTimeOfDay(
      time,
      alwaysUse24HourFormat: use24Hour,
    );
  }

  /// Format DateTime object's time component using MaterialLocalizations
  static String formatDateTimeTime(BuildContext context, DateTime dateTime) {
    return formatTimeOfDay(context, dateTime.hour, dateTime.minute);
  }
}
