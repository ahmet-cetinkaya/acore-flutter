# Responsive Design Utility

## Overview

The `ResponsiveUtil` provides advanced responsive design utilities that help create adaptive user interfaces for different screen sizes, orientations, and device types. It includes sophisticated landscape orientation handling and device-specific optimizations.

## Features

- 📱 **Multi-Breakpoint Support** - Mobile, tablet, and desktop breakpoints
- 🔄 **Orientation Detection** - Landscape vs portrait optimization
- 🎯 **Device Type Detection** - Automatic identification of device categories
- 📐 **Responsive Sizing** - Dynamic font sizes, spacing, and dimensions
- 🖥️ **Desktop Optimizations** - Enhanced desktop experience patterns

## API Reference

### Static Methods

#### Screen Detection

```dart
static bool isCompactLayout(BuildContext context)
static bool isMediumLayout(BuildContext context)
static bool isExpandedLayout(BuildContext context)
```

Detects screen layout categories based on material design breakpoints.

#### Orientation Detection

```dart
static bool isLandscape(BuildContext context)
static bool isPortrait(BuildContext context)
static bool isTabletLandscape(BuildContext context)
```

Specialized landscape detection with tablet-specific handling.

#### Responsive Sizing

```dart
static double getFontSize(BuildContext context, {
  double? mobile,
  double? tablet,
  double? desktop
})

static double getIconSize(BuildContext context, {
  double? mobile,
  double? tablet,
  double? desktop
})

static double getLandscapeSpacing(BuildContext context, {
  double? mobile,
  double? tablet,
  double? desktop
})
```

Device and orientation-aware sizing utilities.

#### Layout Optimization

```dart
static bool shouldUseDesktopLayout(BuildContext context)
static bool shouldUseWideLayout(BuildContext context)
static double getResponsiveWidth(BuildContext context, double maxWidth)
```

Layout decision helpers for responsive design patterns.

## Breakpoint System

### Screen Width Breakpoints

- **Compact**: < 600px (Mobile phones)
- **Medium**: 600px - 1200px (Tablets, large phones)
- **Expanded**: > 1200px (Desktop, large tablets)

### Orientation Breakpoints

- **Landscape**: Width > Height
- **Tablet Landscape**: Width > 900px in landscape mode
- **Portrait**: Height > Width

## Usage Examples

### Basic Responsive Layout

```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveUtil.isCompactLayout(context);
    final isExpanded = ResponsiveUtil.isExpandedLayout(context);

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtil.getLandscapeSpacing(context,
          mobile: 16.0,
          tablet: 24.0,
          desktop: 32.0
        )
      ),
      child: Column(
        children: [
          Text(
            'Responsive Title',
            style: TextStyle(
              fontSize: ResponsiveUtil.getFontSize(context,
                mobile: 24.0,
                tablet: 28.0,
                desktop: 32.0
              )
            ),
          ),
          if (isExpanded) DesktopNavigation(),
          if (!isExpanded) MobileNavigation(),
        ],
      ),
    );
  }
}
```

### Landscape-Specific Optimizations

```dart
class AdaptiveContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLandscape = ResponsiveUtil.isLandscape(context);
    final isTabletLandscape = ResponsiveUtil.isTabletLandscape(context);

    return Row(
      children: [
        // Main content takes full width on mobile, reduced width on tablet landscape
        Expanded(
          flex: isTabletLandscape ? 2 : 3,
          child: MainContent(),
        ),

        // Show sidebar on tablet landscape or desktop
        if (isTabletLandscape || ResponsiveUtil.isExpandedLayout(context))
          Expanded(
            flex: 1,
            child: Sidebar(),
          ),
      ],
    );
  }
}
```

### Responsive Component Design

```dart
class ResponsiveCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ResponsiveCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveUtil.isCompactLayout(context);

    return Card(
      margin: EdgeInsets.all(
        ResponsiveUtil.getLandscapeSpacing(context,
          mobile: 8.0,
          tablet: 12.0,
          desktop: 16.0
        )
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isCompact ? 16.0 : 24.0
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  size: ResponsiveUtil.getIconSize(context,
                    mobile: 20.0,
                    tablet: 24.0,
                    desktop: 28.0
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtil.getFontSize(context,
                      mobile: 18.0,
                      tablet: 20.0,
                      desktop: 22.0
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
```

### Advanced Layout Patterns

```dart
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveUtil.isCompactLayout(context);
    final isMedium = ResponsiveUtil.isMediumLayout(context);

    int crossAxisCount;
    if (isCompact) {
      crossAxisCount = 1;
    } else if (isMedium) {
      crossAxisCount = ResponsiveUtil.isLandscape(context) ? 3 : 2;
    } else {
      crossAxisCount = ResponsiveUtil.isLandscape(context) ? 4 : 3;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isCompact ? 1.2 : 1.0,
        crossAxisSpacing: ResponsiveUtil.getLandscapeSpacing(context,
          mobile: 8.0,
          tablet: 12.0,
          desktop: 16.0
        ),
        mainAxisSpacing: ResponsiveUtil.getLandscapeSpacing(context,
          mobile: 8.0,
          tablet: 12.0,
          desktop: 16.0
        ),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
```

## Best Practices

### 1. Progressive Enhancement

```dart
// Good: Build mobile-first, enhance for larger screens
Widget build(BuildContext context) {
  return Container(
    margin: EdgeInsets.all(16), // Base mobile padding
    child: Column(children: [
      if (ResponsiveUtil.isExpandedLayout(context))
        DesktopEnhancements(),
      MobileContent(), // Always show
    ]),
  );
}
```

### 2. Orientation-Aware Design

```dart
// Good: Consider orientation in layout decisions
Widget build(BuildContext context) {
  final isLandscape = ResponsiveUtil.isLandscape(context);
  final isCompact = ResponsiveUtil.isCompactLayout(context);

  if (isLandscape && isCompact) {
    return HorizontalScrollContent();
  } else {
    return VerticalLayoutContent();
  }
}
```

### 3. Consistent Spacing

```dart
// Good: Use utility methods for consistent responsive spacing
EdgeInsets getResponsivePadding(BuildContext context) {
  return EdgeInsets.all(
    ResponsiveUtil.getLandscapeSpacing(context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0
    )
  );
}
```

## Performance Considerations

- **Minimal Rebuilds**: Responsive checks are optimized to minimize widget rebuilds
- **Efficient Breakpoints**: Uses Material Design's efficient breakpoint detection
- **Orientation Caching**: Orientation state is cached to reduce calculations

## Browser and Platform Support

- **Flutter Web**: Full support with responsive breakpoints
- **Desktop Platforms**: Windows, macOS, Linux with desktop-specific optimizations
- **Mobile Platforms**: Android, iOS with orientation-aware layouts
- **Responsive Testing**: Works across all Flutter-supported platforms

## Integration with Material Design

The utility follows Material Design 3 guidelines:

- Uses Material Design breakpoint system
- Compatible with Material's adaptive layouts
- Respects Material's typography and spacing scales
- Integrates with Material's navigation patterns
