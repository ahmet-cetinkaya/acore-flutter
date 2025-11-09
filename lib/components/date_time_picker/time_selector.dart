import 'package:flutter/material.dart';
import 'date_time_picker_translation_keys.dart';

/// Design constants for time selector
class _TimeSelectorDesign {
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXSmall = 4.0;

  // Border radius
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // Border width
  static const double borderWidth = 1.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;

  // Icon sizes
  static const double iconSizeMedium = 20.0;

  // iOS-style picker dimensions
  static const double pickerHeight = 200.0;
  static const double itemExtent = 40.0;
  static const double squeeze = 1.2;
  static const double diameterRatio = 1.5;
}

/// A reusable time selector component extracted from DatePickerDialog
///
/// This widget provides an inline time selection interface with hour and minute controls,
/// supporting both mobile-optimized touch targets and desktop interactions.
class TimeSelector extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay initialTime;
  final bool showTimePicker;
  final Map<DateTimePickerTranslationKey, String> translations;
  final void Function(DateTime) onTimeChanged;
  final VoidCallback? onHapticFeedback;

  const TimeSelector({
    super.key,
    required this.selectedDate,
    required this.initialTime,
    required this.showTimePicker,
    required this.translations,
    required this.onTimeChanged,
    this.onHapticFeedback,
  });

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  late bool _showInlineTimePicker;
  late TimeOfDay? _tempSelectedTime;
  late FixedExtentScrollController _hourScrollController;
  late FixedExtentScrollController _minuteScrollController;

  @override
  void initState() {
    super.initState();
    _showInlineTimePicker = widget.showTimePicker;
    _tempSelectedTime = widget.initialTime;
    _hourScrollController = FixedExtentScrollController(
      initialItem: widget.initialTime.hour,
    );
    _minuteScrollController = FixedExtentScrollController(
      initialItem: widget.initialTime.minute,
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
    widget.onHapticFeedback?.call();
  }

  /// Format time for display using MaterialLocalizations or fallback
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
    return widget.translations[key] ?? fallback;
  }

  /// Handle time selection from iOS-style picker
  void _onTimeChanged(int hour, int minute) {
    final newDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      hour,
      minute,
    );
    setState(() {
      _tempSelectedTime = TimeOfDay(hour: hour, minute: minute);
    });
    widget.onTimeChanged(newDateTime);
  }

  /// Handle time change when user confirms selection
  void _onTimeSet() {
    if (_tempSelectedTime != null) {
      final newDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _tempSelectedTime!.hour,
        _tempSelectedTime!.minute,
      );
      widget.onTimeChanged(newDateTime);
      setState(() {
        _showInlineTimePicker = false;
      });
    }
  }

  /// Build iOS-style time picker wheel
  Widget _buildIOSPicker() {
    final isCompactScreen = _isCompactScreen(context);

    return Container(
      height: _TimeSelectorDesign.pickerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_TimeSelectorDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: _TimeSelectorDesign.borderWidth,
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
                      itemExtent: _TimeSelectorDesign.itemExtent,
                      squeeze: _TimeSelectorDesign.squeeze,
                      diameterRatio: _TimeSelectorDesign.diameterRatio,
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
                          final isSelected = hour == _tempSelectedTime?.hour;
                          final distance = ((hour - (_tempSelectedTime?.hour ?? 0)).abs() % 24);
                          final isNear = distance == 1 || distance == 23;

                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: _TimeSelectorDesign.spacingSmall),
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
                  padding: const EdgeInsets.only(bottom: _TimeSelectorDesign.spacingSmall),
                  child: Text(
                    'Hour',
                    style: TextStyle(
                      fontSize: _TimeSelectorDesign.fontSizeSmall,
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
            padding: const EdgeInsets.symmetric(horizontal: _TimeSelectorDesign.spacingSmall),
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
                      itemExtent: _TimeSelectorDesign.itemExtent,
                      squeeze: _TimeSelectorDesign.squeeze,
                      diameterRatio: _TimeSelectorDesign.diameterRatio,
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
                          final isSelected = minute == _tempSelectedTime?.minute;
                          final distance = ((minute - (_tempSelectedTime?.minute ?? 0)).abs() % 60);
                          final isNear = distance == 1 || distance == 59;

                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: _TimeSelectorDesign.spacingSmall),
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
                  padding: const EdgeInsets.only(bottom: _TimeSelectorDesign.spacingSmall),
                  child: Text(
                    'Minute',
                    style: TextStyle(
                      fontSize: _TimeSelectorDesign.fontSizeSmall,
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

  /// Build the inline time picker expansion panel
  Widget _buildInlineTimePicker() {
    final isCompactScreen = _isCompactScreen(context);

    return Container(
      margin: EdgeInsets.only(top: isCompactScreen ? 8 : 12),
      padding: EdgeInsets.all(isCompactScreen ? _TimeSelectorDesign.spacingLarge : _TimeSelectorDesign.spacingXLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_TimeSelectorDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: _TimeSelectorDesign.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Semantics(
        label: 'Time picker',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time picker header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getLocalizedText(DateTimePickerTranslationKey.setTime, 'Set Time'),
                  style: TextStyle(
                    fontSize: isCompactScreen ? _TimeSelectorDesign.fontSizeLarge : _TimeSelectorDesign.fontSizeXLarge,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Close time picker',
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showInlineTimePicker = false;
                      });
                      _triggerHapticFeedback();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(_TimeSelectorDesign.spacingXSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: _TimeSelectorDesign.iconSizeMedium,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isCompactScreen ? _TimeSelectorDesign.spacingLarge : _TimeSelectorDesign.spacingXLarge),

            // iOS-style time picker
            Semantics(
              label: 'Time picker with hour and minute wheels. Scroll to change values.',
              child: _buildIOSPicker(),
            ),

            SizedBox(height: isCompactScreen ? _TimeSelectorDesign.spacingXLarge : _TimeSelectorDesign.spacingXLarge),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showInlineTimePicker = false;
                      });
                      _triggerHapticFeedback();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: isCompactScreen ? 12 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_TimeSelectorDesign.radiusMedium),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: isCompactScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: _TimeSelectorDesign.spacingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onTimeSet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: isCompactScreen ? 12 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_TimeSelectorDesign.radiusMedium),
                      ),
                    ),
                    child: Text(
                      'Set Time',
                      style: TextStyle(
                        fontSize: isCompactScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompactScreen = _isCompactScreen(context);
    final currentTime = _tempSelectedTime ?? widget.initialTime;
    final timeString = _formatTimeForDisplay(currentTime);

    return Column(
      children: [
        // Time selector button
        Semantics(
          button: true,
          label: 'Selected time: $timeString. Tap to change time.',
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showInlineTimePicker = !_showInlineTimePicker;
                _tempSelectedTime = widget.initialTime;
              });
              _triggerHapticFeedback();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompactScreen ? 16 : 20,
                vertical: isCompactScreen ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(_TimeSelectorDesign.radiusLarge),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  width: _TimeSelectorDesign.borderWidth,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: isCompactScreen ? 18 : 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: _TimeSelectorDesign.spacingSmall),
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: isCompactScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showInlineTimePicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: _TimeSelectorDesign.iconSizeMedium,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Inline time picker (shown when expanded)
        if (_showInlineTimePicker) _buildInlineTimePicker(),
      ],
    );
  }
}
