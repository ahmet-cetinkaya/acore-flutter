import 'package:flutter/material.dart';
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';
import 'calendar_date_picker.dart' as custom;
import '../mobile_action_button.dart';
import '../../utils/haptic_feedback_util.dart';
import 'footer_action_base.dart';
import 'shared_components.dart';

class _DateSelectionDialogDesign {
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
  final List<DateSelectionDialogFooterAction>? footerActions;

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
    this.footerActions,
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

  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return '';

    try {
      final localizations = MaterialLocalizations.of(context);
      return localizations.formatCompactDate(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations[key] ?? fallback;
  }

  void _onConfirm() {
    DateSelectionResult result;
    if (widget.config.selectionMode == DateSelectionMode.single) {
      if (_selectedDate != null) {
        result = DateSelectionResult.single(_selectedDate!);
      } else {
        result = DateSelectionResult.cancelled();
      }
    } else {
      if (_selectedStartDate != null && _selectedEndDate != null) {
        result = DateSelectionResult.range(_selectedStartDate!, _selectedEndDate!);
      } else {
        result = DateSelectionResult.cancelled();
      }
    }

    Navigator.of(context).pop(result);
  }

  void _onCancel() {
    Navigator.of(context).pop(DateSelectionResult.cancelled());
  }

  void _onSingleDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
    _triggerHapticFeedback();
  }

  void _onRangeSelected(DateTime? startDate, DateTime? endDate) {
    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;
    });
    _triggerHapticFeedback();
  }

  Widget _buildCalendarPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DateTimePickerDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: DateTimePickerDesign.borderWidth,
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

    // AppTheme.surface1 approximation (very light gray / dark surface)
    // Using surfaceContainer (Material 3) or surface
    final surface1 = Theme.of(context).colorScheme.surface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DateTimePickerDesign.spacingLarge),
      decoration: BoxDecoration(
        color: surface1,
        borderRadius: BorderRadius.circular(DateTimePickerDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: DateTimePickerDesign.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.config.selectionMode == DateSelectionMode.single
                ? _getLocalizedText(DateTimePickerTranslationKey.selectedTime, 'Selected Date')
                : _getLocalizedText(DateTimePickerTranslationKey.dateRanges, 'Date Range'),
            style: TextStyle(
              fontSize: DateTimePickerDesign.fontSizeSmall,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: DateTimePickerDesign.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StyledIcon(icon, isActive: true),
              const SizedBox(width: DateTimePickerDesign.spacingLarge),
              Flexible(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 24, // Larger text for better visibility
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.start,
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

  Widget _buildFooterSection() {
    return Row(
      children: [
        for (final action in widget.config.footerActions!) ...[
          Expanded(
            child: MobileActionButton(
              context: context,
              onPressed: () => action.execute(),
              text: action.getCurrentLabel() ?? 'Action',
              icon: action.getCurrentIcon() ?? Icons.help,
              isPrimary: action.isPrimary,
              borderRadius: widget.config.actionButtonRadius,
              customColor: action.getCurrentColor(),
            ),
          ),
          if (action != widget.config.footerActions!.last) const SizedBox(width: DateTimePickerDesign.spacingMedium),
        ],
      ],
    );
  }

  List<Widget> _buildActions() {
    final List<Widget> actions = [];

    // Always show default actions
    actions.add(
      Expanded(
        child: MobileActionButton(
          context: context,
          onPressed: _onCancel,
          text: _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
          icon: Icons.close,
          isPrimary: false,
          borderRadius: widget.config.actionButtonRadius,
        ),
      ),
    );
    actions.add(const SizedBox(width: DateTimePickerDesign.spacingMedium));
    actions.add(
      Expanded(
        child: MobileActionButton(
          context: context,
          onPressed: _isSelectionValid() ? _onConfirm : null,
          text: _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
          icon: Icons.check,
          isPrimary: true,
          borderRadius: widget.config.actionButtonRadius,
        ),
      ),
    );

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme ?? Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final dialogWidth = screenWidth.clamp(
      _DateSelectionDialogDesign.minDialogWidth,
      _DateSelectionDialogDesign.maxDialogWidth,
    );

    return Theme(
      data: theme,
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(16.0),
        contentPadding: EdgeInsets.fromLTRB(
          DateTimePickerDesign.spacingXLarge,
          DateTimePickerDesign.spacingXLarge,
          DateTimePickerDesign.spacingXLarge,
          DateTimePickerDesign.spacingLarge,
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          DateTimePickerDesign.spacingMedium,
          0.0,
          DateTimePickerDesign.spacingMedium,
          DateTimePickerDesign.spacingLarge,
        ),
        title: Semantics(
          label: widget.config.selectionMode == DateSelectionMode.single
              ? _getLocalizedText(DateTimePickerTranslationKey.selectDateTitle, 'Select Date')
              : _getLocalizedText(DateTimePickerTranslationKey.selectDateRangeTitle, 'Select Date Range'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.config.selectionMode == DateSelectionMode.single
                    ? _getLocalizedText(DateTimePickerTranslationKey.selectDateTitle, 'Select Date')
                    : _getLocalizedText(DateTimePickerTranslationKey.selectDateRangeTitle, 'Select Date Range'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: DateTimePickerDesign.fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
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

              const SizedBox(height: DateTimePickerDesign.spacingXLarge),

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

              if (widget.config.footerActions != null && widget.config.footerActions!.isNotEmpty) ...[
                const SizedBox(height: DateTimePickerDesign.spacingLarge),
                _buildFooterSection(),
              ],

              const SizedBox(height: DateTimePickerDesign.spacingXLarge),
            ],
          ),
        ),
        actions: _buildActions(),
      ),
    );
  }
}
