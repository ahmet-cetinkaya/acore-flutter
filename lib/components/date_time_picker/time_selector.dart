import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'date_time_picker_translation_keys.dart';
import 'wheel_time_picker.dart';
import '../../utils/time_formatting_util.dart';
import '../../utils/haptic_feedback_util.dart';
import '../../utils/responsive_util.dart';

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

  // Icon sizes
  static const double iconSizeMedium = 20.0;
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

  @override
  void initState() {
    super.initState();
    _showInlineTimePicker = widget.showTimePicker;
    _tempSelectedTime = widget.initialTime;
  }

  /// Checks if the current screen is compact (mobile)
  bool _isCompactScreen(BuildContext context) {
    return ResponsiveUtil.isCompactLayout(context);
  }

  /// Trigger haptic feedback for better mobile experience
  void _triggerHapticFeedback() {
    widget.onHapticFeedback?.call();
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  /// Format time for display using MaterialLocalizations
  String _formatTimeForDisplay(TimeOfDay time) {
    return TimeFormattingUtil.formatTime(context, time);
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.translations[key] ?? fallback;
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

  /// Build wheel-style time picker
  Widget _buildWheelTimePicker() {
    return WheelTimePicker(
      initialTime: _tempSelectedTime ?? widget.initialTime,
      onTimeChanged: (newTime) {
        final newDateTime = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          newTime.hour,
          newTime.minute,
        );
        setState(() {
          _tempSelectedTime = newTime;
        });
        widget.onTimeChanged(newDateTime);
      },
      onHapticFeedback: _triggerHapticFeedback,
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
                    fontSize: ResponsiveUtil.getFontSize(context, mobile: 16.0, tablet: 18.0, desktop: 20.0),
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

            // Wheel-style time picker
            Semantics(
              label: 'Time picker with hour and minute wheels. Scroll to change values.',
              child: _buildWheelTimePicker(),
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
                      padding: EdgeInsets.symmetric(
                          vertical:
                              ResponsiveUtil.getLandscapeSpacing(context, mobile: 12.0, tablet: 14.0, desktop: 16.0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_TimeSelectorDesign.radiusMedium),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.getFontSize(context, mobile: 14.0, tablet: 15.0, desktop: 16.0),
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
                      padding: EdgeInsets.symmetric(
                          vertical:
                              ResponsiveUtil.getLandscapeSpacing(context, mobile: 12.0, tablet: 14.0, desktop: 16.0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_TimeSelectorDesign.radiusMedium),
                      ),
                    ),
                    child: Text(
                      'Set Time',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.getFontSize(context, mobile: 14.0, tablet: 15.0, desktop: 16.0),
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
    final currentTime = _tempSelectedTime ?? widget.initialTime;
    final timeString = _formatTimeForDisplay(currentTime);

    return Column(
      children: [
        // Time selector button
        Semantics(
          button: true,
          label: 'Selected time: $timeString. Tap to change time.',
          child: Focus(
            autofocus: false,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space) {
                  _showInlineTimePicker = !_showInlineTimePicker;
                  _tempSelectedTime = widget.initialTime;
                  _triggerHapticFeedback();
                  setState(() {});
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                  _showInlineTimePicker = false;
                  setState(() {});
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
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
                  horizontal: ResponsiveUtil.getLandscapeSpacing(context, mobile: 16.0, tablet: 18.0, desktop: 20.0),
                  vertical: ResponsiveUtil.getLandscapeSpacing(context, mobile: 10.0, tablet: 11.0, desktop: 12.0),
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
                      size: ResponsiveUtil.getIconSize(context, mobile: 18.0, tablet: 19.0, desktop: 20.0),
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: _TimeSelectorDesign.spacingSmall),
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: ResponsiveUtil.getFontSize(context, mobile: 16.0, tablet: 17.0, desktop: 18.0),
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
        ),

        // Inline time picker (shown when expanded)
        if (_showInlineTimePicker) _buildInlineTimePicker(),
      ],
    );
  }
}
