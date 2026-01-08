import 'dart:async';
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
  final bool _ownsController;
  final bool _ownsFocusNode;

  final MarkdownEditorState _state = MarkdownEditorState();
  VoidCallback? _onStateChanged;
  Timer? _debounceTimer;

  MarkdownEditorController({
    required this.textController,
    required this.focusNode,
    required this.config,
    required this.callbacks,
    required this.linkHandler,
    required this.styleProvider,
    required this.toolbarConfiguration,
    VoidCallback? onStateChanged,
    bool ownsController = false,
    bool ownsFocusNode = true,
  })  : _ownsController = ownsController,
        _ownsFocusNode = ownsFocusNode {
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
    } on StateError catch (e) {
      // Expected when controller already disposed
      debugPrint('Text controller disposed: $e');
    } catch (e) {
      // Log unexpected errors for debugging
      debugPrint('Unexpected error removing text change listener: $e');
    }
  }

  void _onTextChanged() {
    if (_state.isInitializing) return;

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Schedule new callback with debounce
    _debounceTimer = Timer(config.textChangeDebounce, () {
      try {
        callbacks.onChanged?.call(textController.text);
      } catch (e) {
        // Log user callback errors but don't crash the editor
        debugPrint('Error in onChanged callback: $e');
        rethrow;
      }
    });
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
    // Cancel debounce timer to prevent memory leaks
    _debounceTimer?.cancel();

    // Remove text change listener
    _removeTextChangeListener();

    // Dispose TextEditingController if we own it
    if (_ownsController) {
      textController.dispose();
    }

    // Dispose FocusNode if we own it
    if (_ownsFocusNode) {
      focusNode.dispose();
    }
  }
}
