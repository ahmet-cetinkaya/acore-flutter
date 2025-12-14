# Haptic Feedback Utility

## Overview

The `HapticFeedbackUtil` provides platform-specific haptic feedback
functionality for Flutter applications. It delivers tactile responses that
enhance user interaction and provide physical confirmation for user actions.

## Features

- 📱 **Cross-Platform Support** - Works on Android, iOS, and supported platforms
- 🎯 **Action-Specific Feedback** - Different haptic patterns for different
  interaction types
- 🔧 **Configurable** - Optional haptic feedback with fallback handling
- ⚡ **Performance Optimized** - Minimal overhead with efficient trigger
  mechanisms
- 🛡️ **Error Safe** - Graceful degradation when haptic feedback isn't available

## API Reference

### Static Methods

#### `static void triggerHapticFeedback(BuildContext context, {HapticFeedbackType type = HapticFeedbackType.light})`

Triggers haptic feedback with the specified type.

**Parameters:**

- `context`: BuildContext for platform-specific optimizations
- `type`: Type of haptic feedback (default: light)

#### `static void triggerLightImpact(BuildContext context)`

Triggers a light haptic impact.

#### `static void triggerMediumImpact(BuildContext context)`

Triggers a medium haptic impact.

#### `static void triggerHeavyImpact(BuildContext context)`

Triggers a heavy haptic impact.

#### `static void triggerSelectionChange(BuildContext context)`

Triggers selection change haptic feedback.

#### `static void triggerNotificationSuccess(BuildContext context)`

Triggers success notification haptic feedback.

#### `static void triggerNotificationWarning(BuildContext context)`

Triggers warning notification haptic feedback.

#### `static void triggerNotificationError(BuildContext context)`

Triggers error notification haptic feedback.

### Enum: HapticFeedbackType

```dart
enum HapticFeedbackType {
  light,      // Subtle feedback for light touches
  medium,     // Medium feedback for moderate interactions
  heavy,      // Strong feedback for significant actions
  selection,  // Feedback for selection changes
  success,    // Success notification feedback
  warning,    // Warning notification feedback
  error,      // Error notification feedback
}
```

## Usage Examples

### Basic Haptic Feedback

```dart
class HapticButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HapticButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Trigger light haptic feedback
        HapticFeedbackUtil.triggerLightImpact(context);
        onPressed();
      },
      child: const Text('Press Me'),
    );
  }
}
```

### Action-Specific Haptic Feedback

```dart
class ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Light impact for common actions
        ElevatedButton(
          onPressed: () {
            HapticFeedbackUtil.triggerHapticFeedback(context, type: HapticFeedbackType.light);
            // Handle action
          },
          child: const Text('Save'),
        ),

        // Medium impact for important actions
        ElevatedButton(
          onPressed: () {
            HapticFeedbackUtil.triggerHapticFeedback(context, type: HapticFeedbackType.medium);
            // Handle important action
          },
          child: const Text('Submit'),
        ),

        // Heavy impact for critical actions
        ElevatedButton(
          onPressed: () {
            HapticFeedbackUtil.triggerHapticFeedback(context, type: HapticFeedbackType.heavy);
            // Handle critical action
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
```

### Selection Feedback

```dart
class SelectableList extends StatefulWidget {
  final List<String> items;

  const SelectableList({required this.items});

  @override
  State<SelectableList> createState() => _SelectableListState();
}

class _SelectableListState extends State<SelectableList> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.items[index]),
          selected: selectedIndex == index,
          onTap: () {
            // Trigger selection feedback
            HapticFeedbackUtil.triggerSelectionChange(context);
            setState(() {
              selectedIndex = selectedIndex == index ? null : index;
            });
          },
        );
      },
    );
  }
}
```

### Notification Feedback

```dart
class StatusDisplay extends StatelessWidget {
  final bool isLoading;
  final String? error;

  const StatusDisplay({
    required this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    if (error != null) {
      // Trigger error haptic feedback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HapticFeedbackUtil.triggerNotificationError(context);
      });

      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Expanded(child: Text(error!)),
            ],
          ),
        ),
      );
    }

    // Trigger success haptic feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedbackUtil.triggerNotificationSuccess(context);
    });

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Operation completed successfully!'),
          ],
        ),
      ),
    );
  }
}
```

### Switch and Toggle Feedback

```dart
class HapticSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const HapticSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: (newValue) {
        // Trigger selection feedback for toggle
        HapticFeedbackUtil.triggerSelectionChange(context);
        onChanged(newValue);
      },
    );
  }
}
```

### Form Validation Feedback

```dart
class ValidatedForm extends StatefulWidget {
  @override
  State<ValidatedForm> createState() => _ValidatedFormState();
}

class _ValidatedFormState extends State<ValidatedForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Success feedback
      HapticFeedbackUtil.triggerNotificationSuccess(context);

      // Process form...
    } else {
      // Error feedback
      HapticFeedbackUtil.triggerNotificationError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                // Trigger light impact for validation error
                HapticFeedbackUtil.triggerLightImpact(context);
                return 'Please enter a valid email';
              }
              return null;
            },
            onSaved: (value) => _email = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 6) {
                HapticFeedbackUtil.triggerLightImpact(context);
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onSaved: (value) => _password = value!,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleSubmit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

## Platform-Specific Behavior

### Android

- **Light Impact**: Light vibration (10ms)
- **Medium Impact**: Medium vibration (25ms)
- **Heavy Impact**: Strong vibration (50ms)
- **Selection**: Short tick vibration (5ms)
- **Notifications**: Device-specific notification patterns

### iOS

- **Light Impact**: UIImpactFeedbackStyle.light
- **Medium Impact**: UIImpactFeedbackStyle.medium
- **Heavy Impact**: UIImpactFeedbackStyle.heavy
- **Selection**: UISelectionFeedbackType.changed
- **Notifications**: UINotificationFeedbackType variants

## Best Practices

### 1. Use Appropriate Feedback Levels

```dart
// Good: Match feedback intensity to action importance
ElevatedButton(
  onPressed: () {
    HapticFeedbackUtil.triggerHapticFeedback(
      context,
      type: isCriticalAction ? HapticFeedbackType.heavy : HapticFeedbackType.light
    );
    handleAction();
  },
  child: Text('Action'),
)
```

### 2. Provide Fallback for Non-Haptic Devices

```dart
// Good: The utility automatically handles devices without haptic feedback
void triggerFeedback() {
  HapticFeedbackUtil.triggerLightImpact(context);
  // This will gracefully fail on devices without haptic support
}
```

### 3. Don't Overuse Haptic Feedback

```dart
// Bad: Excessive haptic feedback can be annoying
onTap: () {
  HapticFeedbackUtil.triggerLightImpact(context); // Too frequent
},

// Good: Reserve haptic feedback for meaningful interactions
onTap: () {
  if (isSignificantAction) {
    HapticFeedbackUtil.triggerLightImpact(context);
  }
  handleAction();
},
```

### 4. Respect User Preferences

```dart
// Good: Check if haptic feedback is enabled in settings
void triggerHapticFeedback(BuildContext context) {
  // Check user preferences before triggering
  if (userPreferences.hapticFeedbackEnabled) {
    HapticFeedbackUtil.triggerLightImpact(context);
  }
}
```

## Performance Considerations

- **Minimal Overhead**: Efficient trigger mechanisms with minimal performance
  impact
- **Debouncing**: The utility handles rapid successive calls appropriately
- **Battery Efficiency**: Optimized to minimize battery usage
- **Background Safety**: Safe to call from background threads with proper
  context

## Accessibility Integration

Haptic feedback enhances accessibility by:

- **Visual Impairment Support**: Provides tactile confirmation for actions
- **Motor Impairment Assistance**: Helps users confirm interactions
- **Multi-Sensory Experience**: Complements visual and audio feedback
- **Consistent Patterns**: Uses standard platform haptic patterns

## Testing Support

When testing haptic feedback in unit tests:

```dart
testWidgets('HapticFeedbackUtil triggers correctly', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) {
        return ElevatedButton(
          onPressed: () {
            // This should not throw errors in tests
            HapticFeedbackUtil.triggerLightImpact(context);
          },
          child: const Text('Test'),
        );
      },
    ),
  ));

  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Verify no exceptions were thrown
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

## Troubleshooting

### Common Issues

1. **No Haptic Feedback**: Check if device supports haptic feedback and it's
   enabled in settings
2. **Performance Issues**: Avoid triggering haptic feedback in rapid succession
3. **Platform Differences**: Different platforms may have different feedback
   intensities
4. **Context Requirements**: Always provide a valid BuildContext

### Debug Mode

The utility provides safe fallback behavior:

- Gracefully handles devices without haptic support
- Catches and logs exceptions without crashing the app
- Maintains app functionality even when haptic feedback fails
