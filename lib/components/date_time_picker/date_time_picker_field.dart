import 'package:flutter/material.dart' hide DatePickerDialog;
import '../../time/date_format_service.dart';
import 'date_picker_dialog.dart' as picker;
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';
import 'date_time_picker_constants.dart';

class DateTimePickerField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(DateTime?) onConfirm;
  final DateTime? minDateTime;
  final DateTime? maxDateTime;
  final DateTime? initialValue;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final double? iconSize;
  final Color? iconColor;
  final String Function(DateTimePickerTranslationKey)? translateKey;

  const DateTimePickerField({
    super.key,
    required this.controller,
    required this.onConfirm,
    this.minDateTime,
    this.maxDateTime,
    this.initialValue,
    this.textStyle,
    this.hintStyle,
    this.decoration,
    this.iconSize,
    this.iconColor,
    this.translateKey,
  });

  DateTime _normalizeToMinute(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
  }

  bool _isBeforeIgnoringSeconds(DateTime date1, DateTime date2) {
    final normalized1 = _normalizeToMinute(date1);
    final normalized2 = _normalizeToMinute(date2);
    return normalized1.isBefore(normalized2);
  }

  bool _isAfterIgnoringSeconds(DateTime date1, DateTime date2) {
    final normalized1 = _normalizeToMinute(date1);
    final normalized2 = _normalizeToMinute(date2);
    return normalized1.isAfter(normalized2);
  }

  String _getTranslation(DateTimePickerTranslationKey key, String fallback) {
    return translateKey?.call(key) ?? fallback;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? initialDate = initialValue;

    if (initialDate == null) {
      try {
        if (controller.text.isNotEmpty) {
          initialDate = DateFormatService.parseFromInput(
            controller.text,
            context,
            type: DateFormatType.dateTime,
          );
        }
      } catch (e) {
        // Intentionally ignore parsing errors - will use null as initial date
      }
    }

    if (initialDate != null) {
      if (minDateTime != null && _isBeforeIgnoringSeconds(initialDate, minDateTime!)) {
        initialDate = minDateTime!;
      }
      if (maxDateTime != null && _isAfterIgnoringSeconds(initialDate, maxDateTime!)) {
        initialDate = maxDateTime!;
      }
    }

    final config = DatePickerConfig(
      selectionMode: DateSelectionMode.single,
      initialDate: initialDate,
      minDate: minDateTime,
      maxDate: maxDateTime,
      formatType: DateFormatType.dateTime,
      showTime: true,
      enableManualInput: true,
      translations: {
        DateTimePickerTranslationKey.title: _getTranslation(DateTimePickerTranslationKey.title, 'Select Date & Time'),
        DateTimePickerTranslationKey.confirm: _getTranslation(DateTimePickerTranslationKey.confirm, 'Confirm'),
        DateTimePickerTranslationKey.cancel: _getTranslation(DateTimePickerTranslationKey.cancel, 'Cancel'),
        DateTimePickerTranslationKey.setTime: _getTranslation(DateTimePickerTranslationKey.setTime, 'Set Time'),
        DateTimePickerTranslationKey.selectTimeTitle:
            _getTranslation(DateTimePickerTranslationKey.selectTimeTitle, 'Select Time'),
        DateTimePickerTranslationKey.selectedTime:
            _getTranslation(DateTimePickerTranslationKey.selectedTime, 'Selected time'),
        DateTimePickerTranslationKey.noDateSelected:
            _getTranslation(DateTimePickerTranslationKey.noDateSelected, 'No date selected'),
        DateTimePickerTranslationKey.clear: _getTranslation(DateTimePickerTranslationKey.clear, 'Clear'),
        DateTimePickerTranslationKey.refresh: _getTranslation(DateTimePickerTranslationKey.refresh, 'Refresh'),
      },
    );

    if (!context.mounted) return;
    final result = await picker.DatePickerDialog.show(
      context: context,
      config: config,
    );

    if (result != null && !result.wasCancelled && result.selectedDate != null && context.mounted) {
      final selectedDateTime = result.selectedDate!;

      final String formattedDateTime = DateFormatService.formatForInput(
        selectedDateTime,
        context,
        type: DateFormatType.dateTime,
      );
      controller.text = formattedDateTime;

      onConfirm(selectedDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle = textStyle ?? theme.textTheme.bodyMedium;
    final effectiveHintStyle = hintStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
        );
    final effectiveIconSize = iconSize ?? 16.0;
    final effectiveIconColor = iconColor ?? theme.iconTheme.color?.withValues(alpha: 0.7);

    return Semantics(
      textField: true,
      label: _getTranslation(DateTimePickerTranslationKey.dateTimeFieldLabel, 'Date and time field'),
      hint: _getTranslation(DateTimePickerTranslationKey.dateTimeFieldHint, 'Tap to select date and time'),
      value: controller.text.isNotEmpty ? controller.text : null,
      onTapHint: _getTranslation(DateTimePickerTranslationKey.editButtonHint, 'Open date and time picker'),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: effectiveTextStyle,
        decoration: decoration?.copyWith(
              hintText: _getTranslation(DateTimePickerTranslationKey.dateTimeFieldHint, 'Tap to select date and time'),
              hintStyle: effectiveHintStyle,
              suffixIcon: _buildSuffixIcons(context, effectiveIconSize, effectiveIconColor),
              contentPadding: EdgeInsets.only(left: DateTimePickerConstants.sizeSmall),
            ) ??
            InputDecoration(
              hintText: _getTranslation(DateTimePickerTranslationKey.dateTimeFieldHint, 'Tap to select date and time'),
              hintStyle: effectiveHintStyle,
              suffixIcon: _buildSuffixIcons(context, effectiveIconSize, effectiveIconColor),
              isDense: true,
              contentPadding: EdgeInsets.only(left: DateTimePickerConstants.sizeSmall),
            ),
        onTap: () async {
          await _selectDateTime(context);
        },
      ),
    );
  }

  Widget _buildSuffixIcons(BuildContext context, double iconSize, Color? iconColor) {
    return Semantics(
      button: true,
      label: _getTranslation(DateTimePickerTranslationKey.editButtonLabel, 'Edit date and time'),
      hint: _getTranslation(DateTimePickerTranslationKey.editButtonHint, 'Open date and time picker dialog'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            await _selectDateTime(context);
          },
          child: Padding(
            padding: EdgeInsets.all(DateTimePickerConstants.size2XSmall),
            child: Icon(
              Icons.edit,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
