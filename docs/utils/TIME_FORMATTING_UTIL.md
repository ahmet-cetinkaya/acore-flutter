# Time Formatting Utility

## Overview

The `TimeFormattingUtil` provides locale-aware time formatting capabilities
using Flutter's MaterialLocalizations. It ensures consistent time display across
different locales and follows platform-specific time formatting conventions.

## Features

- 🌍 **Locale-Aware** - Automatically uses device locale settings
- ⏰ **Platform Consistent** - Matches system time formatting
- 🎯 **Type Safe** - Compile-time checked TimeOfDay formatting
- 📱 **Material Design** - Follows Material Design time formatting guidelines
- 🔧 **Flexible API** - Multiple formatting options for different use cases

## API Reference

### Static Methods

#### `String formatTime(BuildContext context, TimeOfDay time)`

Formats a TimeOfDay using the current locale's MaterialLocalizations.

**Parameters:**

- `context`: BuildContext containing the MaterialLocalizations
- `time`: TimeOfDay to format

**Returns:** String representation of the time in the current locale format

## Usage Examples

### Basic Time Formatting

```dart
class TimeDisplay extends StatelessWidget {
  final TimeOfDay selectedTime;

  const TimeDisplay({required this.selectedTime});

  @override
  Widget build(BuildContext context) {
    final formattedTime = TimeFormattingUtil.formatTime(context, selectedTime);

    return Text(
      formattedTime,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
```

### Time Selector Integration

```dart
class CustomTimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const CustomTimePicker({
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Selected Time',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          selectedTime != null
            ? TimeFormattingUtil.formatTime(context, selectedTime!)
            : 'No time selected',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              onTimeChanged(time);
            }
          },
          child: const Text('Select Time'),
        ),
      ],
    );
  }
}
```

### Time Range Display

```dart
class TimeRangeDisplay extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const TimeRangeDisplay({
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    final startFormatted = TimeFormattingUtil.formatTime(context, startTime);
    final endFormatted = TimeFormattingUtil.formatTime(context, endTime);

    return Row(
      children: [
        Icon(Icons.schedule, size: 20),
        const SizedBox(width: 8),
        Text(
          '$startFormatted - $endFormatted',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
```

### Event Card with Time

```dart
class EventCard extends StatelessWidget {
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const EventCard({
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  TimeFormattingUtil.formatTime(context, startTime),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Text(' - '),
                Text(
                  TimeFormattingUtil.formatTime(context, endTime),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## Locale Support

The utility automatically adapts to different locale conventions:

### English (en)

- **12-hour format**: "3:30 PM"
- **24-hour format**: "15:30"

### Spanish (es)

- **12-hour format**: "3:30 p. m."
- **24-hour format**: "15:30"

### Japanese (ja)

- **12-hour format**: "午後3:30"
- **24-hour format**: "15:30"

### French (fr)

- **12-hour format**: "15:30"
- **24-hour format**: "15:30"

## Time Format Detection

The utility respects the user's system settings:

```dart
// The formatting will automatically adapt to:
// - System locale settings
// - 12/24 hour preferences
// - Regional time formatting conventions
```

## Integration with Material Components

### Time Picker Integration

```dart
class TimePickerField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeSelected;

  const TimePickerField({
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          onTimeSelected(time);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Select Time',
          suffixIcon: Icon(Icons.access_time),
          border: OutlineInputBorder(),
        ),
        child: Text(
          selectedTime != null
            ? TimeFormattingUtil.formatTime(context, selectedTime!)
            : '',
        ),
      ),
    );
  }
}
```

## Best Practices

### 1. Always Provide BuildContext

```dart
// Good: Use context for locale-aware formatting
String formattedTime = TimeFormattingUtil.formatTime(context, time);

// Bad: Don't hardcode time formats
String formattedTime = "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
```

### 2. Handle Null Times Gracefully

```dart
// Good: Check for null values
Widget build(BuildContext context) {
  return Text(
    selectedTime != null
      ? TimeFormattingUtil.formatTime(context, selectedTime!)
      : 'No time selected',
  );
}
```

### 3. Consistent Time Display

```dart
// Good: Use the utility throughout your app for consistency
class TimeDisplay {
  static String format(BuildContext context, TimeOfDay? time) {
    return time != null
      ? TimeFormattingUtil.formatTime(context, time)
      : 'Not set';
  }
}
```

## Performance Considerations

- **MaterialLocalizations Access**: The utility efficiently accesses
  MaterialLocalizations
- **String Formatting**: Optimized string operations for performance
- **Context Dependency**: Requires valid BuildContext but minimal overhead

## Error Handling

The utility handles edge cases gracefully:

```dart
// Time outside normal ranges are still formatted correctly
final lateTime = TimeOfDay(hour: 23, minute: 59);
final formatted = TimeFormattingUtil.formatTime(context, lateTime);
// Works correctly: "11:59 PM" or "23:59" based on locale
```

## Testing Support

When testing time formatting, ensure proper MaterialLocalizations are available:

```dart
testWidgets('TimeFormattingUtil formats correctly', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          final time = TimeOfDay(hour: 14, minute: 30);
          final formatted = TimeFormattingUtil.formatTime(context, time);
          return Text(formatted);
        },
      ),
    ),
  ));

  expect(find.text('2:30 PM'), findsOneWidget);
});
```

## Accessibility Considerations

- **Screen Reader Support**: Formatted times are properly announced by screen
  readers
- **Consistent Format**: Uses system-preferred formats for better accessibility
- **Material Compliance**: Follows Material Design accessibility guidelines
