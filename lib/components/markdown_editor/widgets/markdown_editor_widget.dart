import 'package:flutter/material.dart';

/// Widget for markdown editing mode.
///
/// This widget supports two layout behaviors:
/// - Expand to fill a bounded parent (`expandsToAvailableSpace = true`)
/// - Grow naturally inside unbounded parents while remaining scrollable
class MarkdownEditorWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final TextStyle? style;
  final VoidCallback? onTap;
  final bool expandsToAvailableSpace;
  final int minVisibleLines;

  const MarkdownEditorWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.style,
    this.onTap,
    this.expandsToAvailableSpace = true,
    this.minVisibleLines = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveMinVisibleLines = minVisibleLines < 1 ? 1 : minVisibleLines;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: null,
      minLines: expandsToAvailableSpace ? null : effectiveMinVisibleLines,
      expands: expandsToAvailableSpace,
      scrollPhysics: const ClampingScrollPhysics(),
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
    );
  }
}
