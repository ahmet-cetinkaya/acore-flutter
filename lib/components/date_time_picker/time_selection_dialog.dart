import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'date_time_picker_translation_keys.dart';
import 'wheel_time_picker.dart';
import 'time_formatting_util.dart';
import 'haptic_feedback_util.dart';

/// Design constants for time selection dialog
class _TimeSelectionDialogDesign {
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;

  // Border radius
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // Border width
  static const double borderWidth = 1.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeXLarge = 20.0;

  // Icon sizes
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;

  // Dialog sizing
  static const double maxDialogWidth = 400.0;
  static const double minDialogWidth = 320.0;
}

/// Configuration for the time selection dialog
class TimeSelectionDialogConfig {
  final DateTime selectedDate;
  final TimeOfDay initialTime;
  final Map<DateTimePickerTranslationKey, String> translations;
  final ThemeData? theme;
  final Locale? locale;
  final double? actionButtonRadius;

  const TimeSelectionDialogConfig({
    required this.selectedDate,
    required this.initialTime,
    required this.translations,
    this.theme,
    this.locale,
    this.actionButtonRadius,
  });
}

/// Result returned from the time selection dialog
class TimeSelectionResult {
  final TimeOfDay selectedTime;
  final bool isConfirmed;

  const TimeSelectionResult({
    required this.selectedTime,
    required this.isConfirmed,
  });

  factory TimeSelectionResult.cancelled() {
    return TimeSelectionResult(
      selectedTime: TimeOfDay.now(),
      isConfirmed: false,
    );
  }

  factory TimeSelectionResult.confirmed(TimeOfDay time) {
    return TimeSelectionResult(
      selectedTime: time,
      isConfirmed: true,
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

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.config.initialTime;
  }

  /// Checks if the current screen is compact (mobile)
  bool _isCompactScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Trigger haptic feedback for better mobile experience
  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  /// Format time for display using MaterialLocalizations
  String _formatTimeForDisplay(TimeOfDay time) {
    return TimeFormattingUtil.formatTime(context, time);
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations[key] ?? fallback;
  }

  
  /// Handle time confirmation
  void _onConfirm() {
    Navigator.of(context).pop(TimeSelectionResult.confirmed(_selectedTime));
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
    return Semantics(
      button: true,
      label: text,
      child: Container(
        height: 48, // Minimum touch target size
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.config.actionButtonRadius ?? _TimeSelectionDialogDesign.radiusMedium),
          color: isPrimary
              ? Theme.of(context).primaryColor
              : onPressed != null
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.surface,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(widget.config.actionButtonRadius ?? _TimeSelectionDialogDesign.radiusMedium),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: _TimeSelectionDialogDesign.iconSizeMedium,
                    color: isPrimary
                        ? Theme.of(context).colorScheme.onPrimary
                        : onPressed != null
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  const SizedBox(width: _TimeSelectionDialogDesign.spacingSmall),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: _TimeSelectionDialogDesign.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: isPrimary
                          ? Theme.of(context).colorScheme.onPrimary
                          : onPressed != null
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme ?? Theme.of(context);
    final isCompactScreen = _isCompactScreen(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dialog sizing
    final dialogWidth = screenWidth.clamp(
      _TimeSelectionDialogDesign.minDialogWidth,
      _TimeSelectionDialogDesign.maxDialogWidth,
    );

    final timeString = _formatTimeForDisplay(_selectedTime);

    return Theme(
      data: theme,
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(16.0),
        contentPadding: EdgeInsets.fromLTRB(
          _TimeSelectionDialogDesign.spacingXLarge,
          _TimeSelectionDialogDesign.spacingXLarge,
          _TimeSelectionDialogDesign.spacingXLarge,
          _TimeSelectionDialogDesign.spacingLarge,
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          _TimeSelectionDialogDesign.spacingMedium,
          0.0,
          _TimeSelectionDialogDesign.spacingMedium,
          _TimeSelectionDialogDesign.spacingLarge,
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
                size: _TimeSelectionDialogDesign.iconSizeLarge,
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
              // Current time display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(_TimeSelectionDialogDesign.spacingLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(_TimeSelectionDialogDesign.radiusLarge),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    width: _TimeSelectionDialogDesign.borderWidth,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _getLocalizedText(
                        DateTimePickerTranslationKey.selectedTime,
                        'Selected Time',
                      ),
                      style: TextStyle(
                        fontSize: _TimeSelectionDialogDesign.fontSizeSmall,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: _TimeSelectionDialogDesign.spacingSmall),
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: isCompactScreen ? 32 : 40,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _TimeSelectionDialogDesign.spacingXLarge),

              // Wheel-style time picker
              Semantics(
                label: 'Time picker with hour and minute wheels. Scroll to change values.',
                child: _buildWheelTimePicker(),
              ),

              const SizedBox(height: _TimeSelectionDialogDesign.spacingXLarge),
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