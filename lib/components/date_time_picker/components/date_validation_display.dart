import 'dart:async';

import 'package:flutter/material.dart';
import '../../../time/date_format_service.dart';
import '../constants/date_time_picker_translation_keys.dart';
import '../models/date_picker_types.dart';

/// Debounce delay for validation to prevent excessive function calls
const Duration _validationDebounceDelay = Duration(milliseconds: 300);

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
  static const double fontSizeSmall = 14.0;

  // Icon sizes
  static const double iconSizeLarge = 24.0;
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
  final DateTime? Function(DateTime?)? dateTimeValidator;
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
  bool? _lastIsValid;
  Timer? _validationTimer;
  List<String>? _cachedValidationErrors;
  bool? _cachedIsValid;

  @override
  void dispose() {
    _validationTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(DateValidationDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger validation when relevant dependencies change
    final oldDateHash = Object.hash(
      oldWidget.selectedDate,
      oldWidget.selectedStartDate,
      oldWidget.selectedEndDate,
      oldWidget.minDate,
      oldWidget.maxDate,
      oldWidget.dateTimeValidator,
      oldWidget.allowNullConfirm,
    );

    final newDateHash = Object.hash(
      widget.selectedDate,
      widget.selectedStartDate,
      widget.selectedEndDate,
      widget.minDate,
      widget.maxDate,
      widget.dateTimeValidator,
      widget.allowNullConfirm,
    );

    if (oldDateHash != newDateHash) {
      _scheduleValidation();
    }
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.translations[key] ?? fallback;
  }

  /// Triggers debounced validation to prevent excessive function calls
  void _scheduleValidation() {
    _validationTimer?.cancel();
    _validationTimer = Timer(_validationDebounceDelay, () {
      if (mounted) {
        setState(() {
          _cachedValidationErrors = _performValidation();
          _cachedIsValid = _cachedValidationErrors!.isEmpty;
        });
      }
    });
  }

  /// Performs the actual validation logic
  List<String> _performValidation() {
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
      if (widget.dateTimeValidator != null) {
        final validationResult = widget.dateTimeValidator!(widget.selectedDate);
        if (validationResult == null) {
          // Validator returned null, meaning the date is invalid
          if (widget.validationErrorMessage != null) {
            validationErrors.add(widget.validationErrorMessage!);
          } else {
            validationErrors.add(_getLocalizedText(
                DateTimePickerTranslationKey.selectedDateMustBeAtOrBefore, 'Selected date is invalid'));
          }
        }
        // If validator returns a DateTime, consider it valid (no error)
      }

      // Check min/max date constraints (ensure consistent timezone handling)
      final selectedLocal = widget.selectedDate!.toLocal();
      final minLocal = widget.minDate?.toLocal();
      final maxLocal = widget.maxDate?.toLocal();

      if (minLocal != null && selectedLocal.isBefore(minLocal)) {
        final dateStr = DateFormatService.formatForInput(minLocal, context, type: DateFormatType.dateTime);
        validationErrors.add(_getLocalizedText(
                DateTimePickerTranslationKey.selectedDateMustBeAtOrAfter, 'Selected date must be at or after $dateStr')
            .replaceAll('{date}', dateStr));
      }
      if (maxLocal != null && selectedLocal.isAfter(maxLocal)) {
        final dateStr = DateFormatService.formatForInput(maxLocal, context, type: DateFormatType.dateTime);
        validationErrors.add(_getLocalizedText(DateTimePickerTranslationKey.selectedDateMustBeAtOrBefore,
                'Selected date must be at or before $dateStr')
            .replaceAll('{date}', dateStr));
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
        final dateStr = DateFormatService.formatForInput(minLocal, context, type: DateFormatType.date);
        validationErrors.add(_getLocalizedText(
                DateTimePickerTranslationKey.startDateMustBeAtOrAfter, 'Start date must be at or after $dateStr')
            .replaceAll('{date}', dateStr));
      }
      if (maxLocal != null && endLocal.isAfter(maxLocal)) {
        final dateStr = DateFormatService.formatForInput(maxLocal, context, type: DateFormatType.date);
        validationErrors.add(_getLocalizedText(
                DateTimePickerTranslationKey.endDateMustBeAtOrBefore, 'End date must be at or before $dateStr')
            .replaceAll('{date}', dateStr));
      }
    }

    return validationErrors;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showErrorContainer) {
      return const SizedBox.shrink();
    }

    // Schedule validation on first build or when dependencies change
    if (_cachedValidationErrors == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scheduleValidation();
        }
      });

      // Show initial validation immediately for better UX
      _cachedValidationErrors = _performValidation();
      _cachedIsValid = _cachedValidationErrors!.isEmpty;
    }

    final validationErrors = _cachedValidationErrors!;
    final isValid = _cachedIsValid!;

    // Notify parent of validation state change only if it changed
    if (_lastIsValid != isValid) {
      _lastIsValid = isValid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onValidationChanged?.call(isValid);
        }
      });
    }

    if (validationErrors.isEmpty) {
      return const SizedBox.shrink();
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
            // Error messages with prominent icon
            ...validationErrors.map((error) => Padding(
                  padding: const EdgeInsets.only(bottom: _DateValidationDisplayDesign.spacingXSmall),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        size: _DateValidationDisplayDesign.iconSizeLarge,
                      ),
                      const SizedBox(width: _DateValidationDisplayDesign.spacingSmall),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontSize: _DateValidationDisplayDesign.fontSizeSmall,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
