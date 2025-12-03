import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/markdown_editor_interfaces.dart';

/// Default implementation of markdown styling configuration
class MarkdownStyleProvider implements IMarkdownStyleProvider {
  @override
  MarkdownStyleSheet createStyleSheet(BuildContext context) {
    final theme = Theme.of(context);

    return MarkdownStyleSheet(
      p: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        height: 1.5,
      ),
      h1: theme.textTheme.displayLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 32.0,
      ),
      h2: theme.textTheme.headlineLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 28.0,
      ),
      h3: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 24.0,
      ),
      h4: theme.textTheme.headlineSmall?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 20.0,
      ),
      h5: theme.textTheme.headlineSmall?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 16.0,
      ),
      h6: theme.textTheme.headlineSmall?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 14.0,
      ),
      a: TextStyle(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      code: TextStyle(
        backgroundColor: theme.colorScheme.surfaceContainer,
        color: theme.colorScheme.onSurface,
        fontFamily: 'monospace',
        fontSize: 16.0,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      listBullet: TextStyle(
        fontSize: 24.0,
        color: theme.colorScheme.onSurface,
      ),
      blockquote: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
      blockquoteDecoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      tableHead: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
      tableBody: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        height: 1.5,
      ),
      tableBorder: TableBorder.all(
        color: theme.dividerColor.withValues(alpha: 0.3),
        width: 1,
        borderRadius: BorderRadius.circular(8.0),
      ),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.all(8.0),
      tableColumnWidth: const FlexColumnWidth(),
    );
  }

  @override
  TextStyle getEditorStyle(BuildContext context, TextStyle? customStyle) {
    final theme = Theme.of(context);

    return customStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle();
  }

  @override
  TextStyle getHintStyle(BuildContext context) {
    final theme = Theme.of(context);

    return theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ) ??
        const TextStyle();
  }

  @override
  MarkdownStyleSheet createHintStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = createStyleSheet(context);

    return baseStyle.copyWith(
      p: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        height: 1.5,
      ),
    );
  }
}
