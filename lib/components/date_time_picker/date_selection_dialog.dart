import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';
import 'calendar_date_picker.dart' as custom;
import '../../utils/haptic_feedback_util.dart';

/// Design constants for date selection dialog
class _DateSelectionDialogDesign {
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
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;

  // Icon sizes
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;

  // Dialog sizing
  static const double maxDialogWidth = 500.0;
  static const double minDialogWidth = 320.0;
  static const double maxDialogHeight = 700.0;
}

/// Configuration for the date selection dialog
class DateSelectionDialogConfig {
  final DateSelectionMode selectionMode;
  final DateTime? initialDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Map<DateTimePickerTranslationKey, String> translations;
  final ThemeData? theme;
  final Locale? locale;
  final double? actionButtonRadius;

  const DateSelectionDialogConfig({
    required this.selectionMode,
    this.initialDate,
    this.initialStartDate,
    this.initialEndDate,
    this.minDate,
    this.maxDate,
    required this.translations,
    this.theme,
    this.locale,
    this.actionButtonRadius,
  });
}

/// Result returned from the date selection dialog
class DateSelectionResult {
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isConfirmed;

  const DateSelectionResult({
    this.selectedDate,
    this.startDate,
    this.endDate,
    required this.isConfirmed,
  });

  factory DateSelectionResult.cancelled() {
    return const DateSelectionResult(isConfirmed: false);
  }

  factory DateSelectionResult.single(DateTime date) {
    return DateSelectionResult(
      selectedDate: date,
      isConfirmed: true,
    );
  }

  factory DateSelectionResult.range(DateTime startDate, DateTime endDate) {
    return DateSelectionResult(
      startDate: startDate,
      endDate: endDate,
      isConfirmed: true,
    );
  }
}

/// Mobile-optimized date selection dialog
///
/// This dialog provides a dedicated date selection interface with calendar view,
/// designed specifically for better mobile experience compared to inline selection.
class DateSelectionDialog extends StatefulWidget {
  final DateSelectionDialogConfig config;

  const DateSelectionDialog({
    super.key,
    required this.config,
  });

  @override
  State<DateSelectionDialog> createState() => _DateSelectionDialogState();

  /// Shows the date selection dialog
  static Future<DateSelectionResult?> show({
    required BuildContext context,
    required DateSelectionDialogConfig config,
  }) async {
    return await showDialog<DateSelectionResult>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => DateSelectionDialog(config: config),
    );
  }
}

class _DateSelectionDialogState extends State<DateSelectionDialog> {
  late DateTime? _selectedDate;
  late DateTime? _selectedStartDate;
  late DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    if (widget.config.selectionMode == DateSelectionMode.single) {
      _selectedDate = widget.config.initialDate;
      _selectedStartDate = null;
      _selectedEndDate = null;
    } else {
      _selectedDate = null;
      _selectedStartDate = widget.config.initialStartDate;
      _selectedEndDate = widget.config.initialEndDate;
    }
  }

  /// Trigger haptic feedback for better mobile experience
  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  /// Format date for display
  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return '';

    // Try to use MaterialLocalizations if available
    try {
      final localizations = MaterialLocalizations.of(context);
      return localizations.formatCompactDate(date);
    } catch (e) {
      // Fallback formatting
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations[key] ?? fallback;
  }

  /// Handle date confirmation
  void _onConfirm() {
    DateSelectionResult result;
    if (widget.config.selectionMode == DateSelectionMode.single) {
      if (_selectedDate != null) {
        result = DateSelectionResult.single(_selectedDate!);
      } else {
        // No date selected, just close dialog
        result = DateSelectionResult.cancelled();
      }
    } else {
      if (_selectedStartDate != null && _selectedEndDate != null) {
        result = DateSelectionResult.range(_selectedStartDate!, _selectedEndDate!);
      } else {
        // Incomplete range selection
        result = DateSelectionResult.cancelled();
      }
    }

    Navigator.of(context).pop(result);
  }

  /// Handle dialog cancellation
  void _onCancel() {
    Navigator.of(context).pop(DateSelectionResult.cancelled());
  }

  /// Handle single date selection
  void _onSingleDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
    _triggerHapticFeedback();
  }

  /// Handle range selection
  void _onRangeSelected(DateTime? startDate, DateTime? endDate) {
    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;
    });
    _triggerHapticFeedback();
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
          borderRadius:
              BorderRadius.circular(widget.config.actionButtonRadius ?? _DateSelectionDialogDesign.radiusMedium),
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
            borderRadius:
                BorderRadius.circular(widget.config.actionButtonRadius ?? _DateSelectionDialogDesign.radiusMedium),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: _DateSelectionDialogDesign.iconSizeMedium,
                    color: isPrimary
                        ? Theme.of(context).colorScheme.onPrimary
                        : onPressed != null
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  const SizedBox(width: _DateSelectionDialogDesign.spacingSmall),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: _DateSelectionDialogDesign.fontSizeMedium,
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

  /// Build calendar picker widget
  Widget _buildCalendarPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_DateSelectionDialogDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: _DateSelectionDialogDesign.borderWidth,
        ),
      ),
      child: custom.CalendarDatePicker(
        selectionMode: widget.config.selectionMode,
        selectedDate: _selectedDate,
        selectedStartDate: _selectedStartDate,
        selectedEndDate: _selectedEndDate,
        minDate: widget.config.minDate,
        maxDate: widget.config.maxDate,
        showTime: false,
        onSingleDateSelected: _onSingleDateSelected,
        onRangeSelected: _onRangeSelected,
        translations: widget.config.translations,
      ),
    );
  }

  /// Build current selection display
  Widget _buildSelectionDisplay() {
    String displayText;
    IconData icon;

    if (widget.config.selectionMode == DateSelectionMode.single) {
      displayText = _selectedDate != null
          ? _formatDateForDisplay(_selectedDate)
          : _getLocalizedText(DateTimePickerTranslationKey.noDateSelected, 'No date selected');
      icon = Icons.event;
    } else {
      if (_selectedStartDate != null && _selectedEndDate != null) {
        displayText = '${_formatDateForDisplay(_selectedStartDate)} - ${_formatDateForDisplay(_selectedEndDate)}';
      } else if (_selectedStartDate != null) {
        displayText =
            '${_formatDateForDisplay(_selectedStartDate)} - ${_getLocalizedText(DateTimePickerTranslationKey.selectEndDate, 'Select end date')}';
      } else {
        displayText = _getLocalizedText(DateTimePickerTranslationKey.noDatesSelected, 'No dates selected');
      }
      icon = Icons.date_range;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_DateSelectionDialogDesign.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(_DateSelectionDialogDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          width: _DateSelectionDialogDesign.borderWidth,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.config.selectionMode == DateSelectionMode.single
                ? _getLocalizedText(DateTimePickerTranslationKey.selectedTime, 'Selected Date')
                : _getLocalizedText(DateTimePickerTranslationKey.dateRanges, 'Date Range'),
            style: TextStyle(
              fontSize: _DateSelectionDialogDesign.fontSizeSmall,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: _DateSelectionDialogDesign.spacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                size: _DateSelectionDialogDesign.iconSizeLarge,
              ),
              const SizedBox(width: _DateSelectionDialogDesign.spacingSmall),
              Flexible(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: _DateSelectionDialogDesign.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSelectionValid() {
    if (widget.config.selectionMode == DateSelectionMode.single) {
      return _selectedDate != null;
    } else {
      return _selectedStartDate != null && _selectedEndDate != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme ?? Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dialog sizing
    final dialogWidth = screenWidth.clamp(
      _DateSelectionDialogDesign.minDialogWidth,
      _DateSelectionDialogDesign.maxDialogWidth,
    );

    return Theme(
      data: theme,
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(16.0),
        contentPadding: EdgeInsets.fromLTRB(
          _DateSelectionDialogDesign.spacingXLarge,
          _DateSelectionDialogDesign.spacingXLarge,
          _DateSelectionDialogDesign.spacingXLarge,
          _DateSelectionDialogDesign.spacingLarge,
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          _DateSelectionDialogDesign.spacingMedium,
          0.0,
          _DateSelectionDialogDesign.spacingMedium,
          _DateSelectionDialogDesign.spacingLarge,
        ),
        title: Semantics(
          label: widget.config.selectionMode == DateSelectionMode.single
              ? _getLocalizedText(DateTimePickerTranslationKey.selectDateTitle, 'Select Date')
              : _getLocalizedText(DateTimePickerTranslationKey.selectDateRangeTitle, 'Select Date Range'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.config.selectionMode == DateSelectionMode.single ? Icons.event : Icons.date_range,
                color: Theme.of(context).primaryColor,
                size: _DateSelectionDialogDesign.iconSizeLarge,
              ),
              const SizedBox(width: _DateSelectionDialogDesign.spacingSmall),
              Text(
                widget.config.selectionMode == DateSelectionMode.single
                    ? _getLocalizedText(DateTimePickerTranslationKey.selectDateTitle, 'Select Date')
                    : _getLocalizedText(DateTimePickerTranslationKey.selectDateRangeTitle, 'Select Date Range'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: _DateSelectionDialogDesign.fontSizeXLarge,
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
              // Current selection display
              _buildSelectionDisplay(),

              const SizedBox(height: _DateSelectionDialogDesign.spacingXLarge),

              // Calendar picker
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: _DateSelectionDialogDesign.maxDialogHeight * 0.5,
                  ),
                  child: SingleChildScrollView(
                    child: _buildCalendarPicker(),
                  ),
                ),
              ),

              const SizedBox(height: _DateSelectionDialogDesign.spacingXLarge),
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
          const SizedBox(height: _DateSelectionDialogDesign.spacingMedium),
          // Confirm button
          _buildMobileActionButton(
            context: context,
            onPressed: _isSelectionValid() ? _onConfirm : null,
            text: _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
            icon: Icons.check,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}
