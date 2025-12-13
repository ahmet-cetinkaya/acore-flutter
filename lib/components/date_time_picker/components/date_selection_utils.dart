import 'package:flutter/material.dart';
import '../constants/date_time_picker_translation_keys.dart';
import 'quick_range_selector.dart' as quick;

/// Utility class for date selection calculations and helpers.
///
/// Provides static methods for weekday calculations, date comparisons,
/// and quick selection helpers used by DatePickerContent and related components.
class DateSelectionUtils {
  DateSelectionUtils._(); // Private constructor to prevent instantiation

  /// Weekday translation keys - consistently ordered (Mon-Sun)
  static const List<DateTimePickerTranslationKey> weekdayKeys = [
    DateTimePickerTranslationKey.weekdayMonShort,
    DateTimePickerTranslationKey.weekdayTueShort,
    DateTimePickerTranslationKey.weekdayWedShort,
    DateTimePickerTranslationKey.weekdayThuShort,
    DateTimePickerTranslationKey.weekdayFriShort,
    DateTimePickerTranslationKey.weekdaySatShort,
    DateTimePickerTranslationKey.weekdaySunShort,
  ];

  /// Symbol for "No Date" option - using close icon to represent clearing
  static const String noDateSymbol = '×';

  /// Get localized text with fallback
  static String getLocalizedText(
    Map<DateTimePickerTranslationKey, String>? translations,
    DateTimePickerTranslationKey key,
    String fallback,
  ) {
    return translations?[key] ?? fallback;
  }

  /// Get the current day of week abbreviation (Mon, Tue, etc.)
  static String getDayOfWeek(Map<DateTimePickerTranslationKey, String>? translations) {
    final now = DateTime.now();
    return getLocalizedText(translations, weekdayKeys[now.weekday - 1], 'Mon');
  }

  /// Get tomorrow's day of week abbreviation
  static String getTomorrowDayOfWeek(Map<DateTimePickerTranslationKey, String>? translations) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return getLocalizedText(translations, weekdayKeys[tomorrow.weekday - 1], 'Tue');
  }

  /// Get next week's day of week abbreviation (next Monday)
  static String getNextWeekDayOfWeek(Map<DateTimePickerTranslationKey, String>? translations) {
    final now = DateTime.now();
    // Calculate days until next Monday (where Monday is 1)
    // If today is Monday (1), we want next Monday, not today: (8 - 1) = 7 days
    // If today is Tuesday (2), we want next Monday: (8 - 2) = 6 days
    // If today is Sunday (7), we want next Monday: (8 - 7) = 1 day
    final daysUntilNextMonday = now.weekday == DateTime.monday ? 7 : (8 - now.weekday);
    final nextMonday = now.add(Duration(days: daysUntilNextMonday));

    return getLocalizedText(translations, weekdayKeys[nextMonday.weekday - 1], 'Mon');
  }

  /// Get the weekend day of week abbreviation (Saturday)
  static String getWeekendDayOfWeek(Map<DateTimePickerTranslationKey, String>? translations) {
    final now = DateTime.now();
    // Find the next Saturday
    DateTime saturday = now;
    while (saturday.weekday != DateTime.saturday) {
      saturday = saturday.add(const Duration(days: 1));
    }
    return getLocalizedText(translations, weekdayKeys[saturday.weekday - 1], 'Sat');
  }

  /// Check if current day is weekend (Saturday or Sunday)
  static bool isCurrentlyWeekend() {
    final now = DateTime.now();
    return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  /// Check if tomorrow should be hidden to avoid duplication with weekend option
  static bool shouldHideTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    // Hide tomorrow when it's Monday (existing logic) OR Saturday (new logic)
    return tomorrow.weekday == DateTime.monday || tomorrow.weekday == DateTime.saturday;
  }

  /// Get the appropriate weekend/weekday button text based on current day
  static String getWeekendButtonText(Map<DateTimePickerTranslationKey, String>? translations) {
    return isCurrentlyWeekend()
        ? getLocalizedText(translations, DateTimePickerTranslationKey.quickSelectionNextWeekday, 'Next Weekday')
        : getLocalizedText(translations, DateTimePickerTranslationKey.quickSelectionWeekend, 'Weekend');
  }

  /// Get the appropriate weekend/weekday display text based on current day
  static String getWeekendDisplayText(Map<DateTimePickerTranslationKey, String>? translations) {
    if (isCurrentlyWeekend()) {
      // For weekend users, show Monday
      final now = DateTime.now();
      DateTime monday = now;
      while (monday.weekday != DateTime.monday) {
        monday = monday.add(const Duration(days: 1));
      }
      return getLocalizedText(translations, weekdayKeys[monday.weekday - 1], 'Mon');
    } else {
      // For weekday users, show Saturday
      return getWeekendDayOfWeek(translations);
    }
  }

  /// Get the appropriate weekend/weekday icon based on current day
  static IconData getWeekendIcon() {
    return isCurrentlyWeekend() ? Icons.arrow_forward : Icons.weekend;
  }

  /// Get short label for a quick date range
  static String getShortLabelForRange(
    quick.QuickDateRange range,
    Map<DateTimePickerTranslationKey, String>? translations,
  ) {
    switch (range.key) {
      case 'today':
        return getDayOfWeek(translations);
      case 'tomorrow':
        return getTomorrowDayOfWeek(translations);
      case 'next_week':
        return getNextWeekDayOfWeek(translations);
      case 'weekend':
        return getWeekendDayOfWeek(translations);
      case 'no_date':
        return noDateSymbol; // Clear/close symbol to represent "No Date"
      default:
        return range.label.isNotEmpty ? range.label.substring(0, 1).toUpperCase() : '';
    }
  }

  /// Get icon for a quick date range
  static IconData? getIconForRange(quick.QuickDateRange range) {
    switch (range.key) {
      case 'weekend':
        return Icons.weekend;
      case 'next_week':
        return Icons.arrow_forward;
      case 'no_date':
      case 'clear':
        return Icons.close;
      default:
        return null;
    }
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  /// Check if selected time is at the beginning of the day (All Day)
  static bool isAllDayTime(DateTime date) {
    return date.hour == 0 && date.minute == 0 && date.second == 0;
  }

  /// Calculate the next Saturday date from now
  static DateTime getNextSaturday() {
    final now = DateTime.now();
    int daysUntilSaturday = DateTime.saturday - now.weekday;
    if (daysUntilSaturday < 0) {
      daysUntilSaturday += 7;
    }
    return now.add(Duration(days: daysUntilSaturday));
  }

  /// Calculate the next Monday date from now
  static DateTime getNextMonday() {
    final now = DateTime.now();
    DateTime targetDate = now;
    while (targetDate.weekday != DateTime.monday) {
      targetDate = targetDate.add(const Duration(days: 1));
    }
    return targetDate;
  }

  /// Calculate days until next Monday
  static int getDaysUntilNextMonday() {
    final now = DateTime.now();
    return now.weekday == DateTime.monday ? 7 : (8 - now.weekday);
  }
}
