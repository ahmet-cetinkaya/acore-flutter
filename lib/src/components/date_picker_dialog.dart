import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../time/date_format_service.dart';

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
  final Map<String, String>? translations;

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

  const DatePickerResult({
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.isConfirmed = false,
  });

  factory DatePickerResult.cancelled() {
    return const DatePickerResult(isConfirmed: false);
  }

  factory DatePickerResult.single(DateTime date) {
    return DatePickerResult(
      selectedDate: date,
      isConfirmed: true,
    );
  }

  factory DatePickerResult.range(DateTime startDate, DateTime endDate) {
    return DatePickerResult(
      startDate: startDate,
      endDate: endDate,
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

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return '';
    return DateFormatService.formatForInput(
      date,
      context,
      type: widget.config.formatType,
    );
  }

  String _getLocalizedText(String key, String fallback) {
    return widget.config.translations?[key] ?? fallback;
  }


  void _selectQuickRange(QuickDateRange range) {
    if (widget.config.selectionMode != DateSelectionMode.range) return;

    final startDate = range.startDateCalculator();
    final endDate = range.endDateCalculator();

    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;
    });
  }

  bool _isQuickRangeSelected(QuickDateRange range) {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;
    
    final calculatedStart = range.startDateCalculator();
    final calculatedEnd = range.endDateCalculator();
    
    return _isSameDay(_selectedStartDate!, calculatedStart) && 
           _isSameDay(_selectedEndDate!, calculatedEnd);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }


  Future<void> _selectTime(DateTime date, bool isStartDate) async {
    if (!widget.config.showTime) return;

    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
    );

    if (timeOfDay != null && mounted) {
      final updatedDate = DateTime(
        date.year,
        date.month,
        date.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

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
      return _selectedDate != null;
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
      result = DatePickerResult.single(_selectedDate!);
    } else {
      result = DatePickerResult.range(_selectedStartDate!, _selectedEndDate!);
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

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme ?? Theme.of(context);
    
    return Theme(
      data: theme,
      child: AlertDialog(
        title: Text(
          widget.config.titleText ?? 
          _getLocalizedText(
            'date_picker_title', 
            widget.config.selectionMode == DateSelectionMode.single 
                ? 'Select Date' 
                : 'Select Date Range'
          ),
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSelectedDateDisplay(),
              if (widget.config.showQuickRanges && widget.config.quickRanges != null)
                _buildQuickRangesSection(),
              _buildCalendarSection(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _onCancel,
            child: Text(
              widget.config.cancelButtonText ?? 
              _getLocalizedText('cancel', 'Cancel'),
            ),
          ),
          TextButton(
            onPressed: _hasSelection() ? _onClear : null,
            child: Text(
              _getLocalizedText('clear', 'Clear'),
            ),
          ),
          TextButton(
            onPressed: _isValidSelection() ? _onConfirm : null,
            child: Text(
              widget.config.confirmButtonText ?? 
              _getLocalizedText('confirm', 'Confirm'),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSelectedDateDisplay() {
    if (widget.config.selectionMode == DateSelectionMode.single) {
      final displayText = _selectedDate != null 
          ? _formatDateForDisplay(_selectedDate)
          : _getLocalizedText('no_date_selected', 'No date selected');
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.config.showTime ? Icons.event_note : Icons.event,
              color: _selectedDate != null 
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              displayText,
              style: TextStyle(
                color: _selectedDate != null 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
                fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
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
        displayText = '${_formatDateForDisplay(_selectedStartDate)} - ${_getLocalizedText('select_end_date', 'Select end date')}';
      } else {
        displayText = _getLocalizedText('no_dates_selected', 'No dates selected');
      }
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.date_range,
              color: (_selectedStartDate != null && _selectedEndDate != null)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                displayText,
                style: TextStyle(
                  color: (_selectedStartDate != null && _selectedEndDate != null)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  fontWeight: (_selectedStartDate != null && _selectedEndDate != null) 
                      ? FontWeight.bold 
                      : FontWeight.normal,
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
    );
  }

  Widget _buildCalendarSection() {
    return CalendarDatePicker2(
      config: CalendarDatePicker2Config(
        calendarType: widget.config.selectionMode == DateSelectionMode.single
            ? CalendarDatePicker2Type.single
            : CalendarDatePicker2Type.range,
        selectedDayHighlightColor: Theme.of(context).primaryColor,
        firstDate: widget.config.minDate ?? DateTime(1900),
        lastDate: widget.config.maxDate ?? DateTime(2100),
        centerAlignModePicker: true,
        selectedYearTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        rangeBidirectional: true,
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
            setState(() {
              _selectedDate = dates.first;
            });
            
            // If time selection is enabled, automatically show time picker
            if (widget.config.showTime) {
              await _selectTime(dates.first, true);
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
            });
          } else if (dates.length == 1) {
            setState(() {
              _selectedStartDate = dates[0];
              _selectedEndDate = null;
            });
          }
        }
      },
    );
  }
}