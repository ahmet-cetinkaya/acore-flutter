import 'package:flutter/material.dart';
import '../../time/date_format_service.dart';
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';
import 'calendar_date_picker.dart' as custom;
import 'time_selection_dialog.dart';
import 'quick_range_selector.dart' as quick;
import 'date_validation_display.dart';
import '../../utils/time_formatting_util.dart';
import '../../utils/haptic_feedback_util.dart';
import '../../utils/dialog_size.dart';

/// Design constants for date picker
class _DatePickerDesign {
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;

  // Border radius
  static const double radiusSmall = 8.0;

  // Font sizes
  static const double fontSizeMedium = 16.0;

  // Border width
  static const double borderWidth = 1.0;
}

/// Common constants shared across date picker components
class _DatePickerConstants {
  // Weekday translation keys - consistently ordered (Mon-Sun)
  static const List<DateTimePickerTranslationKey> weekdayKeys = [
    DateTimePickerTranslationKey.weekdayMonShort,
    DateTimePickerTranslationKey.weekdayTueShort,
    DateTimePickerTranslationKey.weekdayWedShort,
    DateTimePickerTranslationKey.weekdayThuShort,
    DateTimePickerTranslationKey.weekdayFriShort,
    DateTimePickerTranslationKey.weekdaySatShort,
    DateTimePickerTranslationKey.weekdaySunShort,
  ];
}

/// Configuration for the date picker content component
class DatePickerContentConfig {
  final DateSelectionMode selectionMode;
  final DateTime? initialDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateFormatType formatType;
  final String? titleText;
  final List<quick.QuickDateRange>? quickRanges;
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
  final DateTime? Function(DateTime?)? dateTimeValidator;
  final String? validationErrorMessage;
  final double? actionButtonRadius;
  final void Function(DatePickerContentResult)? onSelectionChanged;
  final bool validationErrorAtTop;

  const DatePickerContentConfig({
    required this.selectionMode,
    this.initialDate,
    this.initialStartDate,
    this.initialEndDate,
    this.minDate,
    this.maxDate,
    this.formatType = DateFormatType.date,
    this.titleText,
    this.quickRanges,
    this.showTime = false,
    this.showQuickRanges = false,
    this.enableManualInput = true,
    this.dateFormatHint,
    this.theme,
    this.locale,
    this.translations,
    this.allowNullConfirm = true,
    this.showRefreshToggle = false,
    this.initialRefreshEnabled = false,
    this.onRefreshToggleChanged,
    this.dateTimeValidator,
    this.validationErrorMessage,
    this.actionButtonRadius,
    this.onSelectionChanged,
    this.validationErrorAtTop = false,
  });
}

/// Result returned from the date picker content
class DatePickerContentResult {
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isRefreshEnabled;
  final String? quickSelectionKey;
  final bool isAllDay;

  const DatePickerContentResult({
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.isRefreshEnabled,
    this.quickSelectionKey,
    this.isAllDay = false,
  });

  factory DatePickerContentResult.single(DateTime date,
      {bool? isRefreshEnabled, String? quickSelectionKey, bool isAllDay = false}) {
    return DatePickerContentResult(
      selectedDate: date,
      isRefreshEnabled: isRefreshEnabled,
      quickSelectionKey: quickSelectionKey,
      isAllDay: isAllDay,
    );
  }

  factory DatePickerContentResult.range(DateTime startDate, DateTime endDate,
      {bool? isRefreshEnabled, String? quickSelectionKey}) {
    return DatePickerContentResult(
      startDate: startDate,
      endDate: endDate,
      isRefreshEnabled: isRefreshEnabled,
      quickSelectionKey: quickSelectionKey,
    );
  }

  factory DatePickerContentResult.cleared() {
    return const DatePickerContentResult(
      selectedDate: null,
    );
  }
}

/// A clean date picker content component that can be used in dialogs or as standalone content
class DatePickerContent extends StatefulWidget {
  final DatePickerContentConfig config;
  final VoidCallback? onCancel;
  final void Function(DatePickerContentResult?)? onComplete;

  const DatePickerContent({
    super.key,
    required this.config,
    this.onCancel,
    this.onComplete,
  });

  @override
  State<DatePickerContent> createState() => _DatePickerContentState();
}

class _DatePickerContentState extends State<DatePickerContent> {
  // Note: This state class is large (800+ lines) and handles multiple responsibilities.
  // Consider refactoring into smaller focused widgets for better maintainability:
  // - QuickSelectionWidget (for quick range selection UI)
  // - DateRangeValidationWidget (for range validation logic)
  // - TimeSelectionWidget (for time-related functionality)

  late DateTime? _selectedDate;
  late DateTime? _selectedStartDate;
  late DateTime? _selectedEndDate;
  late bool _refreshEnabled;

  // All day state tracking
  bool _isAllDay = true;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _initializeQuickSelectionState();
  }

  @override
  void dispose() {
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
          // Found matching quick range, could track selection state here if needed
          break;
        }
      }
    }
  }

  /// Format time for display using MaterialLocalizations
  String _formatTimeForDisplay(DateTime dateTime) {
    return TimeFormattingUtil.formatDateTimeTime(context, dateTime);
  }

  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations?[key] ?? fallback;
  }

  /// Get the current day of week abbreviation (Mon, Tue, etc.)
  String _getDayOfWeek() {
    final now = DateTime.now();
    return _getLocalizedText(_DatePickerConstants.weekdayKeys[now.weekday - 1], 'Mon');
  }

  /// Get tomorrow's day of week abbreviation
  String _getTomorrowDayOfWeek() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _getLocalizedText(_DatePickerConstants.weekdayKeys[tomorrow.weekday - 1], 'Tue');
  }

  /// Get next week's day of week abbreviation (next Monday)
  String _getNextWeekDayOfWeek() {
    final now = DateTime.now();
    // Calculate days until next Monday (where Monday is 1)
    // If today is Monday (1), we want next Monday, not today: (8 - 1) = 7 days
    // If today is Tuesday (2), we want next Monday: (8 - 2) = 6 days
    // If today is Sunday (7), we want next Monday: (8 - 7) = 1 day
    final daysUntilNextMonday = now.weekday == DateTime.monday ? 7 : (8 - now.weekday);
    final nextMonday = now.add(Duration(days: daysUntilNextMonday));

    return _getLocalizedText(_DatePickerConstants.weekdayKeys[nextMonday.weekday - 1], 'Mon');
  }

  /// Get the weekend day of week abbreviation (Saturday)
  String _getWeekendDayOfWeek() {
    final now = DateTime.now();
    // Find the next Saturday
    DateTime saturday = now;
    while (saturday.weekday != DateTime.saturday) {
      saturday = saturday.add(const Duration(days: 1));
    }
    return _getLocalizedText(_DatePickerConstants.weekdayKeys[saturday.weekday - 1], 'Sat');
  }

  /// Build compact Todoist-style quick selection with vertical layout
  Widget _buildTodoistQuickSelection() {
    // Show different buttons based on selection mode
    final isRangeMode = widget.config.selectionMode == DateSelectionMode.range;

    return Container(
      margin: const EdgeInsets.only(bottom: _DatePickerDesign.spacingMedium),
      child: Column(
        children: [
          if (isRangeMode) ...[
            // Range selection buttons
            _buildCompactQuickSelectionButton(
              text: _getDayOfWeek(),
              onTap: () => _selectRangeToday(),
              type: 'today',
              isSelected: _isRangeTodaySelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionToday, 'Today'),
            ),
            SizedBox(height: _DatePickerDesign.spacingXSmall),
            _buildCompactQuickSelectionButton(
              text: '7',
              onTap: () => _select7DaysAgo(),
              type: 'weekend',
              isSelected: _is7DaysAgoSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionLastWeek, 'Last Week'),
            ),
            SizedBox(height: _DatePickerDesign.spacingXSmall),
            _buildCompactQuickSelectionButton(
              text: '30',
              onTap: () => _select30DaysAgo(),
              type: 'noDate',
              isSelected: _is30DaysAgoSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionLastMonth, 'Last Month'),
            ),
            SizedBox(height: _DatePickerDesign.spacingXSmall),
            _buildCompactQuickSelectionButton(
              text: 'x',
              icon: Icons.close,
              onTap: () => _selectNoDateRange(),
              type: 'tomorrow',
              isSelected: _isNoDateRangeSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionNoDate, 'No Date'),
            ),

            // Refresh checkbox for range selection (only show when date is selected)
            if (!_isNoDateRangeSelected()) ...[
              SizedBox(height: _DatePickerDesign.spacingXSmall),
              _buildCompactQuickSelectionButton(
                text: _refreshEnabled ? '✓' : '↻',
                icon: Icons.autorenew,
                onTap: () {
                  setState(() {
                    _refreshEnabled = !_refreshEnabled;
                  });
                  widget.config.onRefreshToggleChanged?.call(_refreshEnabled);
                  _triggerHapticFeedback();
                },
                type: 'today',
                isSelected: _refreshEnabled,
                label: _getLocalizedText(DateTimePickerTranslationKey.refreshSettings, 'Auto-refresh'),
              ),
            ],
          ] else ...[
            // Single date selection buttons
            if (widget.config.quickRanges != null && widget.config.quickRanges!.isNotEmpty)
              ...widget.config.quickRanges!.where((range) {
                // Filter out ranges before minDate
                if (widget.config.minDate != null) {
                  final startDate = range.startDateCalculator();
                  // Reset time to start of day for comparison
                  final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
                  final minDateStartOfDay =
                      DateTime(widget.config.minDate!.year, widget.config.minDate!.month, widget.config.minDate!.day);

                  if (startOfDay.isBefore(minDateStartOfDay)) {
                    return false;
                  }
                }
                return true;
              }).map((range) {
                return _buildCompactQuickSelectionButton(
                  text: _getShortLabelForRange(range),
                  icon: _getIconForRange(range),
                  onTap: () => _selectQuickRange(range),
                  type: range.key,
                  isSelected: _isQuickSingleSelected(range),
                  label: range.label,
                );
              })
            else ...[
              _buildCompactQuickSelectionButton(
                text: _getDayOfWeek(),
                onTap: () => _selectToday(),
                type: 'today',
                isSelected: _isTodaySelected(),
                label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionToday, 'Today'),
              ),
              _buildCompactQuickSelectionButton(
                text: _getTomorrowDayOfWeek(),
                onTap: () => _selectTomorrow(),
                type: 'tomorrow',
                isSelected: _isTomorrowSelected(),
                label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionTomorrow, 'Tomorrow'),
              ),
              _buildCompactQuickSelectionButton(
                text: _getWeekendDayOfWeek(),
                icon: Icons.weekend,
                onTap: () => _selectThisWeekend(),
                type: 'weekend',
                isSelected: _isThisWeekendSelected(),
                label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionWeekend, 'Weekend'),
              ),
              _buildCompactQuickSelectionButton(
                text: _getNextWeekDayOfWeek(),
                icon: Icons.arrow_forward,
                onTap: () => _selectNextWeek(),
                type: 'nextWeek',
                isSelected: _isNextWeekSelected(),
                label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionNextWeek, 'Next Week'),
              ),
              _buildCompactQuickSelectionButton(
                text: 'x',
                icon: Icons.close,
                onTap: () => _selectNoDate(),
                type: 'noDate',
                isSelected: _isNoDateSelected(),
                label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionNoDate, 'No Date'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Build compact quick selection button for vertical layout
  Widget _buildCompactQuickSelectionButton({
    required String text,
    required VoidCallback onTap,
    required String type,
    bool isSelected = false,
    IconData? icon,
    String? label,
  }) {
    return Ink(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : _DatePickerDesign.borderWidth,
          ),
        ),
        child: InkWell(
            onTap: () {
              onTap();
              _triggerHapticFeedback();
            },
            borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
            child: Container(
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.symmetric(
                horizontal: _DatePickerDesign.spacingMedium,
                vertical: _DatePickerDesign.spacingSmall,
              ),
              child: Row(
                children: [
                  // Left icon or number with container styling
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                          : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
                    ),
                    child: Center(
                      child: icon != null
                          ? Icon(
                              icon,
                              size: 16,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            )
                          : Text(
                              text,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(width: _DatePickerDesign.spacingSmall),
                  // Right text
                  Expanded(
                    child: Text(
                      label ?? text,
                      style: TextStyle(
                        fontSize: _DatePickerDesign.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )));
  }

  // Quick selection methods
  void _selectToday() {
    setState(() {
      _selectedDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        _selectedDate?.hour ?? 0,
        _selectedDate?.minute ?? 0,
      );
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
    });
    _triggerHapticFeedback();
  }

  void _selectThisWeekend() {
    final now = DateTime.now();
    // Find the Saturday of the current week. If today is Sunday, it should find the *next* Saturday.
    int daysUntilSaturday = DateTime.saturday - now.weekday;
    if (daysUntilSaturday < 0) {
      daysUntilSaturday += 7;
    }
    var saturday = now.add(Duration(days: daysUntilSaturday));
    setState(() {
      _selectedDate = DateTime(
        saturday.year,
        saturday.month,
        saturday.day,
        _selectedDate?.hour ?? 0,
        _selectedDate?.minute ?? 0,
      );
    });
    _triggerHapticFeedback();
  }

  void _selectNoDate() {
    setState(() {
      _selectedDate = null;
    });
    _triggerHapticFeedback();
  }

  void _selectNextWeek() {
    final now = DateTime.now();
    // Calculate days until next Monday (where Monday is 1)
    // If today is Monday (1), we want next Monday, not today: (8 - 1) = 7 days
    // If today is Tuesday (2), we want next Monday: (8 - 2) = 6 days
    // If today is Sunday (7), we want next Monday: (8 - 7) = 1 day
    final daysUntilNextMonday = now.weekday == DateTime.monday ? 7 : (8 - now.weekday);
    final nextMonday = now.add(Duration(days: daysUntilNextMonday));

    setState(() {
      _selectedDate = DateTime(
        nextMonday.year,
        nextMonday.month,
        nextMonday.day,
        _selectedDate?.hour ?? 0,
        _selectedDate?.minute ?? 0,
      );
    });
    _triggerHapticFeedback();
  }

  // Range selection methods
  void _selectRangeToday() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    setState(() {
      _selectedStartDate = todayStart;
      _selectedEndDate = todayEnd;
    });
    _triggerHapticFeedback();
  }

  void _select7DaysAgo() {
    final now = DateTime.now();
    // Get the last 7 days (from 7 days ago up to yesterday)
    final endDate = now.subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 7));

    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    setState(() {
      _selectedStartDate = rangeStart;
      _selectedEndDate = rangeEnd;
    });
    _triggerHapticFeedback();
  }

  void _select30DaysAgo() {
    final now = DateTime.now();
    // Get the last 30 days (from 30 days ago to yesterday)
    final endDate = now.subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 30));

    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    setState(() {
      _selectedStartDate = rangeStart;
      _selectedEndDate = rangeEnd;
    });
    _triggerHapticFeedback();
  }

  void _selectNoDateRange() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
    _triggerHapticFeedback();
  }

  // Helper methods
  bool _isTodaySelected() {
    if (_selectedDate == null) return false;
    final now = DateTime.now();
    return _isSameDay(_selectedDate!, now);
  }

  bool _isTomorrowSelected() {
    if (_selectedDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _isSameDay(_selectedDate!, tomorrow);
  }

  bool _isThisWeekendSelected() {
    if (_selectedDate == null) return false;
    final now = DateTime.now();
    DateTime saturday = now;
    while (saturday.weekday != DateTime.saturday) {
      saturday = saturday.add(const Duration(days: 1));
    }
    return _isSameDay(_selectedDate!, saturday);
  }

  bool _isNoDateSelected() {
    return _selectedDate == null;
  }

  bool _isNextWeekSelected() {
    if (_selectedDate == null) return false;
    final now = DateTime.now();
    // Get next Monday. If today is Monday, it will be 7 days from now.
    final daysUntilNextMonday = now.weekday == DateTime.monday ? 7 : (8 - now.weekday);
    final nextMonday = now.add(Duration(days: daysUntilNextMonday));
    return _isSameDay(_selectedDate!, nextMonday);
  }

  bool _isNoDateRangeSelected() {
    return _selectedStartDate == null && _selectedEndDate == null;
  }

  bool _isRangeTodaySelected() {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _isSameDay(_selectedStartDate!, todayStart) && _isSameDay(_selectedEndDate!, todayEnd);
  }

  bool _is7DaysAgoSelected() {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;

    final now = DateTime.now();
    // Get the expected range (last 7 days from 7 days ago to yesterday)
    final endDate = now.subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 7));

    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return _isSameDay(_selectedStartDate!, rangeStart) && _isSameDay(_selectedEndDate!, rangeEnd);
  }

  bool _is30DaysAgoSelected() {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;

    final now = DateTime.now();
    // Get the expected range (last 30 days from 30 days ago to yesterday)
    final endDate = now.subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 30));

    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return _isSameDay(_selectedStartDate!, rangeStart) && _isSameDay(_selectedEndDate!, rangeEnd);
  }

  bool _isQuickRangeSelected(quick.QuickDateRange range) {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;

    final calculatedStart = range.startDateCalculator();
    final calculatedEnd = range.endDateCalculator();

    return _isSameDay(_selectedStartDate!, calculatedStart) && _isSameDay(_selectedEndDate!, calculatedEnd);
  }

  bool _isQuickSingleSelected(quick.QuickDateRange range) {
    if (_selectedDate == null) return false;
    final date = range.startDateCalculator();
    return _isSameDay(_selectedDate!, date);
  }

  void _selectQuickRange(quick.QuickDateRange range) {
    final date = range.startDateCalculator();
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedDate?.hour ?? 0,
        _selectedDate?.minute ?? 0,
      );
    });
    _triggerHapticFeedback();
  }

  String _getShortLabelForRange(quick.QuickDateRange range) {
    switch (range.key) {
      case 'today':
        return _getDayOfWeek();
      case 'tomorrow':
        return _getTomorrowDayOfWeek();
      case 'next_week':
        return _getNextWeekDayOfWeek();
      case 'weekend':
        return _getWeekendDayOfWeek();
      default:
        return range.label.isNotEmpty ? range.label.substring(0, 1).toUpperCase() : '';
    }
  }

  IconData? _getIconForRange(quick.QuickDateRange range) {
    switch (range.key) {
      case 'weekend':
        return Icons.weekend;
      case 'next_week':
        return Icons.arrow_forward;
      case 'no_date':
      case 'clear':
        return Icons.close;
      default:
        return null;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  /// Callback for validation state changes from DateValidationDisplay
  void _onValidationStateChanged(bool isValid) {
    setState(() {});
  }

  /// Opens time selection dialog for better mobile experience
  Future<void> _openTimeSelectionDialog() async {
    if (_selectedDate == null) return;

    // Use current time or a default time (09:00) if all-day is currently selected
    final initialTime = _isAllDay ? const TimeOfDay(hour: 9, minute: 0) : TimeOfDay.fromDateTime(_selectedDate!);

    final result = await TimeSelectionDialog.showResponsive(
      context: context,
      config: TimeSelectionDialogConfig(
        selectedDate: _selectedDate!,
        initialTime: initialTime,
        translations: widget.config.translations ?? {},
        theme: widget.config.theme,
        locale: widget.config.locale,
        actionButtonRadius: widget.config.actionButtonRadius,
        initialIsAllDay: _isAllDay,
        useMobileScaffoldLayout: true,
        hideTitle: true,
        dialogSize: DialogSize.medium,
      ),
    );

    if (result != null && result.isConfirmed) {
      final newDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        result.isAllDay ? 0 : result.selectedTime.hour,
        result.isAllDay ? 0 : result.selectedTime.minute,
      );
      setState(() {
        _selectedDate = newDateTime;
        _isAllDay = result.isAllDay;
      });
      _triggerHapticFeedback(); // This also calls _notifySelectionChanged
    }
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
        child: InkWell(
          onTap: () {
            _openTimeSelectionDialog();
          },
          borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
          splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          child: Container(
            height: 40,
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
                  size: 16,
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
                      fontSize: _DatePickerDesign.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: _selectedDate != null
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: _DatePickerDesign.spacingXSmall),
                Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return custom.CalendarDatePicker(
      selectionMode: widget.config.selectionMode,
      selectedDate: _selectedDate,
      selectedStartDate: _selectedStartDate,
      selectedEndDate: _selectedEndDate,
      minDate: widget.config.minDate,
      maxDate: widget.config.maxDate,
      showTime: false,
      onUserHasSelectedQuickRangeChanged: () {
        setState(() {});
      },
      onSingleDateSelected: (DateTime? date) {
        setState(() {
          _selectedDate = date;
        });
        _notifySelectionChanged();
      },
      onRangeSelected: (DateTime? startDate, DateTime? endDate) {
        setState(() {
          _selectedStartDate = startDate;
          _selectedEndDate = endDate;
        });
        _notifySelectionChanged();
      },
      translations: widget.config.translations ?? {},
    );
  }

  /// Check if selected time is at the beginning of the day (All Day)
  bool _isAllDayTime(DateTime date) {
    return date.hour == 0 && date.minute == 0 && date.second == 0;
  }

  /// Notify parent about selection change
  void _notifySelectionChanged() {
    if (widget.config.onSelectionChanged != null) {
      final result = DatePickerContentResult(
        selectedDate: _selectedDate,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        isRefreshEnabled: _refreshEnabled,
        isAllDay: _isAllDay,
      );
      widget.config.onSelectionChanged!(result);
    }
  }

  /// Trigger haptic feedback for better mobile experience
  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
    _notifySelectionChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme ?? Theme.of(context);

    return Theme(
      data: theme,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Validation display (always at top)
                  _buildDateValidationDisplay(),
                  SizedBox(height: _DatePickerDesign.spacingMedium),

                  // Todoist-style quick selection buttons
                  _buildTodoistQuickSelection(),

                  // Calendar section (always visible)
                  _buildCalendarSection(),

                  // Add spacing for time field if showTime is enabled
                  if (widget.config.showTime) SizedBox(height: _DatePickerDesign.spacingMedium),
                ],
              ),
            ),
          ),

          // Fixed bottom time field
          if (widget.config.showTime)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: _DatePickerDesign.spacingMedium,
                vertical: _DatePickerDesign.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
              ),
              child: _buildCompactTimeField(),
            ),
        ],
      ),
    );
  }
}
