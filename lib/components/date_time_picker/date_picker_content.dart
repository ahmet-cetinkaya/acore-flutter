import 'package:flutter/material.dart';
import 'constants/date_picker_design.dart';
import 'models/date_picker_types.dart';
import 'components/calendar_date_picker.dart' as custom;
import 'components/date_validation_display.dart';
import 'components/date_selection_utils.dart';
import 'components/date_picker_quick_selection.dart';
import 'components/date_picker_time_field.dart';
import 'components/date_picker_footer_actions.dart';

/// A clean date picker content component that can be used in dialogs or as standalone content.
///
/// Uses extracted components for better maintainability:
/// - [DatePickerQuickSelection] for quick date selection buttons
/// - [DatePickerTimeField] for time selection
/// - [DatePickerFooterActions] for footer action buttons
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
  late DateTime? _selectedDate;
  late DateTime? _selectedStartDate;
  late DateTime? _selectedEndDate;
  late bool _refreshEnabled;
  bool _isAllDay = true;

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
      _isAllDay = _selectedDate == null || DateSelectionUtils.isAllDayTime(_selectedDate!);
    } else {
      _selectedDate = null;
      _selectedStartDate = widget.config.initialStartDate;
      _selectedEndDate = widget.config.initialEndDate;
      _isAllDay = _selectedStartDate == null || DateSelectionUtils.isAllDayTime(_selectedStartDate!);
    }
    _refreshEnabled = widget.config.initialRefreshEnabled;
  }

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

  void _onQuickSelectionChanged(QuickSelectionResult result) {
    setState(() {
      if (result.selectedDate != null || (result.startDate == null && result.endDate == null)) {
        _selectedDate = result.selectedDate;
      }
      if (result.startDate != null || result.endDate != null) {
        _selectedStartDate = result.startDate;
        _selectedEndDate = result.endDate;
      }
      _refreshEnabled = result.refreshEnabled;
    });
    _notifySelectionChanged();
  }

  void _onRefreshToggleChanged() {
    setState(() {
      _refreshEnabled = !_refreshEnabled;
    });
    widget.config.onRefreshToggleChanged?.call(_refreshEnabled);
    _notifySelectionChanged();
  }

  void _onTimeChanged(DateTime? dateTime) {
    setState(() {
      _selectedDate = dateTime;
    });
    _notifySelectionChanged();
  }

  void _onAllDayChanged(bool isAllDay) {
    setState(() {
      _isAllDay = isAllDay;
    });
    _notifySelectionChanged();
  }

  void _onValidationStateChanged(bool isValid) {
    setState(() {});
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
                  SizedBox(height: DatePickerDesign.spacingMedium),

                  // Quick selection buttons
                  DatePickerQuickSelection(
                    selectionMode: widget.config.selectionMode,
                    selectedDate: _selectedDate,
                    selectedStartDate: _selectedStartDate,
                    selectedEndDate: _selectedEndDate,
                    refreshEnabled: _refreshEnabled,
                    minDate: widget.config.minDate,
                    quickRanges: widget.config.quickRanges,
                    translations: widget.config.translations,
                    onSelectionChanged: _onQuickSelectionChanged,
                    onRefreshToggleChanged: _onRefreshToggleChanged,
                  ),

                  // Calendar section (always visible)
                  _buildCalendarSection(),

                  // Add spacing for time field if showTime is enabled
                  if (widget.config.showTime) SizedBox(height: DatePickerDesign.spacingMedium),
                ],
              ),
            ),
          ),

          // Fixed bottom time field
          if (widget.config.showTime)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DatePickerDesign.spacingMedium,
              ),
              child: DatePickerTimeField(
                selectedDate: _selectedDate,
                isAllDay: _isAllDay,
                translations: widget.config.translations,
                theme: widget.config.theme,
                locale: widget.config.locale,
                actionButtonRadius: widget.config.actionButtonRadius,
                onTimeChanged: _onTimeChanged,
                onAllDayChanged: _onAllDayChanged,
              ),
            ),

          // Footer actions below (always shown when provided)
          if (widget.config.footerActions != null && widget.config.footerActions!.isNotEmpty)
            DatePickerFooterActions(
              actions: widget.config.footerActions!,
              selectedDate: _selectedDate,
              onRebuildRequest: widget.config.onRebuildRequest,
            ),
        ],
      ),
    );
  }
}
