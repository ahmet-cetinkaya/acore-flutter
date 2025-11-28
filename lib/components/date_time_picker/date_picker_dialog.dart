import 'date_picker_content.dart';
import 'package:flutter/material.dart';
import '../../time/date_format_service.dart';
import '../../utils/responsive_dialog_helper.dart';
import '../../utils/dialog_size.dart';

import 'date_picker_types.dart';
import 'date_picker_mobile_content.dart';
import 'date_time_picker_constants.dart';
import 'date_time_picker_translation_keys.dart';

/// Unified Date Picker Dialog - clean wrapper around DatePickerContent
///
/// This dialog provides a responsive date picker that works across all platforms:
/// - Desktop: Modal dialog with full functionality
/// - Mobile: Bottom sheet with mobile-optimized interface (useMobileScaffoldLayout=true)
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

  /// Shows the unified date picker dialog with responsive behavior
  /// On desktop: shows as modal dialog
  /// On mobile: shows as bottom sheet with mobile-optimized AppBar
  static Future<DatePickerResult?> showResponsive({
    required BuildContext context,
    required DatePickerConfig config,
  }) async {
    // Create desktop content with Scaffold structure
    final desktopContent = _ResponsiveDialogContent(
      config: config,
      onComplete: (result) {
        if (result != null) {
          final datePickerResult = DatePickerResult(
            selectedDate: result.selectedDate,
            startDate: result.startDate,
            endDate: result.endDate,
            isRefreshEnabled: result.isRefreshEnabled ?? false,
            quickSelectionKey: result.quickSelectionKey,
            isAllDay: result.isAllDay,
          );
          Navigator.of(context).pop(datePickerResult);
        } else {
          Navigator.of(context).pop(null);
        }
      },
      onCancel: () {
        Navigator.of(context).pop(DatePickerResult.cancelled());
      },
    );

    // Helper to get localized text
    String getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
      if (config.translations != null) {
        return config.translations![key] ?? fallback;
      }
      return fallback;
    }

    // Resolve title
    String appBarTitle;
    if (config.selectionMode == DateSelectionMode.single) {
      appBarTitle = config.singleDateTitle ??
          config.titleText ??
          getLocalizedText(DateTimePickerTranslationKey.selectDateTitle, 'Select Date & Time');
    } else {
      appBarTitle = config.dateRangeTitle ??
          config.titleText ??
          getLocalizedText(DateTimePickerTranslationKey.selectDateRangeTitle, 'Select Date Range');
    }

    // Resolve button texts
    final doneButtonText = config.doneButtonText ?? getLocalizedText(DateTimePickerTranslationKey.confirm, 'Done');
    final cancelButtonText = config.cancelButtonText ?? getLocalizedText(DateTimePickerTranslationKey.cancel, 'Cancel');

    // Create mobile content (with AppBar)
    final mobileContent = DatePickerMobileContent(
      appBarTitle: appBarTitle,
      doneButtonText: doneButtonText,
      cancelButtonText: cancelButtonText,
      config: DatePickerContentConfig(
        validationErrorAtTop: true,
        selectionMode: config.selectionMode,
        initialDate: config.initialDate,
        initialStartDate: config.initialStartDate,
        initialEndDate: config.initialEndDate,
        minDate: config.minDate,
        maxDate: config.maxDate,
        formatType: config.formatType ?? DateFormatType.date,
        quickRanges: config.quickRanges,
        showTime: config.showTime,
        showQuickRanges: config.showQuickRanges,
        enableManualInput: config.enableManualInput,
        dateFormatHint: config.dateFormatHint,
        theme: config.theme,
        locale: config.locale,
        translations: config.translations,
        allowNullConfirm: config.allowNullConfirm,
        showRefreshToggle: config.showRefreshToggle,
        initialRefreshEnabled: config.initialRefreshEnabled,
        onRefreshToggleChanged: config.onRefreshToggleChanged,
        dateTimeValidator: config.dateTimeValidator,
        validationErrorMessage: config.validationErrorMessage,
        actionButtonRadius: config.actionButtonRadius,
      ),
      onConfirm: null,
      onCancel: () {
        Navigator.of(context).pop(DatePickerResult.cancelled());
      },
    );

    // Use ResponsiveDialogHelper for proper responsive behavior
    return await ResponsiveDialogHelper.showResponsiveDialog<DatePickerResult>(
      context: context,
      child: desktopContent,
      mobileChild: mobileContent,
      size: config.dialogSize ?? DialogSize.medium,
      isScrollable: true,
      isDismissible: true,
      enableDrag: true,
    );
  }
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  DatePickerResult? _currentResult;

  @override
  void initState() {
    super.initState();
    _initializeResult();
  }

  @override
  void dispose() {
    super.dispose();
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

  void _handleConfirm() {
    Navigator.pop(context, _currentResult);
  }

  void _handleSelectionChanged(DatePickerContentResult result) {
    // Update current result when selection changes
    final datePickerResult = DatePickerResult(
      selectedDate: result.selectedDate,
      startDate: result.startDate,
      endDate: result.endDate,
      isRefreshEnabled: result.isRefreshEnabled ?? false,
      quickSelectionKey: result.quickSelectionKey,
      isAllDay: result.isAllDay,
    );
    setState(() {
      _currentResult = datePickerResult;
    });
  }

  void _onCancel() {
    Navigator.of(context).pop(DatePickerResult.cancelled());
  }

  /// Check if the screen is compact (for mobile UI adjustments)
  bool _isCompactScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    if (widget.config.translations != null) {
      return widget.config.translations![key] ?? fallback;
    }
    return fallback;
  }

  /// Get the dialog title based on configuration and selection mode
  String _getDialogTitle() {
    // Priority order: specific title → titleText → translated fallback
    if (widget.config.selectionMode == DateSelectionMode.single) {
      if (widget.config.singleDateTitle != null) {
        return widget.config.singleDateTitle!;
      }
    } else {
      if (widget.config.dateRangeTitle != null) {
        return widget.config.dateRangeTitle!;
      }
    }

    // Fallback to generic titleText
    if (widget.config.titleText != null) {
      return widget.config.titleText!;
    }

    // Final fallback to translated text
    if (widget.config.selectionMode == DateSelectionMode.single) {
      return _getLocalizedText(DateTimePickerTranslationKey.selectDateTitle, 'Select Date & Time');
    } else {
      return _getLocalizedText(DateTimePickerTranslationKey.selectDateRangeTitle, 'Select Date Range');
    }
  }

  /// Get the localized done button text
  String _getDoneButtonText() {
    if (widget.config.doneButtonText != null) {
      return widget.config.doneButtonText!;
    }
    return _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Done');
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme ?? Theme.of(context);
    final isCompactScreen = _isCompactScreen(context);

    // Create content config for DatePickerContent
    final contentConfig = DatePickerContentConfig(
      selectionMode: widget.config.selectionMode,
      initialDate: widget.config.initialDate,
      initialStartDate: widget.config.initialStartDate,
      initialEndDate: widget.config.initialEndDate,
      minDate: widget.config.minDate,
      maxDate: widget.config.maxDate,
      formatType: widget.config.formatType ?? DateFormatType.date,
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
      // Force validation at top if using mobile scaffold layout
      validationErrorAtTop: widget.config.useMobileScaffoldLayout || widget.config.validationErrorAtTop,
      onSelectionChanged: _handleSelectionChanged,
    );

    // If using mobile scaffold layout, use proper Scaffold structure
    if (widget.config.useMobileScaffoldLayout) {
      return Theme(
        data: theme,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: false,
            title: Text(
              _getDialogTitle(),
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
                  _getDoneButtonText(),
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
                onCancel: _onCancel,
              ),
            ),
          ),
        ),
      );
    }

    // Desktop: Use AlertDialog wrapper with Scaffold layout for proper structure
    final dialogWidth = isCompactScreen ? _DatePickerDesign.compactDialogWidth : _DatePickerDesign.maxDialogWidth;
    final appBarTitle = _getDialogTitle();

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16.0),
      contentPadding: EdgeInsets.zero,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shadowColor: theme.shadowColor,
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_DatePickerDesign.radiusSmall),
      ),
      content: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: false,
            title: Text(
              appBarTitle,
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
                  _getDoneButtonText(),
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
              child: Theme(
                data: theme,
                child: DatePickerContent(
                  config: contentConfig,
                  onCancel: _onCancel,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive content widget for showResponsive with proper Scaffold layout
class _ResponsiveDialogContent extends StatefulWidget {
  final DatePickerConfig config;
  final void Function(DatePickerContentResult?) onComplete;
  final VoidCallback onCancel;

  const _ResponsiveDialogContent({
    required this.config,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<_ResponsiveDialogContent> createState() => _ResponsiveDialogContentState();
}

class _ResponsiveDialogContentState extends State<_ResponsiveDialogContent> {
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

  void _handleConfirm() {
    Navigator.pop(context, _currentResult);
  }

  void _handleSelectionChanged(DatePickerContentResult result) {
    // Update current result when selection changes
    final datePickerResult = DatePickerResult(
      selectedDate: result.selectedDate,
      startDate: result.startDate,
      endDate: result.endDate,
      isRefreshEnabled: result.isRefreshEnabled ?? false,
      quickSelectionKey: result.quickSelectionKey,
      isAllDay: result.isAllDay,
    );
    setState(() {
      _currentResult = datePickerResult;
    });
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    if (widget.config.translations != null) {
      return widget.config.translations![key] ?? fallback;
    }
    return fallback;
  }

  /// Get the dialog title based on configuration and selection mode
  String _getDialogTitle() {
    // Priority order: specific title → titleText → translated fallback
    if (widget.config.selectionMode == DateSelectionMode.single) {
      if (widget.config.singleDateTitle != null) {
        return widget.config.singleDateTitle!;
      }
    } else {
      if (widget.config.dateRangeTitle != null) {
        return widget.config.dateRangeTitle!;
      }
    }

    // Fallback to generic titleText
    if (widget.config.titleText != null) {
      return widget.config.titleText!;
    }

    // Final fallback to translated text
    if (widget.config.selectionMode == DateSelectionMode.single) {
      return _getLocalizedText(DateTimePickerTranslationKey.selectDateTitle, 'Select Date & Time');
    } else {
      return _getLocalizedText(DateTimePickerTranslationKey.selectDateRangeTitle, 'Select Date Range');
    }
  }

  /// Get the localized done button text
  String _getDoneButtonText() {
    if (widget.config.doneButtonText != null) {
      return widget.config.doneButtonText!;
    }
    return _getLocalizedText(DateTimePickerTranslationKey.confirm, 'Done');
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.theme ?? Theme.of(context);
    final appBarTitle = _getDialogTitle();

    // Create content config for DatePickerContent
    final contentConfig = DatePickerContentConfig(
      selectionMode: widget.config.selectionMode,
      initialDate: widget.config.initialDate,
      initialStartDate: widget.config.initialStartDate,
      initialEndDate: widget.config.initialEndDate,
      minDate: widget.config.minDate,
      maxDate: widget.config.maxDate,
      formatType: widget.config.formatType ?? DateFormatType.date,
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
      validationErrorAtTop: true,
      onSelectionChanged: _handleSelectionChanged,
    );

    // Use basic layout structure for dialog (no Scaffold nesting)
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  Expanded(
                    child: Text(
                      appBarTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  TextButton(
                    key: const Key('date_picker_done_button'),
                    onPressed: _handleConfirm,
                    child: Text(
                      _getDoneButtonText(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Theme(
                  data: theme,
                  child: DatePickerContent(
                    config: contentConfig,
                    onComplete: widget.onComplete,
                    onCancel: widget.onCancel,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile-optimized design constants for date picker
class _DatePickerDesign {
  // Border radius
  static const double radiusSmall = 8.0;

  // Dialog sizing
  static const double maxDialogWidth = 600.0;
  static const double compactDialogWidth = 320.0;

  // Prevent instantiation
  _DatePickerDesign._();
}
