import 'package:flutter/material.dart';
import 'package:acore/acore.dart' hide Container;

/// Mobile-optimized time picker content with Scaffold layout
/// Designed for bottom sheet display with proper mobile UX patterns
/// Matches QuickAddTaskDialog styling for visual consistency
class TimePickerMobileContent extends StatelessWidget {
  final Widget timeSelectionDialog;
  final String? appBarTitle;
  final String? confirmButtonText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const TimePickerMobileContent({
    super.key,
    required this.timeSelectionDialog,
    this.appBarTitle,
    this.confirmButtonText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Always use Scaffold with AppBar styling since this widget is intended for mobile/responsive views
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          appBarTitle ?? 'Select Time',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        actions: [
          TextButton(
            key: const Key('time_picker_done_button'),
            onPressed: onConfirm,
            child: Text(
              confirmButtonText ?? 'Done',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: timeSelectionDialog,
        ),
      ),
    );
  }
}
