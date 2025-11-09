import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'date_time_picker_translation_keys.dart';

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

  // iOS-style picker dimensions
  static const double pickerHeight = 200.0;
  static const double itemExtent = 40.0;
  static const double squeeze = 1.2;
  static const double diameterRatio = 1.5;

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
  late FixedExtentScrollController _hourScrollController;
  late FixedExtentScrollController _minuteScrollController;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.config.initialTime;
    _hourScrollController = FixedExtentScrollController(
      initialItem: widget.config.initialTime.hour,
    );
    _minuteScrollController = FixedExtentScrollController(
      initialItem: widget.config.initialTime.minute,
    );
  }

  @override
  void dispose() {
    _hourScrollController.dispose();
    _minuteScrollController.dispose();
    super.dispose();
  }

  /// Checks if the current screen is compact (mobile)
  bool _isCompactScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Trigger haptic feedback for better mobile experience
  void _triggerHapticFeedback() {
    try {
      // Only trigger haptic feedback on mobile platforms
      if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Ignore haptic feedback errors
    }
  }

  /// Format time for display with consistent 12/24 hour formatting
  String _formatTimeForDisplay(TimeOfDay time) {
    return _formatTimeOfDay(time.hour, time.minute);
  }

  /// Unified time formatting method that respects device 12/24 hour settings
  String _formatTimeOfDay(int hour, int minute) {
    final is24Hour = MediaQuery.of(context).alwaysUse24HourFormat;

    if (is24Hour) {
      // 24-hour format: HH:MM
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else {
      // 12-hour format: H:MM AM/PM
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final period = hour >= 12 ? 'PM' : 'AM';
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations[key] ?? fallback;
  }

  /// Handle time selection from iOS-style picker
  void _onTimeChanged(int hour, int minute) {
    setState(() {
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
    _triggerHapticFeedback();
  }

  /// Handle time confirmation
  void _onConfirm() {
    Navigator.of(context).pop(TimeSelectionResult.confirmed(_selectedTime));
  }

  /// Handle dialog cancellation
  void _onCancel() {
    Navigator.of(context).pop(TimeSelectionResult.cancelled());
  }

  /// Build iOS-style time picker wheel
  Widget _buildIOSPicker() {
    final isCompactScreen = _isCompactScreen(context);

    return Container(
      height: _TimeSelectionDialogDesign.pickerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_TimeSelectionDialogDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: _TimeSelectionDialogDesign.borderWidth,
        ),
      ),
      child: Row(
        children: [
          // Hour picker
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification) {
                        _triggerHapticFeedback();
                        return true;
                      }
                      return false;
                    },
                    child: ListWheelScrollView.useDelegate(
                      controller: _hourScrollController,
                      itemExtent: _TimeSelectionDialogDesign.itemExtent,
                      squeeze: _TimeSelectionDialogDesign.squeeze,
                      diameterRatio: _TimeSelectionDialogDesign.diameterRatio,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        final hour = index % 24;
                        final minute = _minuteScrollController.selectedItem;
                        _onTimeChanged(hour, minute);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 24 * 3, // Allow infinite scrolling
                        builder: (context, index) {
                          final hour = index % 24;
                          final isSelected = hour == _selectedTime.hour;
                          final distance = ((hour - _selectedTime.hour).abs() % 24);
                          final isNear = distance == 1 || distance == 23;

                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: _TimeSelectionDialogDesign.spacingSmall),
                            child: Text(
                              hour.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isCompactScreen ? 20 : 24,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : isNear
                                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: _TimeSelectionDialogDesign.spacingSmall),
                  child: Text(
                    'Hour',
                    style: TextStyle(
                      fontSize: _TimeSelectionDialogDesign.fontSizeSmall,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Separator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: _TimeSelectionDialogDesign.spacingSmall),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: isCompactScreen ? 28 : 32,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          // Minute picker
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification) {
                        _triggerHapticFeedback();
                        return true;
                      }
                      return false;
                    },
                    child: ListWheelScrollView.useDelegate(
                      controller: _minuteScrollController,
                      itemExtent: _TimeSelectionDialogDesign.itemExtent,
                      squeeze: _TimeSelectionDialogDesign.squeeze,
                      diameterRatio: _TimeSelectionDialogDesign.diameterRatio,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        final minute = index % 60;
                        final hour = _hourScrollController.selectedItem;
                        _onTimeChanged(hour, minute);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 60 * 3, // Allow infinite scrolling
                        builder: (context, index) {
                          final minute = index % 60;
                          final isSelected = minute == _selectedTime.minute;
                          final distance = ((minute - _selectedTime.minute).abs() % 60);
                          final isNear = distance == 1 || distance == 59;

                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: _TimeSelectionDialogDesign.spacingSmall),
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isCompactScreen ? 20 : 24,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : isNear
                                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: _TimeSelectionDialogDesign.spacingSmall),
                  child: Text(
                    'Minute',
                    style: TextStyle(
                      fontSize: _TimeSelectionDialogDesign.fontSizeSmall,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

              // iOS-style time picker
              Semantics(
                label: 'Time picker with hour and minute wheels. Scroll to change values.',
                child: _buildIOSPicker(),
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