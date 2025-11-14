# Responsive Dialog Helper

A comprehensive utility for showing responsive dialogs that adapt to different screen sizes, displaying as modal dialogs on desktop and bottom sheets on mobile.

## Overview

The `ResponsiveDialogHelper` provides a unified API for creating responsive dialogs that automatically adapt their presentation based on the device/screen size. This ensures optimal user experience across all platforms (desktop, mobile, web).

## Features

- 📱 **Responsive Design**: Automatically shows modal dialogs on desktop, bottom sheets on mobile
- 🎨 **Configurable Styling**: Customizable breakpoints, border radius, and desktop detection
- ⌨️ **Keyboard Awareness**: Handles keyboard appearance/disappearance gracefully
- 📏 **Flexible Sizing**: Multiple predefined dialog sizes (min, small, medium, large, max)
- 🔄 **Configuration**: Project-specific configuration support
- 🎯 **Cross-Platform**: Works on all Flutter-supported platforms

## Installation

The responsive dialog helper is included in the `acore` package. Simply import:

```dart
import 'package:acore/acore.dart';
```

## Quick Start

### Basic Usage

```dart
import 'package:acore/acore.dart';

// Show a responsive dialog with default settings
await ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  child: MyDialogContent(),
);

// Show with specific size
await ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  child: MyDialogContent(),
  size: DialogSize.large,
);
```

### Configuration

Configure the helper for your project's theme and breakpoints:

```dart
// In your app initialization (e.g., main.dart)
ResponsiveDialogHelper.configure(
  ResponsiveDialogConfig(
    screenMediumBreakpoint: 768.0,
    containerBorderRadius: 12.0,
    isDesktopScreen: (context) => MediaQuery.sizeOf(context).width > 768.0,
  ),
);
```

## API Reference

### ResponsiveDialogHelper

#### Methods

##### `showResponsiveDialog<T>`

Shows a responsive dialog that adapts to screen size.

```dart
static Future<T?> showResponsiveDialog<T>({
  required BuildContext context,
  required Widget child,
  DialogSize size = DialogSize.medium,
  bool isScrollable = true,
  bool isDismissible = true,
  bool enableDrag = true,
  ResponsiveDialogConfig? config,
})
```

**Parameters:**

- `context`: The build context
- `child`: The dialog content widget
- `size`: Dialog size (default: `DialogSize.medium`)
- `isScrollable`: Whether content should be scrollable (default: `true`)
- `isDismissible`: Whether dialog can be dismissed by tapping outside (default: `true`)
- `enableDrag`: Whether bottom sheet can be dragged (default: `true`)
- `config`: Optional configuration override

**Returns:** Future that completes with the dialog result

##### `configure`

Configures the global settings for the responsive dialog helper.

```dart
static void configure(ResponsiveDialogConfig config)
```

**Parameters:**

- `config`: Configuration settings

### DialogSize

Enum defining different dialog sizes with responsive behavior.

| Size     | Desktop               | Mobile               | Use Case                        |
| -------- | --------------------- | -------------------- | ------------------------------- |
| `min`    | Content-based sizing  | Content-based dialog | Alerts, confirmations           |
| `small`  | 50% width, 40% height | 20% initial height   | Quick actions, simple forms     |
| `medium` | 60% width, 70% height | 85% initial height   | Standard dialogs, forms         |
| `large`  | 80% width, 80% height | 95% initial height   | Complex content, detailed forms |
| `max`    | 95% width, 95% height | Fullscreen           | Maximum content, media          |

### ResponsiveDialogConfig

Configuration class for customizing responsive behavior.

```dart
class ResponsiveDialogConfig {
  final double screenMediumBreakpoint;
  final double containerBorderRadius;
  final bool Function(BuildContext context) isDesktopScreen;

  const ResponsiveDialogConfig({
    this.screenMediumBreakpoint = 600,
    this.containerBorderRadius = 12,
    this.isDesktopScreen = _defaultIsDesktopScreen,
  });
}
```

**Properties:**

- `screenMediumBreakpoint`: Width threshold for desktop detection (default: 600px)
- `containerBorderRadius`: Border radius for dialog containers (default: 12px)
- `isDesktopScreen`: Custom function to determine desktop screens

## Examples

### Basic Confirmation Dialog

```dart
Future<bool?> showConfirmationDialog(BuildContext context) {
  return ResponsiveDialogHelper.showResponsiveDialog<bool>(
    context: context,
    size: DialogSize.min,
    child: AlertDialog(
      title: Text('Confirm Action'),
      content: Text('Are you sure you want to proceed?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Confirm'),
        ),
      ],
    ),
  );
}
```

### Form Dialog with Scrollable Content

```dart
Future<void> showSettingsDialog(BuildContext context) {
  return ResponsiveDialogHelper.showResponsiveDialog<void>(
    context: context,
    size: DialogSize.large,
    isScrollable: true,
    child: Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 24),
          // Settings form widgets...
          Expanded(child: SettingsForm()),
        ],
      ),
    ),
  );
}
```

### Custom Configuration for Your App

```dart
void configureResponsiveDialogs() {
  ResponsiveDialogHelper.configure(
    ResponsiveDialogConfig(
      screenMediumBreakpoint: 800.0, // Custom breakpoint
      containerBorderRadius: 16.0,  // Larger border radius
      isDesktopScreen: (context) {
        // Custom logic for desktop detection
        final width = MediaQuery.sizeOf(context).width;
        return width >= 800.0 && !Platform.isIOS;
      },
    ),
  );
}
```

### Using Legacy Function

For simple use cases, the legacy `showResponsiveBottomSheet` function is available:

```dart
showResponsiveBottomSheet(
  context,
  child: MyBottomSheetContent(),
);
```

## Platform Behavior

### Desktop (Web, Windows, macOS, Linux)

- Shows as modal dialog
- Ratio-based sizing with maximum width constraints
- Optional scrolling for content overflow
- Centered on screen

### Mobile (iOS, Android)

- Shows as material bottom sheet
- Keyboard-aware resizing
- Drag-to-dismiss functionality
- Safe area handling

### Adaptive Logic

The helper uses the `isDesktopScreen` function to determine presentation:

```dart
final isDesktop = config.isDesktopScreen(context);

if (isDesktop) {
  // Show modal dialog
} else {
  // Show bottom sheet
}
```

## Customization

### Styling

The responsive dialog helper respects your app's theme but allows customization through configuration:

```dart
ResponsiveDialogHelper.configure(
  ResponsiveDialogConfig(
    containerBorderRadius: 20.0, // Custom corner radius
  ),
);
```

### Custom Desktop Detection

Implement custom logic for determining desktop screens:

```dart
bool isCustomDesktop(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final orientation = MediaQuery.orientationOf(context);

  // Custom logic considering orientation and other factors
  return size.width > 900 && orientation == Orientation.landscape;
}
```

## Best Practices

### 1. Choose Appropriate Dialog Sizes

```dart
// ✅ Good: Use size that matches content complexity
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.small,  // Simple confirmation
  child: SimpleConfirmationDialog(),
);

ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.large,  // Complex form
  child: DetailedSettingsForm(),
);
```

### 2. Handle Dialog Results Properly

```dart
// ✅ Good: Handle null results (dialog dismissed)
final result = await showConfirmationDialog(context);
if (result == true) {
  // User confirmed
  proceedWithAction();
} else if (result == false) {
  // User cancelled
  cancelAction();
} // else: Dialog was dismissed without action
```

### 3. Use Scrollable Content for Large Content

```dart
// ✅ Good: Enable scrolling for potentially large content
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  isScrollable: true,  // Enable scrolling
  child: LongContentList(),
);
```

### 4. Configure Early in App Lifecycle

```dart
// ✅ Good: Configure in main() before UI rendering
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure responsive dialogs
  ResponsiveDialogHelper.configure(/* ... */);

  runApp(MyApp());
}
```

## Migration from Modal/BottomSheet

### From AlertDialog

```dart
// Before
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Title'),
    content: Text('Content'),
    actions: [/* ... */],
  ),
);

// After
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.min,
  child: AlertDialog(
    title: Text('Title'),
    content: Text('Content'),
    actions: [/* ... */],
  ),
);
```

### From showModalBottomSheet

```dart
// Before
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    height: 300,
    child: MyContent(),
  ),
);

// After
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  child: Container(
    child: MyContent(),
  ),
);
```

## Dependencies

The responsive dialog helper requires:

- `flutter`: Flutter framework
- `modal_bottom_sheet: ^3.0.0`: Bottom sheet implementation

## Troubleshooting

### Common Issues

1. **Dialog not appearing on desktop**
   - Check that `isDesktopScreen` function returns true for desktop screens
   - Verify configuration is applied before first dialog use

2. **Bottom sheet not showing on mobile**
   - Ensure `isDesktopScreen` returns false for mobile screens
   - Check that `modal_bottom_sheet` dependency is properly installed

3. **Keyboard covering content**
   - This should be handled automatically
   - If issues persist, ensure proper `resizeToAvoidBottomInset` settings

### Debug Mode

Enable logging to debug responsive behavior:

```dart
ResponsiveDialogHelper.configure(
  ResponsiveDialogConfig(
    isDesktopScreen: (context) {
      final width = MediaQuery.sizeOf(context).width;
      debugPrint('Screen width: $width, isDesktop: ${width > 600}');
      return width > 600;
    },
  ),
);
```

## Contributing

When contributing to the responsive dialog helper:

1. Ensure cross-platform compatibility
2. Test on various screen sizes
3. Maintain backward compatibility
4. Add comprehensive tests
5. Update documentation

## See Also

- [Modal Bottom Sheet Package](https://pub.dev/packages/modal_bottom_sheet)
- [Flutter Dialog Documentation](https://api.flutter.dev/flutter/material/Dialog-class.html)
- [Responsive Design Guidelines](https://material.io/design/layout/responsive-layout-grid.html)
