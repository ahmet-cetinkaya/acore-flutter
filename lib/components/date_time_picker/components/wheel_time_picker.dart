import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../utils/haptic_feedback_util.dart';
import '../constants/date_time_picker_translation_keys.dart';
import 'shared_components.dart';

/// Design constants for wheel time picker
class _WheelTimePickerDesign {
  // Picker dimensions
  static const double pickerHeight = 200.0;
  static const double itemExtent = 40.0;
  static const double squeeze = 1.2;
  static const double diameterRatio = 1.5;
}

/// A reusable wheel-style time picker component
///
/// This widget provides a time picker interface with hour and minute scroll wheels,
/// supporting both 12-hour and 24-hour formats with proper localization support.
class WheelTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final VoidCallback? onHapticFeedback;
  final Map<DateTimePickerTranslationKey, String>? translations;
  final String? hourLabel;
  final String? minuteLabel;

  const WheelTimePicker({
    super.key,
    required this.initialTime,
    this.onTimeChanged,
    this.onHapticFeedback,
    this.translations,
    this.hourLabel,
    this.minuteLabel,
  });

  @override
  State<WheelTimePicker> createState() => _WheelTimePickerState();
}

class _WheelTimePickerState extends State<WheelTimePicker> {
  late TimeOfDay _selectedTime;
  late FixedExtentScrollController _hourScrollController;
  late FixedExtentScrollController _minuteScrollController;

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    if (widget.translations != null) {
      return widget.translations![key] ?? fallback;
    }
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
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
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  /// Build the wheel-style time picker
  @override
  Widget build(BuildContext context) {
    final isCompactScreen = _isCompactScreen(context);

    return Container(
      height: _WheelTimePickerDesign.pickerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DateTimePickerDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: DateTimePickerDesign.borderWidth,
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
                    child: ScrollConfiguration(
                      behavior: _MouseEnabledScrollBehavior(),
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourScrollController,
                        itemExtent: _WheelTimePickerDesign.itemExtent,
                        squeeze: _WheelTimePickerDesign.squeeze,
                        diameterRatio: _WheelTimePickerDesign.diameterRatio,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          final hour = index % 24;
                          final minute = _minuteScrollController.selectedItem % 60;
                          setState(() {
                            _selectedTime = TimeOfDay(hour: hour, minute: minute);
                          });
                          widget.onTimeChanged?.call(_selectedTime);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 24 * 3,
                          builder: (context, index) {
                            final hour = index % 24;
                            final isSelected = hour == _selectedTime.hour;
                            final distance = ((hour - _selectedTime.hour).abs() % 24);
                            final isNear = distance == 1 || distance == 23;

                            return Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: DateTimePickerDesign.spacingSmall),
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
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: DateTimePickerDesign.spacingSmall),
                  child: Text(
                    widget.hourLabel ?? _getLocalizedText(DateTimePickerTranslationKey.timePickerHourLabel, 'Hour'),
                    style: TextStyle(
                      fontSize: DateTimePickerDesign.fontSizeSmall,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Separator
          Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: DateTimePickerDesign.spacingSmall),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: isCompactScreen ? 28 : 32,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DateTimePickerDesign.fontSizeSmall + DateTimePickerDesign.spacingSmall + 4),
            ],
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
                    child: ScrollConfiguration(
                      behavior: _MouseEnabledScrollBehavior(),
                      child: ListWheelScrollView.useDelegate(
                        controller: _minuteScrollController,
                        itemExtent: _WheelTimePickerDesign.itemExtent,
                        squeeze: _WheelTimePickerDesign.squeeze,
                        diameterRatio: _WheelTimePickerDesign.diameterRatio,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          final minute = index % 60;
                          final hour = _hourScrollController.selectedItem % 24;
                          setState(() {
                            _selectedTime = TimeOfDay(hour: hour, minute: minute);
                          });
                          widget.onTimeChanged?.call(_selectedTime);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 60 * 3,
                          builder: (context, index) {
                            final minute = index % 60;
                            final isSelected = minute == _selectedTime.minute;
                            final distance = ((minute - _selectedTime.minute).abs() % 60);
                            final isNear = distance == 1 || distance == 59;

                            return Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: DateTimePickerDesign.spacingSmall),
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
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: DateTimePickerDesign.spacingSmall),
                  child: Text(
                    widget.minuteLabel ??
                        _getLocalizedText(DateTimePickerTranslationKey.timePickerMinuteLabel, 'Minute'),
                    style: TextStyle(
                      fontSize: DateTimePickerDesign.fontSizeSmall,
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
}

class _MouseEnabledScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.unknown,
        PointerDeviceKind.mouse,
      };
}
