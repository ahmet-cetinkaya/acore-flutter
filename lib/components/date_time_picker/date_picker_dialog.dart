import 'package:flutter/material.dart';
import 'dart:async';
import '../../time/date_format_service.dart';
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';
import 'calendar_date_picker.dart' as custom;
import 'time_selection_dialog.dart';
import 'quick_range_selector.dart';
import 'date_validation_display.dart';
import '../mobile_action_button.dart';
import '../../utils/time_formatting_util.dart';
import '../../utils/haptic_feedback_util.dart';

/// Enum for quick selection button types
enum QuickSelectionType {
  today,
  tomorrow,
  weekend,
  noDate,
  nextWeek,
}

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

  // Font sizes
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;

  // Icon sizes

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

  factory DatePickerResult.single(DateTime date,
      {bool? isRefreshEnabled, String? quickSelectionKey, bool isAllDay = false}) {
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
          _selectedQuickRangeKey = range.key;
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
    final days = [
      DateTimePickerTranslationKey.weekdayMonShort,
      DateTimePickerTranslationKey.weekdayTueShort,
      DateTimePickerTranslationKey.weekdayWedShort,
      DateTimePickerTranslationKey.weekdayThuShort,
      DateTimePickerTranslationKey.weekdayFriShort,
      DateTimePickerTranslationKey.weekdaySatShort,
      DateTimePickerTranslationKey.weekdaySunShort,
    ];
    return _getLocalizedText(days[now.weekday - 1], 'Mon');
  }

  /// Get tomorrow's day of week abbreviation
  String _getTomorrowDayOfWeek() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final days = [
      DateTimePickerTranslationKey.weekdayMonShort,
      DateTimePickerTranslationKey.weekdayTueShort,
      DateTimePickerTranslationKey.weekdayWedShort,
      DateTimePickerTranslationKey.weekdayThuShort,
      DateTimePickerTranslationKey.weekdayFriShort,
      DateTimePickerTranslationKey.weekdaySatShort,
      DateTimePickerTranslationKey.weekdaySunShort,
    ];
    return _getLocalizedText(days[tomorrow.weekday - 1], 'Tue');
  }

  /// Get next week's day of week abbreviation (next Monday)
  String _getNextWeekDayOfWeek() {
    final now = DateTime.now();
    final daysUntilNextMonday = (7 - now.weekday + 1) % 7 + 1;
    final nextMonday = now.add(Duration(days: daysUntilNextMonday));

    final days = [
      DateTimePickerTranslationKey.weekdayMonShort,
      DateTimePickerTranslationKey.weekdayTueShort,
      DateTimePickerTranslationKey.weekdayWedShort,
      DateTimePickerTranslationKey.weekdayThuShort,
      DateTimePickerTranslationKey.weekdayFriShort,
      DateTimePickerTranslationKey.weekdaySatShort,
      DateTimePickerTranslationKey.weekdaySunShort,
    ];
    return _getLocalizedText(days[nextMonday.weekday - 1], 'Mon');
  }

  /// Get the weekend day of week abbreviation (Saturday)
  String _getWeekendDayOfWeek() {
    final now = DateTime.now();
    final days = [
      DateTimePickerTranslationKey.weekdayMonShort,
      DateTimePickerTranslationKey.weekdayTueShort,
      DateTimePickerTranslationKey.weekdayWedShort,
      DateTimePickerTranslationKey.weekdayThuShort,
      DateTimePickerTranslationKey.weekdayFriShort,
      DateTimePickerTranslationKey.weekdaySatShort,
      DateTimePickerTranslationKey.weekdaySunShort,
    ];

    // Find the next Saturday
    var saturday = now;
    while (saturday.weekday != DateTime.saturday) {
      saturday = saturday.add(const Duration(days: 1));
    }
    return _getLocalizedText(days[saturday.weekday - 1], 'Sat');
  }

  /// Build compact Todoist-style quick selection with vertical layout
  Widget _buildTodoistQuickSelection() {
    // Show different buttons based on selection mode
    final isRangeMode = widget.config.selectionMode == DateSelectionMode.range;

    return Container(
      margin: const EdgeInsets.only(bottom: _DatePickerDesign.spacingMedium),
      child: Column(
        spacing: _DatePickerDesign.spacingXSmall, // Reduced spacing between quick selection buttons
        children: [
          if (isRangeMode) ...[
            // Range selection buttons
            _buildCompactQuickSelectionButton(
              text: _getDayOfWeek(),
              onTap: () => _selectRangeToday(),
              type: QuickSelectionType.today,
              isSelected: _isRangeTodaySelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionToday, 'Today'),
            ),
            _buildCompactQuickSelectionButton(
              text: '7',
              onTap: () => _select7DaysAgo(),
              type: QuickSelectionType.weekend, // Reusing enum for 7 days ago
              isSelected: _is7DaysAgoSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionLastWeek, 'Last Week'),
            ),
            _buildCompactQuickSelectionButton(
              text: '30',
              onTap: () => _select30DaysAgo(),
              type: QuickSelectionType.noDate, // Reusing enum for 30 days ago
              isSelected: _is30DaysAgoSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionLastMonth, 'Last Month'),
            ),
            _buildCompactQuickSelectionButton(
              text: 'x',
              icon: Icons.close,
              onTap: () => _selectNoDateRange(),
              type: QuickSelectionType.tomorrow, // Reusing enum for no date
              isSelected: _isNoDateRangeSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionNoDate, 'No Date'),
            ),

            // Refresh checkbox for range selection (only show when date is selected)
            if (!_isNoDateRangeSelected())
              _buildCompactQuickSelectionButton(
                text: _refreshEnabled ? '✓' : '↻',
                icon: Icons.autorenew, // Always show refresh icon
                onTap: () {
                  setState(() {
                    _refreshEnabled = !_refreshEnabled;
                  });
                  widget.config.onRefreshToggleChanged?.call(_refreshEnabled);
                  _triggerHapticFeedback();
                },
                type: QuickSelectionType.today, // Reusing enum for refresh
                isSelected: _refreshEnabled,
                label: _getLocalizedText(DateTimePickerTranslationKey.refreshSettings, 'Auto-refresh'),
              ),
          ] else ...[
            // Single date selection buttons
            _buildCompactQuickSelectionButton(
              text: _getDayOfWeek(),
              onTap: () => _selectToday(),
              type: QuickSelectionType.today,
              isSelected: _isTodaySelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionToday, 'Today'),
            ),
            _buildCompactQuickSelectionButton(
              text: _getTomorrowDayOfWeek(),
              onTap: () => _selectTomorrow(),
              type: QuickSelectionType.tomorrow,
              isSelected: _isTomorrowSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionTomorrow, 'Tomorrow'),
            ),
            _buildCompactQuickSelectionButton(
              text: _getWeekendDayOfWeek(),
              icon: Icons.weekend,
              onTap: () => _selectThisWeekend(),
              type: QuickSelectionType.weekend,
              isSelected: _isThisWeekendSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionWeekend, 'Weekend'),
            ),
            _buildCompactQuickSelectionButton(
              text: _getNextWeekDayOfWeek(),
              icon: Icons.arrow_forward,
              onTap: () => _selectNextWeek(),
              type: QuickSelectionType.nextWeek,
              isSelected: _isNextWeekSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionNextWeek, 'Next Week'),
            ),
            _buildCompactQuickSelectionButton(
              text: 'x',
              icon: Icons.close,
              onTap: () => _selectNoDate(),
              type: QuickSelectionType.noDate,
              isSelected: _isNoDateSelected(),
              label: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionNoDate, 'No Date'),
            ),
          ],
        ],
      ),
    );
  }

  /// Build compact quick selection button for vertical layout
  Widget _buildCompactQuickSelectionButton({
    required String text,
    required VoidCallback onTap,
    required QuickSelectionType type,
    bool isSelected = false,
    IconData? icon,
    String? label,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        _triggerHapticFeedback();
      },
      child: Container(
        width: double.infinity, // Full width for vertical layout
        height: 44, // Slightly increased height for better touch targets
        padding: const EdgeInsets.symmetric(
          horizontal: _DatePickerDesign.spacingMedium,
          vertical: _DatePickerDesign.spacingSmall,
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
          children: [
            // Left icon or number with container styling
            Container(
              width: 28, // Slightly larger for better visibility
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
                label ?? text, // Use label if provided, otherwise use text
                style: TextStyle(
                  fontSize: _DatePickerDesign.fontSizeMedium,
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

  /// Get short day name for quick selection buttons using proper localization

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

  /// Check if no date is currently selected
  bool _isNoDateSelected() {
    return _selectedDate == null;
  }

  /// Build fixed time field at bottom of dialog

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
    // Find the Saturday of the current week
    // DateTime.weekday: Monday=1, Tuesday=2, ..., Saturday=6, Sunday=7
    var saturday = now.add(Duration(days: DateTime.saturday - now.weekday));
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
      // Update validation state - allow null selection if configured
    });
    _triggerHapticFeedback();
  }

  /// Range selection methods for date-time range mode
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

  /// Check if today range is currently selected
  bool _isRangeTodaySelected() {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _isSameDay(_selectedStartDate!, todayStart) && _isSameDay(_selectedEndDate!, todayEnd);
  }

  /// Additional range selection methods
  void _select7DaysAgo() {
    final now = DateTime.now();
    // Get the last 7 days (from 7 days ago to yesterday)
    final endDate = now.subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 7));

    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    setState(() {
      _selectedStartDate = rangeStart;
      _selectedEndDate = rangeEnd;
      // Track which quick range was selected
      _selectedQuickRangeKey = 'last_week';
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
      // Track which quick range was selected
      _selectedQuickRangeKey = 'last_month';
    });
    _triggerHapticFeedback();
  }

  void _selectNextWeek() {
    final now = DateTime.now();
    // Get next Monday
    final daysUntilNextMonday = (7 - now.weekday + 1) % 7 + 1;
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

  void _selectNoDateRange() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      // Update validation state - allow null selection if configured
    });
    _triggerHapticFeedback();
  }

  /// Check if last 7 days is currently selected
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

  /// Check if last 30 days is currently selected
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

  /// Check if next week is currently selected
  bool _isNextWeekSelected() {
    if (_selectedDate == null) return false;

    final now = DateTime.now();
    // Get next Monday
    final daysUntilNextMonday = (7 - now.weekday + 1) % 7 + 1;
    final nextMonday = now.add(Duration(days: daysUntilNextMonday));

    return _isSameDay(_selectedDate!, nextMonday);
  }

  /// Check if no date range is currently selected
  bool _isNoDateRangeSelected() {
    return _selectedStartDate == null && _selectedEndDate == null;
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
    // Validation state is managed exclusively by DateValidationDisplay
    setState(() {
      _isSelectionValid = isValid;
    });
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
        initialIsAllDay: _isAllDay,
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
      _triggerHapticFeedback();
    }
  }

  /// Opens date selection dialog for better mobile experience

  bool _isValidSelection() {
    return _isSelectionValid;
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
            _DatePickerDesign.spacingSmall, 0.0, _DatePickerDesign.spacingSmall, _DatePickerDesign.spacingLarge),
        actionsPadding: EdgeInsets.fromLTRB(_DatePickerDesign.spacingSmall, 0.0, _DatePickerDesign.spacingSmall,
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

  bool _isCompactScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // Trigger haptic feedback for better mobile experience
  void _triggerHapticFeedback() {
    HapticFeedbackUtil.triggerHapticFeedback(context);
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
          child: MobileActionButton(
            context: context,
            onPressed: _onCancel,
            text: widget.config.cancelButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
            icon: Icons.close,
            isPrimary: false,
            borderRadius: widget.config.actionButtonRadius,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: MobileActionButton(
            context: context,
            onPressed: _isValidSelection() ? _onConfirm : null,
            text: widget.config.confirmButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
            icon: Icons.check,
            isPrimary: true,
            borderRadius: widget.config.actionButtonRadius,
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
            // Always open time picker dialog
            _openTimeSelectionDialog();
          },
          borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
          splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
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
                  size: 14, // Smaller chevron
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build mobile-friendly action button with proper touch targets
  
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
        });
      },
      onRangeSelected: (DateTime? startDate, DateTime? endDate) {
        setState(() {
          _selectedStartDate = startDate;
          _selectedEndDate = endDate;
        });
      },
      translations: widget.config.translations ?? {},
    );
  }
}
