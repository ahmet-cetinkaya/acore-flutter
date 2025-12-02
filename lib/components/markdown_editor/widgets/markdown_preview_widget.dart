import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/markdown_editor_interfaces.dart';

/// Widget for markdown preview mode
class MarkdownPreviewWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool enableLinkHandling;
  final void Function(String text, String? href, String title)? onTapLink;
  final IMarkdownStyleProvider styleProvider;

  const MarkdownPreviewWidget({
    super.key,
    required this.controller,
    this.hintText,
    this.enableLinkHandling = true,
    this.onTapLink,
    required this.styleProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final text = value.text;
          final displayText = text.isEmpty ? hintText ?? '' : text;

          final styleSheet =
              text.isEmpty ? styleProvider.createHintStyleSheet(context) : styleProvider.createStyleSheet(context);

          return Markdown(
            data: displayText,
            onTapLink: enableLinkHandling ? onTapLink : null,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            styleSheet: styleSheet,
          );
        },
      ),
    );
  }
}
