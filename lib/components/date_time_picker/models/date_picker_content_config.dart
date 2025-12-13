import 'package:flutter/material.dart';
import '../../../time/date_format_service.dart';
import '../constants/date_time_picker_translation_keys.dart';
import '../components/quick_range_selector.dart';
import '../components/footer_action_base.dart';
import 'date_selection_mode.dart';
import 'date_picker_content_result.dart';

/// Configuration for the date picker content component
class DatePickerContentConfig {
  final DateSelectionMode selectionMode;
  final DateTime? initialDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateFormatType formatType;
  final String? titleText;
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
  final void Function(DatePickerContentResult)? onSelectionChanged;
  final bool validationErrorAtTop;
  final List<DatePickerContentFooterAction>? footerActions;
  final VoidCallback? onRebuildRequest;

  const DatePickerContentConfig({
    required this.selectionMode,
    this.initialDate,
    this.initialStartDate,
    this.initialEndDate,
    this.minDate,
    this.maxDate,
    this.formatType = DateFormatType.date,
    this.titleText,
    this.quickRanges,
    this.showTime = false,
    this.showQuickRanges = false,
    this.enableManualInput = true,
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
    this.onSelectionChanged,
    this.validationErrorAtTop = false,
    this.footerActions,
    this.onRebuildRequest,
  });
}
