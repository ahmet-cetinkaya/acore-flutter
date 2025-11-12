# Extensions

## Overview

The extensions module provides convenient extension methods that enhance the functionality of built-in Dart and Flutter types. These extensions offer additional utility methods for common operations, making code more readable and concise while maintaining type safety and performance.

## Features

- 🎨 **Color Extensions** - Enhanced color manipulation and conversion utilities
- 🔧 **Type-Safe Operations** - All extensions maintain compile-time type safety
- 📱 **Flutter Optimized** - Designed specifically for Flutter development patterns
- ⚡ **Performance Efficient** - Minimal overhead with optimized implementations
- 🛠️ **Developer Friendly** - Intuitive method names and clear behavior
- 🔗 **Chainable Methods** - Methods that can be chained for fluent API usage

## Color Extensions

The color extensions provide utility methods for working with Flutter's `Color` class, making it easier to convert between different color formats and perform common operations.

### Available Methods

```dart
extension ColorExtensions on Color {
  /// Converts a Color to a hex string without the alpha channel.
  String toHexString();
}
```

## Usage Examples

### Basic Color Conversion

```dart
import 'package:acore/extensions/extensions.dart';

class ColorUtils {
  /// Convert Flutter Color to hex string for API calls
  String colorToHex(Color color) {
    return color.toHexString();
  }

  /// Create color picker display
  Widget buildColorDisplay(Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          color.toHexString(),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
```

### Theme Color Management

```dart
class ThemeColorManager {
  final Map<String, Color> _customColors = {};

  /// Add custom color with hex representation
  void addCustomColor(String name, Color color) {
    _customColors[name] = color;

    // Store hex representation for persistence
    _saveColorHex(name, color.toHexString());
  }

  /// Get color by name
  Color? getColor(String name) {
    return _customColors[name];
  }

  /// Get color hex string by name
  String? getColorHex(String name) {
    final color = _customColors[name];
    return color?.toHexString();
  }

  /// Export theme colors as hex strings
  Map<String, String> exportThemeColors() {
    return _customColors.map((name, color) => MapEntry(
      name,
      color.toHexString(),
    ));
  }

  void _saveColorHex(String name, String hex) {
    // Implementation for persisting hex colors
  }
}
```

### Color Palette Generator

```dart
class ColorPaletteGenerator {
  /// Generate color palette with hex codes
  List<ColorWithHex> generatePalette(Color baseColor, int count) {
    final palette = <ColorWithHex>[];

    for (int i = 0; i < count; i++) {
      final hue = (baseColor.hue + (i * 360 / count)) % 360;
      final adjustedColor = HSVColor.fromAHSV(1.0, hue, 0.7, 0.9).toColor();

      palette.add(ColorWithHex(
        color: adjustedColor,
        hex: adjustedColor.toHexString(),
      ));
    }

    return palette;
  }
}

class ColorWithHex {
  final Color color;
  final String hex;

  ColorWithHex({required this.color, required this.hex});
}
```

### UI Component with Color Display

```dart
class ColorPickerWidget extends StatefulWidget {
  const ColorPickerWidget({super.key});

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Color preview
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),

        const SizedBox(height: 16),

        // Hex color display
        Text(
          'HEX: ${_selectedColor.toHexString()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Color selection buttons
        Wrap(
          spacing: 8,
          children: [
            _buildColorButton(Colors.red),
            _buildColorButton(Colors.green),
            _buildColorButton(Colors.blue),
            _buildColorButton(Colors.orange),
            _buildColorButton(Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _selectedColor == color
              ? Border.all(color: Colors.black, width: 3)
              : Border.all(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
```

### Color Validation and Conversion

```dart
class ColorValidator {
  /// Validate hex color string
  static bool isValidHex(String hex) {
    final hexPattern = RegExp(r'^#?[0-9A-Fa-f]{6}$');
    return hexPattern.hasMatch(hex);
  }

  /// Convert hex string to Color
  static Color? hexToColor(String hex) {
    if (!isValidHex(hex)) return null;

    String cleanHex = hex.startsWith('#') ? hex.substring(1) : hex;
    try {
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Get hex string from Color and validate it
  static String colorToValidHex(Color color) {
    final hex = color.toHexString();
    return isValidHex(hex) ? '#$hex' : '#000000';
  }
}

class ColorConverter {
  /// Convert color to various formats
  static Map<String, String> colorToFormats(Color color) {
    final hex = color.toHexString();

    return {
      'hex': '#$hex',
      'rgb': '${color.red}, ${color.green}, ${color.blue}',
      'rgba': '${color.red}, ${color.green}, ${color.blue}, ${(color.opacity).toStringAsFixed(2)}',
      'hsv': '${color.hue.toStringAsFixed(1)}, ${(color.saturation * 100).toStringAsFixed(1)}, ${(color.value * 100).toStringAsFixed(1)}',
    };
  }
}
```

### API Integration with Colors

```dart
class ApiService {
  /// Send color data to backend
  Future<void> sendThemeColors(List<Color> colors) async {
    final colorData = colors.map((color) => {
      'hex': '#${color.toHexString()}',
      'name': _getColorName(color),
    }).toList();

    try {
      await http.post(
        Uri.parse('https://api.example.com/colors'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'colors': colorData,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      throw Exception('Failed to send colors: $e');
    }
  }

  /// Parse colors from API response
  List<Color> parseColorsFromResponse(Map<String, dynamic> response) {
    final colorList = response['colors'] as List<dynamic>;

    return colorList.map((colorData) {
      final hex = colorData['hex'] as String;
      return ColorValidator.hexToColor(hex) ?? Colors.grey;
    }).toList();
  }

  String _getColorName(Color color) {
    // Simple color naming logic
    if (color.red > 200 && color.green < 100 && color.blue < 100) return 'Red';
    if (color.red < 100 && color.green > 200 && color.blue < 100) return 'Green';
    if (color.red < 100 && color.green < 100 && color.blue > 200) return 'Blue';
    return 'Custom';
  }
}
```

### Color Testing Utilities

```dart
class ColorTestingUtils {
  /// Generate test colors
  static List<Color> generateTestColors() {
    return [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
    ];
  }

  /// Validate color conversion roundtrip
  static bool validateColorRoundtrip(Color color) {
    final hex = color.toHexString();
    final convertedBack = ColorValidator.hexToColor('#$hex');

    if (convertedBack == null) return false;

    // Allow small variations due to color space conversions
    final tolerance = 1;
    return (convertedBack.red - color.red).abs() <= tolerance &&
           (convertedBack.green - color.green).abs() <= tolerance &&
           (convertedBack.blue - color.blue).abs() <= tolerance;
  }

  /// Generate color test report
  static Map<String, dynamic> generateColorReport(List<Color> colors) {
    final report = <String, dynamic>{
      'total_colors': colors.length,
      'valid_conversions': 0,
      'invalid_conversions': [],
      'color_details': [],
    };

    for (final color in colors) {
      final isValid = validateColorRoundtrip(color);

      if (isValid) {
        report['valid_conversions'] = report['valid_conversions'] + 1;
      } else {
        (report['invalid_conversions'] as List).add(color.toHexString());
      }

      (report['color_details'] as List).add({
        'hex': '#${color.toHexString()}',
        'rgb': '${color.red}, ${color.green}, ${color.blue}',
        'roundtrip_valid': isValid,
      });
    }

    return report;
  }
}
```

### Advanced Color Manipulation

```dart
extension AdvancedColorExtensions on Color {
  /// Darken color by percentage
  Color darken(double percentage) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness * (1 - percentage)).clamp(0.0, 1.0)).toColor();
  }

  /// Lighten color by percentage
  Color lighten(double percentage) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness * (1 + percentage)).clamp(0.0, 1.0)).toColor();
  }

  /// Change hue by degrees
  Color shiftHue(double degrees) {
    final hsl = HSLColor.fromColor(this);
    final newHue = (hsl.hue + degrees) % 360;
    return hsl.withHue(newHue < 0 ? newHue + 360 : newHue).toColor();
  }

  /// Get complementary color
  Color get complementary {
    return shiftHue(180);
  }

  /// Get triadic colors
  List<Color> get triadic {
    return [
      this,
      shiftHue(120),
      shiftHue(240),
    ];
  }

  /// Get analogous colors
  List<Color> get analogous {
    return [
      shiftHue(-30),
      this,
      shiftHue(30),
    ];
  }
}

class ColorSchemeGenerator {
  /// Generate color scheme from base color
  ColorScheme generateColorScheme(Color baseColor, bool isDark) {
    final primary = baseColor;
    final secondary = baseColor.shiftHue(60).lighten(0.1);
    final tertiary = baseColor.shiftHue(120);
    final surface = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: surface,
      onSurface: isDark ? Colors.white : Colors.black,
    );
  }
}
```

## Testing Extensions

### Unit Tests for Color Extensions

```dart
void main() {
  group('ColorExtensions Tests', () {
    test('should convert color to hex string correctly', () {
      // Test known colors
      expect(Colors.red.toHexString(), equals('FF0000'));
      expect(Colors.green.toHexString(), equals('FF00FF')); // Note: Flutter green is #FF00FF
      expect(Colors.blue.toHexString(), equals('0000FF'));
      expect(Colors.black.toHexString(), equals('000000'));
      expect(Colors.white.toHexString(), equals('FFFFFF'));
    });

    test('should handle colors with alpha channel', () {
      final transparentRed = Color.fromRGBO(255, 0, 0, 0.5);
      expect(transparentRed.toHexString(), equals('FF0000')); // Alpha stripped
    });

    test('should return uppercase hex string', () {
      final color = Color(0xFF808080); // Gray
      expect(color.toHexString(), equals('808080')); // Uppercase
    });
  });

  group('AdvancedColorExtensions Tests', () {
    test('should darken color correctly', () {
      final lightGray = Color(0xFFCCCCCC);
      final darkened = lightGray.darken(0.5);

      expect(darkened.red, lessThan(lightGray.red));
      expect(darkened.green, lessThan(lightGray.green));
      expect(darkened.blue, lessThan(lightGray.blue));
    });

    test('should lighten color correctly', () {
      final darkGray = Color(0xFF333333);
      final lightened = darkGray.lighten(0.5);

      expect(lightened.red, greaterThan(darkGray.red));
      expect(lightened.green, greaterThan(darkGray.green));
      expect(lightened.blue, greaterThan(darkGray.blue));
    });

    test('should generate complementary color', () {
      final blue = Color(0xFF0000FF);
      final complementary = blue.complementary;

      // Complementary should be roughly yellow/orange
      expect(complementary.red, greaterThan(200));
      expect(complementary.green, greaterThan(150));
    });
  });
}
```

### Integration Tests

```dart
void main() {
  group('Color Extensions Integration Tests', () {
    test('should work with theme generation', () {
      final baseColor = Color(0xFF2196F3); // Blue
      final schemeGenerator = ColorSchemeGenerator();
      final lightScheme = schemeGenerator.generateColorScheme(baseColor, false);
      final darkScheme = schemeGenerator.generateColorScheme(baseColor, true);

      expect(lightScheme.primary, equals(baseColor));
      expect(darkScheme.primary, equals(baseColor));
      expect(lightScheme.surface.value, greaterThan(darkScheme.surface.value));
    });

    test('should maintain color consistency through conversions', () {
      final originalColors = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Color(0xFF9C27B0), // Purple
        Color(0xFFFF9800), // Orange
      ];

      for (final color in originalColors) {
        final hex = color.toHexString();
        final reconstructed = ColorValidator.hexToColor('#$hex');

        expect(reconstructed, isNotNull);
        expect(ColorTestingUtils.validateColorRoundtrip(color), isTrue);
      }
    });
  });
}
```

## Best Practices

### 1. Use Extensions for Readability

```dart
// ✅ Good: Clean and readable
final user = User.fromJson(response.body);
final formattedAge = user.age.formatWithSuffix();

// ❌ Bad: Verbose utility method calls
final user = User.fromJson(response.body);
final formattedAge = AgeFormatter.formatWithSuffix(user.age);
```

### 2. Chain Extension Methods

```dart
// ✅ Good: Fluent chaining
final processedColor = baseColor
    .darken(0.2)
    .shiftHue(15)
    .withOpacity(0.8);

// ❌ Bad: Multiple steps
final darker = darkenColor(baseColor, 0.2);
final shifted = shiftHue(darker, 15);
final result = colorWithOpacity(shifted, 0.8);
```

### 3. Validate Input in Extensions

```dart
extension SafeColorExtensions on Color {
  Color darkenSafe(double percentage) {
    if (percentage < 0 || percentage > 1) {
      throw ArgumentError('Percentage must be between 0 and 1');
    }

    return darken(percentage);
  }
}
```

### 4. Document Extension Behavior

```dart
/// Darkens a color by the specified percentage.
///
/// [percentage] must be between 0.0 and 1.0, where 1.0 makes the color black.
/// Returns a new [Color] instance with adjusted lightness.
Color darken(double percentage) {
  // Implementation
}
```

## Performance Considerations

### Extension Performance Tips

1. **Avoid Heavy Calculations**: Keep extension methods lightweight
2. **Cache Results**: Cache expensive calculations in extension properties
3. **Use Built-in Methods**: Prefer Flutter's built-in color operations
4. **Minimize Allocations**: Reuse objects where possible

```dart
extension PerformanceColorExtensions on Color {
  // Cached HSL conversion
  HSLColor? _cachedHsl;
  HSLColor get hslCached {
    return _cachedHsl ??= HSLColor.fromColor(this);
  }

  // Efficient color comparison
  bool isCloseTo(Color other, {double tolerance = 5.0}) {
    return (red - other.red).abs() <= tolerance &&
           (green - other.green).abs() <= tolerance &&
           (blue - other.blue).abs() <= tolerance;
  }
}
```

## Future Extensions

The extensions module is designed to be easily extended with additional utility methods. Potential future extensions include:

- **String Extensions**: Enhanced string manipulation and validation
- **DateTime Extensions**: Date formatting and calculation utilities
- **List Extensions**: Enhanced list operations and transformations
- **Map Extensions**: Convenient map manipulation methods
- **Widget Extensions**: Flutter widget enhancement utilities

---

**Related Documentation**
- [Time Utilities](../time/README.md)
- [Error Handling](../errors/README.md)
- [Utils](../utils/README.md)