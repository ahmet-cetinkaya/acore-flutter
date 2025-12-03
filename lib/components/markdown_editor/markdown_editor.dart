import 'package:flutter/material.dart';

import 'models/markdown_editor_interfaces.dart';
import 'controllers/markdown_editor_controller.dart';
import 'widgets/markdown_editor_widget.dart';
import 'widgets/markdown_preview_widget.dart';
import 'widgets/markdown_toolbar_widget.dart';
import 'config/markdown_toolbar_configuration.dart';
import 'services/markdown_link_handler.dart';
import 'services/markdown_style_provider.dart';
import 'config/markdown_editor_translation_keys.dart';

/// A reusable Markdown editor component
/// with clean separation of concerns and modular architecture.
/// This version is designed for the acore package and requires all dependencies
/// to be injected via constructor parameters.
class MarkdownEditor extends StatefulWidget {
  final MarkdownEditorConfig config;
  final MarkdownEditorCallbacks callbacks;
  final TextEditingController? externalController;

  const MarkdownEditor({
    super.key,
    required this.config,
    required this.callbacks,
    this.externalController,
  });
  factory MarkdownEditor.simple({
    Key? key,
    required TextEditingController controller,
    void Function(String)? onChanged,
    String? hintText,
    TextStyle? style,
    bool enableLinkHandling = true,
    void Function(String text, String? href, String title)? onTapLink,
    double? height,
    Color? toolbarBackground,
    bool enablePreviewMode = true,
    Map<String, String>? translations,
  }) {
    return MarkdownEditor(
      key: key,
      externalController: controller,
      config: MarkdownEditorConfig(
        hintText: hintText ?? MarkdownEditorTranslationKeys.hintText,
        style: style,
        toolbarBackground: toolbarBackground,
        height: height,
        enableLinkHandling: enableLinkHandling,
        enablePreviewMode: enablePreviewMode,
        translations: translations,
      ),
      callbacks: MarkdownEditorCallbacks(
        onChanged: onChanged,
        onTapLink: onTapLink,
      ),
    );
  }

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late final MarkdownEditorController _editorController;
  late final IMarkdownToolbarConfiguration _toolbarConfigurator;
  late final IMarkdownLinkHandler _linkHandler;
  late final IMarkdownStyleProvider _styleProvider;
  late final bool _internalControllerCreated;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _createEditorController();
    _setupInitialization();
  }

  void _initializeDependencies() {
    _toolbarConfigurator = MarkdownToolbarConfiguration();
    _linkHandler = MarkdownLinkHandler();
    _styleProvider = MarkdownStyleProvider();
  }

  void _createEditorController() {
    final controller = widget.externalController ?? TextEditingController();
    _internalControllerCreated = widget.externalController == null;

    _editorController = MarkdownEditorController(
      textController: controller,
      config: widget.config,
      callbacks: widget.callbacks,
      linkHandler: _linkHandler,
      styleProvider: _styleProvider,
      toolbarConfiguration: _toolbarConfigurator,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _setupInitialization() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _editorController.setInitializing(false);
      }
    });
  }

  @override
  void dispose() {
    // Dispose the TextEditingController if it was created internally
    if (_internalControllerCreated) {
      _editorController.textController.dispose();
    }
    _editorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.config.height ?? 400,
      ),
      child: Column(
        children: [
          if (widget.config.showToolbar && !_editorController.isPreviewMode)
            MarkdownToolbarWidget(
              controller: _editorController.textController,
              focusNode: _editorController.focusNode,
              backgroundColor: widget.config.toolbarBackground,
              showPreviewToggle: widget.config.enablePreviewMode,
              isPreviewMode: _editorController.isPreviewMode,
              onPreviewToggle: widget.config.enablePreviewMode ? _editorController.togglePreviewMode : null,
              toolbarConfiguration: _toolbarConfigurator,
              translations: widget.config.translations,
            ),

          // Editor/Preview Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Stack(
                children: [
                  if (_editorController.isPreviewMode) _buildPreviewContent() else _buildEditorContent(),
                  if (widget.config.enablePreviewMode && _editorController.isPreviewMode)
                    _buildFloatingEditButton(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorContent() {
    return MarkdownEditorWidget(
      controller: _editorController.textController,
      focusNode: _editorController.focusNode,
      hintText: widget.config.hintText,
      style: widget.config.style,
      onTap: _editorController.requestFocus,
    );
  }

  Widget _buildPreviewContent() {
    return MarkdownPreviewWidget(
      controller: _editorController.textController,
      hintText: widget.config.hintText,
      enableLinkHandling: widget.config.enableLinkHandling,
      onTapLink: _editorController.handleLinkTap,
      styleProvider: _styleProvider,
    );
  }

  Widget _buildFloatingEditButton(ThemeData theme) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: Icon(
            Icons.edit,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          onPressed: _editorController.togglePreviewMode,
          tooltip: widget.config.translations?[MarkdownEditorTranslationKeys.editTooltip] ?? 'Edit',
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
