import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownEditorConfig {
  final String? hintText;
  final TextStyle? style;
  final Color? toolbarBackground;
  final double? height;
  final bool enableLinkHandling;
  final bool showToolbar;
  final bool enablePreviewMode;
  final Map<String, String>? translations;

  const MarkdownEditorConfig({
    this.hintText,
    this.style,
    this.toolbarBackground,
    this.height,
    this.enableLinkHandling = true,
    this.showToolbar = true,
    this.enablePreviewMode = true,
    this.translations,
  });

  MarkdownEditorConfig copyWith({
    String? hintText,
    TextStyle? style,
    Color? toolbarBackground,
    double? height,
    bool? enableLinkHandling,
    bool? showToolbar,
    bool? enablePreviewMode,
    Map<String, String>? translations,
  }) {
    return MarkdownEditorConfig(
      hintText: hintText ?? this.hintText,
      style: style ?? this.style,
      toolbarBackground: toolbarBackground ?? this.toolbarBackground,
      height: height ?? this.height,
      enableLinkHandling: enableLinkHandling ?? this.enableLinkHandling,
      showToolbar: showToolbar ?? this.showToolbar,
      enablePreviewMode: enablePreviewMode ?? this.enablePreviewMode,
      translations: translations ?? this.translations,
    );
  }
}

class MarkdownEditorCallbacks {
  final void Function(String)? onChanged;
  final void Function(String text, String? href, String title)? onTapLink;
  final void Function(bool)? onPreviewModeChanged;

  const MarkdownEditorCallbacks({
    this.onChanged,
    this.onTapLink,
    this.onPreviewModeChanged,
  });
}

abstract class IMarkdownLinkHandler {
  void handleLinkTap(String text, String? href, String title);
  Future<void> launchUrl(String url);
}

abstract class IMarkdownStyleProvider {
  MarkdownStyleSheet createStyleSheet(BuildContext context);
  MarkdownStyleSheet createHintStyleSheet(BuildContext context);
  TextStyle getEditorStyle(BuildContext context, TextStyle? customStyle);
  TextStyle getHintStyle(BuildContext context);
}

abstract class IMarkdownToolbarConfiguration {
  Map<String, String> configureTooltipsUsingKeys({Map<String, String>? translations});
  MarkdownToolbarStyle configureToolbarStyle(ThemeData theme, Color? backgroundColor);
}

class MarkdownToolbarStyle {
  final Color iconColor;
  final Color dropdownTextColor;
  final double iconSize;
  final double width;
  final double height;
  final double spacing;
  final double runSpacing;
  final BorderRadius borderRadius;
  final bool collapsible;
  final WrapAlignment? alignment;

  const MarkdownToolbarStyle({
    this.iconColor = Colors.blue,
    this.dropdownTextColor = Colors.blue,
    this.iconSize = 20.0,
    this.width = 36.0,
    this.height = 36.0,
    this.spacing = 4.0,
    this.runSpacing = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.collapsible = false,
    this.alignment,
  });
}

class MarkdownEditorState {
  bool _isPreviewMode = false;
  bool _isInitializing = true;
  VoidCallback? onStateChanged;

  MarkdownEditorState({this.onStateChanged});

  bool get isPreviewMode => _isPreviewMode;
  bool get isInitializing => _isInitializing;

  void setPreviewMode(bool isPreview) {
    if (_isPreviewMode != isPreview) {
      _isPreviewMode = isPreview;
      onStateChanged?.call();
    }
  }

  void setInitializing(bool isInitializing) {
    if (_isInitializing != isInitializing) {
      _isInitializing = isInitializing;
      onStateChanged?.call();
    }
  }

  void togglePreviewMode() {
    setPreviewMode(!_isPreviewMode);
  }
}
