import 'package:flutter/material.dart';

/// Widget for markdown editing mode
class MarkdownEditorWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final TextStyle? style;
  final VoidCallback? onTap;

  const MarkdownEditorWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: null,
      expands: true,
      style: style ??
          theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16.0),
        filled: false,
      ),
      onTap: onTap,
      onChanged: (value) {},
    );
  }
}
