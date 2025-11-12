# Logging Infrastructure

## Overview

The logging module provides a flexible and extensible logging infrastructure with support for multiple log levels, output destinations, and structured logging. It follows a clean architecture pattern with a simple interface that can be implemented by various concrete loggers.

## Features

- 📊 **Multiple Log Levels** - Debug, Info, Warning, Error, Fatal
- 🎯 **Structured Logging** - Consistent format with error and stack trace support
- 🔄 **Composite Logging** - Multiple log outputs simultaneously
- 💾 **Multiple Outputs** - Console, File, Memory, and custom destinations
- 🔧 **Configurable** - Runtime configuration and filtering
- 🧪 **Test Friendly** - Easy to mock and capture logs for testing

## Core Interface

### ILogger Interface

```dart
abstract class ILogger {
  /// Logs debug messages - used for detailed information during development
  void debug(String message, [Object? error, StackTrace? stackTrace]);

  /// Logs informational messages - general information about application flow
  void info(String message, [Object? error, StackTrace? stackTrace]);

  /// Logs warning messages - potentially harmful situations that are not errors
  void warning(String message, [Object? error, StackTrace? stackTrace]);

  /// Logs error messages - error events that might still allow the application to continue
  void error(String message, [Object? error, StackTrace? stackTrace]);

  /// Logs fatal/critical messages - very severe error events that might lead to termination
  void fatal(String message, [Object? error, StackTrace? stackTrace]);
}
```

## Built-in Implementations

### ConsoleLogger

Outputs log messages to the system console with color-coded levels for better readability.

```dart
class ConsoleLogger implements ILogger {
  final bool _includeColors;
  final LogLevel _minLevel;

  ConsoleLogger({
    bool includeColors = true,
    LogLevel minLevel = LogLevel.debug,
  }) : _includeColors = includeColors,
       _minLevel = minLevel;

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.debug)) {
      _logToConsole(LogLevel.debug, message, error, stackTrace);
    }
  }

  // ... other log level implementations

  void _logToConsole(LogLevel level, String message, Object? error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final colorCode = _getColorCode(level);

    final buffer = StringBuffer();
    if (_includeColors) {
      buffer.write('\x1B[${colorCode}m');
    }
    buffer.write('$timestamp [$levelStr] $message');
    if (_includeColors) {
      buffer.write('\x1B[0m');
    }

    if (error != null) {
      buffer.write('\nError: $error');
    }
    if (stackTrace != null) {
      buffer.write('\nStackTrace:\n$stackTrace');
    }

    print(buffer.toString());
  }
}
```

### FileLogger

Persists log messages to files with automatic rotation and size management.

```dart
class FileLogger implements ILogger {
  final String _logFilePath;
  final LogLevel _minLevel;
  final int _maxFileSize;
  final int _maxBackupFiles;
  final IOSink? _sink;

  FileLogger({
    required String logFilePath,
    LogLevel minLevel = LogLevel.info,
    int maxFileSize = 10 * 1024 * 1024, // 10MB
    int maxBackupFiles = 5,
  }) : _logFilePath = logFilePath,
       _minLevel = minLevel,
       _maxFileSize = maxFileSize,
       _maxBackupFiles = maxBackupFiles;

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.info)) {
      _writeToFile(LogLevel.info, message, error, stackTrace);
    }
  }

  void _writeToFile(LogLevel level, String message, Object? error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();

    final logEntry = '[$timestamp] [$levelStr] $message';
    final buffer = StringBuffer();
    buffer.writeln(logEntry);

    if (error != null) {
      buffer.writeln('Error: $error');
    }
    if (stackTrace != null) {
      buffer.writeln('StackTrace:\n$stackTrace');
    }

    _sink?.write(buffer.toString());
    _sink?.flush();

    _checkAndRotateFile();
  }
}
```

### MemoryLogger

Stores log messages in memory for debugging and testing purposes.

```dart
class MemoryLogger implements ILogger {
  final List<LogEntry> _logs = [];
  final int _maxEntries;
  final LogLevel _minLevel;

  MemoryLogger({
    int maxEntries = 1000,
    LogLevel minLevel = LogLevel.debug,
  }) : _maxEntries = maxEntries,
       _minLevel = minLevel;

  final List<LogEntry> logs = [];

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.debug)) {
      _addLog(LogLevel.debug, message, error, stackTrace);
    }
  }

  void _addLog(LogLevel level, String message, Object? error, StackTrace? stackTrace) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    _logs.add(entry);

    // Maintain max entries limit
    if (_logs.length > _maxEntries) {
      _logs.removeAt(0);
    }
  }

  List<LogEntry> getLogs({LogLevel? minLevel}) {
    if (minLevel == null) return List.unmodifiable(_logs);

    return _logs.where((log) => log.level.index >= minLevel.index).toList();
  }

  void clear() {
    _logs.clear();
  }
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });
}
```

### CompositeLogger

Combines multiple loggers to output to multiple destinations simultaneously.

```dart
class CompositeLogger implements ILogger {
  final List<ILogger> _loggers;

  CompositeLogger(this._loggers);

  CompositeLogger.add(ILogger logger) : _loggers = [logger];

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    for (final logger in _loggers) {
      logger.info(message, error, stackTrace);
    }
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    for (final logger in _loggers) {
      logger.error(message, error, stackTrace);
    }
  }

  // ... other log level implementations

  void addLogger(ILogger logger) {
    _loggers.add(logger);
  }

  void removeLogger(ILogger logger) {
    _loggers.remove(logger);
  }
}
```

## Usage Examples

### Basic Setup

```dart
import 'package:acore/logging.dart';

void main() {
  // Simple console logger
  final logger = ConsoleLogger();

  logger.info("Application started");
  logger.debug("Debug information");
  logger.warning("Warning message");
  logger.error("Error occurred", error, stackTrace);
}
```

### Multiple Output Configuration

```dart
void setupLogging() {
  // Create individual loggers
  final consoleLogger = ConsoleLogger(
    includeColors: true,
    minLevel: LogLevel.debug,
  );

  final fileLogger = FileLogger(
    logFilePath: 'logs/app.log',
    minLevel: LogLevel.info,
    maxFileSize: 5 * 1024 * 1024, // 5MB
  );

  final memoryLogger = MemoryLogger(
    maxEntries: 500,
    minLevel: LogLevel.debug,
  );

  // Combine into composite logger
  final logger = CompositeLogger([
    consoleLogger,
    fileLogger,
    memoryLogger,
  ]);

  // Register with dependency container
  Container.instance.registerSingleton<ILogger>((c) => logger);

  // Use in application
  final appLogger = Container.instance.resolve<ILogger>();
  appLogger.info("Logging system initialized");
}
```

### Structured Logging

```dart
class UserService {
  final ILogger _logger;

  UserService(this._logger);

  Future<User?> getUserById(String userId) async {
    _logger.debug("Attempting to retrieve user", null, StackTrace.current);

    try {
      final user = await userRepository.getById(userId);

      if (user == null) {
        _logger.warning("User not found", userId);
        return null;
      }

      _logger.info("User retrieved successfully", userId);
      return user;

    } catch (e, stackTrace) {
      _logger.error("Failed to retrieve user", e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateUser(User user) async {
    _logger.info("Updating user", user.id);

    try {
      await userRepository.update(user);
      _logger.info("User updated successfully", user.id);

    } catch (e, stackTrace) {
      _logger.error("Failed to update user", e, stackTrace);
      rethrow;
    }
  }
}
```

### Error Logging with Context

```dart
class ApiClient {
  final ILogger _logger;

  ApiClient(this._logger);

  Future<Map<String, dynamic>> get(String endpoint) async {
    _logger.debug("Making API request", endpoint);

    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode != 200) {
        final error = ApiException(
          'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
        _logger.error("API request failed", error, StackTrace.current);
        throw error;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _logger.debug("API request successful", endpoint);
      return data;

    } catch (e, stackTrace) {
      _logger.error("API request exception", e, stackTrace);
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String endpoint;

  ApiException(this.message, {required this.statusCode, required this.endpoint});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode, Endpoint: $endpoint)';
}
```

## Testing with Logging

### Capturing Logs in Tests

```dart
void main() {
  group('UserService Tests', () {
    late UserService userService;
    late MemoryLogger memoryLogger;

    setUp(() {
      memoryLogger = MemoryLogger();
      userService = UserService(memoryLogger);
    });

    test('should log debug message when retrieving user', () async {
      // Arrange
      final userId = 'test-user-id';

      // Act
      await userService.getUserById(userId);

      // Assert
      final debugLogs = memoryLogger.getLogs(minLevel: LogLevel.debug);
      expect(debugLogs, isNotEmpty);
      expect(debugLogs.first.message, contains("Attempting to retrieve user"));
      expect(debugLogs.first.level, equals(LogLevel.debug));
    });

    test('should log warning when user not found', () async {
      // Arrange
      final userId = 'non-existent-user';

      // Act
      await userService.getUserById(userId);

      // Assert
      final warningLogs = memoryLogger.getLogs(minLevel: LogLevel.warning);
      final warningLog = warningLogs.firstWhere(
        (log) => log.message.contains("User not found"),
        orElse: () => throw Exception("Expected warning log not found"),
      );
      expect(warningLog.level, equals(LogLevel.warning));
      expect(warningLog.error, equals(userId));
    });

    test('should log error when exception occurs', () async {
      // Arrange
      final userId = 'error-user';
      // Mock repository to throw exception

      // Act & Assert
      expect(
        () async => await userService.getUserById(userId),
        throwsException,
      );

      final errorLogs = memoryLogger.getLogs(minLevel: LogLevel.error);
      final errorLog = errorLogs.firstWhere(
        (log) => log.message.contains("Failed to retrieve user"),
        orElse: () => throw Exception("Expected error log not found"),
      );
      expect(errorLog.level, equals(LogLevel.error));
      expect(errorLog.error, isA<Exception>());
      expect(errorLog.stackTrace, isNotNull);
    });
  });
}
```

### Mock Logger for Testing

```dart
class MockLogger extends Mock implements ILogger {}

void main() {
  test('should log appropriate messages', () {
    final mockLogger = MockLogger();
    final service = SomeService(mockLogger);

    service.doSomething();

    verify(() => mockLogger.info("Operation started")).called(1);
    verify(() => mockLogger.info("Operation completed")).called(1);
  });
}
```

## Performance Considerations

### Log Level Filtering

```dart
// ✅ Good: Filter at logger level
final logger = ConsoleLogger(minLevel: LogLevel.info);
logger.debug("This won't be logged"); // Skipped early

// ❌ Bad: Filter in application code
final logger = ConsoleLogger();
if (kReleaseMode) {
  logger.debug("This won't be logged"); // Still processes the debug call
}
```

### Asynchronous Logging

```dart
class AsyncLogger implements ILogger {
  final ILogger _innerLogger;
  final StreamController<LogEvent> _controller;
  final Isolate _isolate;

  AsyncLogger(this._innerLogger) : _controller = StreamController() {
    // Process logs in background isolate
    _controller.stream.listen(_processLogAsync);
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _controller.add(LogEvent(LogLevel.info, message, error, stackTrace));
  }

  void _processLogAsync(LogEvent event) {
    // Process in background
    switch (event.level) {
      case LogLevel.info:
        _innerLogger.info(event.message, event.error, event.stackTrace);
        break;
      // ... other cases
    }
  }
}
```

## Log Management

### Log Rotation

```dart
class LogRotator {
  final String _basePath;
  final int _maxFiles;
  final int _maxSize;

  LogRotator({
    required String basePath,
    int maxFiles = 10,
    int maxSize = 10 * 1024 * 1024, // 10MB
  }) : _basePath = basePath,
       _maxFiles = maxFiles,
       _maxSize = maxSize;

  Future<void> rotateIfNeeded() async {
    final file = File(_basePath);
    if (!await file.exists()) return;

    if (await file.length() > _maxSize) {
      await _rotateFiles();
    }
  }

  Future<void> _rotateFiles() async {
    // Delete oldest if at limit
    for (int i = _maxFiles - 1; i >= 1; i--) {
      final oldFile = File('$_basePath.$i');
      final newFile = File('$_basePath.${i + 1}');

      if (await oldFile.exists()) {
        if (i == _maxFiles - 1) {
          await oldFile.delete();
        } else {
          await oldFile.rename(newFile.path);
        }
      }
    }

    // Move current to .1
    final currentFile = File(_basePath);
    final backupFile = File('$_basePath.1');
    await currentFile.rename(backupFile.path);
  }
}
```

### Log Analysis

```dart
class LogAnalyzer {
  final List<LogEntry> _logs;

  LogAnalyzer(this._logs);

  Map<LogLevel, int> getLevelCounts() {
    final counts = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      counts[level] = 0;
    }

    for (final log in _logs) {
      counts[log.level] = (counts[log.level] ?? 0) + 1;
    }

    return counts;
  }

  List<LogEntry> getErrorLogs() {
    return _logs.where((log) =>
      log.level == LogLevel.error || log.level == LogLevel.fatal
    ).toList();
  }

  Map<String, int> getErrorFrequency() {
    final errorCounts = <String, int>{};

    for (final log in getErrorLogs()) {
      final message = log.message;
      errorCounts[message] = (errorCounts[message] ?? 0) + 1;
    }

    return errorCounts;
  }
}
```

## Best Practices

### 1. Use Appropriate Log Levels

```dart
// ✅ Good: Use appropriate levels
logger.debug("Cache miss for key: $key");         // Detailed debugging
logger.info("User logged in: $userId");          // Important events
logger.warning("Rate limit approaching");        // Potential issues
logger.error("Database connection failed", e);   // Actual errors
logger.fatal("Application cannot start", e);     // Critical failures

// ❌ Bad: Wrong level usage
logger.error("User logged in: $userId");         // Not an error
logger.debug("Application crashed", e);          // Too important for debug
```

### 2. Include Context

```dart
// ✅ Good: Include relevant context
logger.error("Failed to process payment", paymentException, StackTrace.current);

// ❌ Bad: Generic error message
logger.error("Something went wrong");
```

### 3. Avoid Sensitive Information

```dart
// ✅ Good: Sanitize sensitive data
logger.info("User login attempt", {"userId": user.id, "timestamp": DateTime.now()});

// ❌ Bad: Log sensitive information
logger.info("User login", {"password": password, "token": authToken});
```

### 4. Use Structured Logging

```dart
// ✅ Good: Structured logging
logger.info("API request completed", {
  "endpoint": "/api/users",
  "method": "GET",
  "duration": "${stopwatch.elapsedMilliseconds}ms",
  "statusCode": 200
});

// ❌ Bad: Unstructured logging
logger.info("GET /api/users completed in 150ms with status 200");
```

---

**Related Documentation**
- [Error Handling](../errors/README.md)
- [Dependency Injection](../dependency_injection/README.md)
- [Testing Guide](../utils/testing_guide.md)

**See Also**
- [ConsoleLogger Implementation](./console_logger.md)
- [FileLogger Implementation](./file_logger.md)
- [MemoryLogger Implementation](./memory_logger.md)