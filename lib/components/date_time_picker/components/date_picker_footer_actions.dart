import 'package:flutter/material.dart';
import 'footer_action_base.dart';

/// Design constants for footer actions
class _FooterActionsDesign {
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double radiusSmall = 8.0;
  static const double fontSizeMedium = 16.0;
  static const double borderWidth = 1.0;
  static const double buttonHeight = 40.0;
  static const double iconSize = 16.0;
  static const double chevronSize = 14.0;
  static const double actionSpacing = 8.0;
}

/// Footer actions widget for date picker.
///
/// Renders a row of customizable action buttons at the bottom of the date picker.
class DatePickerFooterActions extends StatelessWidget {
  final List<DatePickerContentFooterAction> actions;
  final DateTime? selectedDate;
  final VoidCallback? onRebuildRequest;

  const DatePickerFooterActions({
    super.key,
    required this.actions,
    this.selectedDate,
    this.onRebuildRequest,
  });

  Future<void> _executeFooterAction(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Error executing footer action: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action failed: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Future<void> Function() onPressed,
    Color? color,
    String? hint,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      hint: hint ?? 'Tap to perform action',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_FooterActionsDesign.radiusSmall),
        child: InkWell(
          onTap: () async {
            await _executeFooterAction(context, onPressed);
            onRebuildRequest?.call();
          },
          borderRadius: BorderRadius.circular(_FooterActionsDesign.radiusSmall),
          splashColor: theme.primaryColor.withValues(alpha: 0.1),
          highlightColor: theme.primaryColor.withValues(alpha: 0.05),
          child: Container(
            height: _FooterActionsDesign.buttonHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: _FooterActionsDesign.spacingSmall,
              vertical: _FooterActionsDesign.spacingXSmall,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isPrimary && color == null
                    ? theme.primaryColor.withValues(alpha: 0.2)
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: isPrimary && color == null
                    ? _FooterActionsDesign.borderWidth * 1.5
                    : _FooterActionsDesign.borderWidth,
              ),
              borderRadius: BorderRadius.circular(_FooterActionsDesign.radiusSmall),
              color: isPrimary && color == null ? theme.primaryColor.withValues(alpha: 0.1) : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: _FooterActionsDesign.iconSize,
                  color: color ?? (isPrimary ? theme.primaryColor : theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: _FooterActionsDesign.spacingXSmall),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: _FooterActionsDesign.fontSizeMedium,
                      fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                      color: color ?? (isPrimary ? theme.primaryColor : theme.colorScheme.onSurfaceVariant),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: _FooterActionsDesign.spacingXSmall),
                Icon(
                  Icons.chevron_right,
                  size: _FooterActionsDesign.chevronSize,
                  color: selectedDate == null
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                      : theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _FooterActionsDesign.spacingMedium,
        vertical: _FooterActionsDesign.spacingSmall,
      ),
      child: Row(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < actions.length - 1 ? _FooterActionsDesign.actionSpacing : 0.0,
              ),
              child: Builder(
                builder: (context) {
                  return AnimatedBuilder(
                    animation: action.listenable ?? const AlwaysStoppedAnimation(null),
                    builder: (context, _) {
                      final icon = action.icon?.call() ?? Icons.notifications_outlined;
                      final label = action.label?.call() ?? 'Reminder';
                      final color = action.color?.call();

                      return _buildActionButton(
                        context,
                        icon: icon,
                        label: label,
                        onPressed: () async {
                          await _executeFooterAction(context, action.onPressed);
                        },
                        color: color,
                        hint: action.hint?.call(),
                        isPrimary: action.isPrimary,
                      );
                    },
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
