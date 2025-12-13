import 'package:flutter/material.dart';
import 'constants/date_time_picker_translation_keys.dart';
import 'components/wheel_time_picker.dart';
import '../../utils/haptic_feedback_util.dart';
import '../../utils/responsive_dialog_helper.dart';
import '../../utils/dialog_size.dart';
import 'components/time_picker_mobile_content.dart';
import '../mobile_action_button.dart';
import 'components/shared_components.dart';

/// Configuration for the time selection dialog
class TimeSelectionDialogConfig {
  final DateTime selectedDate;
  final TimeOfDay initialTime;
  final Map<DateTimePickerTranslationKey, String> translations;
  final ThemeData? theme;
  final Locale? locale;
  final double? actionButtonRadius;
  final bool initialIsAllDay;

  final bool useResponsiveDialog;
  final DialogSize dialogSize;
  final bool useMobileScaffoldLayout;

  final bool hideActionButtons;
  final bool hideTitle;

  const TimeSelectionDialogConfig({
    required this.selectedDate,
    required this.initialTime,
    required this.translations,
    this.theme,
    this.locale,
    this.actionButtonRadius,
    this.initialIsAllDay = false,
    this.useResponsiveDialog = false,
    this.dialogSize = DialogSize.small,
    this.useMobileScaffoldLayout = false,
    this.hideActionButtons = false,
    this.hideTitle = false,
  });
}

/// Result returned from the time selection dialog
class TimeSelectionResult {
  final TimeOfDay selectedTime;
  final bool isConfirmed;
  final bool isAllDay;

  const TimeSelectionResult({
    required this.selectedTime,
    required this.isConfirmed,
    required this.isAllDay,
  });

  factory TimeSelectionResult.cancelled() {
    return TimeSelectionResult(
      selectedTime: TimeOfDay.now(),
      isConfirmed: false,
      isAllDay: false,
    );
  }

  factory TimeSelectionResult.confirmed(TimeOfDay time, {bool isAllDay = false}) {
    return TimeSelectionResult(
      selectedTime: time,
      isConfirmed: true,
      isAllDay: isAllDay,
    );
  }
}

/// Mobile-optimized time selection dialog
///
/// This dialog provides a dedicated time selection interface with iOS-style picker wheels,
/// designed specifically for better mobile experience compared to accordion-style interfaces.
class TimeSelectionDialog extends StatefulWidget {
  final TimeSelectionDialogConfig config;

  const TimeSelectionDialog({
    super.key,
    required this.config,
  });

  @override
  State<TimeSelectionDialog> createState() => _TimeSelectionDialogState();

  /// Shows the time selection dialog
  static Future<TimeSelectionResult?> show({
    required BuildContext context,
    required TimeSelectionDialogConfig config,
  }) async {
    return await showDialog<TimeSelectionResult>(
      context: context,
      barrierDismissible: true, // Allow dismissal by tapping outside
      builder: (context) => TimeSelectionDialog(config: config),
    );
  }

  static Future<TimeSelectionResult?> showResponsive({
    required BuildContext context,
    required TimeSelectionDialogConfig config,
  }) async {
    Widget? mobileChild;
    TimeSelectionResult? capturedResult;

    if (config.useMobileScaffoldLayout) {
      // Create a modified config that hides title and action buttons
      // since TimePickerMobileContent handles them in its AppBar
      final mobileConfig = TimeSelectionDialogConfig(
        selectedDate: config.selectedDate,
        initialTime: config.initialTime,
        translations: config.translations,
        theme: config.theme,
        locale: config.locale,
        actionButtonRadius: config.actionButtonRadius,
        initialIsAllDay: config.initialIsAllDay,
        useResponsiveDialog: config.useResponsiveDialog,
        dialogSize: config.dialogSize,
        useMobileScaffoldLayout: false, // Don't nest layouts
        hideActionButtons: true, // Hide content action buttons
        hideTitle: true, // Hide content title
      );

      mobileChild = TimePickerMobileContent(
        timeSelectionDialog: _TimeSelectionDialogWithCallback(
          config: mobileConfig,
          onResult: (result) {
            capturedResult = result;
          },
          onTimeChanged: (time) {
            capturedResult = TimeSelectionResult.confirmed(time, isAllDay: false);
          },
          onAllDayChanged: (isAllDay, currentTime) {
            capturedResult = TimeSelectionResult.confirmed(currentTime, isAllDay: isAllDay);
          },
        ),
        appBarTitle: config.translations[DateTimePickerTranslationKey.selectTimeTitle] ?? 'Select Time',
        confirmButtonText: config.translations[DateTimePickerTranslationKey.confirm] ?? 'Confirm',
        onConfirm: () {
          Navigator.of(context).pop(capturedResult ?? TimeSelectionResult.cancelled());
        },
        onCancel: () {
          Navigator.of(context).pop(TimeSelectionResult.cancelled());
        },
      );
    }

    return await ResponsiveDialogHelper.showResponsiveDialog<TimeSelectionResult>(
      context: context,
      size: config.dialogSize,
      isDismissible: true, // Allow dismissal by tapping outside
      enableDrag: true,
      isScrollable: false, // Disable scrolling to prevent conflict with Scaffold
      child: config.useMobileScaffoldLayout && mobileChild != null ? mobileChild : TimeSelectionDialog(config: config),
      mobileChild: mobileChild,
    );
  }

  static Future<TimeSelectionResult?> showAuto({
    required BuildContext context,
    required TimeSelectionDialogConfig config,
  }) async {
    if (config.useResponsiveDialog) {
      return await showResponsive(context: context, config: config);
    } else {
      return await show(context: context, config: config);
    }
  }
}

class _TimeSelectionDialogState extends State<TimeSelectionDialog> {
  late TimeOfDay _selectedTime;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.config.initialTime;
    // Always start with time picker visible when dialog is explicitly opened
    // Users can toggle all-day mode using the checkbox if needed
    _isAllDay = false;
  }

  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations[key] ?? fallback;
  }

  void _onConfirm() {
    Navigator.of(context).pop(TimeSelectionResult.confirmed(_selectedTime, isAllDay: _isAllDay));
  }

  void _onCancel() {
    Navigator.of(context).pop(TimeSelectionResult.cancelled());
  }

  Widget _buildWheelTimePicker() {
    return WheelTimePicker(
      initialTime: _selectedTime,
      translations: widget.config.translations,
      onTimeChanged: (newTime) {
        setState(() {
          _selectedTime = newTime;
        });
        _triggerHapticFeedback();
      },
      onHapticFeedback: _triggerHapticFeedback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DateTimePickerDesign.spacingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          if (!widget.config.hideTitle) ...[
            Text(
              _getLocalizedText(DateTimePickerTranslationKey.selectTimeTitle, 'Select Time'),
              style: TextStyle(
                fontSize: DateTimePickerDesign.fontSizeXLarge,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DateTimePickerDesign.spacingMedium),
          ],
          // All day toggle
          _buildAllDayToggle(),
          // Time picker content
          if (!_isAllDay) ...[
            const SizedBox(height: DateTimePickerDesign.spacingMedium),
            SizedBox(
              height: 180,
              child: _buildWheelTimePicker(),
            ),
          ],
          // Action buttons
          if (!widget.config.hideActionButtons) ...[
            const SizedBox(height: DateTimePickerDesign.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MobileActionButton(
                  context: context,
                  onPressed: _onCancel,
                  text: _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
                  icon: Icons.close,
                  isPrimary: false,
                  borderRadius: widget.config.actionButtonRadius,
                ),
                const SizedBox(width: DateTimePickerDesign.spacingSmall),
                MobileActionButton(
                  context: context,
                  onPressed: _onConfirm,
                  text: _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
                  icon: Icons.check,
                  isPrimary: true,
                  borderRadius: widget.config.actionButtonRadius,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllDayToggle() {
    // Using surfaceContainer (Material 3) or surface
    final surface1 = Theme.of(context).colorScheme.surface;

    return Card(
      elevation: 0,
      color: surface1,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DateTimePickerDesign.radiusLarge),
      ),
      child: SwitchListTile.adaptive(
        value: _isAllDay,
        onChanged: (value) {
          setState(() {
            _isAllDay = value;
          });
          _triggerHapticFeedback();
        },
        title: Text(
          _getLocalizedText(DateTimePickerTranslationKey.allDay, 'All day'),
          style: TextStyle(
            fontSize: DateTimePickerDesign.fontSizeMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        secondary: StyledIcon(
          Icons.access_time,
          isActive: !_isAllDay, // Active when NOT all day (meaning time is relevant)
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      ),
    );
  }
}

/// Internal wrapper class that captures the result from TimeSelectionDialog
class _TimeSelectionDialogWithCallback extends StatefulWidget {
  final TimeSelectionDialogConfig config;
  final void Function(TimeSelectionResult) onResult;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final void Function(bool isAllDay, TimeOfDay currentTime)? onAllDayChanged;

  const _TimeSelectionDialogWithCallback({
    required this.config,
    required this.onResult,
    this.onTimeChanged,
    this.onAllDayChanged,
  });

  @override
  State<_TimeSelectionDialogWithCallback> createState() => _TimeSelectionDialogWithCallbackState();
}

class _TimeSelectionDialogWithCallbackState extends State<_TimeSelectionDialogWithCallback> {
  late TimeOfDay _selectedTime;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.config.initialTime;
    // Always start with time picker visible when dialog is explicitly opened
    // Users can toggle all-day mode using the checkbox if needed
    _isAllDay = false;
  }

  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations[key] ?? fallback;
  }

  void _onConfirm() {
    final result = TimeSelectionResult.confirmed(_selectedTime, isAllDay: _isAllDay);
    widget.onResult(result);
  }

  void _onCancel() {
    final result = TimeSelectionResult.cancelled();
    widget.onResult(result);
  }

  Widget _buildWheelTimePicker() {
    return WheelTimePicker(
      initialTime: _selectedTime,
      translations: widget.config.translations,
      onTimeChanged: (time) {
        setState(() {
          _selectedTime = time;
          _isAllDay = false;
        });
        widget.onTimeChanged?.call(time);
        _triggerHapticFeedback();
      },
    );
  }

  Widget _buildAllDayToggle() {
    // Using surfaceContainer (Material 3) or surface
    final surface1 = Theme.of(context).colorScheme.surface;

    return Card(
      elevation: 0,
      color: surface1,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DateTimePickerDesign.radiusLarge),
      ),
      child: SwitchListTile.adaptive(
        value: _isAllDay,
        onChanged: (value) {
          setState(() {
            _isAllDay = value;
          });
          widget.onAllDayChanged?.call(_isAllDay, _selectedTime);
          _triggerHapticFeedback();
        },
        title: Text(
          _getLocalizedText(DateTimePickerTranslationKey.allDay, 'All day'),
          style: TextStyle(
            fontSize: DateTimePickerDesign.fontSizeMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        secondary: StyledIcon(
          Icons.access_time,
          isActive: !_isAllDay,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DateTimePickerDesign.spacingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.config.hideTitle) ...[
            Text(
              _getLocalizedText(DateTimePickerTranslationKey.selectTimeTitle, 'Select Time'),
              style: TextStyle(
                fontSize: DateTimePickerDesign.fontSizeXLarge,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DateTimePickerDesign.spacingMedium),
          ],
          _buildAllDayToggle(),
          if (!_isAllDay) ...[
            const SizedBox(height: DateTimePickerDesign.spacingMedium),
            SizedBox(
              height: 180,
              child: _buildWheelTimePicker(),
            ),
          ],
          if (!widget.config.hideActionButtons) ...[
            const SizedBox(height: DateTimePickerDesign.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MobileActionButton(
                  context: context,
                  onPressed: _onCancel,
                  text: _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
                  icon: Icons.close,
                  isPrimary: false,
                  borderRadius: widget.config.actionButtonRadius,
                ),
                const SizedBox(width: DateTimePickerDesign.spacingSmall),
                MobileActionButton(
                  context: context,
                  onPressed: _onConfirm,
                  text: _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
                  icon: Icons.check,
                  isPrimary: true,
                  borderRadius: widget.config.actionButtonRadius,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
