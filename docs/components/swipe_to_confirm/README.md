# Swipe to Confirm Component

## Overview

Interactive swipe gesture component that prevents accidental confirmations with
smooth animations and customizable styling.

## Features

- 👆 Interactive swipe-to-confirm gesture
- 🎨 Customizable colors and styling
- ⚡ Smooth animations with visual feedback
- ♿ Accessibility support with alternatives
- 📱 Responsive design for all platforms

## API Reference

### Constructor

```dart
SwipeToConfirm({
  required String text,
  required VoidCallback onConfirmed,
  Color? backgroundColor,
  Color? sliderColor,
  Color? iconColor,
  Color? textColor,
  double height = 56.0,
})
```

### Parameters

- `text`: Instruction text displayed in center
- `onConfirmed`: Callback when swipe completes
- `backgroundColor`: Container background color
- `sliderColor`: Slider button and progress fill color
- `iconColor`: Arrow icon color
- `textColor`: Text color
- `height`: Component height (default: 56.0)

## Usage Examples

### Basic Usage

```dart
SwipeToConfirm(
  text: 'Swipe to delete item',
  onConfirmed: () => _deleteItem(),
)
```

### Custom Styling

```dart
SwipeToConfirm(
  text: 'Swipe to purchase',
  onConfirmed: _completePurchase,
  height: 64.0,
  sliderColor: Colors.green,
  iconColor: Colors.white,
  backgroundColor: Colors.green.withOpacity(0.1),
)
```

### Theme Integration

```dart
final theme = Theme.of(context);
SwipeToConfirm(
  text: 'Swipe to accept terms',
  onConfirmed: _acceptTerms,
  sliderColor: theme.colorScheme.primary,
  textColor: theme.colorScheme.onSurfaceVariant,
)
```

### Form Integration

```dart
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Form fields...
        _isSubmitting
            ? CircularProgressIndicator()
            : SwipeToConfirm(
                text: 'Swipe to sign in',
                onConfirmed: _handleLogin,
              ),
      ],
    );
  }

  void _handleLogin() async {
    setState(() => _isSubmitting = true);
    await _performLogin();
    setState(() => _isSubmitting = false);
  }
}
```

### Dialog Confirmation

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Delete Item'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('This action cannot be undone.'),
        const SizedBox(height: 16),
        SwipeToConfirm(
          text: 'Swipe to delete',
          onConfirmed: () {
            Navigator.pop(context);
            _deleteItem();
          },
          sliderColor: Colors.red,
        ),
      ],
    ),
  ),
)
```

## Best Practices

### Clear Instructions

```dart
// Good
SwipeToConfirm(text: 'Swipe to delete permanently', ...)

// Bad
SwipeToConfirm(text: 'Confirm', ...)
```

### Context-Aware Colors

```dart
// Destructive action
SwipeToConfirm(sliderColor: Colors.red, ...)

// Positive action
SwipeToConfirm(sliderColor: Colors.green, ...)
```

### Prevent Multiple Confirmations

```dart
class SafeConfirmation extends StatefulWidget {
  @override
  _SafeConfirmationState createState() => _SafeConfirmationState();
}

class _SafeConfirmationState extends State<SafeConfirmation> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return _isProcessing
        ? CircularProgressIndicator()
        : SwipeToConfirm(
            text: 'Swipe to confirm',
            onConfirmed: _handleConfirmation,
          );
  }

  void _handleConfirmation() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    await _performAction();
    setState(() => _isProcessing = false);
  }
}
```

### Accessibility Alternative

```dart
Column(
  children: [
    SwipeToConfirm(
      text: 'Swipe to confirm',
      onConfirmed: _confirm,
    ),
    TextButton(
      onPressed: _confirm,
      child: Text('Or tap to confirm'),
    ),
  ],
)
```

## Testing

```dart
testWidgets('SwipeToConfirm triggers callback', (tester) async {
  bool confirmed = false;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SwipeToConfirm(
        text: 'Swipe to test',
        onConfirmed: () => confirmed = true,
      ),
    ),
  ));

  await tester.drag(find.byType(SwipeToConfirm), Offset(300, 0));
  await tester.pumpAndSettle();

  expect(confirmed, isTrue);
});
```

## Platform Notes

- **Mobile**: Touch-optimized with gesture support
- **Desktop**: Mouse drag compatible
- **Web**: Works with touch and mouse input

## Accessibility

Provide keyboard/tap alternatives to swipe gestures for screen reader users and
keyboard navigation.
