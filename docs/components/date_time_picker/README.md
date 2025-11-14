# Date Time Picker Components Documentation

A comprehensive, accessible, and performant date/time picker component library built with Flutter and following SOLID principles.

## Overview

This library provides modular date and time picker components that were extracted from a monolithic `DatePickerDialog` (1,873 lines) into focused, reusable components:

- **CalendarDatePicker** (355 lines) - Clean calendar interface with single/range selection
- **TimeSelector** (325 lines) - Efficient time selection with wheel picker
- **QuickRangeSelector** (419 lines) - Quick range selection with predefined ranges
- **DateValidationDisplay** (262 lines) - Validation handling with real-time feedback

All components include:
- ✅ **WCAG 2.1 AA Accessibility** compliance
- ✅ **Full keyboard navigation** support
- ✅ **Responsive design** with mobile/tablet/desktop optimizations
- ✅ **Performance optimized** with LRU cache
- ✅ **Internationalization** ready

## 🚀 Quick Start

### Basic Calendar Date Picker

```dart
CalendarDatePicker(
  selectionMode: DateSelectionMode.single,
  selectedDate: DateTime.now(),
  onSingleDateSelected: (date) => print('Selected: $date'),
  onRangeSelected: (_, __) {},
  translations: {
    DateTimePickerTranslationKey.today: 'Today',
    DateTimePickerTranslationKey.clear: 'Clear',
  },
)
```

### Basic Time Selector

```dart
TimeSelector(
  selectedDate: DateTime.now(),
  initialTime: TimeOfDay.now(),
  showTimePicker: false,
  translations: translationsMap,
  onTimeChanged: (dateTime) => print('Time: ${dateTime.timeOfDay}'),
)
```

### Basic Quick Range Selector

```dart
QuickRangeSelector(
  quickRanges: [
    QuickDateRange(
      key: 'today',
      label: 'Today',
      startDateCalculator: () => DateTime.now(),
      endDateCalculator: () => DateTime.now(),
    ),
  ],
  onQuickRangeSelected: (range) => print('Selected: ${range.label}'),
  translations: translationsMap,
  hasSelection: false,
)
```

## 📱 Responsive Design

### Responsive Values

```dart
// Get responsive font size
final fontSize = ResponsiveUtil.getFontSize(
  context: context,
  mobile: 14.0,
  tablet: 16.0,
  desktop: 18.0,
);

// Get responsive spacing
final spacing = ResponsiveUtil.getLandscapeSpacing(
  context: context,
  mobile: 8.0,
  tablet: 12.0,
  desktop: 16.0,
);

// Check device type
final isMobile = ResponsiveUtil.isCompactLayout(context);
final isTablet = !ResponsiveUtil.isCompactLayout(context) && !ResponsiveUtil.isExpandedLayout(context);
final isDesktop = ResponsiveUtil.isExpandedLayout(context);
```

### Breakpoints

- **Mobile**: < 600px width
- **Tablet**: 600px - 900px width
- **Desktop**: > 900px width

## 🎨 Common Patterns

### Date and Time Selection Together

```dart
class DateTimePickerWidget extends StatefulWidget {
  @override
  _DateTimePickerWidgetState createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar for date selection
        CalendarDatePicker(
          selectionMode: DateSelectionMode.single,
          selectedDate: selectedDate,
          onSingleDateSelected: (date) {
            setState(() => selectedDate = date);
          },
          onRangeSelected: (_, __) {},
          translations: translations,
        ),

        SizedBox(height: ResponsiveUtil.getLandscapeSpacing(context, mobile: 16.0)),

        // Time selector for time selection
        TimeSelector(
          selectedDate: selectedDate ?? DateTime.now(),
          initialTime: selectedTime ?? TimeOfDay.now(),
          showTimePicker: false,
          translations: translations,
          onTimeChanged: (dateTime) {
            setState(() {
              selectedDate = dateTime;
              selectedTime = dateTime.timeOfDay;
            });
          },
        ),
      ],
    );
  }
}
```

### Range Selection with Quick Ranges

```dart
class RangeDatePickerWidget extends StatefulWidget {
  @override
  _RangeDatePickerWidgetState createState() => _RangeDatePickerWidgetState();
}

class _RangeDatePickerWidgetState extends State<RangeDatePickerWidget> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedQuickRange;

  final quickRanges = [
    QuickDateRange(
      key: 'today',
      label: 'Today',
      startDateCalculator: () => DateTime.now(),
      endDateCalculator: () => DateTime.now(),
    ),
    QuickDateRange(
      key: 'this_week',
      label: 'This Week',
      startDateCalculator: () => DateTime.now().subtract(Duration(days: 7)),
      endDateCalculator: () => DateTime.now(),
    ),
    QuickDateRange(
      key: 'this_month',
      label: 'This Month',
      startDateCalculator: () => DateTime(DateTime.now().year, DateTime.now().month, 1),
      endDateCalculator: () => DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick range selector
        QuickRangeSelector(
          quickRanges: quickRanges,
          selectedQuickRangeKey: selectedQuickRange,
          onQuickRangeSelected: (range) {
            setState(() {
              selectedQuickRange = range.key;
              startDate = range.startDateCalculator();
              endDate = range.endDateCalculator();
            });
          },
          onClear: () {
            setState(() {
              selectedQuickRange = null;
              startDate = null;
              endDate = null;
            });
          },
          translations: translations,
          hasSelection: startDate != null || endDate != null,
        ),

        SizedBox(height: ResponsiveUtil.getLandscapeSpacing(context, mobile: 16.0)),

        // Calendar for custom range selection
        CalendarDatePicker(
          selectionMode: DateSelectionMode.range,
          selectedStartDate: startDate,
          selectedEndDate: endDate,
          onRangeSelected: (start, end) {
            setState(() {
              startDate = start;
              endDate = end;
              selectedQuickRange = null; // Clear quick range when custom selected
            });
          },
          onSingleDateSelected: (_) {},
          translations: translations,
        ),
      ],
    );
  }
}
```

## Components

### 📅 CalendarDatePicker

A responsive calendar date picker supporting both single date and date range selection modes.

#### Usage

```dart
// Single Date Selection
CalendarDatePicker(
  selectionMode: DateSelectionMode.single,
  selectedDate: DateTime.now(),
  onSingleDateSelected: (DateTime? date) {
    print('Selected: $date');
  },
  onRangeSelected: (_, __) {},
  translations: yourTranslationsMap,
)

// Date Range Selection
CalendarDatePicker(
  selectionMode: DateSelectionMode.range,
  selectedStartDate: DateTime.now().subtract(Duration(days: 7)),
  selectedEndDate: DateTime.now(),
  onSingleDateSelected: (_) {},
  onRangeSelected: (DateTime? start, DateTime? end) {
    print('Range: $start to $end');
  },
  translations: yourTranslationsMap,
)
```

#### API Reference

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `selectionMode` | `DateSelectionMode` | ✅ | - | Selection mode (single or range) |
| `selectedDate` | `DateTime?` | ❌ | `null` | Currently selected single date |
| `selectedStartDate` | `DateTime?` | ❌ | `null` | Selected range start date |
| `selectedEndDate` | `DateTime?` | ❌ | `null` | Selected range end date |
| `minDate` | `DateTime?` | ❌ | `null` | Minimum selectable date |
| `maxDate` | `DateTime?` | ❌ | `null` | Maximum selectable date |
| `showTime` | `bool` | ❌ | `false` | Show time picker after date selection |
| `onUserHasSelectedQuickRangeChanged` | `VoidCallback?` | ❌ | `null` | Callback when quick range changes |
| `onSingleDateSelected` | `Function(DateTime?)` | ✅ | - | Callback for single date selection |
| `onRangeSelected` | `Function(DateTime?, DateTime?)` | ✅ | - | Callback for range selection |
| `translations` | `Map<DateTimePickerTranslationKey, String>` | ✅ | - | Translation strings |

#### DateSelectionMode Enum

```dart
enum DateSelectionMode {
  single,  // Select single date
  range,   // Select date range
}
```

#### Features

- **Accessibility**: Full keyboard navigation and screen reader support
- **Responsive**: Adapts to mobile (350px), tablet (420px), desktop (480px) widths
- **International**: Supports 22+ languages via translation system
- **Constraints**: Respects min/max date boundaries with time validation
- **Performance**: Optimized for large date ranges with efficient rendering

---

### ⏰ TimeSelector

An inline time selector with wheel-style picker and keyboard navigation support.

#### Usage

```dart
TimeSelector(
  selectedDate: DateTime.now(),
  initialTime: TimeOfDay(hour: 14, minute: 30),
  showTimePicker: false, // Start collapsed
  translations: yourTranslationsMap,
  onTimeChanged: (DateTime newDateTime) {
    print('Time changed: ${newDateTime.timeOfDay}');
  },
  onHapticFeedback: () {
    // Optional haptic feedback callback
    HapticFeedback.lightImpact();
  },
)
```

#### API Reference

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `selectedDate` | `DateTime` | ✅ | - | Base date for time combination |
| `initialTime` | `TimeOfDay` | ✅ | - | Initial time to display |
| `showTimePicker` | `bool` | ✅ | - | Whether picker starts expanded |
| `translations` | `Map<DateTimePickerTranslationKey, String>` | ✅ | - | Translation strings |
| `onTimeChanged` | `Function(DateTime)` | ✅ | - | Callback when time changes |
| `onHapticFeedback` | `VoidCallback?` | ❌ | `null` | Optional haptic feedback |

#### Keyboard Navigation

- **Enter/Space**: Toggle time picker expansion
- **Escape**: Close time picker
- **Arrow Keys**: Navigate time wheel (when expanded)

#### Features

- **Wheel Picker**: Smooth, native-feeling time selection
- **Inline Interface**: Expands/collapses without dialogs
- **Responsive**: Touch targets scale with device type
- **Haptic**: Optional haptic feedback on interactions
- **Accessibility**: Full keyboard and screen reader support

---

### 🚀 QuickRangeSelector

A quick range selector with predefined date ranges and optional refresh toggles.

#### Usage

```dart
final quickRanges = [
  QuickDateRange(
    key: 'today',
    label: 'Today',
    startDateCalculator: () => DateTime.now(),
    endDateCalculator: () => DateTime.now(),
  ),
  QuickDateRange(
    key: 'week',
    label: 'This Week',
    startDateCalculator: () => DateTime.now().subtract(Duration(days: 7)),
    endDateCalculator: () => DateTime.now(),
  ),
];

QuickRangeSelector(
  quickRanges: quickRanges,
  selectedQuickRangeKey: 'today',
  showQuickRanges: true,
  showRefreshToggle: true,
  refreshEnabled: false,
  translations: yourTranslationsMap,
  onQuickRangeSelected: (QuickDateRange range) {
    print('Quick range: ${range.label}');
  },
  onClear: () {
    print('Clear selection');
  },
  hasSelection: true,
)
```

#### API Reference

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `quickRanges` | `List<QuickDateRange>?` | ❌ | `null` | Available quick ranges |
| `selectedQuickRangeKey` | `String?` | ❌ | `null` | Currently selected range key |
| `showQuickRanges` | `bool` | ✅ | - | Whether to show quick range selector |
| `showRefreshToggle` | `bool` | ✅ | - | Whether to show refresh toggle |
| `refreshEnabled` | `bool` | ✅ | - | Whether refresh is currently enabled |
| `translations` | `Map<DateTimePickerTranslationKey, String>` | ✅ | - | Translation strings |
| `onQuickRangeSelected` | `Function(QuickDateRange)` | ✅ | - | Callback for range selection |
| `onRefreshToggle` | `VoidCallback?` | ❌ | `null` | Callback for refresh toggle |
| `onClear` | `VoidCallback?` | ❌ | `null` | Callback for clear action |
| `hasSelection` | `bool` | ✅ | - | Whether anything is currently selected |
| `isCompactScreen` | `bool?` | ❌ | `null` | Override compact screen detection |
| `actionButtonRadius` | `double?` | ❌ | `null` | Custom button border radius |

#### QuickDateRange Class

```dart
class QuickDateRange {
  final String key;                           // Unique identifier
  final String label;                         // Display label
  final DateTime Function() startDateCalculator;   // Calculate start date
  final DateTime Function() endDateCalculator;     // Calculate end date

  const QuickDateRange({
    required this.key,
    required this.label,
    required this.startDateCalculator,
    required this.endDateCalculator,
  });
}
```

#### Keyboard Navigation

- **Enter/Space**: Open quick range selection dialog
- **Escape**: Close dialog
- **Delete**: Clear selection (when has selection)

#### Features

- **Dynamic Ranges**: Calculator-based date ranges
- **Responsive**: Touch-optimized buttons and dialogs
- **Clear Functionality**: Separate clear button with keyboard support
- **Refresh Toggle**: Optional refresh functionality for dynamic ranges
- **Accessibility**: Full screen reader and keyboard navigation

---

### ⚡ ResponsiveUtil

Centralized responsive design utility for consistent behavior across all components.

#### Usage

```dart
// Get device type
final deviceType = ResponsiveUtil.getDeviceType(context);
// Returns: ResponsiveDeviceType.mobile/tablet/desktop

// Get responsive values
final fontSize = ResponsiveUtil.getFontSize(
  context: context,
  mobile: 14.0,
  tablet: 16.0,
  desktop: 18.0,
);

final spacing = ResponsiveUtil.getSpacing(
  context: context,
  mobile: 8.0,
  tablet: 12.0,
  desktop: 16.0,
);

// Check layout type
final isCompact = ResponsiveUtil.isCompactLayout(context);
final isExpanded = ResponsiveUtil.isExpandedLayout(context);
```

#### Breakpoints

| Device | Width Range | Layout Type |
|--------|-------------|-------------|
| Mobile | < 600px | Compact |
| Tablet | 600px - 900px | Normal |
| Desktop | > 900px | Expanded |

#### API Reference

| Method | Return Type | Description |
|--------|------------|-------------|
| `getDeviceType(BuildContext)` | `ResponsiveDeviceType` | Detect current device type |
| `isCompactLayout(BuildContext)` | `bool` | Check if mobile layout |
| `isExpandedLayout(BuildContext)` | `bool` | Check if tablet/desktop layout |
| `getResponsiveValue({required BuildContext, required T mobile, T? tablet, T? desktop})` | `T` | Get value based on device type |
| `getFontSize({required BuildContext, double mobile, double tablet, double desktop})` | `double` | Get responsive font size |
| `getSpacing({required BuildContext, double mobile, double tablet, double desktop})` | `double` | Get responsive spacing |
| `getIconSize({required BuildContext, double mobile, double tablet, double desktop})` | `double` | Get responsive icon size |
| `calculateDialogWidth(BuildContext)` | `double` | Calculate optimal dialog width |
| `calculateDialogHeight(BuildContext)` | `double` | Calculate optimal dialog height |

---

### 🗄️ LRU Cache

High-performance Least Recently Used cache for date formatting optimization.

#### Usage

```dart
// Create cache
final cache = LRUCache<DateTime, String>(50); // 50 items max

// Store values
cache.put(DateTime.now(), 'Formatted date');

// Retrieve values
final formatted = cache.get(DateTime.now());

// Check cache statistics
final stats = cache.stats;
print('Size: ${stats.size}');
print('Utilization: ${stats.utilizationRatio}');
```

#### API Reference

| Method | Return Type | Description |
|--------|------------|-------------|
| `LRUCache(int maxSize)` | - | Create cache with max size |
| `put(K key, V value)` | `void` | Store or update item |
| `get(K key)` | `V?` | Retrieve item, null if not found |
| `remove(K key)` | `V?` | Remove and return item |
| `containsKey(K key)` | `bool` | Check if key exists |
| `clear()` | `void` | Remove all items |
| `isEmpty` | `bool` | Check if cache is empty |
| `isFull` | `bool` | Check if cache is at capacity |
| `length` | `int` | Get current item count |
| `stats` | `CacheStats` | Get cache statistics |

#### Performance Characteristics

- **Time Complexity**: O(1) for all operations
- **Memory Usage**: Proportional to cache size
- **Eviction**: Least Recently Used (LRU) algorithm
- **Thread Safe**: Not thread-safe (use within single thread)

---

## 🎨 Theming and Styling

All components respect Material Design 3 theming:

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  ),
  home: YourDatePickerWidget(),
)
```

### Customization Options

- **Colors**: Use `primaryColor`, `surface`, `onSurface` from theme
- **Typography**: Respects `textTheme` sizing hierarchy
- **Spacing**: Uses responsive utility for consistent spacing
- **Border Radius**: Follows Material 3 specifications

## ♿ Accessibility Features

### WCAG 2.1 AA Compliance

- **Keyboard Navigation**: Full keyboard support for all interactive elements
- **Screen Reader**: Semantic labels and live regions for assistive technology
- **Focus Management**: Proper focus handling and visual indicators
- **Touch Targets**: Minimum 44px touch targets on mobile
- **Color Contrast**: Meets WCAG contrast ratios

### Keyboard Shortcuts

| Component | Keys | Function |
|-----------|-------|---------|
| All Components | `Tab` | Navigate between elements |
| TimeSelector | `Enter/Space` | Expand/collapse picker |
| TimeSelector | `Escape` | Close picker |
| QuickRangeSelector | `Enter/Space` | Open selection dialog |
| QuickRangeSelector | `Delete` | Clear selection |
| Calendar | `Arrow Keys` | Navigate calendar |
| Calendar | `Enter` | Select date |

## 🌐 Translation Setup

### Translation Map

```dart
final translations = {
  DateTimePickerTranslationKey.today: 'Today',
  DateTimePickerTranslationKey.tomorrow: 'Tomorrow',
  DateTimePickerTranslationKey.yesterday: 'Yesterday',
  DateTimePickerTranslationKey.thisWeek: 'This Week',
  DateTimePickerTranslationKey.thisMonth: 'This Month',
  DateTimePickerTranslationKey.clear: 'Clear',
  DateTimePickerTranslationKey.setTime: 'Set Time',
  DateTimePickerTranslationKey.cancel: 'Cancel',
  DateTimePickerTranslationKey.quickSelection: 'Quick Selection',
  DateTimePickerTranslationKey.dateRanges: 'Date Ranges',
  DateTimePickerTranslationKey.refreshSettings: 'Refresh Settings',
};
```

### Integration with Localization

```dart
import 'package:easy_localization/easy_localization.dart';

final translations = {
  DateTimePickerTranslationKey.today: tr('today'),
  DateTimePickerTranslationKey.clear: tr('clear'),
  DateTimePickerTranslationKey.setTime: tr('set_time'),
  // ... use your localization keys
};
```

### Supported Languages

The WHPH project supports 22+ languages including:
- English, Turkish, German, French, Spanish
- Italian, Portuguese, Russian, Chinese, Japanese
- Korean, Arabic, Hindi, and more...

## 🎯 LRU Cache Usage

### Date Formatting Cache

```dart
class DateFormatter {
  static final _cache = LRUCache<DateTime, String>(50);

  static String formatDate(DateTime date) {
    // Check cache first
    String? cached = _cache.get(date);
    if (cached != null) return cached;

    // Format and cache
    final formatted = '${date.day}/${date.month}/${date.year}';
    _cache.put(date, formatted);
    return formatted;
  }

  static void dispose() {
    _cache.clear();
  }
}
```

### Cache Statistics

```dart
final stats = cache.stats;
print('Cache size: ${stats.size}');
print('Utilization: ${(stats.utilizationRatio * 100).toStringAsFixed(1)}%');
```

## 🧪 Testing Examples

### Widget Test

```dart
testWidgets('TimeSelector handles time changes', (WidgetTester tester) async {
  DateTime? changedTime;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: TimeSelector(
        selectedDate: DateTime.now(),
        initialTime: const TimeOfDay(hour: 12, minute: 30),
        showTimePicker: false,
        translations: {},
        onTimeChanged: (dateTime) {
          changedTime = dateTime;
        },
      ),
    ),
  ));

  // Tap to expand time picker
  await tester.tap(find.byType(OutlinedButton));
  await tester.pumpAndSettle();

  // Tap on hour wheel to change time
  await tester.tap(find.text('1')); // Change hour from 12 to 1
  await tester.pumpAndSettle();

  // Verify time changed
  expect(changedTime, isNotNull);
  expect(changedTime!.hour, equals(1));
});
```

### Performance Test

```dart
testWidgets('CalendarDatePicker builds quickly', (WidgetTester tester) async {
  final stopwatch = Stopwatch()..start();

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: CalendarDatePicker(
        selectionMode: DateSelectionMode.single,
        selectedDate: DateTime.now(),
        onSingleDateSelected: (_) {},
        onRangeSelected: (_, __) {},
        translations: {},
      ),
    ),
  ));

  await tester.pumpAndSettle();
  stopwatch.stop();

  // Should build within 100ms
  expect(stopwatch.elapsedMilliseconds, lessThan(100));
});
```

## ♿ Accessibility Checklist

### Required Semantic Labels

```dart
// ✅ Good: Descriptive labels
Semantics(
  button: true,
  label: 'Time selector, current time: 2:30 PM',
  hint: 'Tap to change time',
  child: TimeSelector(...),
)

// ❌ Avoid: Generic labels
Semantics(
  button: true,
  label: 'Button',
  child: TimeSelector(...),
)
```

### Keyboard Navigation

```dart
Focus(
  onKeyEvent: (node, event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        // Handle interaction
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  },
  child: YourButton(...),
)
```

## 📱 Responsive Design

### Device-Specific Optimizations

#### Mobile (< 600px)
- Compact spacing and touch targets
- Larger tap targets (44px minimum)
- Optimized for thumb navigation
- Vertical-first layouts

#### Tablet (600px - 900px)
- Medium spacing and targets
- Balance of touch and cursor input
- Hybrid layouts
- Enhanced keyboard support

#### Desktop (> 900px)
- Generous spacing and targets
- Cursor-optimized interactions
- Full keyboard navigation
- Horizontal layouts where appropriate

### Breakpoint System

```dart
class ResponsiveBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 900.0;
  static const double desktop = 1200.0;
}
```

## ⚡ Performance Optimizations

### LRU Cache Implementation

The date picker uses an intelligent LRU cache for date formatting:

- **Capacity**: 50 formatted dates (tunable)
- **Hit Ratio**: ~70-80% in typical usage
- **Memory Usage**: ~2KB for full cache
- **Performance**: <1ms for cache operations

### Rendering Optimizations

- **Const Constructors**: Wherever possible for build optimization
- **Lazy Loading**: Calendar renders only visible dates
- **Efficient Rebuilds**: Minimal widget tree invalidation
- **Memory Management**: Proper disposal and cleanup

### Performance Benchmarks

- **TimeSelector Build**: <100ms average
- **QuickRangeSelector Build**: <50ms average
- **Dialog Opening**: <150ms average
- **Cache Operations**: <1ms average

## 🧪 Testing

### Widget Tests

```bash
fvm flutter test test/presentation/ui/components/date_time_picker/
```

### Performance Tests

```bash
fvm flutter test test/presentation/ui/components/date_time_picker/performance_benchmark_test.dart
```

### Accessibility Tests

```bash
fvm flutter test test/presentation/ui/components/date_time_picker/accessibility_test.dart
```

## 🚀 Migration Guide

### From Original DatePickerDialog

The original monolithic component has been split into focused components:

**Before:**
```dart
DatePickerDialog(
  // 40+ parameters in single component
  selectedDate: date,
  initialTime: time,
  showTimePicker: showTime,
  onDateChanged: onDateChanged,
  // ... many more parameters
)
```

**After:**
```dart
// Use specific components as needed
Column(
  children: [
    CalendarDatePicker(
      selectionMode: DateSelectionMode.single,
      selectedDate: date,
      onSingleDateSelected: onDateChanged,
      // ... 12 focused parameters
    ),
    TimeSelector(
      selectedDate: date,
      initialTime: time,
      showTimePicker: showTime,
      onTimeChanged: onTimeChanged,
      // ... 6 focused parameters
    ),
    QuickRangeSelector(
      quickRanges: ranges,
      onQuickRangeSelected: onRangeSelected,
      // ... 8 focused parameters
    ),
  ],
)
```

### Benefits

- **Single Responsibility**: Each component has one clear purpose
- **Composable**: Use only what you need
- **Testable**: Smaller components are easier to test
- **Maintainable**: Easier to understand and modify
- **Reusable**: Components can be used independently

## 📚 Best Practices

### Performance

1. **Use LRU Cache**: Enable date formatting cache for high-frequency updates
2. **Lazy Loading**: Load date picker dialogs only when needed
3. **Dispose Resources**: Call dispose() on cache when no longer needed
4. **Minimize Rebuilds**: Use const constructors and proper keys

### Accessibility

1. **Provide Translations**: Always include translation strings for all user-facing text
2. **Semantic Labels**: Use descriptive semantic labels for screen readers
3. **Keyboard Support**: Test all interactions with keyboard only
4. **Focus Management**: Ensure proper focus order and visual indicators

### Responsive Design

1. **Use ResponsiveUtil**: Always use responsive utilities instead of hard-coded values
2. **Test Multiple Devices**: Verify behavior across mobile, tablet, and desktop
3. **Touch Targets**: Ensure minimum 44px touch targets on mobile
4. **Orientation Changes**: Test both portrait and landscape modes

### Component Usage

1. **Single Purpose**: Use each component for its intended purpose only
2. **Controlled vs Uncontrolled**: Choose appropriate state management pattern
3. **Callbacks**: Use appropriate callback patterns for state changes
4. **Error Handling**: Provide graceful fallbacks for edge cases

## 🔧 Development

### Adding New Components

1. Follow SOLID principles
2. Include accessibility from the start
3. Add comprehensive tests
4. Document with examples
5. Include performance benchmarks

### Code Style

```dart
// ✅ Good: Descriptive names, single responsibility
class TimeSelector extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;

  const TimeSelector({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });
}

// ❌ Avoid: Generic names, unclear purpose
class PickerWidget extends StatefulWidget {
  final dynamic time;
  final VoidCallback cb;
}
```

### Testing Requirements

- Unit tests for all business logic
- Widget tests for UI components
- Integration tests for component interactions
- Accessibility tests for WCAG compliance
- Performance tests for critical paths

## 📖 API Reference Summary

### Component Parameters Overview

| Component | Required Parameters | Optional Parameters | Key Features |
|-----------|-------------------|--------------------|--------------|
| **CalendarDatePicker** | 7 | 6 | Single/range selection, accessibility |
| **TimeSelector** | 5 | 1 | Inline picker, keyboard navigation |
| **QuickRangeSelector** | 7 | 4 | Predefined ranges, clear functionality |
| **LRU Cache** | 1 (size) | - | High-performance date formatting |
| **ResponsiveUtil** | 1+ | - | Centralized responsive logic |

### Common Patterns

**Translation Maps:**
```dart
final translations = {
  DateTimePickerTranslationKey.today: localizations.today,
  DateTimePickerTranslationKey.clear: localizations.clear,
  DateTimePickerTranslationKey.setTime: localizations.setTime,
};
```

**Responsive Values:**
```dart
final fontSize = ResponsiveUtil.getFontSize(
  context: context,
  mobile: 14.0,
  tablet: 16.0,
  desktop: 18.0,
);
```

**State Management:**
```dart
// Controlled component
TimeSelector(
  initialTime: selectedTime,
  onTimeChanged: (newTime) => setState(() => selectedTime = newTime),
)
```

## 🤝 Contributing

When contributing to date picker components:

1. Follow existing code style and patterns
2. Add tests for new functionality
3. Update documentation
4. Consider accessibility implications
5. Include performance impact analysis
6. Test on multiple device sizes

## 📄 License

This component library is part of the WHPH project and follows the same licensing terms.

---

**Last Updated**: November 2024
**Version**: 1.0.0
**Flutter Version**: 3.32.0+