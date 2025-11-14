# Time Utilities

## Overview

The time utilities module provides comprehensive date and time handling with locale-aware formatting, timezone support, weekday calculations, and common date operations designed for international Flutter applications.

## Features

- 🌍 **Locale-Aware** - Supports multiple locales and regional settings
- 📅 **Weekday Helpers** - Localized weekday name generation
- 🕐 **Time Formatting** - Various time display formats
- 🗓️ **Date Calculations** - Common date operations and utilities
- 🌐 **Timezone Support** - Timezone-aware operations
- 📊 **Date Ranges** - Date range calculations and comparisons

## Core Classes

### DateTimeHelper

Provides static methods for common date/time operations with locale support.

```dart
class DateTimeHelper {
  /// Gets the localized weekday name
  static String getWeekday(int weekday, [Locale? locale]);

  /// Gets the localized short weekday name
  static String getWeekdayShort(int weekday, [Locale? locale]);

  /// Gets the first day of week based on locale
  static int getFirstDayOfWeek([Locale? locale]);

  /// Checks if a date is today
  static bool isToday(DateTime date);

  /// Checks if a date is yesterday
  static bool isYesterday(DateTime date);

  /// Checks if a date is tomorrow
  static bool isTomorrow(DateTime date);

  /// Gets start of day (00:00:00)
  static DateTime startOfDay(DateTime date);

  /// Gets end of day (23:59:59)
  static DateTime endOfDay(DateTime date);

  /// Gets start of week
  static DateTime startOfWeek(DateTime date, [Locale? locale]);

  /// Gets end of week
  static DateTime endOfWeek(DateTime date, [Locale? locale]);

  /// Gets start of month
  static DateTime startOfMonth(DateTime date);

  /// Gets end of month
  static DateTime endOfMonth(DateTime date);
}
```

### WeekDays

Utility enum for weekday operations.

```dart
enum WeekDay {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const WeekDay(this.value);
  final int value;

  String getDisplayName([Locale? locale]) {
    return DateTimeHelper.getWeekday(value, locale);
  }

  String getShortName([Locale? locale]) {
    return DateTimeHelper.getWeekdayShort(value, locale);
  }

  static WeekDay fromDateTime(DateTime date) {
    return WeekDay.values[date.weekday - 1];
  }
}
```

## Usage Examples

### Basic Date Operations

```dart
class DateService {
  String formatDateForDisplay(DateTime date, Locale locale) {
    if (DateTimeHelper.isToday(date)) {
      return 'Today';
    } else if (DateTimeHelper.isYesterday(date)) {
      return 'Yesterday';
    } else if (DateTimeHelper.isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      final weekday = DateTimeHelper.getWeekday(date.weekday, locale);
      final formattedDate = DateFormat('MMM d').format(date);
      return '$weekday, $formattedDate';
    }
  }

  List<DateTime> getWeekDates(DateTime date, Locale locale) {
    final startOfWeek = DateTimeHelper.startOfWeek(date, locale);
    final endOfWeek = DateTimeHelper.endOfWeek(date, locale);

    final weekDates = <DateTime>[];
    var currentDate = startOfWeek;

    while (currentDate.isBefore(endOfWeek) || currentDate.isAtSameMomentAs(endOfWeek)) {
      weekDates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return weekDates;
  }
}
```

### Weekday Display

```dart
class WeekdaySelector extends StatelessWidget {
  final Locale locale;
  final int selectedWeekday;
  final ValueChanged<int> onWeekdayChanged;

  const WeekdaySelector({
    required this.locale,
    required this.selectedWeekday,
    required this.onWeekdayChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfWeek = DateTimeHelper.getFirstDayOfWeek(locale);
    final weekdays = <Widget>[];

    for (int i = 0; i < 7; i++) {
      final weekdayNum = ((firstDayOfWeek - 1 + i) % 7) + 1;
      final weekdayName = DateTimeHelper.getWeekdayShort(weekdayNum, locale);
      final isSelected = weekdayNum == selectedWeekday;

      weekdays.add(
        GestureDetector(
          onTap: () => onWeekdayChanged(weekdayNum),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              weekdayName,
              style: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekdays,
    );
  }
}
```

### Calendar View Helper

```dart
class CalendarHelper {
  CalendarMonthData generateMonthData(DateTime date, Locale locale) {
    final startOfMonth = DateTimeHelper.startOfMonth(date);
    final endOfMonth = DateTimeHelper.endOfMonth(date);
    final startOfWeek = DateTimeHelper.startOfWeek(startOfMonth, locale);

    final weeks = <List<CalendarDay>>[];
    var currentDate = startOfWeek;

    // Generate 6 weeks to cover the entire month
    for (int week = 0; week < 6; week++) {
      final weekDays = <CalendarDay>[];

      for (int day = 0; day < 7; day++) {
        final isCurrentMonth = currentDate.month == date.month;
        final isToday = DateTimeHelper.isToday(currentDate);
        final isSelected = false; // Determined by calendar state

        weekDays.add(CalendarDay(
          date: currentDate,
          isCurrentMonth: isCurrentMonth,
          isToday: isToday,
          isSelected: isSelected,
        ));

        currentDate = currentDate.add(const Duration(days: 1));
      }

      weeks.add(weekDays);

      // Stop if we've gone past the end of month
      if (currentDate.isAfter(endOfMonth) && week >= 4) {
        break;
      }
    }

    return CalendarMonthData(
      year: date.year,
      month: date.month,
      weeks: weeks,
    );
  }
}

class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;

  const CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
  });
}

class CalendarMonthData {
  final int year;
  final int month;
  final List<List<CalendarDay>> weeks;

  const CalendarMonthData({
    required this.year,
    required this.month,
    required this.weeks,
  });
}
```

### Date Range Operations

```dart
class DateRangeService {
  bool isDateInRange(DateTime date, DateTimeRange range) {
    return !date.isBefore(range.start) && !date.isAfter(range.end);
  }

  List<DateTime> getDatesInRange(DateTimeRange range) {
    final dates = <DateTime>[];
    var currentDate = range.start;

    while (!currentDate.isAfter(range.end)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  List<DateTime> getWeekdaysInRange(DateTimeRange range, Locale locale) {
    final dates = getDatesInRange(range);
    final firstDayOfWeek = DateTimeHelper.getFirstDayOfWeek(locale);

    // Filter for specific weekdays (e.g., weekdays only)
    return dates.where((date) {
      final weekday = date.weekday;
      return weekday >= firstDayOfWeek && weekday <= ((firstDayOfWeek + 4) % 7);
    }).toList();
  }

  DateTimeRange getWeekRange(DateTime date, Locale locale) {
    final start = DateTimeHelper.startOfWeek(date, locale);
    final end = DateTimeHelper.endOfWeek(date, locale);
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange getMonthRange(DateTime date) {
    final start = DateTimeHelper.startOfMonth(date);
    final end = DateTimeHelper.endOfMonth(date);
    return DateTimeRange(start: start, end: end);
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);
  bool get isSingleDay => start.isAtSameMomentAs(end);
}
```

### Time Formatting

```dart
class TimeFormattingService {
  String formatTime(DateTime time, {bool includeSeconds = false}) {
    if (includeSeconds) {
      return DateFormat('HH:mm:ss').format(time);
    } else {
      return DateFormat('HH:mm').format(time);
    }
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String formatRelativeTime(DateTime dateTime, Locale locale) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return days == 1 ? 'Yesterday' : '$days days ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  String formatWorkingHours(DateTime start, DateTime end) {
    final startTime = formatTime(start);
    final endTime = formatTime(end);
    return '$startTime - $endTime';
  }
}
```

### Task Scheduling Helper

```dart
class TaskSchedulerHelper {
  List<DateTime> getNextAvailableDates(DateTime startDate, int daysCount, Locale locale) {
    final dates = <DateTime>[];
    var currentDate = startDate;

    while (dates.length < daysCount) {
      // Skip weekends if needed
      final weekday = currentDate.weekday;
      if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      dates.add(DateTimeHelper.startOfDay(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  bool isWorkingHour(DateTime time, {TimeOfDay start = const TimeOfDay(9, 0), TimeOfDay end = const TimeOfDay(17, 0)}) {
    final hour = time.hour;
    final minute = time.minute;
    final totalMinutes = hour * 60 + minute;

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return totalMinutes >= startMinutes && totalMinutes < endMinutes;
  }

  DateTime getNextWorkingHour(DateTime time, {TimeOfDay start = const TimeOfDay(9, 0)}) {
    var nextTime = DateTimeHelper.startOfDay(time).add(Duration(hours: start.hour, minutes: start.minute));

    if (time.isAfter(nextTime)) {
      nextTime = nextTime.add(const Duration(days: 1));
    }

    // Skip weekends
    while (nextTime.weekday == DateTime.saturday || nextTime.weekday == DateTime.sunday) {
      nextTime = nextTime.add(const Duration(days: 1));
    }

    return nextTime;
  }
}
```

## Testing Date Utilities

### Unit Testing

```dart
void main() {
  group('DateTimeHelper Tests', () {
    test('should correctly identify today', () {
      final today = DateTime.now();
      expect(DateTimeHelper.isToday(today), isTrue);
    });

    test('should correctly identify yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateTimeHelper.isYesterday(yesterday), isTrue);
    });

    test('should get start of day correctly', () {
      final date = DateTime(2023, 12, 25, 15, 30, 45);
      final startOfDay = DateTimeHelper.startOfDay(date);

      expect(startOfDay.year, equals(2023));
      expect(startOfDay.month, equals(12));
      expect(startOfDay.day, equals(25));
      expect(startOfDay.hour, equals(0));
      expect(startOfDay.minute, equals(0));
      expect(startOfDay.second, equals(0));
    });

    test('should get start of week for US locale', () {
      final date = DateTime(2023, 12, 25); // Monday
      final usLocale = const Locale('en', 'US');
      final startOfWeek = DateTimeHelper.startOfWeek(date, usLocale);

      expect(startOfWeek.weekday, equals(DateTime.sunday)); // Sunday for US
    });

    test('should get start of week for UK locale', () {
      final date = DateTime(2023, 12, 25); // Monday
      final ukLocale = const Locale('en', 'GB');
      final startOfWeek = DateTimeHelper.startOfWeek(date, ukLocale);

      expect(startOfWeek.weekday, equals(DateTime.monday)); // Monday for UK
    });
  });
}
```

### Widget Testing

```dart
void main() {
  testWidgets('WeekdaySelector displays correct days', (tester) async {
    const locale = Locale('en', 'US');

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        home: Scaffold(
          body: WeekdaySelector(
            locale: locale,
            selectedWeekday: 1,
            onWeekdayChanged: (weekday) {},
          ),
        ),
      ),
    );

    // Check for US weekday names (Sunday to Saturday)
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Tue'), findsOneWidget);
    expect(find.text('Wed'), findsOneWidget);
    expect(find.text('Thu'), findsOneWidget);
    expect(find.text('Fri'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);
  });
}
```

## Localization Support

### Supported Locales

The time utilities support common locale patterns:

```dart
class LocaleConfig {
  static Map<String, LocaleSettings> supportedLocales = {
    'en_US': LocaleSettings(
      firstDayOfWeek: DateTime.sunday,
      weekendDays: [DateTime.saturday, DateTime.sunday],
    ),
    'en_GB': LocaleSettings(
      firstDayOfWeek: DateTime.monday,
      weekendDays: [DateTime.saturday, DateTime.sunday],
    ),
    'de_DE': LocaleSettings(
      firstDayOfWeek: DateTime.monday,
      weekendDays: [DateTime.saturday, DateTime.sunday],
    ),
    'fr_FR': LocaleSettings(
      firstDayOfWeek: DateTime.monday,
      weekendDays: [DateTime.saturday, DateTime.sunday],
    ),
    'ja_JP': LocaleSettings(
      firstDayOfWeek: DateTime.sunday,
      weekendDays: [DateTime.saturday, DateTime.sunday],
    ),
  };
}

class LocaleSettings {
  final int firstDayOfWeek;
  final List<int> weekendDays;

  const LocaleSettings({
    required this.firstDayOfWeek,
    required this.weekendDays,
  });
}
```

## Best Practices

### 1. Use Locale-Aware Methods

```dart
// ✅ Good: Use locale-aware methods
final weekdayName = DateTimeHelper.getWeekday(date, userLocale);

// ❌ Bad: Hardcoded English names
final weekdayName = ['Mon', 'Tue', 'Wed'][date.weekday - 1];
```

### 2. Work with Date Boundaries

```dart
// ✅ Good: Use boundary methods
final today = DateTime.now();
final startOfToday = DateTimeHelper.startOfDay(today);
final endOfToday = DateTimeHelper.endOfDay(today);

// ❌ Bad: Manual boundary creation
final startOfToday = DateTime(today.year, today.month, today.day);
final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
```

### 3. Handle Timezones Consistently

```dart
// ✅ Good: Convert to UTC for storage
final utcDate = date.toUtc();
await database.saveDate(utcDate);

// ✅ Good: Convert back to local time for display
final localDate = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
```

### 4. Validate Date Inputs

```dart
// ✅ Good: Validate date ranges
bool isValidDateRange(DateTime start, DateTime end) {
  return start.isBefore(end) || start.isAtSameMomentAs(end);
}

// Usage
if (!isValidDateRange(startDate, endDate)) {
  throw BusinessException('Start date must be before end date', 'INVALID_DATE_RANGE');
}
```

---

**Related Documentation**

- [Date Time Picker Components](../components/date_time_picker/README.md)
- [Numeric Input](../components/numeric_input/README.md)
- [Collection Utils](../utils/collection_utils.md)

**See Also**

- [Time Formatting Util](../utils/time_formatting_util.md)
- [Date Validation Patterns](./date_validation.md)
