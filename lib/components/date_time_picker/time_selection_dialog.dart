import 'package:flutter/material.dart';
import 'date_time_picker_translation_keys.dart';
import 'wheel_time_picker.dart';
import '../../utils/haptic_feedback_util.dart';
import '../../utils/responsive_dialog_helper.dart';
import '../../utils/dialog_size.dart';
import 'time_picker_mobile_content.dart';
import '../mobile_action_button.dart';

class _TimeSelectionDialogDesign {
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;

  static const double radiusMedium = 12.0;

  static const double borderWidth = 1.0;

  static const double fontSizeMedium = 16.0;
  static const double fontSizeXLarge = 20.0;

  static const double iconSizeMedium = 20.0;

  static const double maxDialogWidth = 240.0;
  static const double minDialogWidth = 200.0;
}

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
      barrierDismissible: false, // Prevent accidental dismissal
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
      isDismissible: false, // Prevent accidental dismissal
      enableDrag: true,
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
    _isAllDay = widget.config.initialIsAllDay;
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
    final theme = widget.config.theme ?? Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final dialogWidth = screenWidth.clamp(
      _TimeSelectionDialogDesign.minDialogWidth,
      _TimeSelectionDialogDesign.maxDialogWidth,
    );

    final content = SizedBox(
      width: dialogWidth,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IgnorePointer(
              ignoring: _isAllDay,
              child: Opacity(
                opacity: _isAllDay ? 0.3 : 1.0,
                child: Semantics(
                  label: 'Time picker with hour and minute wheels. Scroll to change values.',
                  child: _buildWheelTimePicker(),
                ),
              ),
            ),
            const SizedBox(height: _TimeSelectionDialogDesign.spacingMedium),
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(_TimeSelectionDialogDesign.radiusMedium),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isAllDay = !_isAllDay;
                  });
                  _triggerHapticFeedback();
                },
                borderRadius: BorderRadius.circular(_TimeSelectionDialogDesign.radiusMedium),
                splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(_TimeSelectionDialogDesign.spacingMedium),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_TimeSelectionDialogDesign.radiusMedium),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: _TimeSelectionDialogDesign.borderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isAllDay,
                        onChanged: (value) {
                          setState(() {
                            _isAllDay = value ?? false;
                          });
                          _triggerHapticFeedback();
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        checkColor: Theme.of(context).colorScheme.onPrimary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          width: 2.0,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: _TimeSelectionDialogDesign.spacingSmall),
                      Expanded(
                        child: Text(
                          _getLocalizedText(
                            DateTimePickerTranslationKey.allDay,
                            'All Day',
                          ),
                          style: TextStyle(
                            fontSize: _TimeSelectionDialogDesign.fontSizeMedium,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: _TimeSelectionDialogDesign.spacingMedium),
          ],
        ),
      ),
    );

    if (widget.config.useMobileScaffoldLayout) {
      return Theme(
        data: theme,
        child: content,
      );
    }

    return Theme(
      data: theme,
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(16.0),
        contentPadding: EdgeInsets.fromLTRB(
          _TimeSelectionDialogDesign.spacingSmall,
          _TimeSelectionDialogDesign.spacingSmall,
          _TimeSelectionDialogDesign.spacingSmall,
          _TimeSelectionDialogDesign.spacingSmall,
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          _TimeSelectionDialogDesign.spacingSmall,
          0.0,
          _TimeSelectionDialogDesign.spacingSmall,
          _TimeSelectionDialogDesign.spacingMedium,
        ),
        title: widget.config.hideTitle
            ? null
            : Semantics(
                label: _getLocalizedText(
                  DateTimePickerTranslationKey.selectTimeTitle,
                  'Select Time',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context).primaryColor,
                      size: _TimeSelectionDialogDesign.iconSizeMedium,
                    ),
                    const SizedBox(width: _TimeSelectionDialogDesign.spacingSmall),
                    Text(
                      _getLocalizedText(
                        DateTimePickerTranslationKey.selectTimeTitle,
                        'Select Time',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: _TimeSelectionDialogDesign.fontSizeXLarge,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
        content: SizedBox(
          width: dialogWidth,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: content,
          ),
        ),
        actions: [
          MobileActionButton(
            context: context,
            onPressed: _onCancel,
            text: _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
            icon: Icons.close,
            isPrimary: false,
            borderRadius: widget.config.actionButtonRadius,
          ),
          const SizedBox(width: _TimeSelectionDialogDesign.spacingSmall),
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
    );
  }
}

/// Internal wrapper class that captures the result from TimeSelectionDialog
class _TimeSelectionDialogWithCallback extends StatefulWidget {
  final TimeSelectionDialogConfig config;
  final void Function(TimeSelectionResult) onResult;

  const _TimeSelectionDialogWithCallback({
    required this.config,
    required this.onResult,
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
    _isAllDay = widget.config.initialIsAllDay;
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
      onTimeChanged: (time) {
        setState(() {
          _selectedTime = time;
          _isAllDay = false;
        });
        _triggerHapticFeedback();
      },
    );
  }

  Widget _buildAllDayToggle() {
    if (!widget.config.hideActionButtons) {
      return Row(
        children: [
          Checkbox(
            value: _isAllDay,
            onChanged: (value) {
              setState(() {
                _isAllDay = value ?? false;
              });
              _triggerHapticFeedback();
            },
          ),
          Text(
            _getLocalizedText(DateTimePickerTranslationKey.allDay, 'All day'),
            style: TextStyle(fontSize: _TimeSelectionDialogDesign.fontSizeMedium),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_TimeSelectionDialogDesign.spacingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.config.hideTitle) ...[
            Text(
              _getLocalizedText(DateTimePickerTranslationKey.selectTimeTitle, 'Select Time'),
              style: TextStyle(
                fontSize: _TimeSelectionDialogDesign.fontSizeXLarge,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _TimeSelectionDialogDesign.spacingMedium),
          ],
          _buildAllDayToggle(),
          if (!_isAllDay) ...[
            const SizedBox(height: _TimeSelectionDialogDesign.spacingMedium),
            SizedBox(
              height: 180,
              child: _buildWheelTimePicker(),
            ),
          ],
          if (!widget.config.hideActionButtons) ...[
            const SizedBox(height: _TimeSelectionDialogDesign.spacingMedium),
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
                const SizedBox(width: _TimeSelectionDialogDesign.spacingSmall),
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
