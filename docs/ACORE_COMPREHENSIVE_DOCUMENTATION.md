# ACore Flutter Package Documentation

## Overview

**acore-flutter** is a comprehensive core package that provides common utilities, abstractions, and components for Flutter applications. It serves as the foundational library for the WHPH productivity app, implementing Clean Architecture principles with a focus on reusability and maintainability.

**Version**: 1.0.0
**Flutter Compatibility**: >=3.0.0
**Dart SDK**: ^3.5.3

## Architecture

### Design Principles

- **Clean Architecture**: Clear separation of concerns with abstraction layers
- **Dependency Injection**: IoC container for loose coupling
- **Repository Pattern**: Data access abstraction
- **CQRS Support**: Command Query Responsibility Segregation ready
- **Interface Segregation**: Small, focused abstractions
- **Single Responsibility**: Each component has one clear purpose

### Package Structure

```
lib/
├── async/                    # Async utilities and helpers
├── components/              # Reusable UI components
│   ├── date_time_picker/   # Advanced date/time picker widgets
│   └── numeric_input/      # Numeric input widget with validation
├── dependency_injection/   # IoC container implementation
├── errors/                 # Custom exception types
├── extensions/             # Dart/Flutter extensions
├── file/                   # File service abstractions
├── logging/                # Logging infrastructure
├── mapper/                 # Object mapping utilities
├── queries/                # Query pattern support
├── repository/             # Repository pattern implementation
├── sounds/                 # Sound player abstractions
├── storage/                # Storage abstractions
├── time/                   # Date/time utilities
└── utils/                  # General utility classes
```

## Core Modules Overview

### 1. Dependency Injection (`dependency_injection/`)

Provides inversion of control capabilities for loose coupling between components.

**Key Interface**: `IContainer` with `resolve<T>()` and `registerSingleton<T>()` methods.

**📖 Detailed Documentation**: See [Dependency Injection README](./dependency_injection/README.md)

### 2. Repository Pattern (`repository/`)

Standardized data access interface with built-in pagination, filtering, and soft delete support.

**Key Interfaces**: `IRepository<T, TId>` and `BaseEntity<TId>`

**📖 Detailed Documentation**: See [Repository README](./repository/README.md)

### 3. Logging Infrastructure (`logging/`)

Structured logging with multiple severity levels and output destinations.

**Key Interface**: `ILogger` with debug, info, warning, error, and fatal methods

**📖 Detailed Documentation**: See [Logging README](./logging/README.md)

### 4. Error Handling (`errors/`)

Structured business exception handling with error codes and localization support.

**Key Class**: `BusinessException` with message, errorCode, and args properties

**📖 Detailed Documentation**: See [Error Handling README](./errors/README.md)

### 5. Async Utilities (`async/`)

Common async operation patterns with error handling and cleanup support.

**Key Class**: `AsyncUtils` with `executeAsync<T>()` and `executeAsyncVoid()` methods

**📖 Detailed Documentation**: See [Async Utils Documentation](./utils/ASYNC_UTILS.md)

### 6. Time Utilities (`time/`)

Localization-aware date/time utilities with proper locale handling.

**Key Class**: `DateTimeHelper` with weekday, date range, and boundary methods

**📖 Detailed Documentation**: See [Time Utilities README](./time/README.md)

## UI Components

### NumericInput (`components/numeric_input/`)

Reusable numeric input widget with increment/decrement buttons, validation, and internationalization support.

**📖 Detailed Documentation**: See [NumericInput README](./components/numeric_input/README.md)

### Date Time Picker (`components/date_time_picker/`)

Comprehensive date/time selection components with calendar views, time dialogs, and range support.

**📖 Detailed Documentation**: See [Date Time Picker README](./components/date_time_picker/README.md)

## Other Core Modules

### Storage Abstractions (`storage/`)
Generic storage interface for key-value data persistence
- Interface: `StorageAbstract` with type-safe get/set/remove operations

### File Services (`file/`)
Cross-platform file operations with proper permission handling
- Interface: `IFileService` with pick, read, write, and save operations

### Object Mapping (`mapper/`)
Object-to-object mapping capabilities with customizable mapping functions
- Interface: `IMapper` with addMap and map methods

### Utility Classes (`utils/`)
Collection comparison, caching, responsive design, and platform utilities
- Classes: `CollectionUtils`, `LRUCache`, `ResponsiveUtil`, `PlatformUtils`, etc.

**📖 Detailed Documentation**: See [Utils Documentation](./DOCUMENTATION_INDEX.md#utility-documentation)

## Quick Start Guide

### 1. Basic Setup

```dart
import 'package:acore/acore.dart';

// Initialize dependency injection
final container = Container();
container.registerSingleton<ILogger>((c) => ConsoleLogger());

// Resolve services
final logger = container.resolve<ILogger>();
logger.info("Application started");
```

### 2. Common Patterns

**Repository Usage**: See [Repository README](./repository/README.md#usage-examples)

**Error Handling**: See [Error Handling README](./errors/README.md#usage-examples)

**Async Operations**: See [Async Utils Documentation](./utils/ASYNC_UTILS.md#usage-examples)

**Time Utilities**: See [Time Utilities README](./time/README.md#usage-examples)

### 3. UI Components

**NumericInput**: See [NumericInput README](./components/numeric_input/README.md#usage-examples)

**Date Time Picker**: See [Date Time Picker README](./components/date_time_picker/README.md)

## Dependencies

### Core Dependencies
- `equatable: ^2.0.7` - Value equality
- `meta: ^1.15.0` - Annotations

### Dependency Injection
- `kiwi: ^5.0.1` - IoC container

### Date/Time
- `intl: ^0.20.2` - Internationalization
- `dart_json_mapper: ^2.2.16` - JSON serialization
- `calendar_date_picker2: ^2.0.0` - Calendar widget

## Integration Guidelines

### Adding New Components
1. Follow existing folder structure mirroring `lib/` layout
2. Create README.md in appropriate `docs/` subfolder
3. Include usage examples and best practices
4. Update main documentation links

### Documentation Structure
```
docs/
├── README.md                    # Main overview
├── API_REFERENCE.md             # Complete API reference
├── QUICK_REFERENCE.md           # Quick start guide
├── DOCUMENTATION_INDEX.md       # Navigation hub
├── dependency_injection/        # DI module docs
├── repository/                  # Repository pattern docs
├── logging/                     # Logging infrastructure docs
├── errors/                      # Error handling docs
├── time/                        # Time utilities docs
├── utils/                       # General utility docs
└── components/                  # UI component docs
    ├── numeric_input/
    └── date_time_picker/
```

## Quick Reference Links

**Core Modules**
- [Dependency Injection](./dependency_injection/README.md)
- [Repository Pattern](./repository/README.md)
- [Logging Infrastructure](./logging/README.md)
- [Error Handling](./errors/README.md)
- [Time Utilities](./time/README.md)

**UI Components**
- [NumericInput](./components/numeric_input/README.md)
- [Date Time Picker](./components/date_time_picker/README.md)

**Utilities**
- [Async Utils](./utils/ASYNC_UTILS.md)
- [Collection Utils](./utils/COLLECTION_UTILS.md)
- [LRU Cache](./utils/LRU_CACHE.md)
- [Responsive Util](./utils/RESPONSIVE_UTIL.md)

## Best Practices Summary

### ✅ DO
- Use interfaces for dependencies
- Handle async errors with `AsyncUtils`
- Log at appropriate levels
- Validate inputs before processing
- Use locale-aware methods for time/date

### ❌ DON'T
- Throw generic exceptions
- Ignore async errors
- Skip logging important events
- Use hardcoded values for time/date
- Mix UI and business logic

## Getting Help

### Documentation Navigation
1. **Beginners**: Start with [Quick Reference](./QUICK_REFERENCE.md)
2. **Module-Specific**: See individual module READMEs
3. **Examples**: Review component-specific documentation

### Common Issues
- **Setup Problems**: Check [Dependency Injection](./dependency_injection/README.md)
- **Data Access**: Review [Repository Pattern](./repository/README.md)
- **Error Handling**: See [Error Handling README](./errors/README.md)
- **UI Issues**: Check component documentation

---

**For detailed documentation on specific modules, see the individual README files in their respective directories.**