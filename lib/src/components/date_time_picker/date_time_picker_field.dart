import 'package:flutter/material.dart' hide DatePickerDialog;
import '../../time/date_format_service.dart';
import 'date_picker_dialog.dart';
import 'date_time_picker_translation_keys.dart';

class DateTimePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
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
    required this.hintText,
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

  // Helper method to normalize DateTime to minute precision (ignoring seconds and milliseconds)
  DateTime _normalizeToMinute(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
  }

  // Helper method to compare dates ignoring seconds and milliseconds
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

  Future<void> _selectDateTime(BuildContext context) async {
    // Use initialValue first, then try to parse from controller, otherwise use null
    DateTime? initialDate = initialValue;

    // If no initialValue provided, try to parse from controller text
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
        // Use null if parsing fails
      }
    }

    // Ensure initialDate is within bounds
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
        DateTimePickerTranslationKey.title:
            translateKey?.call(DateTimePickerTranslationKey.title) ?? 'Select Date & Time',
        DateTimePickerTranslationKey.confirm:
            translateKey?.call(DateTimePickerTranslationKey.confirm) ?? 'Confirm',
        DateTimePickerTranslationKey.cancel:
            translateKey?.call(DateTimePickerTranslationKey.cancel) ?? 'Cancel',
        DateTimePickerTranslationKey.setTime:
            translateKey?.call(DateTimePickerTranslationKey.setTime) ?? 'Set Time',
        DateTimePickerTranslationKey.noDateSelected:
            translateKey?.call(DateTimePickerTranslationKey.noDateSelected) ?? 'No date selected',
        DateTimePickerTranslationKey.clear: 
            translateKey?.call(DateTimePickerTranslationKey.clear) ?? 'Clear',
      },
    );

    final result = await DatePickerDialog.show(
      context: context,
      config: config,
    );

    if (result != null && result.isConfirmed && result.selectedDate != null && context.mounted) {
      final selectedDateTime = result.selectedDate!;

      // Validate the selected date is within bounds
      if ((minDateTime != null && _isBeforeIgnoringSeconds(selectedDateTime, minDateTime!)) ||
          (maxDateTime != null && _isAfterIgnoringSeconds(selectedDateTime, maxDateTime!))) {
        return;
      }

      // Format the date for display using centralized service
      final String formattedDateTime = DateFormatService.formatForInput(
        selectedDateTime,
        context,
        type: DateFormatType.dateTime,
      );
      controller.text = formattedDateTime;

      // Call the callback with the selected date in local timezone
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

    return TextFormField(
      controller: controller,
      readOnly: true,
      style: effectiveTextStyle,
      decoration: decoration?.copyWith(
            hintText: hintText,
            hintStyle: effectiveHintStyle,
            suffixIcon: _buildSuffixIcons(context, effectiveIconSize, effectiveIconColor),
            contentPadding: const EdgeInsets.only(left: 8.0),
          ) ??
          InputDecoration(
            hintText: hintText,
            hintStyle: effectiveHintStyle,
            suffixIcon: _buildSuffixIcons(context, effectiveIconSize, effectiveIconColor),
            isDense: true,
            contentPadding: const EdgeInsets.only(left: 8.0),
          ),
      onTap: () async {
        await _selectDateTime(context);
      },
    );
  }

  Widget _buildSuffixIcons(BuildContext context, double iconSize, Color? iconColor) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          await _selectDateTime(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.edit,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
