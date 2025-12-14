import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';
import '../models/markdown_editor_interfaces.dart';
import '../config/markdown_editor_translation_keys.dart';

/// Widget for markdown toolbar with configurable styling
class MarkdownToolbarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color? backgroundColor;
  final bool showPreviewToggle;
  final bool isPreviewMode;
  final VoidCallback? onPreviewToggle;
  final IMarkdownToolbarConfiguration toolbarConfiguration;
  final Map<String, String>? translations;

  const MarkdownToolbarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.backgroundColor,
    this.showPreviewToggle = true,
    this.isPreviewMode = false,
    this.onPreviewToggle,
    required this.toolbarConfiguration,
    this.translations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toolbarBgColor = backgroundColor ?? theme.colorScheme.surface;
    final toolbarStyle = toolbarConfiguration.configureToolbarStyle(theme, toolbarBgColor);
    final tooltips = toolbarConfiguration.configureTooltipsUsingKeys(translations: translations);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: _buildToolbar(context, tooltips, toolbarStyle, toolbarBgColor),
            ),
          ),
          if (showPreviewToggle) _buildPreviewToggle(theme),
        ],
      ),
    );
  }

  Widget _buildToolbar(
      BuildContext context, Map<String, String> tooltips, MarkdownToolbarStyle style, Color toolbarBgColor) {
    final toolbar = MarkdownToolbar(
      controller: controller,
      useIncludedTextField: false,
      focusNode: focusNode,
      collapsable: style.collapsible,
      backgroundColor: toolbarBgColor,
      borderRadius: style.borderRadius,
      iconColor: style.iconColor,
      iconSize: style.iconSize,
      dropdownTextColor: style.dropdownTextColor,
      width: style.width,
      height: style.height,
      spacing: style.spacing,
      runSpacing: style.runSpacing,
      alignment: style.alignment ?? WrapAlignment.center,
      showTooltips: true,
      imageTooltip: tooltips['image'] ?? '',
      headingTooltip: tooltips['heading'] ?? '',
      checkboxTooltip: tooltips['checkbox'] ?? '',
      boldTooltip: tooltips['bold'] ?? '',
      italicTooltip: tooltips['italic'] ?? '',
      strikethroughTooltip: tooltips['strikethrough'] ?? '',
      linkTooltip: tooltips['link'] ?? '',
      codeTooltip: tooltips['code'] ?? '',
      bulletedListTooltip: tooltips['bulletedList'] ?? '',
      numberedListTooltip: tooltips['numberedList'] ?? '',
      quoteTooltip: tooltips['quote'] ?? '',
      horizontalRuleTooltip: tooltips['horizontalRule'] ?? '',
    );

    // Wrap with semantic container for accessibility
    final semanticToolbar = Semantics(
      label: 'Markdown formatting toolbar',
      hint: 'Use toolbar buttons to format text',
      child: Theme(
        data: Theme.of(context).copyWith(
          hoverColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          focusColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          splashColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        child: toolbar,
      ),
    );

    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: semanticToolbar,
      );
    }

    return semanticToolbar;
  }

  Widget _buildPreviewToggle(ThemeData theme) {
    final buttonLabel = isPreviewMode ? 'Switch to edit mode' : 'Switch to preview mode';
    final buttonHint = isPreviewMode ? 'Return to markdown editing mode' : 'View formatted markdown output';

    return Container(
      margin: const EdgeInsets.all(8),
      child: Semantics(
        button: true,
        label: buttonLabel,
        hint: buttonHint,
        child: IconButton(
          icon: Icon(
            isPreviewMode ? Icons.edit : Icons.visibility,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          onPressed: onPreviewToggle,
          tooltip: isPreviewMode
              ? (translations?[MarkdownEditorTranslationKeys.editTooltip] ?? 'Edit')
              : (translations?[MarkdownEditorTranslationKeys.previewTooltip] ?? 'Preview'),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
