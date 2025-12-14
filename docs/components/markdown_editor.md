# Markdown Editor Component

A comprehensive, reusable Markdown editor component built with Flutter.

## Overview

The Markdown editor provides a full-featured Markdown editing experience with:

- Live editing with syntax highlighting (preview mode)
- Configurable toolbar with common Markdown formatting tools
- Link handling and URL launching
- Responsive design for mobile and desktop
- Clean, modular architecture for easy customization
- Translation key support for internationalization

## Features

### Core Functionality

- **Rich Text Editing**: Full Markdown support with live preview
- **Toolbar Integration**: Common formatting tools (bold, italic, links, lists,
  etc.)
- **Preview Mode**: Toggle between edit and preview modes
- **Link Handling**: Automatic URL detection and launching
- **Responsive Design**: Optimized for both mobile and desktop platforms

### Customization Options

- Configurable height and styling
- Custom toolbar background colors
- Optional preview mode toggle
- Configurable tooltips using translation keys
- Custom text styles and themes

## Structure

```dart
markdown_editor/
├── markdown_editor.dart           # Main orchestrator widget
├── models/
│   └── markdown_editor_interfaces.dart     # Abstract interfaces and data models
├── controllers/
│   └── markdown_editor_controller.dart     # Business logic and state management
├── widgets/
│   ├── markdown_editor_widget.dart         # Text input widget
│   ├── markdown_preview_widget.dart        # Markdown preview widget
│   └── markdown_toolbar_widget.dart        # Formatting toolbar widget
├── services/
│   ├── markdown_link_handler.dart          # URL and link handling
│   └── markdown_style_provider.dart        # Styling and theming
└── config/
    ├── markdown_editor_translation_keys.dart  # Translation key constants
    └── markdown_toolbar_configurator.dart   # Toolbar configuration
```

### Key Components

#### Interfaces

- **`IMarkdownToolbarConfiguration`**: Toolbar configuration interface
- **`IMarkdownLinkHandler`**: Link handling and URL launching
- **`IMarkdownStyleProvider`**: Styling and theme management

#### Core Widgets

- **`MarkdownEditor`**: Main editor widget with factory constructors
- **`MarkdownEditorWidget`**: Text input component
- **`MarkdownPreviewWidget`**: Markdown rendering component
- **`MarkdownToolbarWidget`**: Formatting toolbar

## Usage

### Basic Usage

```dart
import 'package:acore/acore.dart' show MarkdownEditor;

// Simple markdown editor with default configuration
MarkdownEditor.simple(
  controller: _textController,
  onChanged: (text) {
    // Handle text changes
  },
  height: 300,
)
```

### Advanced Usage

```dart
import 'package:acore/acore.dart' show MarkdownEditor, MarkdownEditorConfig, MarkdownEditorCallbacks;

// Fully configured markdown editor
MarkdownEditor(
  config: MarkdownEditorConfig(
    height: 400,
    showToolbar: true,
    enablePreviewMode: true,
    enableLinkHandling: true,
    toolbarBackground: Colors.grey[100],
  ),
  callbacks: MarkdownEditorCallbacks(
    onChanged: (text) => print('Text changed: $text'),
    onTapLink: (text, href, title) => print('Link tapped: $href'),
  ),
  externalController: _textController,
)
```

### Custom Styling

```dart
MarkdownEditor.simple(
  controller: _textController,
  onChanged: _onChanged,
  height: 250,
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    fontSize: 16,
    height: 1.5,
  ),
  toolbarBackground: Theme.of(context).colorScheme.surface,
)
```

## API Reference

### MarkdownEditor

#### Constructors

##### `MarkdownEditor()`

Full constructor with complete configuration options.

```dart
MarkdownEditor({
  Key? key,
  required MarkdownEditorConfig config,
  required MarkdownEditorCallbacks callbacks,
  TextEditingController? externalController,
})
```

##### `MarkdownEditor.simple()`

Convenience factory for common use cases.

```dart
MarkdownEditor.simple({
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
})
```

### MarkdownEditorConfig

Configuration options for the editor behavior and appearance.

```dart
const MarkdownEditorConfig({
  this.hintText,                    // Placeholder text
  this.style,                       // Text styling
  this.toolbarBackground,           // Toolbar background color
  this.height,                      // Editor height
  this.enableLinkHandling = true,   // Enable link click handling
  this.showToolbar = true,          // Show formatting toolbar
  this.enablePreviewMode = true,    // Enable preview mode toggle
})
```

### MarkdownEditorCallbacks

Event handlers for editor interactions.

```dart
const MarkdownEditorCallbacks({
  this.onChanged,                   // Text change callback
  this.onTapLink,                   // Link tap callback
  this.onPreviewModeChanged,        // Preview mode change callback
})
```

## Translation Support

The component uses translation keys for internationalization:

```dart
import 'package:acore/components/markdown_editor/config/markdown_editor_translation_keys.dart';

// Available translation keys:
MarkdownEditorTranslationKeys.hintText
MarkdownEditorTranslationKeys.editTooltip
MarkdownEditorTranslationKeys.previewTooltip
MarkdownEditorTranslationKeys.boldTooltip
MarkdownEditorTranslationKeys.italicTooltip
// ... and more
```

### Integration with App Localization

Map the component's translation keys to your app's localization system:

```dart
// Example with easy_localization
String translateMarkdownKey(String key) {
  switch (key) {
    case MarkdownEditorTranslationKeys.boldTooltip:
      return 'bold'.tr();
    case MarkdownEditorTranslationKeys.italicTooltip:
      return 'italic'.tr();
    // ... other mappings
    default:
      return key;
  }
}
```

## Customization

### Custom Toolbar Configuration

Implement `IMarkdownToolbarConfiguration` to customize toolbar behavior:

```dart
class CustomToolbarConfiguration implements IMarkdownToolbarConfiguration {
  @override
  Map<String, String> configureTooltipsUsingKeys({Map<String, String>? translations}) {
    return {
      'bold': translations?['bold'] ?? 'Make text bold',
      'italic': translations?['italic'] ?? 'Make text italic',
      // Custom tooltips with optional localization
    };
  }

  @override
  MarkdownToolbarStyle configureToolbarStyle(ThemeData theme, Color? backgroundColor) {
    return MarkdownToolbarStyle(
      iconColor: theme.primaryColor,
      iconSize: 24.0,
      // Custom styling
    );
  }
}
```

### Custom Link Handling

Implement `IMarkdownLinkHandler` for custom link behavior:

```dart
class CustomLinkHandler implements IMarkdownLinkHandler {
  @override
  void handleLinkTap(String text, String? href, String title) {
    // Custom link handling logic
    if (href?.startsWith('internal://') == true) {
      // Handle internal navigation
    } else {
      launchUrl(href!);
    }
  }
}
```

## Styling

### Default Styling

The component automatically adapts to your app's theme:

- Uses `Theme.of(context)` for colors and typography
- Supports both light and dark themes
- Responsive design for different screen sizes

### Custom Styling Examples

```dart
// Custom editor styling
MarkdownEditor.simple(
  controller: _controller,
  style: TextStyle(
    fontFamily: 'Courier New',
    fontSize: 14,
    height: 1.6,
    color: Colors.black87,
  ),
  toolbarBackground: Colors.blueGrey[50],
  height: 300,
)
```

## Performance Considerations

- **Lazy Loading**: Preview mode renders on-demand
- **Efficient Updates**: Only re-renders when text actually changes
- **Memory Management**: Proper disposal of controllers and resources
- **Responsive Design**: Optimized layouts for different screen sizes

## Platform Support

- **Mobile**: Android and iOS with touch-friendly interface
- **Desktop**: Web, Windows, Linux, macOS with keyboard shortcuts
- **Responsive**: Automatic adaptation to screen size

## Dependencies

The component requires these Flutter packages:

- `flutter_markdown`: ^0.7.6+3
- `markdown_toolbar`: ^0.5.0
- `url_launcher`: ^6.3.0+3

## Examples

### Note Taking App

```dart
class NoteEditor extends StatefulWidget {
  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Note Editor')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: MarkdownEditor.simple(
          controller: _controller,
          height: MediaQuery.of(context).size.height - 200,
          onChanged: (text) => _saveNote(text),
        ),
      ),
    );
  }
}
```

### Blog Post Editor

```dart
MarkdownEditor(
  config: MarkdownEditorConfig(
    height: 600,
    showToolbar: true,
    enablePreviewMode: true,
    enableLinkHandling: true,
  ),
  callbacks: MarkdownEditorCallbacks(
    onChanged: (text) => _autoSave(text),
    onTapLink: (text, href, title) => _handleLink(href),
  ),
  externalController: _postController,
)
```

## Troubleshooting

### Common Issues

1. **Toolbar not showing**: Ensure `showToolbar: true` in config
2. **Links not working**: Check `enableLinkHandling` configuration
3. **Preview mode not available**: Ensure `enablePreviewMode: true`
4. **Height issues**: Set explicit height or use parent container constraints

### Performance Tips

- Use external controllers for better state management
- Dispose controllers properly when not needed
- Consider debouncing `onChanged` callbacks for large texts

## Contributing

When extending the component:

1. Maintain interface contracts
2. Add appropriate tests
3. Update documentation
4. Consider backward compatibility
