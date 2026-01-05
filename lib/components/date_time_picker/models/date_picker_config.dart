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

  DatePickerConfig copyWith({
    DateSelectionMode? selectionMode,
    DateTime? initialDate,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DateTime? minDate,
    DateTime? maxDate,
    DateFormatType? formatType,
    String? titleText,
    String? singleDateTitle,
    String? dateRangeTitle,
    List<QuickDateRange>? quickRanges,
    bool? showTime,
    bool? showQuickRanges,
    bool? enableManualInput,
    String? dateFormatHint,
    ThemeData? theme,
    Locale? locale,
    Map<DateTimePickerTranslationKey, String>? translations,
    bool? allowNullConfirm,
    bool? showRefreshToggle,
    bool? initialRefreshEnabled,
    void Function(bool)? onRefreshToggleChanged,
    DateTime? Function(DateTime?)? dateTimeValidator,
    String? validationErrorMessage,
    double? actionButtonRadius,
    bool? useMobileScaffoldLayout,
    bool? validationErrorAtTop,
    String? doneButtonText,
    String? cancelButtonText,
    DialogSize? dialogSize,
    List<DatePickerFooterAction>? footerActions,
    VoidCallback? onRebuild,
  }) {
    return DatePickerConfig(
      selectionMode: selectionMode ?? this.selectionMode,
      initialDate: initialDate ?? this.initialDate,
      initialStartDate: initialStartDate ?? this.initialStartDate,
      initialEndDate: initialEndDate ?? this.initialEndDate,
      minDate: minDate ?? this.minDate,
      maxDate: maxDate ?? this.maxDate,
      formatType: formatType ?? this.formatType,
      titleText: titleText ?? this.titleText,
      singleDateTitle: singleDateTitle ?? this.singleDateTitle,
      dateRangeTitle: dateRangeTitle ?? this.dateRangeTitle,
      quickRanges: quickRanges ?? this.quickRanges,
      showTime: showTime ?? this.showTime,
      showQuickRanges: showQuickRanges ?? this.showQuickRanges,
      enableManualInput: enableManualInput ?? this.enableManualInput,
      dateFormatHint: dateFormatHint ?? this.dateFormatHint,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      translations: translations ?? this.translations,
      allowNullConfirm: allowNullConfirm ?? this.allowNullConfirm,
      showRefreshToggle: showRefreshToggle ?? this.showRefreshToggle,
      initialRefreshEnabled: initialRefreshEnabled ?? this.initialRefreshEnabled,
      onRefreshToggleChanged: onRefreshToggleChanged ?? this.onRefreshToggleChanged,
      dateTimeValidator: dateTimeValidator ?? this.dateTimeValidator,
      validationErrorMessage: validationErrorMessage ?? this.validationErrorMessage,
      actionButtonRadius: actionButtonRadius ?? this.actionButtonRadius,
      useMobileScaffoldLayout: useMobileScaffoldLayout ?? this.useMobileScaffoldLayout,
      validationErrorAtTop: validationErrorAtTop ?? this.validationErrorAtTop,
      doneButtonText: doneButtonText ?? this.doneButtonText,
      cancelButtonText: cancelButtonText ?? this.cancelButtonText,
      dialogSize: dialogSize ?? this.dialogSize,
      footerActions: footerActions ?? this.footerActions,
      onRebuild: onRebuild ?? this.onRebuild,
    );
  }
}
