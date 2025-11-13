import 'package:flutter/material.dart';
import 'date_time_picker_translation_keys.dart';
import 'wheel_time_picker.dart';
import '../mobile_action_button.dart';
import '../../utils/haptic_feedback_util.dart';

/// Design constants for time selection dialog
class _TimeSelectionDialogDesign {
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;

  // Border radius
  static const double radiusMedium = 12.0;

  // Border width
  static const double borderWidth = 1.0;

  // Font sizes
  static const double fontSizeMedium = 16.0;
  static const double fontSizeXLarge = 20.0;

  // Icon sizes
  static const double iconSizeMedium = 20.0;

  // Dialog sizing
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

  const TimeSelectionDialogConfig({
    required this.selectedDate,
    required this.initialTime,
    required this.translations,
    this.theme,
    this.locale,
    this.actionButtonRadius,
    this.initialIsAllDay = false,
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

  /// Trigger haptic feedback for better mobile experience
  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations[key] ?? fallback;
  }

  /// Handle time confirmation
  void _onConfirm() {
    Navigator.of(context).pop(TimeSelectionResult.confirmed(_selectedTime, isAllDay: _isAllDay));
  }

  /// Handle dialog cancellation
  void _onCancel() {
    Navigator.of(context).pop(TimeSelectionResult.cancelled());
  }

  /// Build wheel-style time picker
  Widget _buildWheelTimePicker() {
    return WheelTimePicker(
      initialTime: _selectedTime,
      onTimeChanged: (newTime) {
        setState(() {
          _selectedTime = newTime;
        });
        _triggerHapticFeedback();
      },
      onHapticFeedback: _triggerHapticFeedback,
    );
  }

  /// Build mobile-friendly action button with proper touch targets
  Widget _buildMobileActionButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return MobileActionButton(
      context: context,
      onPressed: onPressed,
      text: text,
      icon: icon,
      isPrimary: isPrimary,
      borderRadius: widget.config.actionButtonRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme ?? Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dialog sizing
    final dialogWidth = screenWidth.clamp(
      _TimeSelectionDialogDesign.minDialogWidth,
      _TimeSelectionDialogDesign.maxDialogWidth,
    );

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
        title: Semantics(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wheel-style time picker (shown when not All Day)
              if (!_isAllDay)
                Semantics(
                  label: 'Time picker with hour and minute wheels. Scroll to change values.',
                  child: _buildWheelTimePicker(),
                ),

              if (!_isAllDay) const SizedBox(height: _TimeSelectionDialogDesign.spacingMedium),

              // All Day checkbox (placed at the bottom)
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
        actions: [
          // Cancel button
          _buildMobileActionButton(
            context: context,
            onPressed: _onCancel,
            text: _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
            icon: Icons.close,
            isPrimary: false,
          ),
          const SizedBox(height: _TimeSelectionDialogDesign.spacingMedium),
          // Confirm button
          _buildMobileActionButton(
            context: context,
            onPressed: _onConfirm,
            text: _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
            icon: Icons.check,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}
