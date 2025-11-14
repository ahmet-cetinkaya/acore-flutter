# Utils Module

The utils module provides a comprehensive collection of utility classes and helper functions for common Flutter development tasks. These utilities are designed to be reusable across multiple projects and follow Flutter best practices.

## Available Utilities

### 📱 [Async Utils](ASYNC_UTILS.md)

Advanced asynchronous programming utilities for handling future operations, stream management, and async state management.

**Features:**

- Future composition and chaining
- Stream batching and debouncing
- Async state management
- Error handling patterns

### 🎨 [Color Contrast Helper](COLOR_CONTRAST_HELPER.md)

Utilities for calculating and ensuring proper color contrast ratios for accessibility compliance.

**Features:**

- WCAG contrast ratio calculations
- Accessibility compliance checking
- Color adjustment suggestions
- Dynamic color generation

### 📋 [Collection Utils](COLLECTION_UTILS.md)

Enhanced collection manipulation utilities extending Dart's built-in collection operations.

**Features:**

- Advanced list operations
- Map transformations
- Collection filtering and sorting
- Performance-optimized algorithms

### 📏 [Dialog Size](DIALOG_SIZE.md)

Enum defining different dialog sizes for responsive dialogs with platform-specific behaviors.

**Features:**

- Predefined dialog sizes (min, small, medium, large, max)
- Platform-specific sizing logic
- Mobile and desktop optimizations
- Customizable breakpoints

### 📱 [Haptic Feedback Util](HAPTIC_FEEDBACK_UTIL.md)

Cross-platform haptic feedback utilities for enhanced user experience through tactile responses.

**Features:**

- Platform-specific haptic patterns
- Impact feedback types
- Selection feedback
- Notification feedback
- Error handling for unsupported devices

### 🔄 [LRU Cache](LRU_CACHE.md)

High-performance Least Recently Used (LRU) cache implementation for efficient memory management.

**Features:**

- Thread-safe operations
- Configurable capacity
- Automatic cleanup
- Performance monitoring
- Custom eviction policies

### 📐 [Migration Registry](MIGRATION_REGISTRY.md)

Database migration management system for handling schema changes and data transformations.

**Features:**

- Version tracking
- Migration execution
- Rollback capabilities
- Dependency management

### 📊 [Order Rank](ORDER_RANK.md)

Utility for managing ordered data structures with efficient ranking and position tracking.

**Features:**

- Position management
- Reordering operations
- Rank calculations
- Batch updates

### 💻 [Platform Utils](PLATFORM_UTILS.md)

Cross-platform utilities for detecting device characteristics and adapting behavior accordingly.

**Features:**

- Platform detection (iOS, Android, Web, Desktop)
- Device type identification
- Screen size categorization
- Browser feature detection

### 📱 [Responsive Dialog Helper](RESPONSIVE_DIALOG_HELPER.md)

Comprehensive utility for showing responsive dialogs that adapt to different screen sizes and platforms.

**Features:**

- Desktop modal dialogs
- Mobile bottom sheets
- Keyboard-aware resizing
- Configurable sizing
- Cross-platform consistency

### 📐 [Responsive Util](RESPONSIVE_UTIL.md)

Advanced responsive design utilities for creating adaptive user interfaces across different screen sizes and orientations.

**Features:**

- Multi-breakpoint support
- Orientation detection
- Device type detection
- Responsive sizing
- Layout optimization

### ⏰ [Semantic Version](SEMANTIC_VERSION.md)

Semantic versioning utility for parsing, comparing, and managing version numbers according to SemVer specification.

**Features:**

- Version parsing and validation
- Version comparison operations
- Range matching
- Dependency resolution

### ⏱️ [Time Formatting Util](TIME_FORMATTING_UTIL.md)

Comprehensive time and date formatting utilities with localization support and custom patterns.

**Features:**

- Date/time formatting
- Relative time formatting
- Duration formatting
- Timezone support
- Custom patterns

## Usage Patterns

### Importing Utilities

```dart
// Import all utilities
import 'package:acore/utils.dart';

// Import specific utilities
import 'package:acore/utils/responsive_dialog_helper.dart';
import 'package:acore/utils/collection_utils.dart';
```

### Combining Multiple Utilities

```dart
import 'package:acore/utils.dart';

class AdaptiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Combine responsive utilities with other helpers
    final isDesktop = ResponsiveUtil.isExpandedLayout(context);
    final appropriateSize = isDesktop ? DialogSize.large : DialogSize.medium;

    return Container(
      child: ElevatedButton(
        onPressed: () {
          // Use responsive dialog helper
          ResponsiveDialogHelper.showResponsiveDialog(
            context: context,
            size: appropriateSize,
            child: MyDialogContent(),
          );

          // Use haptic feedback
          HapticFeedbackUtil.lightImpact();
        },
        child: Text('Show Dialog'),
      ),
    );
  }
}
```

### Performance Optimization

```dart
import 'package:acore/utils.dart';

class OptimizedDataProvider {
  // Use LRU cache for performance
  final _cache = LruCache<String, Data>(maxSize: 100);

  // Use async utils for efficient data loading
  Future<Data> getData(String key) async {
    return _cache.get(key, () => _loadDataFromApi(key));
  }

  Future<Data> _loadDataFromApi(String key) async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 500));
    return Data(key);
  }
}
```

### Error Handling

```dart
import 'package:acore/utils.dart';

class RobustComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result>(
      future: _performOperation(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!.fold(
            (error) => ErrorWidget(error),
            (data) => SuccessWidget(data),
          );
        }
        return LoadingWidget();
      },
    );
  }

  Future<Result> _performOperation() async {
    try {
      final data = await fetchData();
      return Result.success(data);
    } catch (e) {
      return Result.failure(e);
    }
  }
}
```

## Best Practices

### 1. Utility Selection

Choose the right utility for your specific need:

```dart
// ✅ Good: Use specialized utilities
ResponsiveDialogHelper.showResponsiveDialog(...);  // For dialogs
PlatformUtils.isDesktop;                           // For platform detection
CollectionUtils.groupBy(list, (item) => item.category); // For collection operations

// ❌ Avoid: Reinventing existing functionality
```

### 2. Performance Considerations

```dart
// ✅ Good: Cache expensive operations
final _cache = LruCache<String, ComplexResult>(maxSize: 50);

Future<ComplexResult> getCachedResult(String key) {
  return _cache.get(key, () => _computeExpensiveResult(key));
}
```

### 3. Error Handling

```dart
// ✅ Good: Handle platform-specific features
void provideFeedback() {
  try {
    HapticFeedbackUtil.mediumImpact();
  } catch (e) {
    // Graceful fallback if haptics not supported
    debugPrint('Haptics not supported: $e');
  }
}
```

### 4. Responsive Design

```dart
// ✅ Good: Combine responsive utilities
Widget build(BuildContext context) {
  final isDesktop = ResponsiveUtil.isExpandedLayout(context);
  final dialogSize = isDesktop ? DialogSize.large : DialogSize.medium;

  return ResponsiveLayout(
    mobile: MobileLayout(),
    desktop: DesktopLayout(),
    onShowDialog: () => ResponsiveDialogHelper.showResponsiveDialog(
      context: context,
      size: dialogSize,
      child: MyContent(),
    ),
  );
}
```

## Cross-Project Usage

These utilities are designed to work across multiple Flutter projects:

### 1. Add Dependency

```yaml
dependencies:
  acore: ^1.0.0
```

### 2. Configure Project-Specific Settings

```dart
// In your app's main.dart
import 'package:acore/utils.dart';

void main() {
  // Configure responsive dialogs for your app's theme
  ResponsiveDialogHelper.configure(
    ResponsiveDialogConfig(
      screenMediumBreakpoint: 800.0,
      containerBorderRadius: 16.0,
      isDesktopScreen: (context) => MediaQuery.sizeOf(context).width > 800.0,
    ),
  );

  runApp(MyApp());
}
```

### 3. Use Utilities Throughout Your App

```dart
import 'package:acore/utils.dart';

class MyFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showResponsiveDialog(context),
      child: Text('Show Dialog'),
    );
  }

  void _showResponsiveDialog(BuildContext context) {
    ResponsiveDialogHelper.showResponsiveDialog(
      context: context,
      size: DialogSize.medium,
      child: MyDialogContent(),
    );
  }
}
```

## Testing

Utilities are designed to be testable:

```dart
// Example test for responsive dialog helper
void main() {
  group('ResponsiveDialogHelper', () {
    testWidgets('shows correct dialog size on desktop', (tester) async {
      // Mock desktop screen size
      tester.binding.window.physicalSizeTestValue = Size(1920, 1080);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(TestApp());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}
```

## Contributing

When contributing to the utils module:

1. **Follow Dart Style**: Use dart format and follow style guidelines
2. **Add Tests**: Include comprehensive tests for new utilities
3. **Document**: Provide clear documentation and examples
4. **Consider Cross-Platform**: Ensure utilities work on all supported platforms
5. **Performance**: Optimize for performance and memory usage
6. **Backward Compatibility**: Maintain API stability

## Migration Guide

### From Custom Implementations

If you have custom implementations, migrate to these utilities:

```dart
// Before: Custom responsive dialog
class MyResponsiveDialog {
  static void show(BuildContext context, Widget child) {
    if (Platform.isDesktop) {
      showDialog(context: context, builder: (_) => Dialog(child: child));
    } else {
      showModalBottomSheet(context: context, builder: (_) => child);
    }
  }
}

// After: Use responsive dialog helper
ResponsiveDialogHelper.showResponsiveDialog(context: context, child: child);
```

### Version Updates

When updating utilities, check the changelog for breaking changes and follow the migration instructions provided.

## See Also

- [ACORE Comprehensive Documentation](../ACORE_COMPREHENSIVE_DOCUMENTATION.md)
- [Quick Reference](../QUICK_REFERENCE.md)
- [Flutter Documentation](https://api.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
