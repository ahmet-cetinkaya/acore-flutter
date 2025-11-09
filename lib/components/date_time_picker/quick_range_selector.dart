import 'package:flutter/material.dart';
import 'date_time_picker_translation_keys.dart';

/// Design constants for quick range selector
class _QuickRangeSelectorDesign {
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXSmall = 4.0;

  // Border width
  static const double borderWidth = 1.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
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

/// A reusable quick range selector component extracted from DatePickerDialog
///
/// This widget provides a quick selection interface for predefined date ranges
/// with support for range filtering and refresh toggles.
class QuickRangeSelector extends StatefulWidget {
  final List<QuickDateRange>? quickRanges;
  final String? selectedQuickRangeKey;
  final bool showQuickRanges;
  final bool showRefreshToggle;
  final bool refreshEnabled;
  final Map<DateTimePickerTranslationKey, String> translations;
  final void Function(QuickDateRange) onQuickRangeSelected;
  final VoidCallback? onRefreshToggle;
  final VoidCallback? onClear;
  final bool hasSelection;
  final bool? isCompactScreen;
  final double? actionButtonRadius;

  const QuickRangeSelector({
    super.key,
    this.quickRanges,
    this.selectedQuickRangeKey,
    required this.showQuickRanges,
    required this.showRefreshToggle,
    required this.refreshEnabled,
    required this.translations,
    required this.onQuickRangeSelected,
    this.onRefreshToggle,
    this.onClear,
    required this.hasSelection,
    this.isCompactScreen,
    this.actionButtonRadius,
  });

  @override
  State<QuickRangeSelector> createState() => _QuickRangeSelectorState();
}

class _QuickRangeSelectorState extends State<QuickRangeSelector> {
  /// Checks if the current screen is compact (mobile)
  bool _isCompactScreen(BuildContext context) {
    return widget.isCompactScreen ?? MediaQuery.of(context).size.width < 600;
  }

  /// Get localized text with fallback
  String _getLocalizedText(DateTimePickerTranslationKey key, String fallback) {
    return widget.translations[key] ?? fallback;
  }

  /// Check if there's an active quick selection
  bool _hasActiveQuickSelection() {
    return widget.selectedQuickRangeKey != null;
  }

  /// Show quick selection dialog
  void _showQuickSelectionDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _QuickSelectionDialog(
          quickRanges: widget.quickRanges,
          selectedQuickRangeKey: widget.selectedQuickRangeKey,
          showRefreshToggle: widget.showRefreshToggle,
          refreshEnabled: widget.refreshEnabled,
          translations: widget.translations,
          onQuickRangeSelected: widget.onQuickRangeSelected,
          onRefreshToggle: widget.onRefreshToggle,
          isCompactScreen: _isCompactScreen(context),
          title: _getLocalizedText(DateTimePickerTranslationKey.dateRanges, 'Date Ranges'),
          actionButtonRadius: widget.actionButtonRadius,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showQuickRanges || widget.quickRanges == null || widget.quickRanges!.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasQuickSelection = _hasActiveQuickSelection();

    // Get current selection label
    String currentSelectionLabel = '';
    if (hasQuickSelection) {
      currentSelectionLabel = widget.quickRanges!
          .firstWhere((r) => widget.selectedQuickRangeKey == r.key, orElse: () => widget.quickRanges!.first)
          .label;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: _QuickRangeSelectorDesign.spacingMedium),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: _QuickRangeSelectorDesign.spacingSmall,
        runSpacing: _QuickRangeSelectorDesign.spacingSmall,
        children: [
          // Quick selection button with refresh indicator
          Semantics(
            button: true,
            label: hasQuickSelection
                ? 'Currently selected: $currentSelectionLabel. Tap to change selection.'
                : 'Quick date range selection',
            hint: 'Opens quick range selection dialog',
            child: OutlinedButton.icon(
              onPressed: _showQuickSelectionDialog,
              icon: Icon(
                Icons.speed,
                size: _QuickRangeSelectorDesign.iconSizeMedium,
                color: hasQuickSelection ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      hasQuickSelection
                          ? currentSelectionLabel
                          : _getLocalizedText(DateTimePickerTranslationKey.quickSelection, 'Quick Selection'),
                      style: TextStyle(
                        fontSize: _QuickRangeSelectorDesign.fontSizeSmall,
                        fontWeight: FontWeight.w500,
                        color: hasQuickSelection
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasQuickSelection && widget.showRefreshToggle && widget.refreshEnabled) ...[
                    SizedBox(width: _QuickRangeSelectorDesign.spacingSmall),
                    Icon(
                      Icons.autorenew,
                      size: _QuickRangeSelectorDesign.iconSizeSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ],
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: _QuickRangeSelectorDesign.spacingSmall,
                  vertical: _QuickRangeSelectorDesign.spacingSmall,
                ),
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: hasQuickSelection
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
                      : Theme.of(context).colorScheme.outline,
                  width: _QuickRangeSelectorDesign.borderWidth,
                ),
              ),
            ),
          ),
          SizedBox(width: _QuickRangeSelectorDesign.spacingSmall),
          // Clear button
          Semantics(
            button: true,
            label: 'Clear selection',
            hint: widget.hasSelection ? 'Clear all selected dates and ranges' : 'No selection to clear',
            child: OutlinedButton.icon(
              onPressed: widget.hasSelection ? widget.onClear : null,
              icon: Icon(
                Icons.delete_outline,
                size: _QuickRangeSelectorDesign.iconSizeMedium,
              ),
              label: Text(
                _getLocalizedText(DateTimePickerTranslationKey.clear, 'Clear'),
                style: TextStyle(
                  fontSize: _QuickRangeSelectorDesign.fontSizeSmall,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: _QuickRangeSelectorDesign.spacingSmall,
                  vertical: _QuickRangeSelectorDesign.spacingSmall,
                ),
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: _QuickRangeSelectorDesign.borderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal quick selection dialog for range selection
class _QuickSelectionDialog extends StatefulWidget {
  final List<QuickDateRange>? quickRanges;
  final String? selectedQuickRangeKey;
  final bool showRefreshToggle;
  final bool refreshEnabled;
  final Map<DateTimePickerTranslationKey, String> translations;
  final void Function(QuickDateRange) onQuickRangeSelected;
  final VoidCallback? onRefreshToggle;
  final bool isCompactScreen;
  final String title;
  final double? actionButtonRadius;

  const _QuickSelectionDialog({
    required this.quickRanges,
    required this.onQuickRangeSelected,
    required this.showRefreshToggle,
    required this.refreshEnabled,
    required this.translations,
    this.selectedQuickRangeKey,
    required this.onRefreshToggle,
    this.isCompactScreen = false,
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
    widget.onRefreshToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: widget.isCompactScreen
                  ? _QuickRangeSelectorDesign.fontSizeLarge
                  : _QuickRangeSelectorDesign.fontSizeXLarge,
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
                      fontSize: _QuickRangeSelectorDesign.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
              ),
              SizedBox(height: _QuickRangeSelectorDesign.spacingMedium),
              Wrap(
                spacing: _QuickRangeSelectorDesign.spacingSmall,
                runSpacing: _QuickRangeSelectorDesign.spacingSmall,
                children: widget.quickRanges!.map((QuickDateRange range) {
                  final isSelected = widget.selectedQuickRangeKey == range.key;
                  return FilterChip(
                    label: Text(
                      range.label,
                      style: TextStyle(
                        fontSize: _QuickRangeSelectorDesign.fontSizeSmall,
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
                    pressElevation: _QuickRangeSelectorDesign.spacingXSmall,
                    surfaceTintColor: Theme.of(context).primaryColor,
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      width: _QuickRangeSelectorDesign.borderWidth,
                    ),
                    checkmarkColor: Theme.of(context).primaryColor,
                    selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                  );
                }).toList(),
              ),
              SizedBox(height: _QuickRangeSelectorDesign.spacingLarge),
            ],
            if (widget.showRefreshToggle) ...[
              Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
              SizedBox(height: _QuickRangeSelectorDesign.spacingMedium),
              Text(
                widget.translations[DateTimePickerTranslationKey.refreshSettingsLabel] ?? 'Refresh Settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: _QuickRangeSelectorDesign.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
              ),
              SizedBox(height: _QuickRangeSelectorDesign.spacingMedium),
              Row(
                children: [
                  Icon(
                    _localRefreshEnabled ? Icons.autorenew : Icons.refresh,
                    size: _QuickRangeSelectorDesign.iconSizeMedium,
                    color: _localRefreshEnabled
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: _QuickRangeSelectorDesign.spacingSmall),
                  Expanded(
                    child: Text(
                      widget.translations[DateTimePickerTranslationKey.refreshSettings] ??
                          DateTimePickerTranslationKey.refreshSettings.name,
                      style: TextStyle(
                        fontSize: _QuickRangeSelectorDesign.fontSizeSmall,
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
        Semantics(
          button: true,
          label: 'Close quick range selection',
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.actionButtonRadius ?? 8.0),
              ),
            ),
            child: Text(
              widget.translations[DateTimePickerTranslationKey.cancel] ?? DateTimePickerTranslationKey.cancel.name,
            ),
          ),
        ),
      ],
    );
  }
}
