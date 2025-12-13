import 'package:flutter/material.dart' hide CalendarDatePicker;
import 'calendar_date_picker.dart';
import '../constants/date_time_picker_translation_keys.dart';
import 'error_boundary.dart';
import '../models/date_picker_types.dart';

/// A wrapper around CalendarDatePicker with error boundary protection
///
/// This widget provides automatic error handling for the CalendarDatePicker component,
/// ensuring graceful degradation when errors occur. It maintains all the functionality
/// of the original CalendarDatePicker while adding robust error reporting and recovery.
class SafeCalendarDatePicker extends StatelessWidget {
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
  final DatePickerErrorHandler? onError;
  final bool enableDetailedErrors;

  const SafeCalendarDatePicker({
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
    this.onError,
    this.enableDetailedErrors = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeDatePicker(
      componentId: 'CalendarDatePicker',
      onError: onError,
      enableDetailedErrors: enableDetailedErrors,
      child: CalendarDatePicker(
        selectionMode: selectionMode,
        selectedDate: selectedDate,
        selectedStartDate: selectedStartDate,
        selectedEndDate: selectedEndDate,
        minDate: minDate,
        maxDate: maxDate,
        showTime: showTime,
        onUserHasSelectedQuickRangeChanged: onUserHasSelectedQuickRangeChanged,
        onSingleDateSelected: _safeOnSingleDateSelected,
        onRangeSelected: _safeOnRangeSelected,
        translations: translations,
      ),
    );
  }

  /// Safe wrapper for single date selection callback with error handling
  void _safeOnSingleDateSelected(DateTime? date) {
    try {
      onSingleDateSelected(date);
    } catch (error, stackTrace) {
      final datePickerError = DatePickerError(
        error: 'Error in onSingleDateSelected callback: ${error.toString()}',
        stackTrace: stackTrace,
        level: DatePickerErrorLevel.error,
        component: 'CalendarDatePicker',
        userFriendlyMessage: 'Failed to process date selection. Please try again.',
      );

      onError?.call(datePickerError);

      if (enableDetailedErrors) {
        debugPrint('CalendarDatePicker callback error: $error');
      }
    }
  }

  /// Safe wrapper for range selection callback with error handling
  void _safeOnRangeSelected(DateTime? startDate, DateTime? endDate) {
    try {
      onRangeSelected(startDate, endDate);
    } catch (error, stackTrace) {
      final datePickerError = DatePickerError(
        error: 'Error in onRangeSelected callback: ${error.toString()}',
        stackTrace: stackTrace,
        level: DatePickerErrorLevel.error,
        component: 'CalendarDatePicker',
        userFriendlyMessage: 'Failed to process date range selection. Please try again.',
      );

      onError?.call(datePickerError);

      if (enableDetailedErrors) {
        debugPrint('CalendarDatePicker callback error: $error');
      }
    }
  }
}
