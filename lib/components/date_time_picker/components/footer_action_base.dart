import 'package:flutter/material.dart';

/// Base class for all footer actions in date picker components
/// Provides common functionality and structure for dynamic callback-based actions
abstract class FooterActionBase {
  /// Icon callback that returns the current icon for the action
  /// Returns null if no icon should be displayed
  final IconData? Function()? icon;

  /// Label callback that returns the current label for the action
  /// Returns null if no label should be displayed
  final String? Function()? label;

  /// Color callback that returns the current color for the action
  /// Returns null to use default theme colors
  final Color? Function()? color;

  /// Hint callback that returns the accessibility hint for the action
  /// Returns null to use default hint
  final String? Function()? hint;

  /// Async callback that executes when the action is pressed
  final Future<void> Function() onPressed;

  /// Whether this action should be styled as a primary action
  final bool isPrimary;

  /// Listenable that triggers a rebuild of the action button when notified
  final Listenable? listenable;

  const FooterActionBase({
    this.icon,
    this.label,
    this.color,
    this.hint,
    required this.onPressed,
    this.isPrimary = false,
    this.listenable,
  });

  /// Gets the current icon for the action
  IconData? getCurrentIcon() => icon?.call();

  /// Gets the current label for the action
  String? getCurrentLabel() => label?.call();

  /// Gets the current color for the action
  Color? getCurrentColor() => color?.call();

  /// Gets the current hint for the action
  String? getCurrentHint() => hint?.call();

  /// Executes the action with proper error handling
  Future<void> execute() async {
    try {
      await onPressed();
    } catch (e) {
      // Re-throw to allow specific components to handle the error
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FooterActionBase && other.runtimeType == runtimeType && other.isPrimary == isPrimary;
  }

  @override
  int get hashCode => Object.hash(isPrimary, runtimeType);
}

/// Concrete implementation for date picker content footer actions
class DatePickerContentFooterAction extends FooterActionBase {
  const DatePickerContentFooterAction({
    super.icon,
    super.label,
    super.color,
    required super.onPressed,
    super.isPrimary,
    super.listenable,
  });
}

/// Concrete implementation for date picker dialog footer actions
class DatePickerFooterAction extends FooterActionBase {
  const DatePickerFooterAction({
    super.icon,
    super.label,
    super.color,
    required super.onPressed,
    super.isPrimary,
    super.listenable,
  });
}

/// Simple footer action for date selection dialogs with static properties
class DateSelectionDialogFooterAction extends FooterActionBase {
  /// Static icon (non-callback based)
  final IconData staticIcon;

  /// Static label (non-callback based)
  final String staticLabel;

  /// Static color (non-callback based)
  final Color? staticColor;

  /// Static hint (non-callback based)
  final String? staticHint;

  /// Static callback (synchronous for compatibility)
  final VoidCallback? staticOnPressed;

  DateSelectionDialogFooterAction({
    required this.staticIcon,
    required this.staticLabel,
    required VoidCallback onPressed,
    this.staticColor,
    this.staticHint,
    super.isPrimary,
  })  : staticOnPressed = onPressed,
        super(
          icon: null,
          label: null,
          color: null,
          hint: null,
          onPressed: () async {
            onPressed();
          },
        );

  @override
  IconData? getCurrentIcon() => staticIcon;

  @override
  String? getCurrentLabel() => staticLabel;

  @override
  Color? getCurrentColor() => staticColor;

  @override
  String? getCurrentHint() => staticHint;
}
