import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';
import '../../utils/haptic_feedback_util.dart';
import '../../utils/responsive_util.dart';

/// Design constants for calendar date picker
class _CalendarDatePickerDesign {
  // Border radius
  static const double radiusFull = 50.0;

  // Font sizes
  static const double fontSizeSmall = 14.0;

  // Prevent instantiation
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
  // Cache for expensive calculations
  bool? _cachedIsCompactScreen;
  CalendarDatePicker2Config? _cachedConfig;
  List<DateTime>? _cachedCalendarValue;

  /// Checks if the current screen is compact (mobile)
  bool _isCompactScreen(BuildContext context) {
    _cachedIsCompactScreen ??= ResponsiveUtil.isCompactLayout(context);
    return _cachedIsCompactScreen!;
  }

  /// Trigger haptic feedback for better mobile experience
  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  /// Get the calendar picker value based on selection mode and selected dates
  List<DateTime> _getCalendarPickerValue() {
    // Use cached value if available and widgets haven't changed
    if (_cachedCalendarValue != null && _shouldUseCachedValue()) {
      return _cachedCalendarValue!;
    }

    List<DateTime> value;
    if (widget.selectionMode == DateSelectionMode.single) {
      value = widget.selectedDate != null ? [widget.selectedDate!] : [];
    } else {
      // Range selection mode
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

  /// Check if cached values should be used
  bool _shouldUseCachedValue() {
    // For simplicity, we'll rebuild cached values when dependencies change
    // In a real implementation, you might want more sophisticated caching logic
    return false;
  }

  /// Clear cached values when widget dependencies change
  void _clearCache() {
    _cachedIsCompactScreen = null;
    _cachedConfig = null;
    _cachedCalendarValue = null;
  }

  @override
  void didUpdateWidget(CalendarDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear cache when widget properties change
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

  /// Shows time picker for the selected date
  Future<void> _selectTime(DateTime date, bool isStartDate) async {
    if (!widget.showTime) return;

    // Check if the selected date is before minDate and handle time constraints
    TimeOfDay? initialTime = TimeOfDay.fromDateTime(date);
    TimeOfDay? earliestTime;
    TimeOfDay? latestTime;

    final selectedDateOnly = DateTime(date.year, date.month, date.day);

    if (widget.minDate != null) {
      final minDate = widget.minDate!;
      final minDateOnly = DateTime(minDate.year, minDate.month, minDate.day);

      // If selected date is the same as minDate, restrict time to be >= minDate time
      if (selectedDateOnly.isAtSameMomentAs(minDateOnly)) {
        earliestTime = TimeOfDay.fromDateTime(minDate);
      }
      // If selected date is before minDate, prevent selection
      else if (selectedDateOnly.isBefore(minDateOnly)) {
        return;
      }
    }

    if (widget.maxDate != null) {
      final maxDate = widget.maxDate!;
      final maxDateOnly = DateTime(maxDate.year, maxDate.month, maxDate.day);

      // If selected date is the same as maxDate, restrict time to be <= maxDate time
      if (selectedDateOnly.isAtSameMomentAs(maxDateOnly)) {
        latestTime = TimeOfDay.fromDateTime(maxDate);
      }
      // If selected date is after maxDate, prevent selection
      else if (selectedDateOnly.isAfter(maxDateOnly)) {
        return;
      }
    }

    // Adjust initial time if it's outside bounds
    if (earliestTime != null && _isTimeBefore(initialTime, earliestTime)) {
      initialTime = earliestTime;
    }
    if (latestTime != null && _isTimeAfter(initialTime, latestTime)) {
      initialTime = latestTime;
    }

    // Use the native time picker which automatically respects device settings
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (timeOfDay != null && mounted) {
      // Validate time constraints before applying
      if (earliestTime != null && _isTimeBefore(timeOfDay, earliestTime)) {
        return;
      }

      if (latestTime != null && _isTimeAfter(timeOfDay, latestTime)) {
        return;
      }

      // Apply the selected time to the date
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
        // For range mode, update the appropriate start or end date
        if (isStartDate && widget.selectedStartDate != null) {
          widget.onRangeSelected(updatedDate, widget.selectedEndDate);
        } else if (!isStartDate && widget.selectedEndDate != null) {
          widget.onRangeSelected(widget.selectedStartDate, updatedDate);
        }
      }
    }
  }

  /// Validates if a date selection is within constraints
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

  /// Handles date selection changes
  void _onDateChanged(List<DateTime?> dates) async {
    if (widget.selectionMode == DateSelectionMode.single) {
      if (dates.isNotEmpty) {
        DateTime selectedDate = dates.first!;

        // Validate date constraints before proceeding
        if (!_isDateValid(selectedDate)) {
          return;
        }

        widget.onSingleDateSelected(selectedDate);
        widget.onUserHasSelectedQuickRangeChanged?.call();

        // Add haptic feedback for mobile date selection
        if (_isCompactScreen(context)) {
          _triggerHapticFeedback();
        }

        // If time selection is enabled, automatically show time picker
        if (widget.showTime) {
          await _selectTime(selectedDate, true);
        }
      }
    } else {
      // Range selection
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

        // Validate range constraints
        if (widget.minDate != null && startDate.isBefore(widget.minDate!)) {
          return;
        }

        if (widget.maxDate != null && endDate.isAfter(widget.maxDate!)) {
          return;
        }

        widget.onRangeSelected(startDate, endDate);
        widget.onUserHasSelectedQuickRangeChanged?.call();

        // Add haptic feedback for mobile range selection
        if (_isCompactScreen(context)) {
          _triggerHapticFeedback();
        }

        // If time selection is enabled, allow user to select times for start and end dates
        if (widget.showTime) {
          await _selectRangeTimes(startDate, endDate);
        }
      } else if (dates.length == 1) {
        widget.onRangeSelected(dates[0]!, null);
        widget.onUserHasSelectedQuickRangeChanged?.call();

        // Add haptic feedback for mobile partial range selection
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

    // Cache expensive config creation
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

  /// Build and cache the calendar configuration
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
      // Enhanced mobile-specific configurations
      dayMaxWidth: ResponsiveCalendarConstants.dayWidth(context), // Optimized for touch
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
      // Enhanced visual feedback for mobile - supported parameters only
      dayBorderRadius: BorderRadius.circular(_CalendarDatePickerDesign.radiusFull),
      daySplashColor: primaryColor.withValues(alpha: 0.1),
    );
  }

  /// Check if time1 is before time2
  bool _isTimeBefore(TimeOfDay t1, TimeOfDay t2) {
    return t1.hour < t2.hour || (t1.hour == t2.hour && t1.minute < t2.minute);
  }

  /// Check if time1 is after time2
  bool _isTimeAfter(TimeOfDay t1, TimeOfDay t2) {
    return t1.hour > t2.hour || (t1.hour == t2.hour && t1.minute > t2.minute);
  }

  /// Select times for date range selection
  Future<void> _selectRangeTimes(DateTime startDate, DateTime endDate) async {
    if (!widget.showTime) return;

    // First, select start time
    await _selectTime(startDate, true);

    // Then, select end time if the widget is still mounted
    if (mounted) {
      // Use the original end date (not widget state, as it might not be updated yet)
      await _selectTime(endDate, false);

      // Ensure the range is valid after time selection
      if (widget.selectedStartDate != null && widget.selectedEndDate != null) {
        final start = widget.selectedStartDate!;
        final end = widget.selectedEndDate!;

        // If start time is after end time, adjust end time to be after start time
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
