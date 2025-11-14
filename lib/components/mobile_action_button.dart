import 'package:flutter/material.dart';

/// Shared mobile action button component used across date picker dialogs
class MobileActionButton extends StatelessWidget {
  const MobileActionButton({
    super.key,
    required this.context,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.isPrimary = false,
    this.borderRadius,
  });

  final BuildContext context;
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;
  final bool isPrimary;
  final double? borderRadius;

  static const double _height = 48; // Minimum touch target size
  static const double _iconSize = 20.0;
  static const double _spacing = 8.0;
  static const double _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: text,
      child: Container(
        height: _height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          color: isPrimary
              ? Theme.of(context).primaryColor
              : onPressed != null
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.surface,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: _iconSize,
                    color: isPrimary
                        ? Theme.of(context).colorScheme.onPrimary
                        : onPressed != null
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  const SizedBox(width: _spacing),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w500,
                      color: isPrimary
                          ? Theme.of(context).colorScheme.onPrimary
                          : onPressed != null
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
