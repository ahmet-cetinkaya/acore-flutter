import 'package:flutter/material.dart';
import 'date_time_picker_translation_keys.dart';
import '../../time/date_format_service.dart';
import '../../utils/dialog_size.dart';
import 'quick_range_selector.dart';
import 'footer_action_base.dart';

// Shared types for date picker components

/// Date selection modes
enum DateSelectionMode {
  single,
  range,
}

/// Configuration for the legacy DatePickerDialog
/// Note: Consider using DatePickerContentConfig for new implementations
class DatePickerConfig {
  final DateSelectionMode selectionMode;
  final DateTime? initialDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateFormatType? formatType;
  final String? titleText;
  final String? singleDateTitle;
  final String? dateRangeTitle;
  final List<QuickDateRange>? quickRanges;
  final bool showTime;
  final bool showQuickRanges;
  final bool enableManualInput;
  final String? dateFormatHint;
  final ThemeData? theme;
  final Locale? locale;
  final Map<DateTimePickerTranslationKey, String>? translations;
  final bool allowNullConfirm;
  final bool showRefreshToggle;
  final bool initialRefreshEnabled;
  final void Function(bool)? onRefreshToggleChanged;
  final DateTime? Function(DateTime?)? dateTimeValidator;
  final String? validationErrorMessage;
  final double? actionButtonRadius;
  final bool useMobileScaffoldLayout;
  final bool validationErrorAtTop;
  final String? doneButtonText;
  final String? cancelButtonText;
  final DialogSize? dialogSize;
  final List<DatePickerFooterAction>? footerActions;
  final VoidCallback? onRebuild;

  const DatePickerConfig({
    required this.selectionMode,
    this.initialDate,
    this.initialStartDate,
    this.initialEndDate,
    this.minDate,
    this.maxDate,
    this.formatType,
    this.titleText,
    this.singleDateTitle,
    this.dateRangeTitle,
    this.quickRanges,
    this.showTime = false,
    this.showQuickRanges = true,
    this.enableManualInput = false,
    this.dateFormatHint,
    this.theme,
    this.locale,
    this.translations,
    this.allowNullConfirm = true,
    this.showRefreshToggle = false,
    this.initialRefreshEnabled = false,
    this.onRefreshToggleChanged,
    this.dateTimeValidator,
    this.validationErrorMessage,
    this.actionButtonRadius,
    this.useMobileScaffoldLayout = false,
    this.validationErrorAtTop = false,
    this.doneButtonText,
    this.cancelButtonText,
    this.dialogSize,
    this.footerActions,
    this.onRebuild,
  });
}

/// Result from the legacy DatePickerDialog
/// Note: Consider using DatePickerContentResult for new implementations
class DatePickerResult {
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isRefreshEnabled;
  final String? quickSelectionKey;
  final bool isAllDay;
  final bool wasCancelled;

  const DatePickerResult({
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.isRefreshEnabled = false,
    this.quickSelectionKey,
    this.isAllDay = false,
    this.wasCancelled = false,
  });

  factory DatePickerResult.single(
    DateTime date, {
    bool? isRefreshEnabled,
    String? quickSelectionKey,
    bool isAllDay = false,
  }) {
    return DatePickerResult(
      selectedDate: date,
      isRefreshEnabled: isRefreshEnabled ?? false,
      quickSelectionKey: quickSelectionKey,
      isAllDay: isAllDay,
    );
  }

  factory DatePickerResult.range(
    DateTime startDate,
    DateTime endDate, {
    bool? isRefreshEnabled,
    String? quickSelectionKey,
  }) {
    return DatePickerResult(
      startDate: startDate,
      endDate: endDate,
      isRefreshEnabled: isRefreshEnabled ?? false,
      quickSelectionKey: quickSelectionKey,
    );
  }

  factory DatePickerResult.cancelled() {
    return const DatePickerResult(wasCancelled: true);
  }
}
