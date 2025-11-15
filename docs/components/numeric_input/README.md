# Numeric Input Component

## Overview

The `NumericInput` component is a specialized input field designed for numeric data entry with built-in validation, formatting, and accessibility support. It provides a consistent user experience across different platforms and locales.

## Features

- 🔢 **Numeric-Only Input** - Automatically filters non-numeric characters
- 📱 **Platform-Native Keyboard** - Displays numeric keyboard on mobile devices
- 🎨 **Customizable Styling** - Flexible theming and appearance options
- ♿ **Accessibility Compliant** - Full screen reader and keyboard navigation support
- 🌍 **Locale-Aware** - Respects regional numeric formatting preferences
- ✅ **Built-in Validation** - Configurable min/max value validation
- 📐 **Responsive Design** - Adapts to different screen sizes

## API Reference

### Constructor

```dart
NumericInput({
  Key? key,
  required String? value,
  ValueChanged<String?>? onChanged,
  ValueChanged<String?>? onSubmitted,
  String? label,
  String? hint,
  String? errorText,
  bool? enabled,
  bool? readOnly,
  int? min,
  int? max,
  TextInputType? keyboardType,
  InputDecoration? decoration,
  TextStyle? style,
  TextEditingController? controller,
  FocusNode? focusNode,
  bool? autofocus,
  Map<NumericInputTranslationKey, String>? translations,
  VoidCallback? onHapticFeedback,
})
```

### Parameters

#### Core Parameters

- `value`: Current numeric value as string
- `onChanged`: Callback when value changes
- `onSubmitted`: Callback when form is submitted

#### Validation Parameters

- `min`: Minimum allowed value (inclusive)
- `max`: Maximum allowed value (inclusive)
- `errorText`: Custom error message to display

#### UI Parameters

- `label`: Label text for the input field
- `hint`: Placeholder text when field is empty
- `decoration`: Custom InputDecoration styling
- `style`: Custom TextStyle for the input text

#### Behavior Parameters

- `enabled`: Whether the input is interactive
- `readOnly`: Whether the input can be modified
- `autofocus`: Whether to automatically focus the field
- `keyboardType`: Custom keyboard type (defaults to numeric)

#### Accessibility Parameters

- `translations`: Localized strings for accessibility labels
- `onHapticFeedback`: Callback for haptic feedback on interactions

### Translation Keys

```dart
enum NumericInputTranslationKey {
  numericInputLabel,
  numericInputHint,
  numericInputError,
  clearValue,
  incrementValue,
  decrementValue,
}
```

## Usage Examples

### Basic Numeric Input

```dart
class AgeInput extends StatelessWidget {
  final String? age;
  final ValueChanged<String?> onAgeChanged;

  const AgeInput({
    required this.age,
    required this.onAgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NumericInput(
      value: age,
      onChanged: onAgeChanged,
      label: 'Age',
      hint: 'Enter your age',
      min: 0,
      max: 120,
    );
  }
}
```

### With Validation

```dart
class PriceInput extends StatefulWidget {
  @override
  _PriceInputState createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput> {
  String? price;
  String? errorText;

  void validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        errorText = 'Price is required';
      });
    } else {
      final priceValue = double.tryParse(value);
      if (priceValue == null) {
        setState(() {
          errorText = 'Please enter a valid number';
        });
      } else if (priceValue < 0) {
        setState(() {
          errorText = 'Price cannot be negative';
        });
      } else if (priceValue > 999999) {
        setState(() {
          errorText = 'Price is too high';
        });
      } else {
        setState(() {
          errorText = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NumericInput(
      value: price,
      onChanged: (value) {
        setState(() {
          price = value;
        });
        validatePrice(value);
      },
      label: 'Price',
      hint: '0.00',
      errorText: errorText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
```

### Custom Styling

```dart
class StyledNumericInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NumericInput(
      value: null,
      onChanged: (value) => print('Value: $value'),
      decoration: InputDecoration(
        labelText: 'Amount',
        hintText: 'Enter amount',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
```

### With Controller and Focus Node

```dart
class ControlledNumericInput extends StatefulWidget {
  @override
  _ControlledNumericInputState createState() => _ControlledNumericInputState();
}

class _ControlledNumericInputState extends State<ControlledNumericInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '0');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NumericInput(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: (value) {
        print('Controller value: ${_controller.text}');
      },
      label: 'Quantity',
      min: 1,
      max: 100,
    );
  }
}
```

### Form Integration

```dart
class ProductForm extends StatefulWidget {
  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  String? quantity;
  String? weight;
  String? price;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          NumericInput(
            value: quantity,
            onChanged: (value) => quantity = value,
            label: 'Quantity',
            hint: 'Enter quantity',
            min: 1,
            max: 1000,
          ),
          const SizedBox(height: 16),
          NumericInput(
            value: weight,
            onChanged: (value) => weight = value,
            label: 'Weight (kg)',
            hint: '0.0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            min: 0,
            max: 1000,
          ),
          const SizedBox(height: 16),
          NumericInput(
            value: price,
            onChanged: (value) => price = value,
            label: 'Price ($)',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            min: 0,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Process form
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

### Accessibility Configuration

```dart
class AccessibleNumericInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NumericInput(
      value: null,
      onChanged: (value) => print('Value: $value'),
      label: 'Age',
      hint: 'Enter your age',
      translations: {
        NumericInputTranslationKey.numericInputLabel: 'Age input field',
        NumericInputTranslationKey.numericInputHint: 'Enter age between 0 and 120',
        NumericInputTranslationKey.numericInputError: 'Please enter a valid age',
        NumericInputTranslationKey.clearValue: 'Clear age value',
        NumericInputTranslationKey.incrementValue: 'Increment age',
        NumericInputTranslationKey.decrementValue: 'Decrement age',
      },
      onHapticFeedback: () {
        // Trigger haptic feedback for better accessibility
        HapticFeedbackUtil.triggerLightImpact(context);
      },
    );
  }
}
```

## Styling and Theming

### Custom Theme Integration

```dart
class ThemedNumericInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NumericInput(
      value: null,
      onChanged: (value) => print('Value: $value'),
      decoration: InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color,
        fontSize: 16,
      ),
    );
  }
}
```

## Validation Patterns

### Range Validation

```dart
NumericInput(
  value: value,
  onChanged: onChanged,
  min: 1,        // Minimum value is 1
  max: 100,      // Maximum value is 100
  errorText: errorText, // Custom error message
)
```

### Decimal Support

```dart
NumericInput(
  value: value,
  onChanged: onChanged,
  keyboardType: const TextInputType.numberWithOptions(
    decimal: true,  // Allow decimal numbers
  ),
)
```

### Integer-Only Input

```dart
NumericInput(
  value: value,
  onChanged: onChanged,
  keyboardType: TextInputType.number,  // Integer keyboard
)
```

## Best Practices

### 1. Always Provide Labels and Hints

```dart
// Good: Clear labeling
NumericInput(
  label: 'Age',
  hint: 'Enter your age (1-120)',
  onChanged: onChanged,
)

// Bad: No context
NumericInput(
  onChanged: onChanged,
)
```

### 2. Implement Proper Validation

```dart
// Good: Comprehensive validation
void validateValue(String? value) {
  if (value == null || value.isEmpty) {
    setError('This field is required');
  } else {
    final numValue = int.tryParse(value);
    if (numValue == null || numValue < min || numValue > max) {
      setError('Please enter a valid value between $min and $max');
    } else {
      clearError();
    }
  }
}
```

### 3. Use Appropriate Keyboard Types

```dart
// Good: Match keyboard to input type
NumericInput(
  keyboardType: isDecimalInput
    ? const TextInputType.numberWithOptions(decimal: true)
    : TextInputType.number,
)
```

### 4. Provide Accessibility Support

```dart
// Good: Include accessibility labels
NumericInput(
  translations: {
    NumericInputTranslationKey.numericInputLabel: 'Age input field',
    NumericInputTranslationKey.numericInputHint: 'Enter age between 0 and 120',
  },
)
```

## Platform Considerations

### Mobile Platforms

- Displays numeric keyboard automatically
- Supports haptic feedback
- Optimized for touch input

### Desktop Platforms

- Supports keyboard navigation
- Number pad input support
- Mouse wheel increment/decrement

### Web Platform

- Responsive to browser locale settings
- Keyboard-friendly navigation
- Screen reader compatible

## Accessibility Features

- **Screen Reader Support**: Fully compatible with VoiceOver and TalkBack
- **Keyboard Navigation**: Tab, Shift+Tab, Arrow keys, Enter, Escape
- **Focus Management**: Clear focus indication and management
- **High Contrast**: Works with high contrast modes
- **Large Text**: Supports dynamic type scaling
- **Switch Control**: Compatible with switch navigation

## Performance Considerations

- **Efficient Input Filtering**: Optimized character filtering
- **Minimal Rebuilds**: Smart widget rebuilding
- **Memory Management**: Proper resource cleanup
- **Validation Optimization**: Efficient validation logic

## Testing Support

The component is designed to be easily testable:

```dart
testWidgets('NumericInput handles input correctly', (tester) async {
  String? value;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: NumericInput(
        value: null,
        onChanged: (newValue) => value = newValue,
        label: 'Test',
      ),
    ),
  ));

  await tester.tap(find.byType(NumericInput));
  await tester.enterText(find.byType(NumericInput), '123');
  await tester.pump();

  expect(value, equals('123'));
});
```
