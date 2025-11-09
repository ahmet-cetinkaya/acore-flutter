import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';
import 'haptic_feedback_util.dart';

/// Design constants for calendar date picker
class _CalendarDatePickerDesign {
  // Border radius
  static const double radiusMedium = 12.0;
  static const double radiusFull = 50.0;

  // Font sizes
  static const double fontSizeSmall = 14.0;
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
  /// Checks if the current screen is compact (mobile)
  bool _isCompactScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Trigger haptic feedback for better mobile experience
  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  /// Get the calendar picker value based on selection mode and selected dates
  List<DateTime> _getCalendarPickerValue() {
    if (widget.selectionMode == DateSelectionMode.single) {
      return widget.selectedDate != null ? [widget.selectedDate!] : [];
    }

    // Range selection mode
    final List<DateTime> dates = [];
    if (widget.selectedStartDate != null) {
      dates.add(widget.selectedStartDate!);
    }
    if (widget.selectedEndDate != null) {
      dates.add(widget.selectedEndDate!);
    }
    return dates;
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
    if (earliestTime != null) {
      if (initialTime.hour < earliestTime.hour ||
          (initialTime.hour == earliestTime.hour && initialTime.minute < earliestTime.minute)) {
        initialTime = earliestTime;
      }
    }
    if (latestTime != null) {
      if (initialTime.hour > latestTime.hour ||
          (initialTime.hour == latestTime.hour && initialTime.minute > latestTime.minute)) {
        initialTime = latestTime;
      }
    }

    // Use the native time picker which automatically respects device settings
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (timeOfDay != null && mounted) {
      // Validate time constraints before applying
      if (earliestTime != null) {
        if (timeOfDay.hour < earliestTime.hour ||
            (timeOfDay.hour == earliestTime.hour && timeOfDay.minute < earliestTime.minute)) {
          return;
        }
      }

      if (latestTime != null) {
        if (timeOfDay.hour > latestTime.hour ||
            (timeOfDay.hour == latestTime.hour && timeOfDay.minute > latestTime.minute)) {
          return;
        }
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

        // If there's a minDate constraint and selected date is on the same day as minDate,
        // ensure the time is not before minDate time
        if (widget.minDate != null && widget.showTime) {
          final minDate = widget.minDate!;
          final minDateOnly = DateTime(minDate.year, minDate.month, minDate.day);
          final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

          if (selectedDateOnly.isAtSameMomentAs(minDateOnly)) {
            // Set the time to minDate time if selecting today
            selectedDate = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              minDate.hour,
              minDate.minute,
            );
          }
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
    final calendarWidth = isCompactScreen ? 350.0 : 420.0;

    return Semantics(
      label: widget.translations[DateTimePickerTranslationKey.dateTimeFieldLabel] ?? 'Calendar date picker',
      hint: widget.translations[DateTimePickerTranslationKey.editButtonHint] ??
          'Use arrow keys to navigate dates, Enter to select',
      child: Container(
        width: calendarWidth,
        constraints: BoxConstraints(maxWidth: calendarWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_CalendarDatePickerDesign.radiusMedium),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              calendarType: widget.selectionMode == DateSelectionMode.single
                  ? CalendarDatePicker2Type.single
                  : CalendarDatePicker2Type.range,
              selectedDayHighlightColor: Theme.of(context).primaryColor,
              selectedDayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
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
              dayMaxWidth: isCompactScreen ? 44.0 : 48.0, // Optimized for touch
              dayTextStyle: TextStyle(
                fontSize: isCompactScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
              disabledDayTextStyle: TextStyle(
                fontSize: isCompactScreen ? 14 : 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              todayTextStyle: TextStyle(
                fontSize: isCompactScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              controlsHeight: isCompactScreen ? 36.0 : 40.0,
              controlsTextStyle: TextStyle(
                fontSize: isCompactScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
              modePickersGap: isCompactScreen ? 8.0 : 12.0,
              useAbbrLabelForMonthModePicker: true,
              weekdayLabelTextStyle: TextStyle(
                fontSize:
                    isCompactScreen ? _CalendarDatePickerDesign.fontSizeSmall : _CalendarDatePickerDesign.fontSizeSmall,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              // Enhanced visual feedback for mobile - supported parameters only
              dayBorderRadius: BorderRadius.circular(_CalendarDatePickerDesign.radiusFull),
              daySplashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            value: _getCalendarPickerValue(),
            onValueChanged: _onDateChanged,
          ),
      ),
    );
  }
}
