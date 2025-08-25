import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../time/date_format_service.dart';
import 'date_time_picker_translation_keys.dart';

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
  });
}

/// Date selection mode for the picker
enum DateSelectionMode {
  single,
  range,
}

/// Quick date range option
class QuickDateRange {
  final String key;
  final String label;
  final DateTime Function() startDateCalculator;
  final DateTime Function() endDateCalculator;

  const QuickDateRange({
    required this.key,
    required this.label,
    required this.startDateCalculator,
    required this.endDateCalculator,
  });
}

/// Result returned from the date picker dialog
class DatePickerResult {
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isConfirmed;
  final bool? isRefreshEnabled;
  final String? quickSelectionKey;

  const DatePickerResult({
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.isConfirmed = false,
    this.isRefreshEnabled,
    this.quickSelectionKey,
  });

  factory DatePickerResult.cancelled() {
    return const DatePickerResult(isConfirmed: false);
  }

  factory DatePickerResult.single(DateTime date, {bool? isRefreshEnabled, String? quickSelectionKey}) {
    return DatePickerResult(
      selectedDate: date,
      isConfirmed: true,
      isRefreshEnabled: isRefreshEnabled,
      quickSelectionKey: quickSelectionKey,
    );
  }

  factory DatePickerResult.range(DateTime startDate, DateTime endDate, {bool? isRefreshEnabled, String? quickSelectionKey}) {
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
  bool _userHasSelectedQuickRange = false;
  String? _selectedQuickRangeKey;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _initializeQuickSelectionState();
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
    _refreshEnabled = widget.config.initialRefreshEnabled;
  }

  void _initializeQuickSelectionState() {
    // Check if initial dates match any quick range - if so, consider it as user selected
    if (widget.config.quickRanges != null && _selectedStartDate != null && _selectedEndDate != null) {
      for (final range in widget.config.quickRanges!) {
        if (_isQuickRangeSelected(range)) {
          _userHasSelectedQuickRange = true;
          _selectedQuickRangeKey = range.key;
          break;
        }
      }
    }
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return '';
    return DateFormatService.formatForInput(
      date,
      context,
      type: widget.config.formatType,
    );
  }

  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.config.translations?[key] ?? fallback;
  }

  void _selectQuickRange(QuickDateRange range) {
    if (widget.config.selectionMode != DateSelectionMode.range) return;

    final startDate = range.startDateCalculator();
    final endDate = range.endDateCalculator();

    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;
      _userHasSelectedQuickRange = true; // User has now selected a quick range
      _selectedQuickRangeKey = range.key; // Track which quick range was selected
    });
  }

  bool _isQuickRangeSelected(QuickDateRange range) {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;

    final calculatedStart = range.startDateCalculator();
    final calculatedEnd = range.endDateCalculator();

    return _isSameDay(_selectedStartDate!, calculatedStart) && _isSameDay(_selectedEndDate!, calculatedEnd);
  }

  bool _hasActiveQuickSelection() {
    // The refresh toggle should only show if the user has explicitly selected a quick range.
    // This flag is reset to false on any manual date interaction, so checking it is sufficient.
    return _userHasSelectedQuickRange;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Future<void> _selectTime(DateTime date, bool isStartDate) async {
    if (!widget.config.showTime) return;

    // Check if the selected date is before minDate and handle time constraints
    TimeOfDay? initialTime = TimeOfDay.fromDateTime(date);
    TimeOfDay? earliestTime;

    if (widget.config.minDate != null) {
      final minDate = widget.config.minDate!;
      final selectedDateOnly = DateTime(date.year, date.month, date.day);
      final minDateOnly = DateTime(minDate.year, minDate.month, minDate.day);

      // If selected date is the same as minDate, restrict time to be >= minDate time
      if (selectedDateOnly.isAtSameMomentAs(minDateOnly)) {
        earliestTime = TimeOfDay.fromDateTime(minDate);

        // If current time is before earliest allowed time, set to earliest time
        // Since minDate is start of day (00:00:00), allow any time for today
        if (initialTime.hour < earliestTime.hour ||
            (initialTime.hour == earliestTime.hour && initialTime.minute < earliestTime.minute)) {
          initialTime = earliestTime;
        }
      }
    }

    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (timeOfDay != null && mounted) {
      final updatedDate = DateTime(
        date.year,
        date.month,
        date.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      // Validate that the selected time is not before minDate (must be >= minDate)
      if (widget.config.minDate != null && updatedDate.isBefore(widget.config.minDate!)) {
        // If selected time is before minDate, set to minDate time
        final correctedDate = DateTime(
          date.year,
          date.month,
          date.day,
          widget.config.minDate!.hour,
          widget.config.minDate!.minute,
        );

        setState(() {
          if (widget.config.selectionMode == DateSelectionMode.single) {
            _selectedDate = correctedDate;
          } else if (isStartDate) {
            _selectedStartDate = correctedDate;
          } else {
            _selectedEndDate = correctedDate;
          }
        });
        return;
      }

      setState(() {
        if (widget.config.selectionMode == DateSelectionMode.single) {
          _selectedDate = updatedDate;
        } else if (isStartDate) {
          _selectedStartDate = updatedDate;
        } else {
          _selectedEndDate = updatedDate;
        }
      });
    }
  }

  bool _isValidSelection() {
    if (widget.config.selectionMode == DateSelectionMode.single) {
      return _selectedDate != null || widget.config.allowNullConfirm;
    }
    return _selectedStartDate != null && _selectedEndDate != null;
  }

  bool _hasSelection() {
    if (widget.config.selectionMode == DateSelectionMode.single) {
      return _selectedDate != null;
    }
    return _selectedStartDate != null || _selectedEndDate != null;
  }

  void _onConfirm() {
    if (!_isValidSelection()) return;

    DatePickerResult result;
    if (widget.config.selectionMode == DateSelectionMode.single) {
      if (_selectedDate != null) {
        result = DatePickerResult.single(_selectedDate!, isRefreshEnabled: _refreshEnabled, quickSelectionKey: _selectedQuickRangeKey);
      } else {
        // Date was cleared
        result = DatePickerResult.cleared();
      }
    } else {
      result = DatePickerResult.range(_selectedStartDate!, _selectedEndDate!, isRefreshEnabled: _refreshEnabled, quickSelectionKey: _selectedQuickRangeKey);
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
    final dialogWidth = isCompactScreen ? 350.0 : 420.0;

    return Theme(
      data: theme,
      child: AlertDialog(
        title: Text(
          widget.config.titleText ??
              _getLocalizedText(DateTimePickerTranslationKey.title,
                  widget.config.selectionMode == DateSelectionMode.single ? 'Select Date & Time' : 'Select Date Range'),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSelectedDateDisplay(),
                  if (widget.config.showQuickRanges && widget.config.quickRanges != null) _buildQuickRangesSection(),
                  _buildCalendarSection(),
                ],
              ),
            ),
          ),
        ),
        actions: [
          _buildActionButton(
            context: context,
            onPressed: _onCancel,
            text: widget.config.cancelButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel'),
            icon: Icons.close,
          ),
          _buildActionButton(
            context: context,
            onPressed: _hasSelection() ? _onClear : null,
            text: _getLocalizedText(DateTimePickerTranslationKey.clear, 'Clear'),
            icon: Icons.delete_outline,
          ),
          _buildActionButton(
            context: context,
            onPressed: _isValidSelection() ? _onConfirm : null,
            text: widget.config.confirmButtonText ?? _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Confirm'),
            icon: Icons.check,
            isPrimary: true,
            forceTextButton: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateDisplay() {
    if (widget.config.selectionMode == DateSelectionMode.single) {
      final displayText = _selectedDate != null
          ? _formatDateForDisplay(_selectedDate)
          : _getLocalizedText(DateTimePickerTranslationKey.noDateSelected, 'No date selected');

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 8,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _isCompactScreen(context) ? 280 : 350),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.config.showTime ? Icons.event_note : Icons.event,
                        color: _selectedDate != null ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          displayText,
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor,
                            fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add time button that can wrap to next line on small screens
                if (widget.config.showTime && _selectedDate != null)
                  InkWell(
                    onTap: () async {
                      await _selectTime(_selectedDate!, true);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getLocalizedText(DateTimePickerTranslationKey.setTime, 'Set Time'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
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
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 8,
          children: [
            Icon(
              Icons.date_range,
              color: (_selectedStartDate != null && _selectedEndDate != null)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              size: 16,
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
                  fontSize: 16,
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

  Widget _buildQuickRangesSection() {
    if (widget.config.quickRanges == null || widget.config.quickRanges!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Quick ranges section (85% width)
          Expanded(
            flex: 85,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.config.quickRanges!.map((range) {
                final isSelected = _isQuickRangeSelected(range);
                return FilterChip(
                  label: Text(
                    range.label,
                    style: const TextStyle(fontSize: 10),
                  ),
                  selected: isSelected,
                  onSelected: (_) => _selectQuickRange(range),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
          // Refresh toggle section (15% width) - only show when any quick selection is active
          if (widget.config.showRefreshToggle && _hasActiveQuickSelection()) ...[
            const SizedBox(width: 8.0),
            Expanded(
              flex: 15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleRefresh,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _refreshEnabled ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: _refreshEnabled ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _refreshEnabled ? Icons.autorenew : Icons.refresh,
                            size: 16,
                            color: _refreshEnabled ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getLocalizedText(DateTimePickerTranslationKey.refresh, 'Refresh'),
                            style: TextStyle(
                              fontSize: 8,
                              color: _refreshEnabled
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: _refreshEnabled ? FontWeight.w600 : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isCompactScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
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
          padding: const EdgeInsets.all(8),
        ),
      );
    }
  }

  Widget _buildCalendarSection() {
    final isCompactScreen = _isCompactScreen(context);
    final calendarWidth = isCompactScreen ? 350.0 : 420.0;

    return Container(
      width: calendarWidth,
      constraints: BoxConstraints(maxWidth: calendarWidth),
      child: CalendarDatePicker2(
        config: CalendarDatePicker2Config(
          calendarType: widget.config.selectionMode == DateSelectionMode.single
              ? CalendarDatePicker2Type.single
              : CalendarDatePicker2Type.range,
          selectedDayHighlightColor: Theme.of(context).primaryColor,
          firstDate: widget.config.minDate ?? DateTime(1900),
          lastDate: widget.config.maxDate ?? DateTime(2100),
          currentDate: _selectedDate ?? DateTime.now(), // Set current date to show correct month
          centerAlignModePicker: true,
          selectedYearTextStyle: const TextStyle(fontWeight: FontWeight.bold),
          rangeBidirectional: true,
          // Size control configurations to prevent overflow
          dayMaxWidth: 48.0, // Control max width of each day cell
          controlsHeight: 40.0, // Reduce height of controls
          modePickersGap: 4.0, // Reduce gap between month/year pickers
          useAbbrLabelForMonthModePicker: true, // Use shorter labels for month picker
          controlsTextStyle: const TextStyle(fontSize: 12), // Smaller text for controls
          // toggleDateOnTap: true, // Removed - causes deselection issues
        ),
        value: widget.config.selectionMode == DateSelectionMode.single
            ? (_selectedDate != null ? [_selectedDate] : [])
            : (_selectedStartDate != null && _selectedEndDate != null
                ? [_selectedStartDate, _selectedEndDate]
                : _selectedStartDate != null
                    ? [_selectedStartDate]
                    : []),
        onValueChanged: (dates) async {
          if (widget.config.selectionMode == DateSelectionMode.single) {
            if (dates.isNotEmpty) {
              DateTime selectedDate = dates.first;

              // If there's a minDate constraint and selected date is on the same day as minDate,
              // ensure the time is not before minDate time
              if (widget.config.minDate != null && widget.config.showTime) {
                final minDate = widget.config.minDate!;
                final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                final minDateOnly = DateTime(minDate.year, minDate.month, minDate.day);

                if (selectedDateOnly.isAtSameMomentAs(minDateOnly)) {
                  // Set the time to minDate time if selecting today
                  selectedDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    minDate.hour,
                    minDate.minute,
                  );
                }
              }

              setState(() {
                _selectedDate = selectedDate;
                _userHasSelectedQuickRange = false; // Manual selection, not quick range
                _selectedQuickRangeKey = null; // Clear quick range key for manual selection
              });

              // If time selection is enabled, automatically show time picker
              if (widget.config.showTime) {
                await _selectTime(selectedDate, true);
              }
            }
          } else {
            // Range selection
            if (dates.length == 2) {
              final startDate = dates[0];
              final endDate = DateTime(
                dates[1].year,
                dates[1].month,
                dates[1].day,
                23,
                59,
                59,
              );

              setState(() {
                _selectedStartDate = startDate;
                _selectedEndDate = endDate;
                _userHasSelectedQuickRange = false; // Manual range selection, not quick range
                _selectedQuickRangeKey = null; // Clear quick range key for manual selection
              });
            } else if (dates.length == 1) {
              setState(() {
                _selectedStartDate = dates[0];
                _selectedEndDate = null;
                _userHasSelectedQuickRange = false; // Manual selection, not quick range
                _selectedQuickRangeKey = null; // Clear quick range key for manual selection
              });
            }
          }
        },
      ),
    );
  }
}
