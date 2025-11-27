import 'package:flutter/material.dart';
import 'package:acore/acore.dart' hide Container;
import 'date_time_picker_constants.dart';
import 'date_picker_content.dart';

/// Mobile-optimized date picker content with Scaffold layout
/// Designed for bottom sheet display with proper mobile UX patterns
/// Matches QuickAddTaskDialog styling for visual consistency
///
/// IMPORTANT: This is a mobile-specific component. Responsive switching between
/// mobile/desktop layouts should be handled by parent components like
/// DatePickerDialog.showResponsive(). The else block provides a fallback
/// mobile layout if this component is used in non-mobile contexts.
class DatePickerMobileContent extends StatefulWidget {
  final DatePickerContentConfig config;
  final String? appBarTitle;
  final String? doneButtonText;
  final String? cancelButtonText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const DatePickerMobileContent({
    super.key,
    required this.config,
    this.appBarTitle,
    this.doneButtonText,
    this.cancelButtonText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<DatePickerMobileContent> createState() => _DatePickerMobileContentState();
}

class _DatePickerMobileContentState extends State<DatePickerMobileContent> {
  DatePickerResult? _currentResult;

  @override
  void initState() {
    super.initState();
    _initializeResult();
  }

  void _initializeResult() {
    // Initialize result with initial configuration
    if (widget.config.selectionMode == DateSelectionMode.single) {
      if (widget.config.initialDate != null) {
        _currentResult = DatePickerResult.single(
          widget.config.initialDate!,
          isRefreshEnabled: widget.config.initialRefreshEnabled,
        );
      }
    } else {
      if (widget.config.initialStartDate != null && widget.config.initialEndDate != null) {
        _currentResult = DatePickerResult.range(
          widget.config.initialStartDate!,
          widget.config.initialEndDate!,
          isRefreshEnabled: widget.config.initialRefreshEnabled,
        );
      }
    }
  }

  void _handleSelectionChanged(DatePickerContentResult result) {
    setState(() {
      _currentResult = DatePickerResult(
        selectedDate: result.selectedDate,
        startDate: result.startDate,
        endDate: result.endDate,
        isRefreshEnabled: result.isRefreshEnabled ?? false,
        quickSelectionKey: result.quickSelectionKey,
        isAllDay: result.isAllDay,
      );
    });
  }

  void _handleConfirm() {
    // If onConfirm is provided, call it (legacy behavior)
    // But we also want to return the result
    if (widget.onConfirm != null) {
      widget.onConfirm!();
    } else {
      Navigator.pop(context, _currentResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create a modified config that includes our selection listener
    final contentConfig = DatePickerContentConfig(
      selectionMode: widget.config.selectionMode,
      initialDate: widget.config.initialDate,
      initialStartDate: widget.config.initialStartDate,
      initialEndDate: widget.config.initialEndDate,
      minDate: widget.config.minDate,
      maxDate: widget.config.maxDate,
      formatType: widget.config.formatType,
      titleText: widget.config.titleText,
      quickRanges: widget.config.quickRanges,
      showTime: widget.config.showTime,
      showQuickRanges: widget.config.showQuickRanges,
      enableManualInput: widget.config.enableManualInput,
      dateFormatHint: widget.config.dateFormatHint,
      theme: widget.config.theme,
      locale: widget.config.locale,
      translations: widget.config.translations,
      allowNullConfirm: widget.config.allowNullConfirm,
      showRefreshToggle: widget.config.showRefreshToggle,
      initialRefreshEnabled: widget.config.initialRefreshEnabled,
      onRefreshToggleChanged: widget.config.onRefreshToggleChanged,
      dateTimeValidator: widget.config.dateTimeValidator,
      validationErrorMessage: widget.config.validationErrorMessage,
      actionButtonRadius: widget.config.actionButtonRadius,
      validationErrorAtTop: widget.config.validationErrorAtTop,
      onSelectionChanged: _handleSelectionChanged,
    );

    // Use Scaffold with AppBar styling to match other dialog content (e.g., PrioritySelectionDialogContent)
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: theme.cardColor,
        title: Text(
          widget.appBarTitle ?? 'Select Date & Time',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        actions: [
          TextButton(
            key: const Key('date_picker_done_button'),
            onPressed: _handleConfirm,
            child: Text(
              widget.doneButtonText ?? 'Done',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: DateTimePickerConstants.sizeSmall),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DatePickerContent(
            config: contentConfig,
            onComplete: (result) {
              // Convert DatePickerContentResult back to DatePickerResult for compatibility
              if (result != null) {
                final datePickerResult = DatePickerResult(
                  selectedDate: result.selectedDate,
                  startDate: result.startDate,
                  endDate: result.endDate,
                  isRefreshEnabled: result.isRefreshEnabled ?? false,
                  quickSelectionKey: result.quickSelectionKey,
                  isAllDay: result.isAllDay,
                );
                // Update current result before confirming
                _currentResult = datePickerResult;
                _handleConfirm();
              }
            },
          ),
        ),
      ),
    );
  }
}
