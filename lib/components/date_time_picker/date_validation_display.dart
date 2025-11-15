import 'package:flutter/material.dart';
import 'dart:async';
import '../../time/date_format_service.dart';
import 'date_time_picker_translation_keys.dart';
import 'date_picker_types.dart';

/// Design constants for date validation display
class _DateValidationDisplayDesign {
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingXSmall = 4.0;

  // Border radius
  static const double radiusSmall = 8.0;

  // Border width
  static const double borderWidth = 1.0;

  // Font sizes
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;

  // Icon sizes
  static const double iconSizeMedium = 20.0;
}

/// A reusable date validation display component extracted from DatePickerDialog
///
/// This widget provides validation feedback with debounced performance optimization
/// and supports both single date and date range validation modes.
class DateValidationDisplay extends StatefulWidget {
  final DateSelectionMode selectionMode;
  final DateTime? selectedDate;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool Function(DateTime?)? dateTimeValidator;
  final String? validationErrorMessage;
  final bool allowNullConfirm;
  final Map<DateTimePickerTranslationKey, String> translations;
  final bool showErrorContainer;
  final void Function(bool)? onValidationChanged;

  const DateValidationDisplay({
    super.key,
    required this.selectionMode,
    this.selectedDate,
    this.selectedStartDate,
    this.selectedEndDate,
    this.minDate,
    this.maxDate,
    this.dateTimeValidator,
    this.validationErrorMessage,
    this.allowNullConfirm = false,
    required this.translations,
    this.showErrorContainer = true,
    this.onValidationChanged,
  });

  @override
  State<DateValidationDisplay> createState() => _DateValidationDisplayState();
}

class _DateValidationDisplayState extends State<DateValidationDisplay> {
  // Performance optimization: debounce timer for validation
  Timer? _validationDebounceTimer;

  // Performance optimization: cached validation results
  String? _cachedValidationResult;
  DateTime? _lastValidationCheck;

  @override
  void dispose() {
    _validationDebounceTimer?.cancel();
    super.dispose();
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.translations[key] ?? fallback;
  }

  /// Returns a list of validation error messages for the current selection
  List<String> _getValidationErrors() {
    List<String> validationErrors = [];

    if (widget.selectionMode == DateSelectionMode.single) {
      // Check if selection is required but not provided
      if (widget.selectedDate == null) {
        if (!widget.allowNullConfirm) {
          validationErrors
              .add(_getLocalizedText(DateTimePickerTranslationKey.noDateSelected, 'A date must be selected.'));
        }
        return validationErrors; // Return early if no selection
      }

      // Check custom validator
      if (widget.dateTimeValidator != null &&
          !widget.dateTimeValidator!(widget.selectedDate) &&
          widget.validationErrorMessage != null) {
        validationErrors.add(widget.validationErrorMessage!);
      }

      // Check min/max date constraints (ensure consistent timezone handling)
      final selectedLocal = widget.selectedDate!.toLocal();
      final minLocal = widget.minDate?.toLocal();
      final maxLocal = widget.maxDate?.toLocal();

      if (minLocal != null && selectedLocal.isBefore(minLocal)) {
        validationErrors.add(_getLocalizedText(DateTimePickerTranslationKey.selectedDateMustBeAtOrAfter,
            'Selected date must be at or after ${DateFormatService.formatForInput(minLocal, context, type: DateFormatType.dateTime)}'));
      }
      if (maxLocal != null && selectedLocal.isAfter(maxLocal)) {
        validationErrors.add(_getLocalizedText(DateTimePickerTranslationKey.selectedDateMustBeAtOrBefore,
            'Selected date must be at or before ${DateFormatService.formatForInput(maxLocal, context, type: DateFormatType.dateTime)}'));
      }
    } else {
      // Range selection validation
      if (widget.selectedStartDate == null || widget.selectedEndDate == null) {
        if (!widget.allowNullConfirm) {
          validationErrors
              .add(_getLocalizedText(DateTimePickerTranslationKey.noDatesSelected, 'A date range must be selected.'));
        }
        return validationErrors; // Return early if incomplete range
      }

      final startLocal = widget.selectedStartDate!.toLocal();
      final endLocal = widget.selectedEndDate!.toLocal();
      final minLocal = widget.minDate?.toLocal();
      final maxLocal = widget.maxDate?.toLocal();

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

    return validationErrors;
  }

  // Debounced validation for performance optimization
  void _debouncedValidation() {
    _validationDebounceTimer?.cancel();
    _validationDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final isValid = _getValidationErrors().isEmpty;
        setState(() {
          _cachedValidationResult = isValid ? null : 'has_errors';
          _lastValidationCheck = DateTime.now();
        });
        // Notify parent of validation change
        widget.onValidationChanged?.call(isValid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showErrorContainer) {
      return const SizedBox.shrink();
    }

    // Use cached validation result if available and recent
    final now = DateTime.now();
    final useCached = _cachedValidationResult != null &&
        _lastValidationCheck != null &&
        now.difference(_lastValidationCheck!).inMilliseconds < 500;

    final validationErrors =
        useCached ? (_cachedValidationResult == null ? <String>[] : ['validation_error']) : _getValidationErrors();

    // Always trigger validation notification for valid selections
    if (validationErrors.isEmpty) {
      if (!useCached || _cachedValidationResult != null) {
        // Update cache for valid selections
        setState(() {
          _cachedValidationResult = null;
          _lastValidationCheck = DateTime.now();
        });
        // Notify parent after the current build phase to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onValidationChanged?.call(true);
        });
      }
    } else if (validationErrors.isNotEmpty) {
      // Trigger debounced validation for next update
      if (!useCached) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _debouncedValidation();
        });
      }

      return Semantics(
        container: true,
        liveRegion: true,
        label: 'Validation errors',
        child: Container(
          padding: const EdgeInsets.all(_DateValidationDisplayDesign.spacingMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(_DateValidationDisplayDesign.radiusSmall),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              width: _DateValidationDisplayDesign.borderWidth,
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
                    size: _DateValidationDisplayDesign.iconSizeMedium,
                  ),
                  const SizedBox(width: _DateValidationDisplayDesign.spacingSmall),
                  Expanded(
                    child: Text(
                      _getLocalizedText(DateTimePickerTranslationKey.cannotSelectDateBeforeMinDate, 'Validation Error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: _DateValidationDisplayDesign.fontSizeSmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (validationErrors.first != 'validation_error') ...[
                const SizedBox(height: _DateValidationDisplayDesign.spacingSmall),
                ...validationErrors.map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: _DateValidationDisplayDesign.spacingXSmall),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: _DateValidationDisplayDesign.spacingXSmall,
                            height: _DateValidationDisplayDesign.spacingXSmall,
                            margin: const EdgeInsets.only(
                                top: _DateValidationDisplayDesign.spacingSmall -
                                    _DateValidationDisplayDesign.spacingXSmall,
                                right: _DateValidationDisplayDesign.spacingSmall),
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
                                fontSize: _DateValidationDisplayDesign.fontSizeXSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink(); // Return empty widget if no errors
  }
}
