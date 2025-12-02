import 'package:flutter/material.dart';
import '../models/markdown_editor_interfaces.dart';
import 'markdown_editor_translation_keys.dart';

/// Default implementation of markdown toolbar configuration
class MarkdownToolbarConfiguration implements IMarkdownToolbarConfiguration {
  @override
  Map<String, String> configureTooltipsUsingKeys({Map<String, String>? translations}) {
    return {
      'image': translations?[MarkdownEditorTranslationKeys.imageTooltip] ?? 'Image',
      'heading': translations?[MarkdownEditorTranslationKeys.headingTooltip] ?? 'Heading',
      'checkbox': translations?[MarkdownEditorTranslationKeys.checkboxTooltip] ?? 'Checkbox',
      'bold': translations?[MarkdownEditorTranslationKeys.boldTooltip] ?? 'Bold',
      'italic': translations?[MarkdownEditorTranslationKeys.italicTooltip] ?? 'Italic',
      'strikethrough': translations?[MarkdownEditorTranslationKeys.strikethroughTooltip] ?? 'Strikethrough',
      'link': translations?[MarkdownEditorTranslationKeys.linkTooltip] ?? 'Link',
      'code': translations?[MarkdownEditorTranslationKeys.codeTooltip] ?? 'Code',
      'bulletedList': translations?[MarkdownEditorTranslationKeys.bulletedListTooltip] ?? 'Bulleted List',
      'numberedList': translations?[MarkdownEditorTranslationKeys.numberedListTooltip] ?? 'Numbered List',
      'quote': translations?[MarkdownEditorTranslationKeys.quoteTooltip] ?? 'Quote',
      'horizontalRule': translations?[MarkdownEditorTranslationKeys.horizontalRuleTooltip] ?? 'Horizontal Rule',
    };
  }

  @override
  MarkdownToolbarStyle configureToolbarStyle(ThemeData theme, Color? backgroundColor) {
    return MarkdownToolbarStyle(
      iconColor: theme.colorScheme.primary,
      dropdownTextColor: theme.colorScheme.primary,
      iconSize: 20.0,
      width: 36.0,
      height: 36.0,
      spacing: 4.0,
      runSpacing: 4.0,
      borderRadius: BorderRadius.circular(8),
      collapsible: false,
    );
  }
}
