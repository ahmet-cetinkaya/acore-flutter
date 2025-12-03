import 'package:flutter/material.dart';
import '../models/markdown_editor_interfaces.dart';

/// Controls the markdown editor's state and operations
class MarkdownEditorController {
  final TextEditingController textController;
  final FocusNode focusNode;
  final MarkdownEditorConfig config;
  final MarkdownEditorCallbacks callbacks;
  final IMarkdownLinkHandler linkHandler;
  final IMarkdownStyleProvider styleProvider;
  final IMarkdownToolbarConfiguration toolbarConfiguration;

  final MarkdownEditorState _state = MarkdownEditorState();
  VoidCallback? _onStateChanged;

  MarkdownEditorController({
    required this.textController,
    required this.config,
    required this.callbacks,
    required this.linkHandler,
    required this.styleProvider,
    required this.toolbarConfiguration,
    VoidCallback? onStateChanged,
  }) : focusNode = FocusNode() {
    _onStateChanged = onStateChanged;
    _initialize();
  }

  MarkdownEditorState get state => _state;

  bool get isPreviewMode => _state.isPreviewMode;
  bool get isInitializing => _state.isInitializing;

  void _initialize() {
    _state.setPreviewMode(false);

    _state.onStateChanged = () {
      callbacks.onPreviewModeChanged?.call(_state.isPreviewMode);
      _onStateChanged?.call();
    };

    _addTextChangeListener();
  }

  void _addTextChangeListener() {
    textController.addListener(_onTextChanged);
  }

  void _removeTextChangeListener() {
    try {
      textController.removeListener(_onTextChanged);
    } catch (e) {
      // Log errors for debugging - removeListener should not typically throw
      debugPrint('Error removing text change listener: $e');
    }
  }

  void _onTextChanged() {
    if (_state.isInitializing) return;

    try {
      callbacks.onChanged?.call(textController.text);
    } catch (e) {
      // Propagate user callback errors for better debugging
      debugPrint('Error in onChanged callback: $e');
      rethrow;
    }
  }

  void togglePreviewMode() {
    if (!_state.isPreviewMode) {
      _state.setPreviewMode(true);
    } else {
      _state.setPreviewMode(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusNode.canRequestFocus) {
          focusNode.requestFocus();
        }
      });
    }
  }

  void setInitializing(bool isInitializing) {
    _state.setInitializing(isInitializing);
  }

  /// Request focus for the text editor
  void requestFocus() {
    if (focusNode.canRequestFocus && !focusNode.hasFocus) {
      focusNode.requestFocus();
    }
  }

  /// Handle link tap in preview mode
  void handleLinkTap(String text, String? href, String title) {
    if (config.enableLinkHandling) {
      if (callbacks.onTapLink != null) {
        callbacks.onTapLink!(text, href, title);
      } else {
        linkHandler.handleLinkTap(text, href, title);
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _removeTextChangeListener();
    focusNode.dispose();
  }
}
