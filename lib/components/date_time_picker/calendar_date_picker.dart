import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';
import '../../utils/haptic_feedback_util.dart';
import '../../utils/responsive_util.dart';

class _CalendarDatePickerDesign {
  static const double radiusFull = 50.0;
  static const double fontSizeSmall = 14.0;

  _CalendarDatePickerDesign._();
}

/// A reusable calendar date picker component extracted from DatePickerDialog
///
/// This widget provides a clean, accessible calendar interface for date selection
/// with support for both single date and date range selection modes.
class CalendarDatePicker extends StatefulWidget {
  final DateSelectionMode selectionMode;
  final DateTime? selectedDate;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool showTime;
  final VoidCallback? onUserHasSelectedQuickRangeChanged;
  final void Function(DateTime?) onSingleDateSelected;
  final void Function(DateTime?, DateTime?) onRangeSelected;
  final Map<DateTimePickerTranslationKey, String> translations;

  const CalendarDatePicker({
    super.key,
    required this.selectionMode,
    this.selectedDate,
    this.selectedStartDate,
    this.selectedEndDate,
    this.minDate,
    this.maxDate,
    this.showTime = false,
    this.onUserHasSelectedQuickRangeChanged,
    required this.onSingleDateSelected,
    required this.onRangeSelected,
    required this.translations,
  });

  @override
  State<CalendarDatePicker> createState() => _CalendarDatePickerState();
}

class _CalendarDatePickerState extends State<CalendarDatePicker> {
  bool? _cachedIsCompactScreen;
  CalendarDatePicker2Config? _cachedConfig;
  List<DateTime>? _cachedCalendarValue;

  bool _isCompactScreen(BuildContext context) {
    _cachedIsCompactScreen ??= ResponsiveUtil.isCompactLayout(context);
    return _cachedIsCompactScreen!;
  }

  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  List<DateTime> _getCalendarPickerValue() {
    if (_cachedCalendarValue != null && _shouldUseCachedValue()) {
      return _cachedCalendarValue!;
    }

    List<DateTime> value;
    if (widget.selectionMode == DateSelectionMode.single) {
      value = widget.selectedDate != null ? [widget.selectedDate!] : [];
    } else {
      value = [];
      if (widget.selectedStartDate != null) {
        value.add(widget.selectedStartDate!);
      }
      if (widget.selectedEndDate != null) {
        value.add(widget.selectedEndDate!);
      }
    }

    _cachedCalendarValue = value;
    return value;
  }

  bool _shouldUseCachedValue() {
    return false;
  }

  void _clearCache() {
    _cachedIsCompactScreen = null;
    _cachedConfig = null;
    _cachedCalendarValue = null;
  }

  @override
  void didUpdateWidget(CalendarDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.selectedStartDate != widget.selectedStartDate ||
        oldWidget.selectedEndDate != widget.selectedEndDate ||
        oldWidget.selectionMode != widget.selectionMode ||
        oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate ||
        oldWidget.showTime != widget.showTime) {
      _clearCache();
    }
  }

  Future<void> _selectTime(DateTime date, bool isStartDate) async {
    if (!widget.showTime) return;

    TimeOfDay? initialTime = TimeOfDay.fromDateTime(date);
    TimeOfDay? earliestTime;
    TimeOfDay? latestTime;

    final selectedDateOnly = DateTime(date.year, date.month, date.day);

    if (widget.minDate != null) {
      final minDate = widget.minDate!;
      final minDateOnly = DateTime(minDate.year, minDate.month, minDate.day);

      if (selectedDateOnly.isAtSameMomentAs(minDateOnly)) {
        earliestTime = TimeOfDay.fromDateTime(minDate);
      } else if (selectedDateOnly.isBefore(minDateOnly)) {
        return;
      }
    }

    if (widget.maxDate != null) {
      final maxDate = widget.maxDate!;
      final maxDateOnly = DateTime(maxDate.year, maxDate.month, maxDate.day);

      if (selectedDateOnly.isAtSameMomentAs(maxDateOnly)) {
        latestTime = TimeOfDay.fromDateTime(maxDate);
      } else if (selectedDateOnly.isAfter(maxDateOnly)) {
        return;
      }
    }

    if (earliestTime != null && _isTimeBefore(initialTime, earliestTime)) {
      initialTime = earliestTime;
    }
    if (latestTime != null && _isTimeAfter(initialTime, latestTime)) {
      initialTime = latestTime;
    }

    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (timeOfDay != null && mounted) {
      if (earliestTime != null && _isTimeBefore(timeOfDay, earliestTime)) {
        return;
      }

      if (latestTime != null && _isTimeAfter(timeOfDay, latestTime)) {
        return;
      }

      final updatedDate = DateTime(
        date.year,
        date.month,
        date.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      if (widget.selectionMode == DateSelectionMode.single) {
        widget.onSingleDateSelected(updatedDate);
      } else {
        if (isStartDate && widget.selectedStartDate != null) {
          widget.onRangeSelected(updatedDate, widget.selectedEndDate);
        } else if (!isStartDate && widget.selectedEndDate != null) {
          widget.onRangeSelected(widget.selectedStartDate, updatedDate);
        }
      }
    }
  }

  bool _isDateValid(DateTime selectedDate) {
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (widget.minDate != null) {
      final minDateOnly = DateTime(widget.minDate!.year, widget.minDate!.month, widget.minDate!.day);
      if (selectedDateOnly.isBefore(minDateOnly)) {
        return false;
      }
    }

    if (widget.maxDate != null) {
      final maxDateOnly = DateTime(widget.maxDate!.year, widget.maxDate!.month, widget.maxDate!.day);
      if (selectedDateOnly.isAfter(maxDateOnly)) {
        return false;
      }
    }

    return true;
  }

  void _onDateChanged(List<DateTime?> dates) async {
    if (widget.selectionMode == DateSelectionMode.single) {
      if (dates.isNotEmpty) {
        DateTime selectedDate = dates.first!;

        if (!_isDateValid(selectedDate)) {
          return;
        }

        widget.onSingleDateSelected(selectedDate);
        widget.onUserHasSelectedQuickRangeChanged?.call();

        if (_isCompactScreen(context)) {
          _triggerHapticFeedback();
        }

        if (widget.showTime) {
          await _selectTime(selectedDate, true);
        }
      }
    } else {
      if (dates.length == 2) {
        final startDate = dates[0]!;
        final endDate = DateTime(
          dates[1]!.year,
          dates[1]!.month,
          dates[1]!.day,
          23,
          59,
          59,
        );

        if (widget.minDate != null && startDate.isBefore(widget.minDate!)) {
          return;
        }

        if (widget.maxDate != null && endDate.isAfter(widget.maxDate!)) {
          return;
        }

        widget.onRangeSelected(startDate, endDate);
        widget.onUserHasSelectedQuickRangeChanged?.call();

        if (_isCompactScreen(context)) {
          _triggerHapticFeedback();
        }

        if (widget.showTime) {
          await _selectRangeTimes(startDate, endDate);
        }
      } else if (dates.length == 1) {
        widget.onRangeSelected(dates[0]!, null);
        widget.onUserHasSelectedQuickRangeChanged?.call();

        if (_isCompactScreen(context)) {
          _triggerHapticFeedback();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompactScreen = _isCompactScreen(context);
    final calendarLayout = ResponsiveUtil.calculateCalendarLayout(context);

    _cachedConfig ??= _buildCalendarConfig(isCompactScreen);

    return Semantics(
      label: widget.translations[DateTimePickerTranslationKey.dateTimeFieldLabel] ?? 'Calendar date picker',
      hint: widget.translations[DateTimePickerTranslationKey.editButtonHint] ??
          'Use arrow keys to navigate dates, Enter to select',
      child: Container(
        width: calendarLayout.maxWidth,
        constraints: BoxConstraints(maxWidth: calendarLayout.maxWidth),
        child: CalendarDatePicker2(
          config: _cachedConfig!,
          value: _getCalendarPickerValue(),
          onValueChanged: _onDateChanged,
        ),
      ),
    );
  }

  CalendarDatePicker2Config _buildCalendarConfig(bool isCompactScreen) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    return CalendarDatePicker2Config(
      calendarType: widget.selectionMode == DateSelectionMode.single
          ? CalendarDatePicker2Type.single
          : CalendarDatePicker2Type.range,
      selectedDayHighlightColor: primaryColor,
      selectedDayTextStyle: TextStyle(
        color: onPrimaryColor,
        fontWeight: FontWeight.bold,
        fontSize: isCompactScreen ? 14 : 16,
      ),
      firstDate: widget.minDate ?? DateTime(1900),
      lastDate: widget.maxDate ?? DateTime(2100),
      currentDate: widget.selectedDate ?? widget.selectedStartDate ?? DateTime.now(),
      centerAlignModePicker: true,
      selectedYearTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      rangeBidirectional: true,
      dayMaxWidth: ResponsiveCalendarConstants.dayWidth(context),
      dayTextStyle: TextStyle(
        fontSize: isCompactScreen ? 14 : 16,
        fontWeight: FontWeight.w500,
      ),
      disabledDayTextStyle: TextStyle(
        fontSize: isCompactScreen ? 14 : 16,
        color: onSurfaceColor.withValues(alpha: 0.38),
      ),
      todayTextStyle: TextStyle(
        fontSize: isCompactScreen ? 14 : 16,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      controlsHeight: isCompactScreen ? 36.0 : 40.0,
      controlsTextStyle: TextStyle(
        fontSize: isCompactScreen ? 14 : 16,
        fontWeight: FontWeight.w500,
      ),
      modePickersGap: isCompactScreen ? 8.0 : 12.0,
      useAbbrLabelForMonthModePicker: true,
      weekdayLabelTextStyle: TextStyle(
        fontSize: _CalendarDatePickerDesign.fontSizeSmall,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor.withValues(alpha: 0.6),
      ),
      dayBorderRadius: BorderRadius.circular(_CalendarDatePickerDesign.radiusFull),
      daySplashColor: primaryColor.withValues(alpha: 0.1),
    );
  }

  bool _isTimeBefore(TimeOfDay t1, TimeOfDay t2) {
    return t1.hour < t2.hour || (t1.hour == t2.hour && t1.minute < t2.minute);
  }

  bool _isTimeAfter(TimeOfDay t1, TimeOfDay t2) {
    return t1.hour > t2.hour || (t1.hour == t2.hour && t1.minute > t2.minute);
  }

  Future<void> _selectRangeTimes(DateTime startDate, DateTime endDate) async {
    if (!widget.showTime) return;

    await _selectTime(startDate, true);

    if (mounted) {
      await _selectTime(endDate, false);

      if (widget.selectedStartDate != null && widget.selectedEndDate != null) {
        final start = widget.selectedStartDate!;
        final end = widget.selectedEndDate!;

        if (start.isAfter(end)) {
          final adjustedEnd = DateTime(
            end.year,
            end.month,
            end.day,
            start.hour,
            start.minute,
          );
          widget.onRangeSelected(start, adjustedEnd);
        }
      }
    }
  }
}
