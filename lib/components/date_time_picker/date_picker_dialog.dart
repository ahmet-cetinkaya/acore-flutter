import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../time/date_format_service.dart';
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';
import 'calendar_date_picker.dart' as custom;
import 'time_selection_dialog.dart';
import 'date_selection_dialog.dart';
import 'quick_range_selector.dart';
import 'date_validation_display.dart';

/// Mobile-optimized design constants for date picker
class _DatePickerDesign {
  // Touch targets (following 48dp minimum requirement)

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;

  // Dialog sizing
  static const double maxDialogWidth = 600.0;
  static const double maxDialogHeight = 800.0;
  static const double compactDialogWidth = 320.0;

  // Border width
  static const double borderWidth = 1.0;
}

/// Configuration for the unified date picker dialog
class DatePickerConfig {
  final DateSelectionMode selectionMode;
  final DateTime? initialDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateFormatType formatType;
  final String? titleText;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final List<QuickDateRange>? quickRanges;
  final bool showTime;
  final bool showQuickRanges;
  final bool enableManualInput;
  final String? dateFormatHint;
  final ThemeData? theme;
  final Locale? locale;
  final Map<DateTimePickerTranslationKey, String>? translations;
  final bool allowNullConfirm;
  final bool showRefreshToggle;
  final bool initialRefreshEnabled;
  final void Function(bool)? onRefreshToggleChanged;
  final bool Function(DateTime?)? dateTimeValidator;
  final String? validationErrorMessage;
  final double? actionButtonRadius;

  const DatePickerConfig({
    required this.selectionMode,
    this.initialDate,
    this.initialStartDate,
    this.initialEndDate,
    this.minDate,
    this.maxDate,
    this.formatType = DateFormatType.date,
    this.titleText,
    this.confirmButtonText,
    this.cancelButtonText,
    this.quickRanges,
    this.showTime = false,
    this.showQuickRanges = false,
    this.enableManualInput = true,
    this.dateFormatHint,
    this.theme,
    this.locale,
    this.translations,
    this.allowNullConfirm = false,
    this.showRefreshToggle = false,
    this.initialRefreshEnabled = false,
    this.onRefreshToggleChanged,
    this.dateTimeValidator,
    this.validationErrorMessage,
    this.actionButtonRadius,
  });
}

/// Date selection mode for the picker

/// Result returned from the date picker dialog
class DatePickerResult {
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isConfirmed;
  final bool? isRefreshEnabled;
  final String? quickSelectionKey;
  final bool isAllDay;

  const DatePickerResult({
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.isConfirmed = false,
    this.isRefreshEnabled,
    this.quickSelectionKey,
    this.isAllDay = false,
  });

  factory DatePickerResult.cancelled() {
    return const DatePickerResult(isConfirmed: false);
  }

  factory DatePickerResult.single(DateTime date, {bool? isRefreshEnabled, String? quickSelectionKey, bool isAllDay = false}) {
    return DatePickerResult(
      selectedDate: date,
      isConfirmed: true,
      isRefreshEnabled: isRefreshEnabled,
      quickSelectionKey: quickSelectionKey,
      isAllDay: isAllDay,
    );
  }

  factory DatePickerResult.range(DateTime startDate, DateTime endDate,
      {bool? isRefreshEnabled, String? quickSelectionKey}) {
    return DatePickerResult(
      startDate: startDate,
      endDate: endDate,
      isConfirmed: true,
      isRefreshEnabled: isRefreshEnabled,
      quickSelectionKey: quickSelectionKey,
    );
  }

  factory DatePickerResult.cleared() {
    return const DatePickerResult(
      selectedDate: null,
      isConfirmed: true,
    );
  }
}

/// Unified date picker dialog that supports both single date and date range selection
class DatePickerDialog extends StatefulWidget {
  final DatePickerConfig config;

  const DatePickerDialog({
    super.key,
    required this.config,
  });

  @override
  State<DatePickerDialog> createState() => _DatePickerDialogState();

  /// Shows the unified date picker dialog
  static Future<DatePickerResult?> show({
    required BuildContext context,
    required DatePickerConfig config,
  }) async {
    return await showDialog<DatePickerResult>(
      context: context,
      builder: (context) => DatePickerDialog(config: config),
    );
  }
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  late DateTime? _selectedDate;
  late DateTime? _selectedStartDate;
  late DateTime? _selectedEndDate;
  late bool _refreshEnabled;
  String? _selectedQuickRangeKey;

  // All day state tracking
  bool _isAllDay = true; // Separate state for All Day toggle

  // Validation state tracking
  bool _isSelectionValid = false;

  // Performance optimization: cached formatted dates
  final Map<DateTime, String> _formattedDateCache = {};

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _initializeQuickSelectionState();
  }

  @override
  void dispose() {
    _formattedDateCache.clear();
    super.dispose();
  }

  void _initializeValues() {
    if (widget.config.selectionMode == DateSelectionMode.single) {
      _selectedDate = widget.config.initialDate;
      _selectedStartDate = null;
      _selectedEndDate = null;
      // Initialize All Day state based on whether the initial date has time set
      _isAllDay = _selectedDate == null || _isAllDayTime(_selectedDate!);
    } else {
      _selectedDate = null;
      _selectedStartDate = widget.config.initialStartDate;
      _selectedEndDate = widget.config.initialEndDate;
      // For range selection, check if start date determines all-day state
      _isAllDay = _selectedStartDate == null || _isAllDayTime(_selectedStartDate!);
    }
    _refreshEnabled = widget.config.initialRefreshEnabled;
  }

  void _initializeQuickSelectionState() {
    // Check if initial dates match any quick range - if so, consider it as user selected
    if (widget.config.quickRanges != null && _selectedStartDate != null && _selectedEndDate != null) {
      for (final range in widget.config.quickRanges!) {
        if (_isQuickRangeSelected(range)) {
          _selectedQuickRangeKey = range.key;
          break;
        }
      }
    }
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return '';

    // Create a cache key based on the date only (not time)
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Check cache first
    if (_formattedDateCache.containsKey(dateOnly)) {
      return _formattedDateCache[dateOnly]!;
    }

    // Format and cache the result
    final formatted = DateFormatService.formatForInput(
      date,
      context,
      type: widget.config.formatType,
    );

    // Limit cache size to prevent memory leaks
    if (_formattedDateCache.length > 50) {
      _formattedDateCache.clear();
    }

    _formattedDateCache[dateOnly] = formatted;
    return formatted;
  }

  /// Format time for display with consistent 12/24 hour formatting
  String _formatTimeForDisplay(DateTime dateTime) {
    return _formatTimeOfDay(dateTime.hour, dateTime.minute);
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

  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations?[key] ?? fallback;
  }

  /// Build compact Todoist-style quick selection with horizontal layout
  Widget _buildTodoistQuickSelection() {
    return Container(
      margin: const EdgeInsets.only(bottom: _DatePickerDesign.spacingMedium),
      child: Wrap(
        spacing: _DatePickerDesign.spacingSmall,
        runSpacing: _DatePickerDesign.spacingSmall,
        children: [
          _buildCompactQuickSelectionButton(
            text: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionToday, 'Today'),
            onTap: () => _selectToday(),
            isSelected: _isTodaySelected(),
          ),
          _buildCompactQuickSelectionButton(
            text: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionTomorrow, 'Tomorrow'),
            onTap: () => _selectTomorrow(),
            isSelected: _isTomorrowSelected(),
          ),
          _buildCompactQuickSelectionButton(
            text: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionWeekend, 'Weekend'),
            onTap: () => _selectThisWeekend(),
            isSelected: _isThisWeekendSelected(),
          ),
          _buildCompactQuickSelectionButton(
            text: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionNoDate, 'No Date'),
            onTap: () => _selectNoDate(),
            isSelected: _isNoDateSelected(),
            isNoDate: true,
          ),
        ],
      ),
    );
  }

  /// Build compact quick selection button for space-efficient layout
  Widget _buildCompactQuickSelectionButton({
    required String text,
    required VoidCallback onTap,
    bool isNoDate = false,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        _triggerHapticFeedback();
      },
      child: Container(
        height: 40, // Reduced height for compact design
        constraints: const BoxConstraints(
          minWidth: 80, // Minimum width to ensure text is readable
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: _DatePickerDesign.spacingSmall,
          vertical: _DatePickerDesign.spacingXSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : _DatePickerDesign.borderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact icon indicator
            Container(
              width: 24, // Reduced size for compact design
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
              ),
              child: Center(
                child: isNoDate
                    ? Icon(
                        Icons.close,
                        size: 14, // Smaller icon for compact design
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                    : Text(
                        _getShortDayName(text),
                        style: TextStyle(
                          fontSize: 10, // Even smaller font to fit 3-letter day names
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: _DatePickerDesign.spacingXSmall),
            // Compact text
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 10, // Even smaller font to fit 3-letter day names
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get short day name for quick selection buttons
  String _getShortDayName(String selectionText) {
    final now = DateTime.now();

    if (selectionText.contains('Today') || selectionText.toLowerCase().contains('bugün')) {
      return _getShortDayNameFromDateTime(now);
    } else if (selectionText.contains('Tomorrow') || selectionText.toLowerCase().contains('yarın')) {
      return _getShortDayNameFromDateTime(now.add(const Duration(days: 1)));
    } else if (selectionText.contains('Weekend')) {
      // Find Saturday
      var saturday = now;
      while (saturday.weekday != DateTime.saturday) {
        saturday = saturday.add(const Duration(days: 1));
      }
      return _getShortDayNameFromDateTime(saturday);
    } else if (selectionText.contains('Next Week')) {
      // Monday of next week
      var monday = now;
      while (monday.weekday != DateTime.monday) {
        monday = monday.add(const Duration(days: 1));
      }
      return _getShortDayNameFromDateTime(monday);
    }

    return '---'; // Default
  }

  /// Get short day name from DateTime
  String _getShortDayNameFromDateTime(DateTime dateTime) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']; // Short day names
    return weekdays[dateTime.weekday - 1];
  }

  /// Check if today is currently selected
  bool _isTodaySelected() {
    if (_selectedDate == null) return false;
    final now = DateTime.now();
    return _isSameDay(_selectedDate!, now);
  }

  /// Check if tomorrow is currently selected
  bool _isTomorrowSelected() {
    if (_selectedDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _isSameDay(_selectedDate!, tomorrow);
  }

  /// Check if this weekend is currently selected
  bool _isThisWeekendSelected() {
    if (_selectedDate == null) return false;
    final now = DateTime.now();
    var saturday = now;
    while (saturday.weekday != DateTime.saturday) {
      saturday = saturday.add(const Duration(days: 1));
    }
    return _isSameDay(_selectedDate!, saturday);
  }

  /// Check if next week is currently selected
  bool _isNextWeekSelected() {
    if (_selectedDate == null) return false;
    final now = DateTime.now();
    var monday = now;
    while (monday.weekday != DateTime.monday) {
      monday = monday.add(const Duration(days: 1));
    }
    // If today is Monday, go to next Monday
    if (monday.day == now.day) {
      monday = monday.add(const Duration(days: 7));
    }
    return _isSameDay(_selectedDate!, monday);
  }

  /// Check if no date is currently selected
  bool _isNoDateSelected() {
    return _selectedDate == null;
  }

  /// Build fixed time field at bottom of dialog
  Widget _buildFixedTimeField() {
    return Container(
      margin: const EdgeInsets.only(top: _DatePickerDesign.spacingLarge),
      padding: const EdgeInsets.all(_DatePickerDesign.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_DatePickerDesign.radiusMedium),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: _DatePickerDesign.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getLocalizedText(DateTimePickerTranslationKey.selectTimeTitle, 'Select Time'),
            style: TextStyle(
              fontSize: _DatePickerDesign.fontSizeSmall,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: _DatePickerDesign.spacingSmall),
          GestureDetector(
            onTap: () {
              _openTimeSelectionDialog();
              _triggerHapticFeedback();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: _DatePickerDesign.spacingMedium,
                vertical: _DatePickerDesign.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: _DatePickerDesign.borderWidth,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: _DatePickerDesign.iconSizeMedium,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: _DatePickerDesign.spacingSmall),
                  Text(
                    _selectedDate != null
                        ? _formatTimeForDisplay(_selectedDate!)
                        : _getLocalizedText(DateTimePickerTranslationKey.selectTimeTitle, 'Select Time'),
                    style: TextStyle(
                      fontSize: _DatePickerDesign.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: _selectedDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: _DatePickerDesign.iconSizeSmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Quick selection methods
  void _selectToday() {
    setState(() {
      _selectedDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        _selectedDate?.hour ?? 0,
        _selectedDate?.minute ?? 0,
      );
      // Update validation state - date selection is always valid
      _isSelectionValid = true;
    });
    _triggerHapticFeedback();
  }

  void _selectTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    setState(() {
      _selectedDate = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        _selectedDate?.hour ?? 0,
        _selectedDate?.minute ?? 0,
      );
      // Update validation state - date selection is always valid
      _isSelectionValid = true;
    });
    _triggerHapticFeedback();
  }

  void _selectThisWeekend() {
    final now = DateTime.now();
    var saturday = now;
    while (saturday.weekday != DateTime.saturday) {
      saturday = saturday.add(const Duration(days: 1));
    }
    setState(() {
      _selectedDate = DateTime(
        saturday.year,
        saturday.month,
        saturday.day,
        _selectedDate?.hour ?? 0,
        _selectedDate?.minute ?? 0,
      );
      // Update validation state - date selection is always valid
      _isSelectionValid = true;
    });
    _triggerHapticFeedback();
  }

  void _selectNoDate() {
    setState(() {
      _selectedDate = null;
      // Update validation state - allow null selection if configured
      _isSelectionValid = widget.config.allowNullConfirm || _selectedDate != null;
    });
    _triggerHapticFeedback();
  }

  void _selectQuickRange(QuickDateRange range) {
    if (widget.config.selectionMode != DateSelectionMode.range) return;

    final startDate = range.startDateCalculator();
    final endDate = range.endDateCalculator();

    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;
      _selectedQuickRangeKey = range.key; // Track which quick range was selected
    });
  }

  bool _isQuickRangeSelected(QuickDateRange range) {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;

    final calculatedStart = range.startDateCalculator();
    final calculatedEnd = range.endDateCalculator();

    return _isSameDay(_selectedStartDate!, calculatedStart) && _isSameDay(_selectedEndDate!, calculatedEnd);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  /// Callback for validation state changes from DateValidationDisplay
  void _onValidationStateChanged(bool isValid) {
    if (_isSelectionValid != isValid) {
      setState(() {
        _isSelectionValid = isValid;
      });
    }
  }

  /// Opens time selection dialog for better mobile experience
  Future<void> _openTimeSelectionDialog() async {
    if (_selectedDate == null) return;

    // Use current time or a default time (09:00) if all-day is currently selected
    final initialTime = _isAllDay
        ? const TimeOfDay(hour: 9, minute: 0) // Default to 9:00 AM when switching from all-day
        : TimeOfDay.fromDateTime(_selectedDate!);

    final result = await TimeSelectionDialog.show(
      context: context,
      config: TimeSelectionDialogConfig(
        selectedDate: _selectedDate!,
        initialTime: initialTime,
        translations: widget.config.translations ?? {},
        theme: widget.config.theme,
        locale: widget.config.locale,
        actionButtonRadius: widget.config.actionButtonRadius,
      ),
    );

    if (result != null && result.isConfirmed) {
      final newDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        result.selectedTime.hour,
        result.selectedTime.minute,
      );
      setState(() {
        _selectedDate = newDateTime;
        _isAllDay = false; // Turn off all-day when specific time is selected
      });
      _triggerHapticFeedback();
    }
  }

  /// Opens date selection dialog for better mobile experience
  Future<void> _openDateSelectionDialog() async {
    final result = await DateSelectionDialog.show(
      context: context,
      config: DateSelectionDialogConfig(
        selectionMode: widget.config.selectionMode,
        initialDate: _selectedDate,
        initialStartDate: _selectedStartDate,
        initialEndDate: _selectedEndDate,
        minDate: widget.config.minDate,
        maxDate: widget.config.maxDate,
        translations: widget.config.translations ?? {},
        theme: widget.config.theme,
        locale: widget.config.locale,
        actionButtonRadius: widget.config.actionButtonRadius,
      ),
    );

    if (result != null && result.isConfirmed) {
      if (widget.config.selectionMode == DateSelectionMode.single) {
        if (result.selectedDate != null) {
          setState(() {
            _selectedDate = result.selectedDate;
          });
          _triggerHapticFeedback();
        }
      } else {
        if (result.startDate != null && result.endDate != null) {
          setState(() {
            _selectedStartDate = result.startDate;
            _selectedEndDate = result.endDate;
          });
          _triggerHapticFeedback();
        }
      }
    }
  }

  bool _isValidSelection() {
    return _isSelectionValid;
  }

  bool _hasSelection() {
    if (widget.config.selectionMode == DateSelectionMode.single) {
      return _selectedDate != null;
    }
    return _selectedStartDate != null || _selectedEndDate != null;
  }

  Widget _buildDateValidationDisplay() {
    return DateValidationDisplay(
      selectionMode: widget.config.selectionMode,
      selectedDate: _selectedDate,
      selectedStartDate: _selectedStartDate,
      selectedEndDate: _selectedEndDate,
      minDate: widget.config.minDate,
      maxDate: widget.config.maxDate,
      dateTimeValidator: widget.config.dateTimeValidator,
      validationErrorMessage: widget.config.validationErrorMessage,
      allowNullConfirm: widget.config.allowNullConfirm,
      translations: widget.config.translations ?? {},
      showErrorContainer: true,
      onValidationChanged: _onValidationStateChanged,
    );
  }

  void _onConfirm() {
    if (!_isValidSelection()) return;

    DatePickerResult result;
    if (widget.config.selectionMode == DateSelectionMode.single) {
      if (_selectedDate != null) {
        result = DatePickerResult.single(_selectedDate!,
            isRefreshEnabled: _refreshEnabled, quickSelectionKey: _selectedQuickRangeKey, isAllDay: _isAllDay);
      } else {
        // Date was cleared
        result = DatePickerResult.cleared();
      }
    } else {
      result = DatePickerResult.range(_selectedStartDate!, _selectedEndDate!,
          isRefreshEnabled: _refreshEnabled, quickSelectionKey: _selectedQuickRangeKey);
    }

    Navigator.of(context).pop(result);
  }

  void _onCancel() {
    Navigator.of(context).pop(DatePickerResult.cancelled());
  }

  void _onClear() {
    setState(() {
      if (widget.config.selectionMode == DateSelectionMode.single) {
        _selectedDate = null;
      } else {
        _selectedStartDate = null;
        _selectedEndDate = null;
      }
    });
  }

  void _toggleRefresh() {
    setState(() {
      _refreshEnabled = !_refreshEnabled;
    });
    widget.config.onRefreshToggleChanged?.call(_refreshEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme ?? Theme.of(context);
    final isCompactScreen = _isCompactScreen(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Responsive dialog sizing
    final dialogWidth = _calculateDialogWidth(screenWidth, isCompactScreen);
    final maxDialogHeight = _calculateMaxDialogHeight(screenHeight, isLandscape);

    return Theme(
      data: theme,
      child: AlertDialog(
        titlePadding: EdgeInsets.fromLTRB(
            _DatePickerDesign.spacingXLarge,
            _DatePickerDesign.spacingXLarge,
            _DatePickerDesign.spacingXLarge,
            isCompactScreen ? _DatePickerDesign.spacingMedium : _DatePickerDesign.spacingLarge),
        contentPadding: EdgeInsets.fromLTRB(
            _DatePickerDesign.spacingXLarge, 0.0, _DatePickerDesign.spacingXLarge, _DatePickerDesign.spacingLarge),
        actionsPadding: EdgeInsets.fromLTRB(_DatePickerDesign.spacingMedium, 0.0, _DatePickerDesign.spacingMedium,
            isCompactScreen ? _DatePickerDesign.spacingMedium : _DatePickerDesign.spacingLarge),
        title: Semantics(
          label: _getLocalizedText(
            DateTimePickerTranslationKey.title,
            widget.config.selectionMode == DateSelectionMode.single
                ? _getLocalizedText(DateTimePickerTranslationKey.selectDateTimeTitle, 'Select Date & Time')
                : _getLocalizedText(DateTimePickerTranslationKey.selectDateRangeTitle, 'Select Date Range'),
          ),
          child: Text(
            widget.config.titleText ??
                _getLocalizedText(
                    DateTimePickerTranslationKey.title,
                    widget.config.selectionMode == DateSelectionMode.single
                        ? _getLocalizedText(DateTimePickerTranslationKey.selectDateTimeTitle, 'Select Date & Time')
                        : _getLocalizedText(DateTimePickerTranslationKey.selectDateRangeTitle, 'Select Date Range')),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: isCompactScreen ? _DatePickerDesign.fontSizeLarge : _DatePickerDesign.fontSizeXLarge,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxDialogHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Todoist-style quick selection buttons
                  _buildTodoistQuickSelection(),

                  // Calendar section (always visible)
                  _buildCalendarSection(),

                  // Validation display
                  _buildDateValidationDisplay(),
                ],
              ),
            ),
          ),
        ),
        actions: _buildFooterWithTimeAndActions(isCompactScreen),
      ),
    );
  }

  Widget _buildSimpleDateButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: _DatePickerDesign.spacingLarge,
        vertical: _DatePickerDesign.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_DatePickerDesign.radiusMedium),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: _DatePickerDesign.borderWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openDateSelectionDialog,
          borderRadius: BorderRadius.circular(_DatePickerDesign.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(_DatePickerDesign.spacingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: _DatePickerDesign.iconSizeMedium,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: _DatePickerDesign.spacingSmall),
                    Text(
                      _getLocalizedText(DateTimePickerTranslationKey.selectDateTitle, 'Select Date'),
                      style: TextStyle(
                        fontSize: _DatePickerDesign.fontSizeLarge,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  size: _DatePickerDesign.iconSizeMedium,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTimeButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: _DatePickerDesign.spacingLarge,
        vertical: _DatePickerDesign.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_DatePickerDesign.radiusMedium),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: _DatePickerDesign.borderWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openTimeSelectionDialog,
          borderRadius: BorderRadius.circular(_DatePickerDesign.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(_DatePickerDesign.spacingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: _DatePickerDesign.iconSizeMedium,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: _DatePickerDesign.spacingSmall),
                    Text(
                      _selectedDate != null
                          ? _formatTimeForDisplay(_selectedDate!)
                          : _getLocalizedText(DateTimePickerTranslationKey.selectTimeTitle, 'Select Time'),
                      style: TextStyle(
                        fontSize: _DatePickerDesign.fontSizeLarge,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  size: _DatePickerDesign.iconSizeMedium,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDateDisplay() {
    final isCompactScreen = _isCompactScreen(context);

    if (widget.config.selectionMode == DateSelectionMode.single) {
      // When both date and time selection are enabled, show simple buttons
      if (widget.config.showTime) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: isCompactScreen ? _DatePickerDesign.spacingSmall : _DatePickerDesign.spacingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSimpleDateButton(),
              const SizedBox(height: _DatePickerDesign.spacingMedium),
              _buildSimpleTimeButton(),
            ],
          ),
        );
      } else {
        // When only date selection is enabled, show current selection with calendar
        final displayText = _selectedDate != null
            ? _formatDateForDisplay(_selectedDate)
            : _getLocalizedText(DateTimePickerTranslationKey.noDateSelected, 'No date selected');

        return Padding(
          padding: EdgeInsets.only(
              bottom: isCompactScreen ? _DatePickerDesign.spacingSmall : _DatePickerDesign.spacingMedium),
          child: Container(
            padding: EdgeInsets.all(isCompactScreen ? _DatePickerDesign.spacingMedium : _DatePickerDesign.spacingLarge),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(_DatePickerDesign.radiusMedium),
              border: Border.all(
                color: _selectedDate != null
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: _DatePickerDesign.borderWidth,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event,
                  color: _selectedDate != null ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                  size: isCompactScreen ? _DatePickerDesign.iconSizeMedium : _DatePickerDesign.iconSizeLarge,
                ),
                const SizedBox(width: _DatePickerDesign.spacingSmall),
                Flexible(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: _selectedDate != null ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                      fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                      fontSize: isCompactScreen ? _DatePickerDesign.fontSizeMedium : _DatePickerDesign.fontSizeLarge,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      // For range selection
      String displayText;
      if (_selectedStartDate != null && _selectedEndDate != null) {
        displayText = '${_formatDateForDisplay(_selectedStartDate)} - ${_formatDateForDisplay(_selectedEndDate)}';
      } else if (_selectedStartDate != null) {
        displayText =
            '${_formatDateForDisplay(_selectedStartDate)} - ${_getLocalizedText(DateTimePickerTranslationKey.selectEndDate, 'Select end date')}';
      } else {
        displayText = _getLocalizedText(DateTimePickerTranslationKey.noDatesSelected, 'No dates selected');
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: _DatePickerDesign.spacingMedium),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: _DatePickerDesign.spacingSmall - _DatePickerDesign.spacingXSmall,
          runSpacing: _DatePickerDesign.spacingSmall,
          children: [
            Icon(
              Icons.date_range,
              color: (_selectedStartDate != null && _selectedEndDate != null)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              size: _DatePickerDesign.iconSizeSmall,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _isCompactScreen(context) ? 280 : 350),
              child: Text(
                displayText,
                style: TextStyle(
                  color: (_selectedStartDate != null && _selectedEndDate != null)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  fontWeight:
                      (_selectedStartDate != null && _selectedEndDate != null) ? FontWeight.bold : FontWeight.normal,
                  fontSize: _DatePickerDesign.fontSizeMedium,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildQuickRangeSelector() {
    return QuickRangeSelector(
      quickRanges: widget.config.quickRanges,
      selectedQuickRangeKey: _selectedQuickRangeKey,
      showQuickRanges: widget.config.showQuickRanges,
      showRefreshToggle: widget.config.showRefreshToggle,
      refreshEnabled: _refreshEnabled,
      translations: widget.config.translations ?? {},
      onQuickRangeSelected: _selectQuickRange,
      onRefreshToggle: _toggleRefresh,
      onClear: _onClear,
      hasSelection: _hasSelection(),
      isCompactScreen: _isCompactScreen(context),
      actionButtonRadius: _DatePickerDesign.radiusMedium,
    );
  }

  bool _isCompactScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // Trigger haptic feedback for better mobile experience
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

  // Calculate responsive dialog width based on screen size
  double _calculateDialogWidth(double screenWidth, bool isCompactScreen) {
    if (isCompactScreen) {
      // Use 90% of screen width on small screens, but ensure minimum width
      return (screenWidth * 0.9).clamp(_DatePickerDesign.compactDialogWidth, _DatePickerDesign.maxDialogWidth * 0.8);
    } else {
      // On larger screens, use responsive width with maximum
      return (screenWidth * 0.85)
          .clamp(_DatePickerDesign.maxDialogWidth * 0.7, _DatePickerDesign.maxDialogWidth * 0.85);
    }
  }

  // Calculate maximum dialog height based on screen size and orientation
  double _calculateMaxDialogHeight(double screenHeight, bool isLandscape) {
    if (isLandscape) {
      // In landscape, use 80% of screen height
      return screenHeight * 0.8;
    } else {
      // In portrait, use 70% of screen height or design maximum, whichever is smaller
      return (screenHeight * 0.7)
          .clamp(_DatePickerDesign.maxDialogHeight * 0.5, _DatePickerDesign.maxDialogHeight * 0.75);
    }
  }

  // Build action buttons with mobile-friendly layout
  List<Widget> _buildActionButtons(bool isCompactScreen) {
    if (isCompactScreen) {
      // Vertical layout for compact screens
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _buildMobileActionButton(
            context: context,
            onPressed: _onCancel,
            text: widget.config.cancelButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
            icon: Icons.close,
            isPrimary: false,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _buildMobileActionButton(
            context: context,
            onPressed: _isValidSelection() ? _onConfirm : null,
            text: widget.config.confirmButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
            icon: Icons.check,
            isPrimary: true,
          ),
        ),
      ];
    } else {
      // Horizontal layout for larger screens
      return [
        _buildActionButton(
          context: context,
          onPressed: _onCancel,
          text: widget.config.cancelButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
          icon: Icons.close,
        ),
        _buildActionButton(
          context: context,
          onPressed: _isValidSelection() ? _onConfirm : null,
          text: widget.config.confirmButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
          icon: Icons.check,
          isPrimary: true,
          forceTextButton: true,
        ),
      ];
    }
  }

  /// Check if selected time is at the beginning of the day (All Day)
  bool _isAllDayTime(DateTime date) {
    return date.hour == 0 && date.minute == 0 && date.second == 0;
  }

  /// Build footer with time field and action buttons
  List<Widget> _buildFooterWithTimeAndActions(bool isCompactScreen) {
    final widgets = <Widget>[];

    // Add time field at the top of footer if showTime is enabled
    if (widget.config.showTime) {
      widgets.add(
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            bottom: isCompactScreen ? _DatePickerDesign.spacingMedium : _DatePickerDesign.spacingLarge,
            left: isCompactScreen ? 0 : _DatePickerDesign.spacingMedium,
            right: isCompactScreen ? 0 : _DatePickerDesign.spacingMedium,
          ),
          child: _buildCompactTimeField(),
        ),
      );
    }

    // Add action buttons
    if (isCompactScreen) {
      // Vertical layout for compact screens
      widgets.addAll([
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _buildMobileActionButton(
            context: context,
            onPressed: _onCancel,
            text: widget.config.cancelButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
            icon: Icons.close,
            isPrimary: false,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _buildMobileActionButton(
            context: context,
            onPressed: _isValidSelection() ? _onConfirm : null,
            text: widget.config.confirmButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
            icon: Icons.check,
            isPrimary: true,
          ),
        ),
      ]);
    } else {
      // Horizontal layout for larger screens
      widgets.addAll([
        _buildActionButton(
          context: context,
          onPressed: _onCancel,
          text: widget.config.cancelButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
          icon: Icons.close,
        ),
        _buildActionButton(
          context: context,
          onPressed: _isValidSelection() ? _onConfirm : null,
          text: widget.config.confirmButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
          icon: Icons.check,
          isPrimary: true,
          forceTextButton: true,
        ),
      ]);
    }

    return widgets;
  }

  /// Build compact time field for footer
  Widget _buildCompactTimeField() {
    return Semantics(
      button: true,
      label: _selectedDate != null
          ? _isAllDay
              ? '${_getLocalizedText(DateTimePickerTranslationKey.allDay, 'All Day')}. Tap to change time.'
              : '${_formatTimeForDisplay(_selectedDate!)}. Tap to change time.'
          : '${_getLocalizedText(DateTimePickerTranslationKey.allDay, 'All Day')}. Tap to choose a time.',
      hint: 'Opens time picker dialog',
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
        child: InkWell(
          onTap: () {
            // Toggle all-day state or open time picker
            if (_isAllDay) {
              _openTimeSelectionDialog();
            } else {
              setState(() {
                _isAllDay = true;
                // Set time to 00:00 when switching to all-day
                if (_selectedDate != null) {
                  _selectedDate = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    0,
                    0,
                    0,
                  );
                }
              });
              _triggerHapticFeedback();
            }
          },
          borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
          child: Container(
            height: 40, // Compact fixed height
            padding: const EdgeInsets.symmetric(
              horizontal: _DatePickerDesign.spacingSmall,
              vertical: _DatePickerDesign.spacingXSmall,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: _DatePickerDesign.borderWidth,
              ),
              borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16, // Smaller icon for compact design
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: _DatePickerDesign.spacingXSmall),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? _isAllDay
                            ? _getLocalizedText(DateTimePickerTranslationKey.allDay, 'All Day')
                            : _formatTimeForDisplay(_selectedDate!)
                        : _getLocalizedText(DateTimePickerTranslationKey.allDay, 'All Day'),
                    style: TextStyle(
                      fontSize: _DatePickerDesign.fontSizeSmall, // Smaller font
                      fontWeight: FontWeight.w500,
                      color: _selectedDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: _DatePickerDesign.spacingXSmall),
                Icon(
                  Icons.chevron_right,
                  size: 14, // Smaller chevron
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build mobile-friendly action button with proper touch targets
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.config.actionButtonRadius ?? _DatePickerDesign.radiusSmall),
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
            borderRadius: BorderRadius.circular(widget.config.actionButtonRadius ?? _DatePickerDesign.radiusSmall),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: _DatePickerDesign.iconSizeMedium,
                    color: isPrimary
                        ? Theme.of(context).colorScheme.onPrimary
                        : onPressed != null
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  const SizedBox(width: _DatePickerDesign.spacingSmall),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: _DatePickerDesign.fontSizeMedium,
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

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
    bool isPrimary = false,
    bool forceTextButton = false,
  }) {
    final isCompact = _isCompactScreen(context);

    if (forceTextButton || !isCompact) {
      return TextButton(
        onPressed: onPressed,
        style: isPrimary
            ? TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              )
            : null,
        child: Text(text),
      );
    } else {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        tooltip: text,
        iconSize: 18,
        style: IconButton.styleFrom(
          foregroundColor: isPrimary ? Theme.of(context).primaryColor : null,
          padding: const EdgeInsets.all(_DatePickerDesign.spacingSmall),
        ),
      );
    }
  }

  Widget _buildCalendarSection() {
    return custom.CalendarDatePicker(
      selectionMode: widget.config.selectionMode,
      selectedDate: _selectedDate,
      selectedStartDate: _selectedStartDate,
      selectedEndDate: _selectedEndDate,
      minDate: widget.config.minDate,
      maxDate: widget.config.maxDate,
      showTime: false, // Disable time picker in calendar - we handle time in footer
      onUserHasSelectedQuickRangeChanged: () {
        setState(() {
          _selectedQuickRangeKey = null;
        });
      },
      onSingleDateSelected: (DateTime? date) {
        setState(() {
          _selectedDate = date;
          // Update validation state when date is selected from calendar
          _isSelectionValid = date != null || widget.config.allowNullConfirm;
        });
      },
      onRangeSelected: (DateTime? startDate, DateTime? endDate) {
        setState(() {
          _selectedStartDate = startDate;
          _selectedEndDate = endDate;
          // Update validation state when date range is selected from calendar
          _isSelectionValid = (startDate != null && endDate != null) || widget.config.allowNullConfirm;
        });
      },
      translations: widget.config.translations ?? {},
    );
  }
}
