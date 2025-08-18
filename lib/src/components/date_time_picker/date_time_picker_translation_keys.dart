/// Translation keys for DateTimePickerField component
enum DateTimePickerTranslationKey {
  /// Title of the date picker dialog
  title,

  /// Confirm button text
  confirm,

  /// Cancel button text
  cancel,

  /// Set time button text
  setTime,

  /// No date selected placeholder text
  noDateSelected,

  /// Clear button text
  clear,
  
  /// Select end date text for range picker
  selectEndDate,
  
  /// No dates selected text for range picker
  noDatesSelected,
}

/// Extension to provide string values for DateTimePickerTranslationKey enum
extension DateTimePickerTranslationKeyExtension on DateTimePickerTranslationKey {
  /// Returns the translation key string for the enum value
  String get key {
    switch (this) {
      case DateTimePickerTranslationKey.title:
        return 'date_picker_title';
      case DateTimePickerTranslationKey.confirm:
        return 'confirm';
      case DateTimePickerTranslationKey.cancel:
        return 'cancel';
      case DateTimePickerTranslationKey.setTime:
        return 'set_time';
      case DateTimePickerTranslationKey.noDateSelected:
        return 'no_date_selected';
      case DateTimePickerTranslationKey.clear:
        return 'clear';
      case DateTimePickerTranslationKey.selectEndDate:
        return 'select_end_date';
      case DateTimePickerTranslationKey.noDatesSelected:
        return 'no_dates_selected';
    }
  }
}
