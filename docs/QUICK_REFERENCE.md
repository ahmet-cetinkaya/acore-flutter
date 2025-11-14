# ACore Flutter Quick Reference Guide

## Getting Started

### Import
```dart
import 'package:acore/acore.dart';
```

### Basic Setup
```dart
// Initialize dependency container
final container = Container();
container.registerSingleton<ILogger>((c) => ConsoleLogger());

// Resolve services
final logger = container.resolve<ILogger>();
```

## Common Patterns

### Repository Pattern
```dart
class TaskRepository extends IRepository<Task, String> {
  // Implementation
}

// Usage
final repository = TaskRepository();
final tasks = await repository.getList(0, 20);
```

### Error Handling
```dart
try {
  await operation();
} on BusinessException catch (e) {
  logger.error("Business error: ${e.message}");
}
```

### Async Operations
```dart
final result = await AsyncUtils.executeAsync(
  operation: () => fetchData(),
  onSuccess: (data) => logger.info("Success"),
  onError: (e, s) => logger.error("Failed", e, s),
);
```

### Logging
```dart
logger.debug("Debug info");
logger.info("General info");
logger.warning("Warning message");
logger.error("Error occurred");
logger.fatal("Critical error");
```

## UI Components

### NumericInput
```dart
NumericInput(
  initialValue: 10,
  minValue: 0,
  maxValue: 100,
  onValueChanged: (value) => print(value),
)
```

### Date Picker
```dart
SafeCalendarDatePicker(
  selectionMode: DateSelectionMode.single,
  selectedDate: DateTime.now(),
  onSingleDateSelected: (date) => print(date),
  onRangeSelected: (_, __) {},
  translations: const {},
)
```

## Utilities

### Collections
```dart
// List comparison
CollectionUtils.areListsEqual(list1, list2);

// Value change detection
CollectionUtils.hasValueChanged(oldValue, newValue);
```

### Date/Time
```dart
// Localized weekday
DateTimeHelper.getWeekday(1); // Monday

// First day of week
DateTimeHelper.getFirstDayOfWeek();
```

### File Operations
```dart
final fileService = FileService();
final content = await fileService.readFile("path.txt");
await fileService.saveFile("export.txt", data, "txt");
```

## Key Classes

| Class | Purpose | Key Methods |
|-------|---------|-------------|
| `BaseEntity` | Base entity with audit trail | `toJson()`, `baseFromJson()` |
| `BusinessException` | Structured errors | `toString()` |
| `AsyncUtils` | Async patterns | `executeAsync()`, `executeAsyncVoid()` |
| `CollectionUtils` | Collection helpers | `areListsEqual()`, `hasValueChanged()` |
| `DateTimeHelper` | Date utilities | `getWeekday()`, `getFirstDayOfWeek()` |

## Interfaces

| Interface | Purpose | Key Methods |
|-----------|---------|-------------|
| `IRepository<T, TId>` | Data access | `getList()`, `add()`, `update()`, `delete()` |
| `ILogger` | Logging | `debug()`, `info()`, `warning()`, `error()`, `fatal()` |
| `IContainer` | DI container | `resolve()`, `registerSingleton()` |
| `IFileService` | File operations | `readFile()`, `writeFile()`, `saveFile()` |
| `StorageAbstract` | Key-value storage | `getValue()`, `setValue()`, `removeValue()` |

## Common Enums

### SortDirection
```dart
SortDirection.asc  // Ascending
SortDirection.desc // Descending
```

### NumericInputTranslationKey
```dart
NumericInputTranslationKey.increment
NumericInputTranslationKey.decrement
```

## Error Handling

### Exception Types
- `BusinessException`: Business logic errors
- `Exception`: General exceptions

### Error Codes
- `VALIDATION_ERROR`: Input validation
- `NOT_FOUND`: Resource missing
- `PERMISSION_DENIED`: Access issues
- `CONFLICT`: Resource conflicts

## Platform Considerations

### File Operations
- **Android**: Uses SAF (no permissions required)
- **iOS**: App sandbox restrictions
- **Desktop**: Full filesystem access
- **Web**: Browser limitations

### Storage
- **Mobile**: SharedPreferences/NSUserDefaults
- **Desktop**: Local storage
- **Web**: LocalStorage

## Best Practices

### DO
- Use interfaces for dependencies
- Handle async errors properly
- Log at appropriate levels
- Validate inputs
- Use type-safe operations

### DON'T
- Throw generic exceptions
- Ignore async errors
- Skip logging important events
- Use hardcoded values
- Mix UI and business logic

## Common Pitfalls

### Async Operations
```dart
// ❌ Wrong
final result = riskyOperation(); // Missing await

// ✅ Correct
final result = await AsyncUtils.executeAsync(
  operation: riskyOperation,
  onError: (e, s) => logger.error("Operation failed", e, s),
);
```

### Dependency Injection
```dart
// ❌ Wrong
final service = Service(); // Direct instantiation

// ✅ Correct
final service = container.resolve<IService>();
```

### Error Handling
```dart
// ❌ Wrong
try {
  await operation();
} catch (e) {
  // Too generic
}

// ✅ Correct
try {
  await operation();
} on BusinessException catch (e) {
  logger.error("Business logic error: ${e.message}");
} catch (e) {
  logger.error("Unexpected error", e);
}
```

## Performance Tips

1. **Repository Operations**
   - Use pagination for large datasets
   - Apply filters early
   - Cache frequently accessed data

2. **Async Operations**
   - Cancel unused operations
   - Set appropriate timeouts
   - Batch operations when possible

3. **UI Components**
   - Use const constructors
   - Implement proper disposal
   - Optimize rebuilds

## Testing Patterns

### Repository Testing
```dart
test('should add entity', () async {
  final mockRepository = MockRepository();
  await mockRepository.add(testEntity);
  verify(mockRepository.add(testEntity)).called(1);
});
```

### Async Testing
```dart
test('should handle async error', () async {
  final result = await AsyncUtils.executeAsync(
    operation: () => throw Exception('Test error'),
    onError: (e, s) => expect(e, isA<Exception>()),
  );
  expect(result, isNull);
});
```

## Debugging

### Logging Levels
```dart
logger.debug("Detailed info for development");
logger.info("General application flow");
logger.warning("Potential issues");
logger.error("Actual errors");
logger.fatal("Critical failures");
```

### Error Tracking
```dart
try {
  await operation();
} catch (e, s) {
  logger.error("Operation failed", e, s);
  // Report to monitoring service
}
```

## Resources

- **Full Documentation**: See `ACORE_COMPREHENSIVE_DOCUMENTATION.md`
- **API Reference**: See `API_REFERENCE.md`
- **Examples**: Check `docs/` folder for component-specific examples
- **Tests**: Reference test files for usage patterns

---

**Need Help?**
- Check comprehensive documentation for detailed explanations
- Review API reference for method signatures
- Examine test files for practical examples
- Look at existing implementations in the main codebase