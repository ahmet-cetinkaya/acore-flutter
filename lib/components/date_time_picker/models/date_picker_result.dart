/// Result from the legacy DatePickerDialog
/// Note: Consider using DatePickerContentResult for new implementations
class DatePickerResult {
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isRefreshEnabled;
  final String? quickSelectionKey;
  final bool isAllDay;
  final bool wasCancelled;

  const DatePickerResult({
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.isRefreshEnabled = false,
    this.quickSelectionKey,
    this.isAllDay = false,
    this.wasCancelled = false,
  });

  factory DatePickerResult.single(
    DateTime date, {
    bool? isRefreshEnabled,
    String? quickSelectionKey,
    bool isAllDay = false,
  }) {
    return DatePickerResult(
      selectedDate: date,
      isRefreshEnabled: isRefreshEnabled ?? false,
      quickSelectionKey: quickSelectionKey,
      isAllDay: isAllDay,
    );
  }

  factory DatePickerResult.range(
    DateTime startDate,
    DateTime endDate, {
    bool? isRefreshEnabled,
    String? quickSelectionKey,
  }) {
    return DatePickerResult(
      startDate: startDate,
      endDate: endDate,
      isRefreshEnabled: isRefreshEnabled ?? false,
      quickSelectionKey: quickSelectionKey,
    );
  }

  factory DatePickerResult.cancelled() {
    return const DatePickerResult(wasCancelled: true);
  }
}
