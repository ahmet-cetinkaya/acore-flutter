import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../time/date_format_service.dart';
import 'date_time_picker_translation_keys.dart';

/// Quick selection dialog for better desktop UX
class _QuickSelectionDialog extends StatefulWidget {
  final List<QuickDateRange>? quickRanges;
  final void Function(QuickDateRange) onQuickRangeSelected;
  final bool showRefreshToggle;
  final bool refreshEnabled;
  final VoidCallback onRefreshToggle;
  final Map<DateTimePickerTranslationKey, String> translations;
  final String? selectedQuickRangeKey;
  final bool isCompactScreen;
  final String title;
  final double? actionButtonRadius;

  const _QuickSelectionDialog({
    required this.quickRanges,
    required this.onQuickRangeSelected,
    required this.showRefreshToggle,
    required this.refreshEnabled,
    required this.onRefreshToggle,
    required this.translations,
    this.selectedQuickRangeKey,
    required this.isCompactScreen,
    required this.title,
    this.actionButtonRadius,
  });

  @override
  State<_QuickSelectionDialog> createState() => _QuickSelectionDialogState();
}

class _QuickSelectionDialogState extends State<_QuickSelectionDialog> {
  bool _localRefreshEnabled = false;

  @override
  void initState() {
    super.initState();
    _localRefreshEnabled = widget.refreshEnabled;
  }

  @override
  void didUpdateWidget(_QuickSelectionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state when parent state changes
    if (oldWidget.refreshEnabled != widget.refreshEnabled) {
      setState(() {
        _localRefreshEnabled = widget.refreshEnabled;
      });
    }
  }

  void _handleRefreshToggle() {
    setState(() {
      _localRefreshEnabled = !_localRefreshEnabled;
    });
    widget.onRefreshToggle();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: widget.isCompactScreen ? _DatePickerDesign.fontSizeLarge : _DatePickerDesign.fontSizeXLarge,
              fontWeight: FontWeight.w600,
            ),
      ),
      content: SizedBox(
        width: widget.isCompactScreen ? 280 : 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.quickRanges != null && widget.quickRanges!.isNotEmpty) ...[
              Text(
                widget.translations[DateTimePickerTranslationKey.dateRanges] ?? 'Date Ranges',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: _DatePickerDesign.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
              ),
              SizedBox(height: _DatePickerDesign.spacingMedium),
              Wrap(
                spacing: _DatePickerDesign.spacingSmall,
                runSpacing: _DatePickerDesign.spacingSmall,
                children: widget.quickRanges!.map((QuickDateRange range) {
                  final isSelected = widget.selectedQuickRangeKey == range.key;
                  return FilterChip(
                    label: Text(
                      range.label,
                      style: TextStyle(
                        fontSize: _DatePickerDesign.fontSizeSmall,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      widget.onQuickRangeSelected(range);
                      Navigator.of(context).pop();
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    visualDensity: VisualDensity.comfortable,
                    pressElevation: _DatePickerDesign.spacingXSmall,
                    surfaceTintColor: Theme.of(context).primaryColor,
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: _DatePickerDesign.borderWidth,
                    ),
                    checkmarkColor: Theme.of(context).primaryColor,
                    selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                  );
                }).toList(),
              ),
              SizedBox(height: _DatePickerDesign.spacingLarge),
            ],
            if (widget.showRefreshToggle) ...[
              Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
              SizedBox(height: _DatePickerDesign.spacingMedium),
              Text(
                widget.translations[DateTimePickerTranslationKey.refreshSettingsLabel] ?? 'Refresh Settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: _DatePickerDesign.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
              ),
              SizedBox(height: _DatePickerDesign.spacingMedium),
              Row(
                children: [
                  Icon(
                    _localRefreshEnabled ? Icons.autorenew : Icons.refresh,
                    size: _DatePickerDesign.iconSizeMedium,
                    color: _localRefreshEnabled
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: _DatePickerDesign.spacingSmall),
                  Expanded(
                    child: Text(
                      widget.translations[DateTimePickerTranslationKey.refreshSettings] ??
                          DateTimePickerTranslationKey.refreshSettings.name,
                      style: TextStyle(
                        fontSize: _DatePickerDesign.fontSizeSmall,
                        color: _localRefreshEnabled
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: _localRefreshEnabled,
                    onChanged: (_) => _handleRefreshToggle(),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.actionButtonRadius ?? 8.0),
            ),
          ),
          child: Text(
              widget.translations[DateTimePickerTranslationKey.cancel] ?? DateTimePickerTranslationKey.cancel.name),
        ),
      ],
    );
  }
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
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusFull = 24.0;

  // Font sizes
  static const double fontSizeXSmall = 12.0;
  static const double fontSizeSmall = 14.0;
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

  // Animation durations
  static const Duration defaultAnimation = Duration(milliseconds: 200);

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
  bool _userHasSelectedQuickRange = false;
  String? _selectedQuickRangeKey;

  // Performance optimization: cached formatted dates
  final Map<DateTime, String> _formattedDateCache = {};

  // Performance optimization: debounce timer for validation
  Timer? _validationDebounceTimer;

  // Performance optimization: cached validation results
  String? _cachedValidationResult;
  DateTime? _lastValidationCheck;

  // Inline time picker state
  bool _showInlineTimePicker = false;
  TimeOfDay? _tempSelectedTime;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _initializeQuickSelectionState();
  }

  @override
  void dispose() {
    _validationDebounceTimer?.cancel();
    _formattedDateCache.clear();
    super.dispose();
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

  // Format time for display
  String _formatTimeForDisplay(TimeOfDay time) {
    // Try to use MaterialLocalizations if available
    try {
      final localizations = MaterialLocalizations.of(context);
      final use24Hour = MediaQuery.of(context).alwaysUse24HourFormat;
      return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: use24Hour);
    } catch (e) {
      // Fallback formatting
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
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
    TimeOfDay? latestTime;

    final selectedDateOnly = DateTime(date.year, date.month, date.day);

    if (widget.config.minDate != null) {
      final minDate = widget.config.minDate!;
      final minDateOnly = DateTime(minDate.year, minDate.month, minDate.day);

      // If selected date is the same as minDate, restrict time to be >= minDate time
      if (selectedDateOnly.isAtSameMomentAs(minDateOnly)) {
        earliestTime = TimeOfDay.fromDateTime(minDate);
      }
      // If selected date is before minDate, prevent selection
      else if (selectedDateOnly.isBefore(minDateOnly)) {
        return;
      }
    }

    if (widget.config.maxDate != null) {
      final maxDate = widget.config.maxDate!;
      final maxDateOnly = DateTime(maxDate.year, maxDate.month, maxDate.day);

      // If selected date is the same as maxDate, restrict time to be <= maxDate time
      if (selectedDateOnly.isAtSameMomentAs(maxDateOnly)) {
        latestTime = TimeOfDay.fromDateTime(maxDate);
      }
      // If selected date is after maxDate, prevent selection
      else if (selectedDateOnly.isAfter(maxDateOnly)) {
        return;
      }
    }

    // Adjust initial time if it's outside bounds
    if (earliestTime != null) {
      if (initialTime.hour < earliestTime.hour ||
          (initialTime.hour == earliestTime.hour && initialTime.minute < earliestTime.minute)) {
        initialTime = earliestTime;
      }
    }
    if (latestTime != null) {
      if (initialTime.hour > latestTime.hour ||
          (initialTime.hour == latestTime.hour && initialTime.minute > latestTime.minute)) {
        initialTime = latestTime;
      }
    }

    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (timeOfDay != null && mounted) {
      // Validate time constraints before applying
      if (earliestTime != null) {
        if (timeOfDay.hour < earliestTime.hour ||
            (timeOfDay.hour == earliestTime.hour && timeOfDay.minute < earliestTime.minute)) {
          return;
        }
      }

      if (latestTime != null) {
        if (timeOfDay.hour > latestTime.hour ||
            (timeOfDay.hour == latestTime.hour && timeOfDay.minute > latestTime.minute)) {
          return;
        }
      }

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

  /// Returns a list of validation error messages for the current selection
  List<String> _getValidationErrors() {
    List<String> validationErrors = [];

    if (widget.config.selectionMode == DateSelectionMode.single) {
      // Check if we have a selection (or null is allowed)
      bool hasSelection = _selectedDate != null || widget.config.allowNullConfirm;
      if (!hasSelection) {
        return validationErrors; // No selection, but errors would be shown elsewhere
      }

      // Check custom validator
      if (_selectedDate != null &&
          widget.config.dateTimeValidator != null &&
          !widget.config.dateTimeValidator!(_selectedDate) &&
          widget.config.validationErrorMessage != null) {
        validationErrors.add(widget.config.validationErrorMessage!);
      }

      // Check min/max date constraints (ensure consistent timezone handling)
      if (_selectedDate != null) {
        final selectedLocal = _selectedDate!.toLocal();
        final minLocal = widget.config.minDate?.toLocal();
        final maxLocal = widget.config.maxDate?.toLocal();

        if (minLocal != null && selectedLocal.isBefore(minLocal)) {
          validationErrors.add(_getLocalizedText(DateTimePickerTranslationKey.selectedDateMustBeAtOrAfter,
              'Selected date must be at or after ${DateFormatService.formatForInput(minLocal, context, type: DateFormatType.dateTime)}'));
        }
        if (maxLocal != null && selectedLocal.isAfter(maxLocal)) {
          validationErrors.add(_getLocalizedText(DateTimePickerTranslationKey.selectedDateMustBeAtOrBefore,
              'Selected date must be at or before ${DateFormatService.formatForInput(maxLocal, context, type: DateFormatType.dateTime)}'));
        }
      }
    } else {
      // Range selection validation
      if (_selectedStartDate != null && _selectedEndDate != null) {
        final startLocal = _selectedStartDate!.toLocal();
        final endLocal = _selectedEndDate!.toLocal();
        final minLocal = widget.config.minDate?.toLocal();
        final maxLocal = widget.config.maxDate?.toLocal();

        if (startLocal.isAfter(endLocal)) {
          validationErrors.add(_getLocalizedText(
              DateTimePickerTranslationKey.startDateCannotBeAfterEndDate, 'Start date cannot be after end date'));
        }
        if (minLocal != null && startLocal.isBefore(minLocal)) {
          validationErrors.add(_getLocalizedText(DateTimePickerTranslationKey.startDateMustBeAtOrAfter,
              'Start date must be at or after ${DateFormatService.formatForInput(minLocal, context, type: DateFormatType.date)}'));
        }
        if (maxLocal != null && endLocal.isAfter(maxLocal)) {
          validationErrors.add(_getLocalizedText(DateTimePickerTranslationKey.endDateMustBeAtOrBefore,
              'End date must be at or before ${DateFormatService.formatForInput(maxLocal, context, type: DateFormatType.date)}'));
        }
      }
    }

    return validationErrors;
  }

  bool _isValidSelection() {
    // Check for presence of selection first
    if (widget.config.selectionMode == DateSelectionMode.single) {
      if (!(_selectedDate != null || widget.config.allowNullConfirm)) {
        return false;
      }
    } else {
      if (_selectedStartDate == null || _selectedEndDate == null) {
        return false;
      }
    }
    // Then check for validation errors
    return _getValidationErrors().isEmpty;
  }

  bool _hasSelection() {
    if (widget.config.selectionMode == DateSelectionMode.single) {
      return _selectedDate != null;
    }
    return _selectedStartDate != null || _selectedEndDate != null;
  }

  // Debounced validation for performance optimization
  void _debouncedValidation() {
    _validationDebounceTimer?.cancel();
    _validationDebounceTimer = Timer(_DatePickerDesign.defaultAnimation, () {
      if (mounted) {
        setState(() {
          _cachedValidationResult = _getValidationErrors().isEmpty ? null : 'has_errors';
          _lastValidationCheck = DateTime.now();
        });
      }
    });
  }

  Widget _buildValidationMessage() {
    // Use cached validation result if available and recent
    final now = DateTime.now();
    final useCached = _cachedValidationResult != null &&
        _lastValidationCheck != null &&
        now.difference(_lastValidationCheck!).inMilliseconds < 500;

    final validationErrors =
        useCached ? (_cachedValidationResult == null ? <String>[] : ['validation_error']) : _getValidationErrors();

    if (validationErrors.isNotEmpty) {
      // Trigger debounced validation for next update
      if (!useCached) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _debouncedValidation();
        });
      }

      return Container(
        padding: const EdgeInsets.all(_DatePickerDesign.spacingMedium),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
            width: _DatePickerDesign.borderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: _DatePickerDesign.iconSizeMedium,
                ),
                const SizedBox(width: _DatePickerDesign.spacingSmall),
                Text(
                  _getLocalizedText(DateTimePickerTranslationKey.cannotSelectDateBeforeMinDate, 'Validation Error'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: _DatePickerDesign.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (validationErrors.first != 'validation_error') ...[
              const SizedBox(height: _DatePickerDesign.spacingSmall),
              ...validationErrors.map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: _DatePickerDesign.spacingXSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: _DatePickerDesign.spacingXSmall,
                          height: _DatePickerDesign.spacingXSmall,
                          margin: const EdgeInsets.only(
                              top: _DatePickerDesign.spacingSmall - _DatePickerDesign.spacingXSmall,
                              right: _DatePickerDesign.spacingSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            error,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                              fontSize: _DatePickerDesign.fontSizeXSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink(); // Return empty widget if no errors
  }

  void _onConfirm() {
    if (!_isValidSelection()) return;

    DatePickerResult result;
    if (widget.config.selectionMode == DateSelectionMode.single) {
      if (_selectedDate != null) {
        result = DatePickerResult.single(_selectedDate!,
            isRefreshEnabled: _refreshEnabled, quickSelectionKey: _selectedQuickRangeKey);
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
                  _buildSelectedDateDisplay(),
                  if (widget.config.showQuickRanges && widget.config.quickRanges != null) _buildQuickRangesSection(),
                  _buildCalendarSection(),
                  _buildValidationMessage(),
                ],
              ),
            ),
          ),
        ),
        actions: _buildActionButtons(isCompactScreen),
      ),
    );
  }

  Widget _buildSelectedDateDisplay() {
    final isCompactScreen = _isCompactScreen(context);

    if (widget.config.selectionMode == DateSelectionMode.single) {
      final displayText = _selectedDate != null
          ? _formatDateForDisplay(_selectedDate)
          : _getLocalizedText(DateTimePickerTranslationKey.noDateSelected, 'No date selected');

      return Padding(
        padding:
            EdgeInsets.only(bottom: isCompactScreen ? _DatePickerDesign.spacingSmall : _DatePickerDesign.spacingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date display section
            Container(
              padding:
                  EdgeInsets.all(isCompactScreen ? _DatePickerDesign.spacingMedium : _DatePickerDesign.spacingLarge),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.config.showTime ? Icons.event_note : Icons.event,
                        color: _selectedDate != null ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                        size: isCompactScreen ? _DatePickerDesign.iconSizeMedium : _DatePickerDesign.iconSizeLarge,
                      ),
                      const SizedBox(width: _DatePickerDesign.spacingSmall),
                      Flexible(
                        child: Text(
                          displayText,
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor,
                            fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                            fontSize:
                                isCompactScreen ? _DatePickerDesign.fontSizeMedium : _DatePickerDesign.fontSizeLarge,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Enhanced time selector for mobile
                  if (widget.config.showTime && _selectedDate != null) ...[
                    SizedBox(
                        height: isCompactScreen ? _DatePickerDesign.spacingMedium : _DatePickerDesign.spacingLarge),
                    _buildInlineTimeSelector(),
                  ],
                ],
              ),
            ),

            // Inline time picker panel
            if (_showInlineTimePicker && widget.config.showTime && _selectedDate != null) _buildInlineTimePicker(),
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

  Widget _buildQuickRangesSection() {
    if (widget.config.quickRanges == null || widget.config.quickRanges!.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasQuickSelection = _hasActiveQuickSelection();
    final hasSelection = _hasSelection();

    // Get current selection label
    String currentSelectionLabel = '';
    if (hasQuickSelection) {
      currentSelectionLabel = widget.config.quickRanges!
          .firstWhere((r) => _selectedQuickRangeKey == r.key, orElse: () => widget.config.quickRanges!.first)
          .label;
    }

    // Show centered quick selection and clear buttons with refresh indicator
    return Padding(
      padding: EdgeInsets.only(bottom: _DatePickerDesign.spacingMedium),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: _DatePickerDesign.spacingSmall,
        runSpacing: _DatePickerDesign.spacingSmall,
        children: [
          // Quick selection button with refresh indicator
          OutlinedButton.icon(
            onPressed: () => _showQuickSelectionDialog(),
            icon: Icon(Icons.speed, size: _DatePickerDesign.iconSizeMedium),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    hasQuickSelection
                        ? currentSelectionLabel
                        : _getLocalizedText(DateTimePickerTranslationKey.quickSelection, 'Quick Selection'),
                    style: TextStyle(
                      fontSize: _DatePickerDesign.fontSizeSmall,
                      fontWeight: FontWeight.w500,
                      color: hasQuickSelection ? Theme.of(context).primaryColor : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasQuickSelection && widget.config.showRefreshToggle && _refreshEnabled) ...[
                  SizedBox(width: _DatePickerDesign.spacingSmall),
                  Icon(
                    Icons.autorenew,
                    size: _DatePickerDesign.iconSizeSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ],
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: _DatePickerDesign.spacingSmall,
                vertical: _DatePickerDesign.spacingSmall,
              ),
              visualDensity: VisualDensity.compact,
              side: BorderSide(
                color: hasQuickSelection
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
                    : Theme.of(context).colorScheme.outline,
                width: _DatePickerDesign.borderWidth,
              ),
            ),
          ),
          SizedBox(width: _DatePickerDesign.spacingSmall),
          // Clear button
          OutlinedButton.icon(
            onPressed: hasSelection ? _onClear : null,
            icon: Icon(
              Icons.delete_outline,
              size: _DatePickerDesign.iconSizeMedium,
            ),
            label: Text(
              _getLocalizedText(DateTimePickerTranslationKey.clear, 'Clear'),
              style: TextStyle(
                fontSize: _DatePickerDesign.fontSizeSmall,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: _DatePickerDesign.spacingSmall,
                vertical: _DatePickerDesign.spacingSmall,
              ),
              visualDensity: VisualDensity.compact,
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: _DatePickerDesign.borderWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show quick selection dialog for unified UX across all platforms
  void _showQuickSelectionDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _QuickSelectionDialog(
          quickRanges: widget.config.quickRanges,
          onQuickRangeSelected: _selectQuickRange,
          showRefreshToggle: widget.config.showRefreshToggle,
          refreshEnabled: _refreshEnabled,
          onRefreshToggle: _toggleRefresh,
          translations: widget.config.translations ?? {},
          selectedQuickRangeKey: _selectedQuickRangeKey,
          isCompactScreen: _isCompactScreen(context),
          title: _getLocalizedText(DateTimePickerTranslationKey.quickSelectionTitle, 'Quick Selection'),
          actionButtonRadius: widget.config.actionButtonRadius,
        );
      },
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

  // Build inline time selector button
  Widget _buildInlineTimeSelector() {
    final isCompactScreen = _isCompactScreen(context);
    final currentTime = _tempSelectedTime ?? TimeOfDay.fromDateTime(_selectedDate!);
    final timeString = _formatTimeForDisplay(currentTime);

    return Semantics(
      button: true,
      label: 'Selected time: $timeString. Tap to change time.',
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showInlineTimePicker = !_showInlineTimePicker;
            _tempSelectedTime = TimeOfDay.fromDateTime(_selectedDate!);
          });
          _triggerHapticFeedback();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompactScreen ? 16 : 20,
            vertical: isCompactScreen ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(_DatePickerDesign.radiusLarge),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              width: _DatePickerDesign.borderWidth,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: isCompactScreen ? 18 : 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: _DatePickerDesign.spacingSmall),
              Text(
                timeString,
                style: TextStyle(
                  fontSize: isCompactScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _showInlineTimePicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: _DatePickerDesign.iconSizeMedium,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build inline time picker
  Widget _buildInlineTimePicker() {
    final isCompactScreen = _isCompactScreen(context);
    final currentTime = _tempSelectedTime ?? TimeOfDay.fromDateTime(_selectedDate!);

    return Container(
      margin: EdgeInsets.only(top: isCompactScreen ? 8 : 12),
      padding: EdgeInsets.all(isCompactScreen ? _DatePickerDesign.spacingLarge : _DatePickerDesign.spacingXLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_DatePickerDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: _DatePickerDesign.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  fontSize: isCompactScreen ? _DatePickerDesign.fontSizeLarge : _DatePickerDesign.fontSizeXLarge,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showInlineTimePicker = false;
                  });
                  _triggerHapticFeedback();
                },
                child: Container(
                  padding: const EdgeInsets.all(_DatePickerDesign.spacingXSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: _DatePickerDesign.iconSizeMedium,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isCompactScreen ? _DatePickerDesign.spacingLarge : _DatePickerDesign.spacingXLarge),

          // Time picker controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Hour selector
              _buildTimeUnitSelector(
                label: 'Hour',
                value: currentTime.hour,
                maxValue: 23,
                isCompactScreen: isCompactScreen,
                onChanged: (value) {
                  setState(() {
                    _tempSelectedTime = TimeOfDay(hour: value, minute: currentTime.minute);
                  });
                  _triggerHapticFeedback();
                },
              ),

              // Separator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isCompactScreen ? 16 : 24),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: isCompactScreen ? 24 : 32,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              // Minute selector
              _buildTimeUnitSelector(
                label: 'Minute',
                value: currentTime.minute,
                maxValue: 59,
                isCompactScreen: isCompactScreen,
                onChanged: (value) {
                  setState(() {
                    _tempSelectedTime = TimeOfDay(hour: currentTime.hour, minute: value);
                  });
                  _triggerHapticFeedback();
                },
              ),
            ],
          ),

          SizedBox(height: isCompactScreen ? _DatePickerDesign.spacingXLarge : _DatePickerDesign.spacingXLarge),

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
                    padding: EdgeInsets.symmetric(vertical: isCompactScreen ? 12 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_DatePickerDesign.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: isCompactScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: _DatePickerDesign.spacingMedium),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_tempSelectedTime != null && _selectedDate != null) {
                      final newDateTime = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _tempSelectedTime!.hour,
                        _tempSelectedTime!.minute,
                      );
                      setState(() {
                        _selectedDate = newDateTime;
                        _showInlineTimePicker = false;
                      });
                      _triggerHapticFeedback();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: isCompactScreen ? 12 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_DatePickerDesign.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Set Time',
                    style: TextStyle(
                      fontSize: isCompactScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build time unit selector (hour or minute)
  Widget _buildTimeUnitSelector({
    required String label,
    required int value,
    required int maxValue,
    required bool isCompactScreen,
    required void Function(int) onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isCompactScreen ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: isCompactScreen ? _DatePickerDesign.spacingSmall : _DatePickerDesign.spacingMedium),
        Container(
          width: isCompactScreen ? 80 : 100,
          height: isCompactScreen ? 120 : 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: _DatePickerDesign.borderWidth,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Increment button
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final newValue = value < maxValue ? value + 1 : 0;
                      onChanged(newValue);
                    },
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        size: isCompactScreen ? 24 : 28,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),

              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),

              // Value display
              Container(
                height: isCompactScreen ? 40 : 48,
                alignment: Alignment.center,
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: isCompactScreen ? 24 : 32,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),

              // Decrement button
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final newValue = value > 0 ? value - 1 : maxValue;
                      onChanged(newValue);
                    },
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: isCompactScreen ? 24 : 28,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
    final isCompactScreen = _isCompactScreen(context);
    final calendarWidth = isCompactScreen ? 350.0 : 420.0;

    return Semantics(
      label: 'Calendar date picker',
      child: Container(
        width: calendarWidth,
        constraints: BoxConstraints(maxWidth: calendarWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(
          padding: EdgeInsets.all(isCompactScreen ? _DatePickerDesign.spacingSmall : _DatePickerDesign.spacingMedium),
          child: CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              calendarType: widget.config.selectionMode == DateSelectionMode.single
                  ? CalendarDatePicker2Type.single
                  : CalendarDatePicker2Type.range,
              selectedDayHighlightColor: Theme.of(context).primaryColor,
              selectedDayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: isCompactScreen ? 14 : 16,
              ),
              firstDate: widget.config.minDate ?? DateTime(1900),
              lastDate: widget.config.maxDate ?? DateTime(2100),
              currentDate: _selectedDate ?? _selectedStartDate ?? DateTime.now(),
              centerAlignModePicker: true,
              selectedYearTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              rangeBidirectional: true,
              // Enhanced mobile-specific configurations
              dayMaxWidth: isCompactScreen ? 44.0 : 48.0, // Optimized for touch
              dayTextStyle: TextStyle(
                fontSize: isCompactScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
              disabledDayTextStyle: TextStyle(
                fontSize: isCompactScreen ? 14 : 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              todayTextStyle: TextStyle(
                fontSize: isCompactScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              controlsHeight: isCompactScreen ? 36.0 : 40.0,
              controlsTextStyle: TextStyle(
                fontSize: isCompactScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
              modePickersGap: isCompactScreen ? 8.0 : 12.0,
              useAbbrLabelForMonthModePicker: true,
              weekdayLabelTextStyle: TextStyle(
                fontSize: isCompactScreen ? _DatePickerDesign.fontSizeSmall : _DatePickerDesign.fontSizeSmall,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              // Enhanced visual feedback for mobile - supported parameters only
              dayBorderRadius: BorderRadius.circular(_DatePickerDesign.radiusFull),
              daySplashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                  final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

                  // Validate date constraints before proceeding
                  if (widget.config.minDate != null) {
                    final minDateOnly =
                        DateTime(widget.config.minDate!.year, widget.config.minDate!.month, widget.config.minDate!.day);

                    if (selectedDateOnly.isBefore(minDateOnly)) {
                      return;
                    }
                  }

                  if (widget.config.maxDate != null) {
                    final maxDateOnly =
                        DateTime(widget.config.maxDate!.year, widget.config.maxDate!.month, widget.config.maxDate!.day);

                    if (selectedDateOnly.isAfter(maxDateOnly)) {
                      return;
                    }
                  }

                  // If there's a minDate constraint and selected date is on the same day as minDate,
                  // ensure the time is not before minDate time
                  if (widget.config.minDate != null && widget.config.showTime) {
                    final minDate = widget.config.minDate!;
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

                  // Add haptic feedback for mobile date selection
                  if (isCompactScreen) {
                    _triggerHapticFeedback();
                  }

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

                  // Validate range constraints
                  if (widget.config.minDate != null) {
                    if (startDate.isBefore(widget.config.minDate!)) {
                      return;
                    }
                  }

                  if (widget.config.maxDate != null) {
                    if (endDate.isAfter(widget.config.maxDate!)) {
                      return;
                    }
                  }

                  setState(() {
                    _selectedStartDate = startDate;
                    _selectedEndDate = endDate;
                    _userHasSelectedQuickRange = false; // Manual range selection, not quick range
                    _selectedQuickRangeKey = null; // Clear quick range key for manual selection
                  });

                  // Add haptic feedback for mobile range selection
                  if (isCompactScreen) {
                    _triggerHapticFeedback();
                  }
                } else if (dates.length == 1) {
                  setState(() {
                    _selectedStartDate = dates[0];
                    _selectedEndDate = null;
                    _userHasSelectedQuickRange = false; // Manual selection, not quick range
                    _selectedQuickRangeKey = null; // Clear quick range key for manual selection
                  });

                  // Add haptic feedback for mobile partial range selection
                  if (isCompactScreen) {
                    _triggerHapticFeedback();
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
