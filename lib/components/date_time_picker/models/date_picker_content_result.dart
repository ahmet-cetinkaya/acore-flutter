/// Result returned from the date picker content
class DatePickerContentResult {
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isRefreshEnabled;
  final String? quickSelectionKey;
  final bool isAllDay;

  const DatePickerContentResult({
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.isRefreshEnabled,
    this.quickSelectionKey,
    this.isAllDay = false,
  });

  factory DatePickerContentResult.single(DateTime date,
      {bool? isRefreshEnabled, String? quickSelectionKey, bool isAllDay = false}) {
    return DatePickerContentResult(
      selectedDate: date,
      isRefreshEnabled: isRefreshEnabled,
      quickSelectionKey: quickSelectionKey,
      isAllDay: isAllDay,
    );
  }

  factory DatePickerContentResult.range(DateTime startDate, DateTime endDate,
      {bool? isRefreshEnabled, String? quickSelectionKey}) {
    return DatePickerContentResult(
      startDate: startDate,
      endDate: endDate,
      isRefreshEnabled: isRefreshEnabled,
      quickSelectionKey: quickSelectionKey,
    );
  }

  factory DatePickerContentResult.cleared() {
    return const DatePickerContentResult(
      selectedDate: null,
    );
  }
}
