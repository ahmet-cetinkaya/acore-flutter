import 'package:flutter/material.dart';
import '../../../time/date_format_service.dart';
import '../../../utils/dialog_size.dart';
import '../constants/date_time_picker_translation_keys.dart';
import '../components/quick_range_selector.dart';
import '../components/footer_action_base.dart';
import 'date_selection_mode.dart';

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
