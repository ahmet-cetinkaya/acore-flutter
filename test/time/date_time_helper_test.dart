import 'package:flutter_test/flutter_test.dart';
import 'package:acore/time/date_time_helper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('tr', null);
  });

  group('DateTimeHelper Comprehensive Tests', () {
    group('Weekday Logic', () {
      test('getWeekday returns name for weekday', () {
        // Monday = 1
        expect(DateTimeHelper.getWeekday(1, const Locale('en')), equals('Mon'));
        // Sunday = 7
        expect(DateTimeHelper.getWeekday(7, const Locale('en')), equals('Sun'));
      });

      test('getWeekdayShort returns short name', () {
        expect(DateTimeHelper.getWeekdayShort(1, const Locale('en')), equals('Mon'));
      });

      test('getFirstDayOfWeek returns correct start day', () {
        expect(DateTimeHelper.getFirstDayOfWeek(const Locale('en', 'US')), equals(7)); // Sunday
        expect(DateTimeHelper.getFirstDayOfWeek(const Locale('tr', 'TR')), equals(1)); // Monday
      });
    });

    group('Timezone Conversion', () {
      test('toLocalDateTime converts UTC to local', () {
        final utc = DateTime.utc(2024, 1, 1, 12, 0);
        final local = DateTimeHelper.toLocalDateTime(utc);
        expect(local.isUtc, isFalse);
      });

      test('toUtcDateTime converts local to UTC', () {
        final local = DateTime(2024, 1, 1, 12, 0);
        final utc = DateTimeHelper.toUtcDateTime(local);
        expect(utc.isUtc, isTrue);
      });
    });

    group('Comparison Utilities', () {
      test('isSameDay correctly identifies same day', () {
        final date1 = DateTime(2024, 1, 1, 10, 0);
        final date2 = DateTime(2024, 1, 1, 20, 0);
        final date3 = DateTime(2024, 1, 2, 10, 0);

        expect(DateTimeHelper.isSameDay(date1, date2), isTrue);
        expect(DateTimeHelper.isSameDay(date1, date3), isFalse);
      });
    });

    group('Formatting Methods', () {
      test('formatDateTime uses locale-appropriate format', () {
        final date = DateTime(2024, 1, 1, 14, 30);
        final result = DateTimeHelper.formatDateTime(date, locale: const Locale('en', 'US'));
        expect(result.contains('1/1/2024'), isTrue);
      });

      test('formatDuration returns localized string', () {
        const duration = Duration(hours: 2, minutes: 30);
        expect(DateTimeHelper.formatDuration(duration, const Locale('en')), equals('2 h 30 m'));
        expect(DateTimeHelper.formatDuration(duration, const Locale('tr')), equals('2 sa 30 dk'));
      });

      test('formatDurationShort returns short localized string', () {
        const duration = Duration(hours: 1, minutes: 45);
        expect(DateTimeHelper.formatDurationShort(duration, const Locale('en')), equals('1h'));
        expect(DateTimeHelper.formatDurationShort(duration, const Locale('tr')), equals('1sa'));
      });
    });

    group('Smart Short Formatting', () {
      test('formatDateShortSmart returns Today for today', () {
        final now = DateTime.now();
        final result = DateTimeHelper.formatDateShortSmart(now);
        expect(result, equals('Today'));
      });

      test('formatDateShortSmart returns Tomorrow for tomorrow', () {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final result = DateTimeHelper.formatDateShortSmart(tomorrow);
        expect(result, equals('Tomorrow'));
      });

      test('formatDateShortSmart returns weekday for dates within 7 days', () {
        final now = DateTime.now();
        final threeDaysFromNow = now.add(const Duration(days: 3));
        final result = DateTimeHelper.formatDateShortSmart(threeDaysFromNow);

        final expected = DateTimeHelper.getWeekday(threeDaysFromNow.weekday);
        expect(result, equals(expected));
      });

      test('formatDateShortSmart uses dd.MM for current year', () {
        final now = DateTime.now();
        final laterDate = DateTime(now.year, now.month, now.day + 11);
        final result = DateTimeHelper.formatDateShortSmart(laterDate);
        final expected = DateFormat('dd.MM').format(laterDate);
        expect(result, equals(expected));
      });

      test('formatDateShortSmart uses dd.MM.yy for other years', () {
        final now = DateTime.now();
        final nextYear = now.year + 1;
        final nextYearDate = DateTime(nextYear, 1, 1);
        final result = DateTimeHelper.formatDateShortSmart(nextYearDate);
        final expectedYearStr = nextYear.toString().substring(2);
        expect(result, equals('01.01.$expectedYearStr'));
      });
    });
  });
}
