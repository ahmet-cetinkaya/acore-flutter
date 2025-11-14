# Dialog Size

Enum defining different dialog sizes for responsive dialogs with platform-specific behaviors.

## Overview

The `DialogSize` enum provides predefined size configurations that adapt differently on desktop and mobile platforms, ensuring optimal user experience across all devices.

## Enum Values

### `DialogSize.min`

**Best for:** Alerts, confirmations, simple prompts

**Desktop:** Default Dialog behavior (content-based sizing)

- No width or height constraints
- Native dialog sizing
- Perfect for AlertDialogs and confirmation dialogs

**Mobile:** Default Dialog sizing (content-based)

- Standard modal dialog appearance
- Content-driven dimensions
- Optimal for quick interactions

**Use Cases:**

- Confirmation dialogs
- Alert messages
- Simple yes/no prompts
- Short text input dialogs

### `DialogSize.small`

**Best for:** Quick actions, simple forms, brief content

**Desktop:**

- Width: 50% of screen width
- Height: 40% of screen height
- Maximum width: 600px

**Mobile:**

- Initial height: 20% of available height
- Maximum height: 95% of available height

**Use Cases:**

- Quick action menus
- Short form dialogs
- Simple settings panels
- Brief information displays

### `DialogSize.medium`

**Best for:** Standard dialogs, forms, moderate content

**Desktop:**

- Width: 60% of screen width
- Height: 70% of screen height
- Maximum width: 900px

**Mobile:**

- Initial height: 85% of available height
- Maximum height: 95% of available height

**Use Cases:**

- Standard form dialogs
- Moderate-length content
- Settings panels
- User profiles
- Edit forms

### `DialogSize.large`

**Best for:** Complex content, detailed forms, rich media

**Desktop:**

- Width: 80% of screen width
- Height: 80% of screen height
- Maximum width: 1200px

**Mobile:**

- Initial height: 95% of available height
- Maximum height: 95% of available height

**Use Cases:**

- Complex forms
- Detailed information displays
- Media galleries
- Multi-step wizards
- Rich content presentations

### `DialogSize.max`

**Best for:** Maximum content space, fullscreen experiences

**Desktop:**

- Width: 95% of screen width
- Height: 95% of screen height
- Maximum width: Unbounded

**Mobile:**

- Initial height: 100% of available height
- Maximum height: 95% of available height (with safe area)

**Use Cases:**

- Fullscreen experiences
- Document viewers
- Image galleries
- Video players
- Maximum content density

## Usage Examples

### Basic Usage

```dart
import 'package:acore/acore.dart';

// Show a small dialog
await ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.small,
  child: QuickActionDialog(),
);

// Show a large dialog
await ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.large,
  child: DetailedForm(),
);
```

### Size Selection Guidelines

```dart
// ✅ Good: Choose size based on content complexity
DialogSize getSizeForContent(ContentComplexity complexity) {
  switch (complexity) {
    case ContentComplexity.simple:
      return DialogSize.small;
    case ContentComplexity.moderate:
      return DialogSize.medium;
    case ContentComplexity.complex:
      return DialogSize.large;
    case ContentComplexity.maximum:
      return DialogSize.max;
    default:
      return DialogSize.min;
  }
}

// Example: Confirmation dialog (min size)
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.min,  // Simple confirmation
  child: AlertDialog(
    title: Text('Delete Item?'),
    content: Text('This action cannot be undone.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
    ],
  ),
);

// Example: Complex settings form (large size)
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.large,  // Complex content
  child: Padding(
    padding: EdgeInsets.all(24.0),
    child: Column(
      children: [
        Text('Advanced Settings', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 24),
        Expanded(child: AdvancedSettingsForm()),
      ],
    ),
  ),
);
```

## Platform Behavior Details

### Desktop Platforms (Web, Windows, macOS, Linux)

- Dialogs appear as centered modal windows
- Ratio-based sizing maintains consistency across different screen sizes
- Maximum width constraints prevent excessively wide dialogs on large displays
- Content is constrained within defined dimensions
- Scrollable content when content exceeds available space

### Mobile Platforms (iOS, Android)

- Dialogs appear as material bottom sheets
- Keyboard-aware resizing prevents content obstruction
- Safe area handling ensures content doesn't overlap system UI
- Flexible initial height adapts to content while respecting screen space
- Drag-to-dismiss functionality on supported platforms

## Size Properties

Each DialogSize enum value provides several properties for customization:

### Desktop Properties

```dart
enum DialogSize {
  // ... enum values

  /// Width ratio for desktop dialogs
  double get desktopWidthRatio;

  /// Height ratio for desktop dialogs
  double get desktopHeightRatio;

  /// Maximum width constraint for desktop dialogs
  double get maxDesktopWidth;
}
```

### Mobile Properties

```dart
enum DialogSize {
  // ... enum values

  /// Initial child size ratio for mobile bottom sheets
  double get mobileInitialSizeRatio;

  /// Minimum child size ratio for mobile bottom sheets
  double get mobileMinSizeRatio;

  /// Maximum child size ratio for mobile bottom sheets
  double get mobileMaxSizeRatio;
}
```

## Responsive Behavior

The `ResponsiveDialogHelper` uses these size properties to determine optimal dialog dimensions:

```dart
// Desktop sizing logic
final dialogWidth = screenSize.width * size.desktopWidthRatio;
final dialogHeight = screenSize.height * size.desktopHeightRatio;
final maxWidth = size.maxDesktopWidth;

// Mobile sizing logic
final availableHeight = screenHeight - safeAreaBottom;
final maxHeight = availableHeight * size.mobileMaxSizeRatio;
final initialHeight = availableHeight * size.mobileInitialSizeRatio;
```

## Custom Size Logic

If predefined sizes don't meet your needs, you can:

### 1. Use Configuration Override

```dart
await ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  child: MyCustomContent(),
  config: ResponsiveDialogConfig(
    isDesktopScreen: (context) {
      // Custom logic for size determination
      return MediaQuery.sizeOf(context).width > 1200;
    },
  ),
);
```

### 2. Wrap in Custom Container

```dart
await ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.medium,  // Use medium as base
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: 400,  // Custom constraint
      maxHeight: 600,  // Custom constraint
    ),
    child: MyCustomContent(),
  ),
);
```

## Best Practices

### 1. Choose Appropriate Size for Content

```dart
// ✅ Good: Match size to content complexity
showSimpleConfirmation() => DialogSize.min;
showQuickAction() => DialogSize.small;
showStandardForm() => DialogSize.medium;
showComplexWizard() => DialogSize.large;
showFullscreenContent() => DialogSize.max;
```

### 2. Consider Input Methods

```dart
// ✅ Good: Larger sizes for touch-heavy interactions
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: Platform.isMobile ? DialogSize.large : DialogSize.medium,
  child: TouchHeavyForm(),
);
```

### 3. Handle Content Overflow

```dart
// ✅ Good: Enable scrolling for potentially large content
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.medium,
  isScrollable: true,  // Important for variable content
  child: VariableHeightContent(),
);
```

### 4. Test Across Devices

```dart
// ✅ Good: Consider different screen sizes in testing
final screenSize = MediaQuery.sizeOf(context);
final appropriateSize = screenSize.width > 800
  ? DialogSize.large
  : DialogSize.medium;
```

## Migration Guide

### From Fixed-Size Dialogs

```dart
// Before: Fixed size dialog
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: SizedBox(
      width: 600,
      height: 400,
      child: MyContent(),
    ),
  ),
);

// After: Responsive dialog
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.medium,  // Adapts to screen size
  child: MyContent(),
);
```

### From Fixed-Height Bottom Sheets

```dart
// Before: Fixed height bottom sheet
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    height: 300,
    child: MyContent(),
  ),
);

// After: Responsive dialog
ResponsiveDialogHelper.showResponsiveDialog(
  context: context,
  size: DialogSize.small,  // Responsive height
  child: MyContent(),
);
```

## Size Comparison Chart

| Size       | Desktop Width    | Desktop Height | Mobile Initial | Mobile Max    | Best For              |
| ---------- | ---------------- | -------------- | -------------- | ------------- | --------------------- |
| **min**    | Content-based    | Content-based  | Content-based  | Content-based | Alerts, confirmations |
| **small**  | 50% (max 600px)  | 40%            | 20%            | 95%           | Quick actions         |
| **medium** | 60% (max 900px)  | 70%            | 85%            | 95%           | Standard dialogs      |
| **large**  | 80% (max 1200px) | 80%            | 95%            | 95%           | Complex content       |
| **max**    | 95% (no max)     | 95%            | 100%           | 95%           | Fullscreen content    |

## Troubleshooting

### Common Issues

1. **Dialog too small on large screens**
   - Use larger `DialogSize` values
   - Check desktop detection logic

2. **Dialog too large on mobile**
   - Use smaller `DialogSize` values
   - Ensure mobile detection works correctly

3. **Content overflow**
   - Enable `isScrollable: true`
   - Consider using larger dialog size

4. **Inconsistent sizing**
   - Verify configuration is applied
   - Check custom `isDesktopScreen` function

### Debug Information

```dart
// Debug dialog sizes
void debugDialogSize(BuildContext context, DialogSize size) {
  final screenSize = MediaQuery.sizeOf(context);
  print('Screen: ${screenSize.width}x${screenSize.height}');
  print('Size: $size');
  print('Desktop Width Ratio: ${size.desktopWidthRatio}');
  print('Desktop Height Ratio: ${size.desktopHeightRatio}');
  print('Max Desktop Width: ${size.maxDesktopWidth}');
  print('Mobile Initial Ratio: ${size.mobileInitialSizeRatio}');
  print('Mobile Max Ratio: ${size.mobileMaxSizeRatio}');
}
```

## See Also

- [Responsive Dialog Helper](RESPONSIVE_DIALOG_HELPER.md)
- [Responsive Design Guidelines](https://material.io/design/layout/responsive-layout-grid.html)
- [Flutter Sizing Best Practices](https://api.flutter.dev/flutter/widgets/SizedBox-class.html)
