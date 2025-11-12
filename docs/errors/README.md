# Error Handling

## Overview

The error handling module provides structured exception management with support for business logic errors, error codes, localization, and consistent error reporting throughout the application.

## Features

- 🏷️ **Business Exceptions** - Structured business logic error handling
- 🔢 **Error Codes** - Machine-readable error identification
- 🌍 **Localization Support** - Error message internationalization
- 📊 **Error Context** - Rich error information with arguments
- 🔗 **Chainable Errors** - Error wrapping and cause tracking

## Core Classes

### BusinessException

The primary exception class for business logic errors.

```dart
class BusinessException implements Exception {
  final String message;
  final String errorCode;
  final Map<String, String>? args;

  BusinessException(this.message, this.errorCode, {this.args});

  @override
  String toString() => message;
}
```

**Properties:**
- `message`: Human-readable error description
- `errorCode`: Machine-readable error identifier
- `args`: Optional arguments for localization or context

## Usage Examples

### Basic Error Creation

```dart
class UserService {
  Future<User> createUser(String email, String password) async {
    if (email.isEmpty) {
      throw BusinessException(
        'Email is required',
        'EMAIL_REQUIRED',
      );
    }

    if (password.length < 8) {
      throw BusinessException(
        'Password must be at least 8 characters long',
        'PASSWORD_TOO_SHORT',
        args: {'minLength': '8'},
      );
    }

    if (await _emailExists(email)) {
      throw BusinessException(
        'A user with this email already exists',
        'EMAIL_ALREADY_EXISTS',
        args: {'email': email},
      );
    }

    // Create user logic...
  }
}
```

### Error Handling with Context

```dart
class TaskService {
  final ILogger _logger;
  final IRepository<Task, String> _repository;

  TaskService(this._logger, this._repository);

  Future<void> completeTask(String taskId) async {
    try {
      final task = await _repository.getById(taskId);
      if (task == null) {
        throw BusinessException(
          'Task not found',
          'TASK_NOT_FOUND',
          args: {'taskId': taskId},
        );
      }

      if (task.isCompleted) {
        throw BusinessException(
          'Task is already completed',
          'TASK_ALREADY_COMPLETED',
          args: {'taskId': taskId},
        );
      }

      task.isCompleted = true;
      task.modifiedDate = DateTime.now();
      await _repository.update(task);

    } on BusinessException catch (e) {
      _logger.warning("Business logic error in completeTask", {
        'errorCode': e.errorCode,
        'message': e.message,
        'args': e.args,
      });
      rethrow;
    } catch (e, stackTrace) {
      _logger.error("Unexpected error in completeTask", e, stackTrace);
      throw BusinessException(
        'Failed to complete task',
        'TASK_COMPLETION_FAILED',
        args: {'taskId': taskId},
      );
    }
  }
}
```

### Error Code Constants

```dart
class ErrorCodes {
  // User-related errors
  static const String USER_NOT_FOUND = 'USER_NOT_FOUND';
  static const String USER_ALREADY_EXISTS = 'USER_ALREADY_EXISTS';
  static const String INVALID_CREDENTIALS = 'INVALID_CREDENTIALS';
  static const String ACCOUNT_LOCKED = 'ACCOUNT_LOCKED';

  // Task-related errors
  static const String TASK_NOT_FOUND = 'TASK_NOT_FOUND';
  static const String TASK_ALREADY_COMPLETED = 'TASK_ALREADY_COMPLETED';
  static const String INVALID_TASK_STATUS = 'INVALID_TASK_STATUS';

  // Validation errors
  static const String REQUIRED_FIELD = 'REQUIRED_FIELD';
  static const String INVALID_FORMAT = 'INVALID_FORMAT';
  static const String VALUE_OUT_OF_RANGE = 'VALUE_OUT_OF_RANGE';

  // System errors
  static const String DATABASE_ERROR = 'DATABASE_ERROR';
  static const String NETWORK_ERROR = 'NETWORK_ERROR';
  static const String FILE_NOT_FOUND = 'FILE_NOT_FOUND';
}
```

### Error Messages with Localization

```dart
class ErrorMessageLocalizer {
  static String getMessage(String errorCode, [Map<String, String>? args]) {
    final templates = {
      ErrorCodes.USER_NOT_FOUND: 'User not found',
      ErrorCodes.USER_ALREADY_EXISTS: 'A user with this email already exists',
      ErrorCodes.INVALID_CREDENTIALS: 'Invalid email or password',
      ErrorCodes.REQUIRED_FIELD: 'The {fieldName} field is required',
      ErrorCodes.INVALID_FORMAT: 'Invalid {fieldName} format',
      ErrorCodes.VALUE_OUT_OF_RANGE: 'Value must be between {minValue} and {maxValue}',
    };

    String template = templates[errorCode] ?? 'Unknown error: $errorCode';

    if (args != null) {
      for (final entry in args.entries) {
        template = template.replaceAll('{${entry.key}}', entry.value);
      }
    }

    return template;
  }
}

// Usage in service layer
class ValidationService {
  void validateEmail(String email) {
    if (email.isEmpty) {
      throw BusinessException(
        ErrorMessageLocalizer.getMessage(ErrorCodes.REQUIRED_FIELD, {'fieldName': 'Email'}),
        ErrorCodes.REQUIRED_FIELD,
        args: {'fieldName': 'Email'},
      );
    }

    if (!_isValidEmailFormat(email)) {
      throw BusinessException(
        ErrorMessageLocalizer.getMessage(ErrorCodes.INVALID_FORMAT, {'fieldName': 'Email'}),
        ErrorCodes.INVALID_FORMAT,
        args: {'fieldName': 'Email'},
      );
    }
  }
}
```

### Error Response for API

```dart
class ErrorResponse {
  final String errorCode;
  final String message;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  ErrorResponse({
    required this.errorCode,
    required this.message,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'error_code': errorCode,
    'message': message,
    'details': details,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ErrorResponse.fromException(Exception exception) {
    if (exception is BusinessException) {
      return ErrorResponse(
        errorCode: exception.errorCode,
        message: exception.message,
        details: exception.args,
      );
    } else {
      return ErrorResponse(
        errorCode: 'INTERNAL_SERVER_ERROR',
        message: 'An unexpected error occurred',
      );
    }
  }
}

// API Controller usage
class TaskController {
  final TaskService _taskService;

  TaskController(this._taskService);

  Future<Map<String, dynamic>> completeTask(String taskId) async {
    try {
      await _taskService.completeTask(taskId);
      return {'success': true, 'message': 'Task completed successfully'};
    } on BusinessException catch (e) {
      return ErrorResponse.fromException(e).toJson();
    } catch (e) {
      return ErrorResponse.fromException(e).toJson();
    }
  }
}
```

### Error Wrapping and Chaining

```dart
class ServiceException implements Exception {
  final String message;
  final String errorCode;
  final Exception? cause;
  final Map<String, String>? args;

  ServiceException({
    required this.message,
    required this.errorCode,
    this.cause,
    this.args,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(message);

    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }

    return buffer.toString();
  }

  factory ServiceException.wrap(
    Exception cause,
    String message,
    String errorCode, {
    Map<String, String>? args,
  }) {
    return ServiceException(
      message: message,
      errorCode: errorCode,
      cause: cause,
      args: args,
    );
  }
}

// Usage in repository layer
class TaskRepository implements IRepository<Task, String> {
  @override
  Future<Task?> getById(String id, {bool includeDeleted = false}) async {
    try {
      // Database query logic
      final result = await _database.query('tasks', where: 'id = ?', whereArgs: [id]);
      if (result.isEmpty) return null;

      return Task.fromJson(result.first);
    } on DatabaseException catch (e) {
      throw ServiceException.wrap(
        e,
        'Failed to retrieve task from database',
        ErrorCodes.DATABASE_ERROR,
        args: {'taskId': id, 'originalError': e.toString()},
      );
    }
  }
}
```

### Error Categories

```dart
abstract class ErrorCategory {
  static const List<String> VALIDATION_ERRORS = [
    ErrorCodes.REQUIRED_FIELD,
    ErrorCodes.INVALID_FORMAT,
    ErrorCodes.VALUE_OUT_OF_RANGE,
  ];

  static const List<String> AUTHENTICATION_ERRORS = [
    ErrorCodes.INVALID_CREDENTIALS,
    ErrorCodes.ACCOUNT_LOCKED,
    ErrorCodes.USER_NOT_FOUND,
  ];

  static const List<String> BUSINESS_LOGIC_ERRORS = [
    ErrorCodes.USER_ALREADY_EXISTS,
    ErrorCodes.TASK_ALREADY_COMPLETED,
    ErrorCodes.INVALID_TASK_STATUS,
  ];

  static const List<String> SYSTEM_ERRORS = [
    ErrorCodes.DATABASE_ERROR,
    ErrorCodes.NETWORK_ERROR,
    ErrorCodes.FILE_NOT_FOUND,
  ];

  static bool isValidationError(String errorCode) =>
      VALIDATION_ERRORS.contains(errorCode);

  static bool isAuthenticationError(String errorCode) =>
      AUTHENTICATION_ERRORS.contains(errorCode);

  static bool isBusinessLogicError(String errorCode) =>
      BUSINESS_LOGIC_ERRORS.contains(errorCode);

  static bool isSystemError(String errorCode) =>
      SYSTEM_ERRORS.contains(errorCode);
}

// Usage in error handling middleware
class ErrorHandler {
  void handleError(Exception exception) {
    if (exception is BusinessException) {
      if (ErrorCategory.isValidationError(exception.errorCode)) {
        _showValidationError(exception);
      } else if (ErrorCategory.isBusinessLogicError(exception.errorCode)) {
        _showBusinessError(exception);
      } else if (ErrorCategory.isSystemError(exception.errorCode)) {
        _showSystemError(exception);
      }
    } else {
      _showGenericError(exception);
    }
  }
}
```

## Testing Error Scenarios

### Unit Testing Error Handling

```dart
void main() {
  group('UserService Tests', () {
    late UserService userService;
    late MockUserRepository mockRepository;

    setUp(() {
      mockRepository = MockUserRepository();
      userService = UserService(mockRepository);
    });

    test('should throw BusinessException for empty email', () async {
      // Act & Assert
      expect(
        () => userService.createUser('', 'password123'),
        throwsA(isA<BusinessException>()
            .having((e) => e.errorCode, 'errorCode', ErrorCodes.REQUIRED_FIELD)
            .having((e) => e.message, 'message', contains('Email is required'))),
      );
    });

    test('should throw BusinessException for short password', () async {
      // Act & Assert
      expect(
        () => userService.createUser('test@example.com', 'short'),
        throwsA(isA<BusinessException>()
            .having((e) => e.errorCode, 'errorCode', ErrorCodes.PASSWORD_TOO_SHORT)
            .having((e) => e.args, 'args', containsPair('minLength', '8'))),
      );
    });

    test('should throw BusinessException for existing email', () async {
      // Arrange
      when(() => mockRepository.emailExists('test@example.com'))
          .thenAnswer((_) async => true);

      // Act & Assert
      expect(
        () => userService.createUser('test@example.com', 'password123'),
        throwsA(isA<BusinessException>()
            .having((e) => e.errorCode, 'errorCode', ErrorCodes.EMAIL_ALREADY_EXISTS)),
      );
    });
  });
}
```

### Widget Testing Error States

```dart
void main() {
  testWidgets('should display error message when BusinessException occurs', (tester) async {
    // Arrange
    final mockService = MockUserService();
    when(() => mockService.createUser(any(), any()))
        .thenThrow(BusinessException(
          'Email already exists',
          ErrorCodes.EMAIL_ALREADY_EXISTS,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: CreateUserForm(service: mockService),
      ),
    );

    // Act
    await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password123');
    await tester.tap(find.byKey(Key('createButton')));
    await tester.pump();

    // Assert
    expect(find.text('Email already exists'), findsOneWidget);
  });
}
```

## Best Practices

### 1. Use Specific Error Codes

```dart
// ✅ Good: Specific error codes
throw BusinessException(
  'Email is required',
  ErrorCodes.REQUIRED_FIELD,
  args: {'fieldName': 'Email'},
);

// ❌ Bad: Generic error code
throw BusinessException(
  'Email is required',
  'VALIDATION_ERROR',
);
```

### 2. Include Context in Arguments

```dart
// ✅ Good: Include relevant context
throw BusinessException(
  'Task not found',
  ErrorCodes.TASK_NOT_FOUND,
  args: {'taskId': taskId, 'userId': currentUserId},
);

// ❌ Bad: No context
throw BusinessException(
  'Task not found',
  ErrorCodes.TASK_NOT_FOUND,
);
```

### 3. Handle Errors at Appropriate Levels

```dart
// ✅ Good: Handle business errors in service layer
class TaskService {
  Future<void> completeTask(String taskId) async {
    try {
      await _repository.update(task);
    } on DatabaseException catch (e) {
      // Wrap system errors as business exceptions
      throw ServiceException.wrap(e, 'Failed to update task', ErrorCodes.DATABASE_ERROR);
    }
  }
}

// ❌ Bad: Let system errors bubble up to UI
class TaskService {
  Future<void> completeTask(String taskId) async {
    await _repository.update(task); // DatabaseException may reach UI
  }
}
```

### 4. Log Errors Appropriately

```dart
// ✅ Good: Log business warnings and system errors
try {
  await operation();
} on BusinessException catch (e) {
  _logger.warning("Business logic error", {
    'errorCode': e.errorCode,
    'args': e.args,
  });
  rethrow;
} catch (e, stackTrace) {
  _logger.error("Unexpected system error", e, stackTrace);
  throw BusinessException('Operation failed', ErrorCodes.INTERNAL_ERROR);
}

// ❌ Bad: Don't log or log everything as errors
try {
  await operation();
} catch (e) {
  _logger.error("Something went wrong", e); // Too generic
  rethrow;
}
```

---

**Related Documentation**
- [Logging](../logging/README.md)
- [Repository Pattern](../repository/README.md)
- [Async Utils](../utils/async_utils.md)

**See Also**
- [Error Response Format](./error_response.md)
- [Validation Patterns](./validation_patterns.md)