import 'package:flutter/material.dart';
import '../models/date_picker_types.dart';
import 'date_selection_utils.dart';
import '../constants/date_time_picker_translation_keys.dart';
import 'quick_range_selector.dart' as quick;
import '../../../utils/haptic_feedback_util.dart';

/// Design constants for quick selection
class _QuickSelectionDesign {
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double radiusSmall = 8.0;
  static const double fontSizeMedium = 16.0;
  static const double borderWidth = 1.0;
  static const double buttonHeight = 44.0;
  static const double iconContainerSize = 32.0;
  static const double iconSize = 18.0;
}

/// Quick selection result containing the selected date/range and refresh state
class QuickSelectionResult {
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool refreshEnabled;

  const QuickSelectionResult({
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.refreshEnabled = false,
  });
}

/// Quick selection widget for date picker.
///
/// Provides quick selection buttons for common date choices like Today, Tomorrow,
/// Weekend, Next Week, and No Date. Supports both single date and range selection modes.
class DatePickerQuickSelection extends StatelessWidget {
  final DateSelectionMode selectionMode;
  final DateTime? selectedDate;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final bool refreshEnabled;
  final DateTime? minDate;
  final List<quick.QuickDateRange>? quickRanges;
  final Map<DateTimePickerTranslationKey, String>? translations;
  final ValueChanged<QuickSelectionResult> onSelectionChanged;
  final VoidCallback? onRefreshToggleChanged;

  const DatePickerQuickSelection({
    super.key,
    required this.selectionMode,
    required this.onSelectionChanged,
    this.selectedDate,
    this.selectedStartDate,
    this.selectedEndDate,
    this.refreshEnabled = false,
    this.minDate,
    this.quickRanges,
    this.translations,
    this.onRefreshToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isRangeMode = selectionMode == DateSelectionMode.range;

    return Container(
      margin: const EdgeInsets.only(bottom: _QuickSelectionDesign.spacingMedium),
      child: Column(
        children: isRangeMode ? _buildRangeButtons(context) : _buildSingleButtons(context),
      ),
    );
  }

  List<Widget> _buildRangeButtons(BuildContext context) {
    return [
      _buildButton(
        context: context,
        text: DateSelectionUtils.getDayOfWeek(translations),
        onTap: () => _selectRangeToday(context),
        type: 'today',
        isSelected: _isRangeTodaySelected(),
        label: DateSelectionUtils.getLocalizedText(
          translations,
          DateTimePickerTranslationKey.quickSelectionToday,
          'Today',
        ),
      ),
      const SizedBox(height: _QuickSelectionDesign.spacingXSmall),
      _buildButton(
        context: context,
        text: '7',
        onTap: () => _select7DaysAgo(context),
        type: 'weekend',
        isSelected: _is7DaysAgoSelected(),
        label: DateSelectionUtils.getLocalizedText(
          translations,
          DateTimePickerTranslationKey.quickSelectionLastWeek,
          'Last Week',
        ),
      ),
      const SizedBox(height: _QuickSelectionDesign.spacingXSmall),
      _buildButton(
        context: context,
        text: '30',
        onTap: () => _select30DaysAgo(context),
        type: 'noDate',
        isSelected: _is30DaysAgoSelected(),
        label: DateSelectionUtils.getLocalizedText(
          translations,
          DateTimePickerTranslationKey.quickSelectionLastMonth,
          'Last Month',
        ),
      ),
      const SizedBox(height: _QuickSelectionDesign.spacingXSmall),
      _buildButton(
        context: context,
        text: 'x',
        icon: Icons.close,
        onTap: () => _selectNoDateRange(context),
        type: 'tomorrow',
        isSelected: _isNoDateRangeSelected(),
        label: DateSelectionUtils.getLocalizedText(
          translations,
          DateTimePickerTranslationKey.quickSelectionNoDate,
          'No Date',
        ),
      ),
      // Refresh checkbox for range selection (only show when date is selected)
      if (!_isNoDateRangeSelected()) ...[
        const SizedBox(height: _QuickSelectionDesign.spacingXSmall),
        _buildButton(
          context: context,
          text: refreshEnabled ? '✓' : '↻',
          icon: Icons.autorenew,
          onTap: () {
            onRefreshToggleChanged?.call();
            HapticFeedbackUtil.triggerHapticFeedback(context);
          },
          type: 'today',
          isSelected: refreshEnabled,
          label: DateSelectionUtils.getLocalizedText(
            translations,
            DateTimePickerTranslationKey.refreshSettings,
            'Auto-refresh',
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildSingleButtons(BuildContext context) {
    // Use custom quick ranges if provided
    if (quickRanges != null && quickRanges!.isNotEmpty) {
      return quickRanges!.where((range) {
        // Always include "No Date" option
        if (range.key == 'no_date') return true;

        // Filter out ranges before minDate
        if (minDate != null) {
          final startDate = range.startDateCalculator();
          final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
          final minDateStartOfDay = DateTime(minDate!.year, minDate!.month, minDate!.day);
          if (startOfDay.isBefore(minDateStartOfDay)) return false;
        }
        return true;
      }).map((range) {
        return _buildButton(
          context: context,
          text: DateSelectionUtils.getShortLabelForRange(range, translations),
          icon: DateSelectionUtils.getIconForRange(range),
          onTap: () => _selectQuickRange(context, range),
          type: range.key,
          isSelected: _isQuickSingleSelected(range),
          label: range.label,
        );
      }).toList();
    }

    // Default quick selection buttons
    return [
      _buildButton(
        context: context,
        text: DateSelectionUtils.getDayOfWeek(translations),
        onTap: () => _selectToday(context),
        type: 'today',
        isSelected: _isTodaySelected(),
        label: DateSelectionUtils.getLocalizedText(
          translations,
          DateTimePickerTranslationKey.quickSelectionToday,
          'Today',
        ),
      ),
      if (!DateSelectionUtils.shouldHideTomorrow())
        _buildButton(
          context: context,
          text: DateSelectionUtils.getTomorrowDayOfWeek(translations),
          onTap: () => _selectTomorrow(context),
          type: 'tomorrow',
          isSelected: _isTomorrowSelected(),
          label: DateSelectionUtils.getLocalizedText(
            translations,
            DateTimePickerTranslationKey.quickSelectionTomorrow,
            'Tomorrow',
          ),
        ),
      _buildButton(
        context: context,
        text: DateSelectionUtils.getWeekendDisplayText(translations),
        icon: DateSelectionUtils.getWeekendIcon(),
        onTap: () => _selectThisWeekend(context),
        type: 'weekend',
        isSelected: _isThisWeekendSelected(),
        label: DateSelectionUtils.getWeekendButtonText(translations),
      ),
      if (!DateSelectionUtils.isCurrentlyWeekend())
        _buildButton(
          context: context,
          text: DateSelectionUtils.getNextWeekDayOfWeek(translations),
          icon: Icons.arrow_forward,
          onTap: () => _selectNextWeek(context),
          type: 'nextWeek',
          isSelected: _isNextWeekSelected(),
          label: DateSelectionUtils.getLocalizedText(
            translations,
            DateTimePickerTranslationKey.quickSelectionNextWeek,
            'Next Week',
          ),
        ),
      _buildButton(
        context: context,
        text: 'x',
        icon: Icons.close,
        onTap: () => _selectNoDate(context),
        type: 'noDate',
        isSelected: _isNoDateSelected(),
        label: DateSelectionUtils.getLocalizedText(
          translations,
          DateTimePickerTranslationKey.quickSelectionNoDate,
          'No Date',
        ),
      ),
    ];
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
    required String type,
    bool isSelected = false,
    IconData? icon,
    String? label,
  }) {
    final theme = Theme.of(context);
    final surface2 = theme.colorScheme.surfaceContainerLow;

    return Ink(
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(_QuickSelectionDesign.radiusSmall),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 1.0 : _QuickSelectionDesign.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: () {
          onTap();
          HapticFeedbackUtil.triggerHapticFeedback(context);
        },
        borderRadius: BorderRadius.circular(_QuickSelectionDesign.radiusSmall),
        child: Container(
          width: double.infinity,
          height: _QuickSelectionDesign.buttonHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: _QuickSelectionDesign.spacingMedium,
            vertical: _QuickSelectionDesign.spacingSmall,
          ),
          child: Row(
            children: [
              // Left icon or number with StyledIcon style
              Container(
                width: _QuickSelectionDesign.iconContainerSize,
                height: _QuickSelectionDesign.iconContainerSize,
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : surface2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: icon != null
                      ? Icon(
                          icon,
                          size: _QuickSelectionDesign.iconSize,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        )
                      : Text(
                          text,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: false,
                        ),
                ),
              ),
              const SizedBox(width: _QuickSelectionDesign.spacingSmall),
              // Right text
              Expanded(
                child: Text(
                  label ?? text,
                  style: TextStyle(
                    fontSize: _QuickSelectionDesign.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Selection methods for single date
  void _selectToday(BuildContext context) {
    final now = DateTime.now();
    onSelectionChanged(QuickSelectionResult(
      selectedDate: DateTime(now.year, now.month, now.day, selectedDate?.hour ?? 0, selectedDate?.minute ?? 0),
    ));
  }

  void _selectTomorrow(BuildContext context) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    onSelectionChanged(QuickSelectionResult(
      selectedDate:
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, selectedDate?.hour ?? 0, selectedDate?.minute ?? 0),
    ));
  }

  void _selectThisWeekend(BuildContext context) {
    DateTime targetDate;

    if (DateSelectionUtils.isCurrentlyWeekend()) {
      targetDate = DateSelectionUtils.getNextMonday();
    } else {
      targetDate = DateSelectionUtils.getNextSaturday();
    }

    onSelectionChanged(QuickSelectionResult(
      selectedDate: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        selectedDate?.hour ?? 0,
        selectedDate?.minute ?? 0,
      ),
    ));
  }

  void _selectNextWeek(BuildContext context) {
    final now = DateTime.now();
    final daysUntilNextMonday = DateSelectionUtils.getDaysUntilNextMonday();
    final nextMonday = now.add(Duration(days: daysUntilNextMonday));

    onSelectionChanged(QuickSelectionResult(
      selectedDate: DateTime(
        nextMonday.year,
        nextMonday.month,
        nextMonday.day,
        selectedDate?.hour ?? 0,
        selectedDate?.minute ?? 0,
      ),
    ));
  }

  void _selectNoDate(BuildContext context) {
    onSelectionChanged(const QuickSelectionResult(selectedDate: null));
  }

  void _selectQuickRange(BuildContext context, quick.QuickDateRange range) {
    if (range.key == 'no_date') {
      onSelectionChanged(const QuickSelectionResult(
        selectedDate: null,
        startDate: null,
        endDate: null,
      ));
      return;
    }

    final date = range.startDateCalculator();
    onSelectionChanged(QuickSelectionResult(
      selectedDate: DateTime(date.year, date.month, date.day, selectedDate?.hour ?? 0, selectedDate?.minute ?? 0),
    ));
  }

  // Selection methods for range
  void _selectRangeToday(BuildContext context) {
    final now = DateTime.now();
    onSelectionChanged(QuickSelectionResult(
      startDate: DateTime(now.year, now.month, now.day, 0, 0, 0),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      refreshEnabled: refreshEnabled,
    ));
  }

  void _select7DaysAgo(BuildContext context) {
    final now = DateTime.now();
    final endDate = now.subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 7));

    onSelectionChanged(QuickSelectionResult(
      startDate: DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0),
      endDate: DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59),
      refreshEnabled: refreshEnabled,
    ));
  }

  void _select30DaysAgo(BuildContext context) {
    final now = DateTime.now();
    final endDate = now.subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 30));

    onSelectionChanged(QuickSelectionResult(
      startDate: DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0),
      endDate: DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59),
      refreshEnabled: refreshEnabled,
    ));
  }

  void _selectNoDateRange(BuildContext context) {
    onSelectionChanged(const QuickSelectionResult(
      startDate: null,
      endDate: null,
    ));
  }

  // Selection check methods
  bool _isTodaySelected() {
    if (selectedDate == null) return false;
    return DateSelectionUtils.isSameDay(selectedDate!, DateTime.now());
  }

  bool _isTomorrowSelected() {
    if (selectedDate == null) return false;
    return DateSelectionUtils.isSameDay(selectedDate!, DateTime.now().add(const Duration(days: 1)));
  }

  bool _isThisWeekendSelected() {
    if (selectedDate == null) return false;
    final targetDate = DateSelectionUtils.isCurrentlyWeekend()
        ? DateSelectionUtils.getNextMonday()
        : DateSelectionUtils.getNextSaturday();
    return DateSelectionUtils.isSameDay(selectedDate!, targetDate);
  }

  bool _isNextWeekSelected() {
    if (selectedDate == null) return false;
    final now = DateTime.now();
    final daysUntilNextMonday = DateSelectionUtils.getDaysUntilNextMonday();
    final nextMonday = now.add(Duration(days: daysUntilNextMonday));
    return DateSelectionUtils.isSameDay(selectedDate!, nextMonday);
  }

  bool _isNoDateSelected() => selectedDate == null;

  bool _isNoDateRangeSelected() => selectedStartDate == null && selectedEndDate == null;

  bool _isRangeTodaySelected() {
    if (selectedStartDate == null || selectedEndDate == null) return false;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateSelectionUtils.isSameDay(selectedStartDate!, todayStart) &&
        DateSelectionUtils.isSameDay(selectedEndDate!, todayEnd);
  }

  bool _is7DaysAgoSelected() {
    if (selectedStartDate == null || selectedEndDate == null) return false;
    final now = DateTime.now();
    final endDate = now.subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 7));
    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return DateSelectionUtils.isSameDay(selectedStartDate!, rangeStart) &&
        DateSelectionUtils.isSameDay(selectedEndDate!, rangeEnd);
  }

  bool _is30DaysAgoSelected() {
    if (selectedStartDate == null || selectedEndDate == null) return false;
    final now = DateTime.now();
    final endDate = now.subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 30));
    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return DateSelectionUtils.isSameDay(selectedStartDate!, rangeStart) &&
        DateSelectionUtils.isSameDay(selectedEndDate!, rangeEnd);
  }

  bool _isQuickSingleSelected(quick.QuickDateRange range) {
    if (range.key == 'no_date') return selectedDate == null;
    if (selectedDate == null) return false;
    final date = range.startDateCalculator();
    return DateSelectionUtils.isSameDay(selectedDate!, date);
  }
}
