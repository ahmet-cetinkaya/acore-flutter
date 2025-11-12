# ACore Flutter Package Documentation

Welcome to the comprehensive documentation for the ACore Flutter package - a core utility and component library for Flutter applications.

## 📚 Documentation Structure

### Components
Reusable UI components built with accessibility, performance, and internationalization in mind.

#### [Date Time Picker Components](./components/date_time_picker/)
Comprehensive, accessible, and performant date/time picker component library.
- **CalendarDatePicker** - Clean calendar interface with single/range selection
- **TimeSelector** - Efficient time selection with wheel picker
- **QuickRangeSelector** - Quick range selection with predefined ranges
- **DateValidationDisplay** - Validation handling with real-time feedback

#### [Numeric Input Components](./components/numeric_input/)
Input components for numeric data entry with validation and formatting.

### Utilities
Core utility classes and helper functions used across the package.

#### [Cache Utilities](./utils/lru_cache.md)
LRU (Least Recently Used) Cache implementation for efficient data caching.

#### [Responsive Utilities](./utils/responsive_util.md)
Advanced responsive design utilities including landscape orientation handling.

#### [Time Formatting Utilities](./utils/time_formatting_util.md)
Locale-aware time formatting using MaterialLocalizations.

#### [Haptic Feedback Utilities](./utils/haptic_feedback_util.md)
Platform-specific haptic feedback functionality.

## 🚀 Getting Started

All components follow SOLID principles and include:
- ✅ **WCAG 2.1 AA Accessibility** compliance
- ✅ **Full keyboard navigation** support
- ✅ **Responsive design** with mobile/tablet/desktop optimizations
- ✅ **Performance optimized** with efficient algorithms
- ✅ **Internationalization** ready

## 📖 Usage Examples

See individual component documentation for detailed usage examples and API references.

## 🏗️ Architecture

The package follows Clean Architecture principles with:
- **Domain Layer** - Core business entities and rules
- **Application Layer** - Use cases and business logic
- **Infrastructure Layer** - Platform-specific implementations
- **Presentation Layer** - UI components and shared utilities

## 🤝 Contributing

When adding new components or utilities:
1. Follow existing code patterns and naming conventions
2. Include comprehensive documentation
3. Add appropriate tests
4. Ensure accessibility compliance
5. Update this index documentation