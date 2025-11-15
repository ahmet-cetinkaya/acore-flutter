# Dependency Injection

## Overview

The dependency injection module provides a lightweight IoC (Inversion of Control) container that manages object creation and lifetime, promoting loose coupling and testability in Flutter applications.

## Features

- 🏗️ **Simple API** - Minimal learning curve with intuitive interface
- 🔄 **Singleton Management** - Automatic singleton lifecycle management
- 🧪 **Test Friendly** - Easy to mock and replace dependencies
- 📦 **Type Safe** - Compile-time type checking for all dependencies
- 🔗 **Circular Reference Detection** - Prevents infinite dependency loops

## Core Interface

### IContainer

```dart
abstract class IContainer {
  /// Global singleton instance
  IContainer get instance;

  /// Resolve dependency of type T
  T resolve<T>();

  /// Register singleton dependency with factory
  void registerSingleton<T>(T Function(IContainer) factory);
}
```

## Usage Examples

### Basic Setup

```dart
import 'package:acore/dependency_injection.dart';

// Initialize container
final container = Container();

// Register dependencies
container.registerSingleton<ILogger>((c) => ConsoleLogger());
container.registerSingleton<IFileService>((c) => FileService());
container.registerSingleton<StorageAbstract>((c) => StorageService());
```

### Resolving Dependencies

```dart
// Simple resolution
final logger = container.resolve<ILogger>();
logger.info("Application started");

// Resolution with dependencies
final repository = container.resolve<TaskRepository>();
// Repository automatically receives its dependencies
```

### Dependency Chain

```dart
// Register service that depends on other services
container.registerSingleton<IUserService>((container) {
  final logger = container.resolve<ILogger>();
  final storage = container.resolve<StorageAbstract>();
  return UserService(logger: logger, storage: storage);
});
```

### Replacing Dependencies (Testing)

```dart
// Replace logger for testing
final testContainer = Container();
testContainer.registerSingleton<ILogger>((c) => MockLogger());
testContainer.registerSingleton<IUserService>((c) => UserService(
  logger: c.resolve<ILogger>(),
  storage: MockStorage()
));
```

## Implementation

### Container Class

```dart
class Container implements IContainer {
  final Map<Type, dynamic> _singletons = {};
  final Map<Type, Function(IContainer)> _factories = {};

  @override
  IContainer get instance => this;

  @override
  T resolve<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    if (_factories.containsKey(T)) {
      final instance = _factories[T]!(this);
      _singletons[T] = instance;
      return instance as T;
    }

    throw Exception('No registration found for type $T');
  }

  @override
  void registerSingleton<T>(T Function(IContainer) factory) {
    _factories[T] = factory;
  }
}
```

## Best Practices

### 1. Register at Application Start

```dart
// ✅ Good: Register all dependencies early
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setupDependencies(); // Call at app start
    return MaterialApp(
      // ...
    );
  }
}

void setupDependencies() {
  final container = Container.instance;
  container.registerSingleton<ILogger>((c) => ConsoleLogger());
  container.registerSingleton<IFileService>((c) => FileService());
  // ... other dependencies
}
```

### 2. Use Interface Types

```dart
// ✅ Good: Register against interfaces
container.registerSingleton<ILogger>((c) => ConsoleLogger());

// ❌ Bad: Register concrete types
container.registerSingleton<ConsoleLogger>((c) => ConsoleLogger());
```

### 3. Keep Factories Simple

```dart
// ✅ Good: Simple factory function
container.registerSingleton<IRepository<Task, String>>((c) =>
  TaskRepository(
    logger: c.resolve<ILogger>(),
    storage: c.resolve<StorageAbstract>()
  )
);

// ❌ Bad: Complex factory with logic
container.registerSingleton<IRepository<Task, String>>((c) {
  final config = loadConfiguration();
  final logger = config.debugMode ? ConsoleLogger() : FileLogger();
  final storage = config.isTest ? MockStorage() : StorageService();
  return TaskRepository(logger: logger, storage: storage);
});
```

### 4. Avoid Circular Dependencies

```dart
// ❌ Bad: Circular dependency
class ServiceA {
  final ServiceB serviceB;
  ServiceA(this.serviceB);
}

class ServiceB {
  final ServiceA serviceA;
  ServiceB(this.serviceA);
}

// ✅ Good: Extract interface or restructure
class ServiceA {
  final IServiceB serviceB;
  ServiceA(this.serviceB);
}

class ServiceB implements IServiceB {
  // No dependency on ServiceA
}
```

## Advanced Patterns

### Conditional Registration

```dart
void setupDependencies({bool isTest = false}) {
  final container = Container.instance;

  if (isTest) {
    container.registerSingleton<ILogger>((c) => MockLogger());
    container.registerSingleton<StorageAbstract>((c) => MockStorage());
  } else {
    container.registerSingleton<ILogger>((c) => CompositeLogger([
      ConsoleLogger(),
      FileLogger()
    ]));
    container.registerSingleton<StorageAbstract>((c) => StorageService());
  }
}
```

### Lazy Loading

```dart
// Dependencies are created only when first resolved
container.registerSingleton<IExpensiveService>((c) {
  print("Creating expensive service..."); // Called only on first resolve
  return ExpensiveService();
});

final service1 = container.resolve<IExpensiveService>(); // Creates instance
final service2 = container.resolve<IExpensiveService>(); // Returns same instance
```

### Configuration Injection

```dart
class AppConfig {
  final String apiBaseUrl;
  final bool enableDebugMode;

  AppConfig(this.apiBaseUrl, this.enableDebugMode);
}

// Register configuration
container.registerSingleton<AppConfig>((c) => AppConfig(
  'https://api.example.com',
  kDebugMode
));

// Use in services
container.registerSingleton<IApiService>((c) => ApiService(
  config: c.resolve<AppConfig>(),
  logger: c.resolve<ILogger>()
));
```

## Testing with DI Container

### Unit Tests

```dart
void main() {
  group('UserService Tests', () {
    late Container testContainer;
    late MockLogger mockLogger;
    late MockStorage mockStorage;

    setUp(() {
      testContainer = Container();
      mockLogger = MockLogger();
      mockStorage = MockStorage();

      testContainer.registerSingleton<ILogger>((c) => mockLogger);
      testContainer.registerSingleton<StorageAbstract>((c) => mockStorage);
      testContainer.registerSingleton<IUserService>((c) => UserService(
        logger: c.resolve<ILogger>(),
        storage: c.resolve<StorageAbstract>()
      ));
    });

    test('should log user creation', () {
      final userService = testContainer.resolve<IUserService>();
      userService.createUser('test@example.com');

      verify(mockLogger.info(any)).called(1);
    });
  });
}
```

### Widget Tests

```dart
void main() {
  testWidgets('MyApp loads correctly', (tester) async {
    final testContainer = Container();
    testContainer.registerSingleton<ILogger>((c) => MockLogger());

    await tester.pumpWidget(
      MaterialApp(
        home: MyServiceWidget(
          service: testContainer.resolve<IUserService>(),
        ),
      ),
    );

    expect(find.byType(MyServiceWidget), findsOneWidget);
  });
}
```

## Error Handling

### Common Exceptions

```dart
try {
  final service = container.resolve<IService>();
} on Exception catch (e) {
  if (e.toString().contains('No registration found')) {
    // Handle missing registration
    print('Service not registered: $IService');
  }
}
```

### Validation

```dart
// Usage
if (!Container.instance.isRegistered<ILogger>()) {
  throw Exception('Logger not registered. Call setupDependencies() first.');
}
```

## Performance Considerations

- **Memory Usage**: Singletons persist for app lifetime
- **Startup Time**: Dependencies created lazily on first use
- **Type Safety**: Compile-time checking prevents runtime errors
- **Thread Safety**: Container is not thread-safe by design (Flutter single-threaded)

## Comparison with Alternatives

| Feature             | ACore Flutter DI | get_it | kiwi | injectable |
| ------------------- | ---------------- | ------ | ---- | ---------- |
| Compile-time Safety | ✅               | ❌     | ✅   | ✅         |
| Code Generation     | ❌               | ❌     | ✅   | ✅         |
| Simplicity          | ✅               | ✅     | ⚠️   | ❌         |
| Singleton Support   | ✅               | ✅     | ✅   | ✅         |
| Testing Support     | ✅               | ✅     | ✅   | ✅         |

## Migration Guide

### From Manual DI

```dart
// Before: Manual instantiation
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logger = ConsoleLogger();
    final service = UserService(logger);
    return ServiceWidget(service: service);
  }
}

// After: DI container
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = Container.instance.resolve<IUserService>();
    return ServiceWidget(service: service);
  }
}
```

### From Other DI Libraries

```dart
// From get_it
final getIt = GetIt.instance;
getIt.registerSingleton<ILogger>(() => ConsoleLogger());

// To ACore Flutter DI
final container = Container.instance;
container.registerSingleton<ILogger>((c) => ConsoleLogger());
```

## Troubleshooting

### Common Issues

1. **"No registration found" Error**
   - Ensure dependency is registered before resolving
   - Check for typos in type names
   - Verify registration happens at app startup

2. **Circular Dependency Error**
   - Review dependency graph for cycles
   - Extract interfaces to break cycles
   - Consider restructuring responsibilities

3. **Test Dependencies Not Working**
   - Use separate container for tests
   - Ensure mocks are registered before real implementations
   - Verify mock setup in test setUp()

---

**Related Documentation**

- [Repository Pattern](../repository/README.md)
- [Logging](../logging/README.md)
- [Error Handling](../errors/README.md)

**See Also**

- [Dependency Injection Best Practices](../QUICK_REFERENCE.md#dependency-injection)
- [Testing with DI](../utils/testing_guide.md)
