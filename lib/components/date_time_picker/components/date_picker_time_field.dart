import 'package:flutter/material.dart';
import '../constants/date_time_picker_translation_keys.dart';
import '../time_selection_dialog.dart';
import '../../../utils/time_formatting_util.dart';
import '../../../utils/haptic_feedback_util.dart';
import '../../../utils/dialog_size.dart';

/// Design constants for time field
class _TimeFieldDesign {
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double radiusSmall = 8.0;
  static const double fontSizeMedium = 16.0;
  static const double borderWidth = 1.0;
  static const double fieldHeight = 40.0;
  static const double iconSize = 16.0;
  static const double chevronSize = 14.0;
}

/// Time field widget for date picker.
///
/// Displays the current time selection and opens a time selection dialog when tapped.
/// Shows "All Day" when no specific time is set.
class DatePickerTimeField extends StatelessWidget {
  final DateTime? selectedDate;
  final bool isAllDay;
  final Map<DateTimePickerTranslationKey, String>? translations;
  final ThemeData? theme;
  final Locale? locale;
  final double? actionButtonRadius;
  final ValueChanged<DateTime?> onTimeChanged;
  final ValueChanged<bool> onAllDayChanged;

  const DatePickerTimeField({
    super.key,
    required this.onTimeChanged,
    required this.onAllDayChanged,
    this.selectedDate,
    this.isAllDay = true,
    this.translations,
    this.theme,
    this.locale,
    this.actionButtonRadius,
  });

  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return translations?[key] ?? fallback;
  }

  String _formatTimeForDisplay(BuildContext context, DateTime dateTime) {
    return TimeFormattingUtil.formatDateTimeTime(context, dateTime);
  }

  Future<void> _openTimeSelectionDialog(BuildContext context) async {
    if (selectedDate == null) return;

    // Use current time or a default time (09:00) if all-day is currently selected
    final initialTime = isAllDay ? const TimeOfDay(hour: 9, minute: 0) : TimeOfDay.fromDateTime(selectedDate!);

    final result = await TimeSelectionDialog.showResponsive(
      context: context,
      config: TimeSelectionDialogConfig(
        selectedDate: selectedDate!,
        initialTime: initialTime,
        translations: translations ?? {},
        theme: theme,
        locale: locale,
        actionButtonRadius: actionButtonRadius,
        initialIsAllDay: isAllDay,
        useMobileScaffoldLayout: true,
        hideTitle: true,
        dialogSize: DialogSize.large,
      ),
    );

    if (result != null && result.isConfirmed && context.mounted) {
      final newDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        result.isAllDay ? 0 : result.selectedTime.hour,
        result.isAllDay ? 0 : result.selectedTime.minute,
      );
      onTimeChanged(newDateTime);
      onAllDayChanged(result.isAllDay);
      HapticFeedbackUtil.triggerHapticFeedback(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = theme ?? Theme.of(context);

    return Semantics(
      button: true,
      label: selectedDate != null
          ? isAllDay
              ? '${_getLocalizedText(DateTimePickerTranslationKey.allDay, 'All Day')}. Tap to change time.'
              : '${_formatTimeForDisplay(context, selectedDate!)}. Tap to change time.'
          : '${_getLocalizedText(DateTimePickerTranslationKey.allDay, 'All Day')}. No date selected.',
      hint: selectedDate == null ? 'Time selection disabled. Select a date first.' : 'Opens time picker dialog',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_TimeFieldDesign.radiusSmall),
        child: InkWell(
          onTap: selectedDate == null ? null : () => _openTimeSelectionDialog(context),
          borderRadius: BorderRadius.circular(_TimeFieldDesign.radiusSmall),
          splashColor: selectedDate == null ? Colors.transparent : themeData.primaryColor.withValues(alpha: 0.1),
          highlightColor: selectedDate == null ? Colors.transparent : themeData.primaryColor.withValues(alpha: 0.05),
          child: Container(
            height: _TimeFieldDesign.fieldHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: _TimeFieldDesign.spacingSmall,
              vertical: _TimeFieldDesign.spacingXSmall,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedDate == null
                    ? themeData.colorScheme.outline.withValues(alpha: 0.1)
                    : themeData.colorScheme.outline.withValues(alpha: 0.2),
                width: _TimeFieldDesign.borderWidth,
              ),
              borderRadius: BorderRadius.circular(_TimeFieldDesign.radiusSmall),
              color: selectedDate == null ? themeData.colorScheme.surface.withValues(alpha: 0.5) : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: _TimeFieldDesign.iconSize,
                  color: selectedDate == null
                      ? themeData.colorScheme.onSurface.withValues(alpha: 0.38)
                      : themeData.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: _TimeFieldDesign.spacingXSmall),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? isAllDay
                            ? _getLocalizedText(DateTimePickerTranslationKey.allDay, 'All Day')
                            : _formatTimeForDisplay(context, selectedDate!)
                        : _getLocalizedText(DateTimePickerTranslationKey.allDay, 'All Day'),
                    style: TextStyle(
                      fontSize: _TimeFieldDesign.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: selectedDate != null
                          ? themeData.colorScheme.onSurfaceVariant
                          : themeData.colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: _TimeFieldDesign.spacingXSmall),
                Icon(
                  Icons.chevron_right,
                  size: _TimeFieldDesign.chevronSize,
                  color: selectedDate == null
                      ? themeData.colorScheme.onSurface.withValues(alpha: 0.38)
                      : themeData.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
