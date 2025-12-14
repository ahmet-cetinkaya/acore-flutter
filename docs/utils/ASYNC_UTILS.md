# Async Utils

## Overview

The `AsyncUtils` class provides common async operation patterns with built-in
error handling, success/failure callbacks, and cleanup support. It simplifies
asynchronous operations and promotes consistent error handling throughout the
application.

## Features

- 🔄 **Operation Wrapping** - Execute async operations with consistent error
  handling
- ✅ **Success Callbacks** - Handle successful results gracefully
- ❌ **Error Callbacks** - Centralized error handling with stack traces
- 🧹 **Cleanup Support** - Finally blocks for resource cleanup
- 🎯 **Null Safety** - Safe handling of operation results

## Core Methods

### `executeAsync<T>()`

Executes an async operation that returns a value and provides callbacks for
different outcomes.

```dart
static Future<T?> executeAsync<T>({
  required Future<T> Function() operation,
  void Function(T result)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
  VoidCallback? onFinally,
})
```

**Parameters:**

- `operation`: The async function to execute
- `onSuccess`: Callback called when operation succeeds
- `onError`: Callback called when operation fails
- `onFinally`: Callback always called (success or failure)

**Returns:** The operation result, or `null` if an error occurred

### executeAsyncVoid()

Executes an async operation that doesn't return a value (void operations).

```dart
static Future<void> executeAsyncVoid({
  required Future<void> Function() operation,
  VoidCallback? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
  VoidCallback? onFinally,
})
```

**Parameters:**

- `operation`: The async void function to execute
- `onSuccess`: Callback called when operation completes successfully
- `onError`: Callback called when operation fails
- `onFinally`: Callback always called (success or failure)

## Usage Examples

### Basic Async Operation

```dart
class DataService {
  final ILogger _logger;

  DataService(this._logger);

  Future<String?> fetchData(String url) async {
    return await AsyncUtils.executeAsync<String>(
      operation: () async {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      },
      onSuccess: (data) {
        _logger.info("Data fetched successfully", data.length);
      },
      onError: (error, stackTrace) {
        _logger.error("Failed to fetch data", error, stackTrace);
      },
    );
  }
}
```

### API Service Example

```dart
class ApiService {
  final ILogger _logger;
  final IHttpClient _httpClient;

  ApiService(this._logger, this._httpClient);

  Future<User?> getUserById(String userId) async {
    return await AsyncUtils.executeAsync<User>(
      operation: () async {
        final response = await _httpClient.get('/api/users/$userId');
        return User.fromJson(response.data);
      },
      onSuccess: (user) {
        _logger.info("User retrieved successfully", userId);
      },
      onError: (error, stackTrace) {
        _logger.error("Failed to retrieve user", error, stackTrace);
      },
    );
  }

  Future<void> updateUser(User user) async {
    await AsyncUtils.executeAsyncVoid(
      operation: () async {
        await _httpClient.put('/api/users/${user.id}', user.toJson());
      },
      onSuccess: () {
        _logger.info("User updated successfully", user.id);
      },
      onError: (error, stackTrace) {
        _logger.error("Failed to update user", error, stackTrace);
      },
    );
  }
}
```

### File Operations

```dart
class FileManager {
  final ILogger _logger;
  final IFileService _fileService;

  FileManager(this._logger, this._fileService);

  Future<void> saveData(String data, String filename) async {
    await AsyncUtils.executeAsyncVoid(
      operation: () async {
        final bytes = utf8.encode(data);
        await _fileService.saveFile(
          fileName: filename,
          data: bytes,
          fileExtension: 'txt',
          isTextFile: true,
        );
      },
      onSuccess: () {
        _logger.info("File saved successfully", filename);
      },
      onError: (error, stackTrace) {
        _logger.error("Failed to save file", error, stackTrace);
      },
    );
  }

  Future<String?> loadData(String filename) async {
    return await AsyncUtils.executeAsync<String>(
      operation: () async {
        final bytes = await _fileService.readFile(filename);
        return utf8.decode(bytes);
      },
      onSuccess: (data) {
        _logger.info("File loaded successfully", filename);
      },
      onError: (error, stackTrace) {
        _logger.error("Failed to load file", error, stackTrace);
      },
    );
  }
}
```

### Database Operations

```dart
class TaskRepository {
  final ILogger _logger;
  final Database _database;

  TaskRepository(this._logger, this._database);

  Future<List<Task>> getActiveTasks() async {
    return await AsyncUtils.executeAsync<List<Task>>(
      operation: () async {
        final results = await _database.query(
          'tasks',
          where: 'is_completed = 0 AND deleted_date IS NULL',
          orderBy: 'priority DESC, created_date DESC',
        );
        return results.map((json) => Task.fromJson(json)).toList();
      },
      onSuccess: (tasks) {
        _logger.info("Active tasks retrieved", tasks.length);
      },
      onError: (error, stackTrace) {
        _logger.error("Failed to retrieve active tasks", error, stackTrace);
      },
    ) ?? []; // Return empty list if operation failed
  }

  Future<void> createTask(Task task) async {
    await AsyncUtils.executeAsyncVoid(
      operation: () async {
        await _database.insert('tasks', task.toJson());
      },
      onSuccess: () {
        _logger.info("Task created successfully", task.id);
      },
      onError: (error, stackTrace) {
        _logger.error("Failed to create task", error, stackTrace);
      },
    );
  }
}
```

## Advanced Patterns

### Chaining Operations

```dart
class DataProcessor {
  final ILogger _logger;
  final ApiService _apiService;
  final CacheService _cacheService;

  DataProcessor(this._logger, this._apiService, this._cacheService);

  Future<String?> processAndCacheData(String endpoint) async {
    return await AsyncUtils.executeAsync<String>(
      operation: () async {
        // Step 1: Fetch data from API
        final rawData = await _apiService.getRawData(endpoint);

        // Step 2: Process the data
        final processedData = _processData(rawData);

        // Step 3: Cache the result
        await _cacheService.store(endpoint, processedData);

        return processedData;
      },
      onSuccess: (data) {
        _logger.info("Data processed and cached", endpoint);
      },
      onError: (error, stackTrace) {
        _logger.error("Failed to process and cache data", error, stackTrace);

        // Fallback: try to get from cache
        return _cacheService.retrieve(endpoint);
      },
    );
  }
}
```

### Retry Pattern

```dart
class ResilientService {
  final ILogger _logger;
  final int _maxRetries;
  final Duration _retryDelay;

  ResilientService(this._logger, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) : _maxRetries = maxRetries,
       _retryDelay = retryDelay;

  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    int attempts = 0;

    while (attempts <= _maxRetries) {
      try {
        return await AsyncUtils.executeAsync<T>(
          operation: operation,
          onSuccess: (result) {
            if (attempts > 0) {
              _logger.info("Operation succeeded after retries", {
                'operation': operationName ?? 'unknown',
                'attempts': attempts + 1,
              });
            }
          },
          onError: (error, stackTrace) {
            if (attempts < _maxRetries) {
              _logger.warning("Operation failed, retrying...", {
                'operation': operationName ?? 'unknown',
                'attempt': attempts + 1,
                'error': error.toString(),
              });

              // Wait before retry
              Future.delayed(_retryDelay * (attempts + 1));
              attempts++;
              throw error; // Re-throw to continue retry loop
            } else {
              _logger.error("Operation failed after all retries", error, stackTrace);
            }
          },
        );
      } catch (e) {
        if (attempts == _maxRetries) {
          return null; // All retries exhausted
        }
        attempts++;
      }
    }

    return null;
  }
}
```

### Concurrent Operations

```dart
class ParallelProcessor {
  final ILogger _logger;

  ParallelProcessor(this._logger);

  Future<List<T?>> processInParallel<T>(
    List<Future<T> Function()> operations,
  ) async {
    final futures = operations.map((operation) =>
      AsyncUtils.executeAsync<T>(
        operation: operation,
        onError: (error, stackTrace) {
          _logger.error("Parallel operation failed", error, stackTrace);
        },
      )
    ).toList();

    try {
      return await Future.wait(futures);
    } catch (e) {
      _logger.error("Failed to wait for parallel operations", e);
      return List.filled(operations.length, null);
    }
  }

  Future<void> processTasksConcurrently(List<Task> tasks) async {
    final operations = tasks.map((task) => () async {
      await _processSingleTask(task);
    }).toList();

    final results = await processInParallel(operations);

    final successful = results.where((r) => r != null).length;
    final failed = results.length - successful;

    _logger.info("Concurrent processing completed", {
      'total': tasks.length,
      'successful': successful,
      'failed': failed,
    });
  }

  Future<void> _processSingleTask(Task task) async {
    // Individual task processing logic
  }
}
```

## Testing with AsyncUtils

### Unit Testing

```dart
void main() {
  group('DataService Tests', () {
    late DataService dataService;
    late MockLogger mockLogger;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockLogger = MockLogger();
      mockHttpClient = MockHttpClient();
      dataService = DataService(mockLogger, mockHttpClient);
    });

    test('should handle successful data fetch', () async {
      // Arrange
      const testData = "test data";
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn(testData);
      when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataService.fetchData("https://api.example.com/data");

      // Assert
      expect(result, equals(testData));
      verify(() => mockLogger.info(any, testData.length)).called(1);
    });

    test('should handle failed data fetch', () async {
      // Arrange
      const testError = "Network error";
      when(() => mockHttpClient.get(any())).thenThrow(Exception(testError));

      // Act
      final result = await dataService.fetchData("https://api.example.com/data");

      // Assert
      expect(result, isNull);
      verify(() => mockLogger.error(any, any, any)).called(1);
    });
  });
}
```

### Widget Testing

```dart
void main() {
  testWidgets('AsyncDataWidget loads and displays data', (tester) async {
    // Arrange
    final mockService = MockDataService();
    when(() => mockService.fetchData(any())).thenAnswer((_) async => "test data");

    await tester.pumpWidget(
      MaterialApp(
        home: AsyncDataWidget(service: mockService),
      ),
    );

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('test data'), findsOneWidget);
  });
}
```

## Best Practices

### 1. Use Appropriate Callbacks

```dart
// ✅ Good: Use callbacks for side effects
await AsyncUtils.executeAsyncVoid(
  operation: () => _saveData(data),
  onSuccess: () => _showSuccessMessage(),
  onError: (e, s) => _showErrorMessage(e.toString()),
  onFinally: () => _hideLoadingIndicator(),
);

// ❌ Bad: Don't perform side effects in the operation
await AsyncUtils.executeAsyncVoid(
  operation: () async {
    await _saveData(data);
    _showSuccessMessage(); // This should be in onSuccess callback
  },
);
```

### 2. Handle Null Results

```dart
// ✅ Good: Handle potential null results
final result = await AsyncUtils.executeAsync(() => _fetchData());
if (result != null) {
  _processData(result);
} else {
  _handleError();
}

// ❌ Bad: Assume success
final result = await AsyncUtils.executeAsync(() => _fetchData());
_processData(result); // May throw if result is null
```

### 3. Use Meaningful Error Messages

```dart
// ✅ Good: Provide context in callbacks
await AsyncUtils.executeAsyncVoid(
  operation: () => _saveUser(user),
  onError: (error, stackTrace) {
    _logger.error("Failed to save user", {
      'userId': user.id,
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
    });
  },
);

// ❌ Bad: Generic error handling
await AsyncUtils.executeAsyncVoid(
  operation: () => _saveUser(user),
  onError: (error, stackTrace) {
    _logger.error("Operation failed", error, stackTrace);
  },
);
```

### 4. Avoid Nested AsyncUtils

```dart
// ✅ Good: Keep operations flat
await AsyncUtils.executeAsyncVoid(
  operation: () async {
    await _step1();
    await _step2();
    await _step3();
  },
);

// ❌ Bad: Nested calls
await AsyncUtils.executeAsyncVoid(
  operation: () async {
    await AsyncUtils.executeAsyncVoid(
      operation: () async {
        await _step1();
      },
    );
  },
);
```

## Performance Considerations

- **Callback Overhead**: Minimal overhead for callback execution
- **Stack Trace Capture**: Only captured when errors occur
- **Memory Usage**: No significant memory overhead
- **Thread Safety**: Safe for use in single-threaded Flutter environment

---

### Related Documentation

- [Error Handling](../errors/README.md)
- [Logging](../logging/README.md)
- [Testing Guide](./testing_guide.md)

### See Also

- [Repository Pattern](../repository/README.md)
- [File Services](../file/README.md)
