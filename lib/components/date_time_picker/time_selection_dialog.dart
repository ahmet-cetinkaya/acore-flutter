import 'package:flutter/material.dart';
import 'constants/date_time_picker_translation_keys.dart';

import '../../utils/haptic_feedback_util.dart';
import '../../utils/responsive_dialog_helper.dart';
import '../../utils/dialog_size.dart';
import 'components/time_picker_mobile_content.dart';
import '../mobile_action_button.dart';
import 'components/shared_components.dart';

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
    this.dialogSize = DialogSize.large,
    this.useMobileScaffoldLayout = false,
    this.hideActionButtons = false,
    this.hideTitle = false,
  });
}

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

class TimeSelectionDialog extends StatefulWidget {
  final TimeSelectionDialogConfig config;

  const TimeSelectionDialog({
    super.key,
    required this.config,
  });

  @override
  State<TimeSelectionDialog> createState() => _TimeSelectionDialogState();

  static Future<TimeSelectionResult?> show({
    required BuildContext context,
    required TimeSelectionDialogConfig config,
  }) async {
    return await showDialog<TimeSelectionResult>(
      context: context,
      barrierDismissible: true,
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
        useMobileScaffoldLayout: false,
        hideActionButtons: true,
        hideTitle: true,
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
      isDismissible: true,
      enableDrag: true,
      isScrollable: false,
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          _selectedTime = picked;
          _isAllDay = false;
        });
        _triggerHapticFeedback();
      }
    }
  }

  Widget _buildTimeSelector() {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerLow;

    return InkWell(
      onTap: () => _selectTime(context),
      borderRadius: BorderRadius.circular(DateTimePickerDesign.radiusLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: DateTimePickerDesign.spacingLarge, vertical: DateTimePickerDesign.spacingLarge),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(DateTimePickerDesign.radiusLarge),
        ),
        child: Row(
          children: [
            StyledIcon(Icons.access_time_filled, isActive: true),
            const SizedBox(width: DateTimePickerDesign.spacingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.headlineLarge?.copyWith(fontSize: 32),
                  ),
                  Text(
                    _getLocalizedText(DateTimePickerTranslationKey.selectTimeTitle, 'Select Time'),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DateTimePickerDesign.spacingMedium),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
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
              _buildTimeSelector(),
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
      ),
    );
  }

  Widget _buildAllDayToggle() {
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
          isActive: !_isAllDay,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      ),
    );
  }
}

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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          _selectedTime = picked;
          _isAllDay = false;
        });
        widget.onTimeChanged?.call(picked);
        _triggerHapticFeedback();
      }
    }
  }

  Widget _buildTimeSelector() {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerLow;

    return InkWell(
      onTap: () => _selectTime(context),
      borderRadius: BorderRadius.circular(DateTimePickerDesign.radiusLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: DateTimePickerDesign.spacingLarge, vertical: DateTimePickerDesign.spacingLarge),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(DateTimePickerDesign.radiusLarge),
        ),
        child: Row(
          children: [
            StyledIcon(Icons.access_time_filled, isActive: true),
            const SizedBox(width: DateTimePickerDesign.spacingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.headlineLarge?.copyWith(fontSize: 32),
                  ),
                  Text(
                    _getLocalizedText(DateTimePickerTranslationKey.selectTimeTitle, 'Select Time'),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDayToggle() {
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
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
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
              _buildTimeSelector(),
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
      ),
    );
  }
}
