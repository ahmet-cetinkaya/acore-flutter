# Mapper

## Overview

The mapper module provides a simple yet powerful object-to-object mapping system for Flutter applications. It allows you to define transformations between different object types and execute them through a clean, type-safe interface. This is particularly useful for converting between data transfer objects (DTOs), domain entities, and view models.

## Features

- 🔄 **Type-Safe Mapping** - Generic mapping with compile-time type safety
- 🎯 **Simple Interface** - Minimal API with just two core methods
- ⚡ **High Performance** - Efficient mapping function storage and execution
- 🔧 **Extensible** - Support for complex mapping logic through custom functions
- 🧩 **Generic Support** - Works with any Dart object types
- 🎨 **Clean Architecture** - Perfect for Clean Architecture layer transitions

## Core Interface

### IMapper

```dart
abstract class IMapper {
  /// Register a mapping function between two types
  void addMap<TDestination, TSource>(TDestination Function(TSource source) mapper);

  /// Execute a mapped transformation
  TDestination map<TDestination, TSource>(TSource sourceObject);
}
```

## Usage Examples

### Basic Object Mapping

```dart
// Define your data models
class UserDto {
  final String first_name;
  final String last_name;
  final String email_address;
  final int age;

  UserDto({
    required this.first_name,
    required this.last_name,
    required this.email_address,
    required this.age,
  });
}

class UserEntity {
  final String firstName;
  final String lastName;
  final String email;
  final int age;

  UserEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
  });
}

// Set up the mapper
final mapper = CoreMapper();

// Register mapping function
mapper.addMap<UserEntity, UserDto>((UserDto dto) {
  return UserEntity(
    firstName: dto.first_name,
    lastName: dto.last_name,
    email: dto.email_address,
    age: dto.age,
  );
});

// Execute mapping
final userDto = UserDto(
  first_name: 'John',
  last_name: 'Doe',
  email_address: 'john.doe@example.com',
  age: 30,
);

final userEntity = mapper.map<UserEntity, UserDto>(userDto);
print(userEntity.firstName); // Output: John
```

### Complex Entity Transformations

```dart
class ProductDto {
  final String product_id;
  final String product_name;
  final double price_amount;
  final String currency_code;
  final List<String> category_tags;

  ProductDto({
    required this.product_id,
    required this.product_name,
    required this.price_amount,
    required this.currency_code,
    required this.category_tags,
  });
}

class ProductEntity {
  final String id;
  final String name;
  final Money price;
  final List<String> categories;
  final DateTime createdAt;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.categories,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class Money {
  final double amount;
  final String currency;

  Money({required this.amount, required this.currency});

  @override
  String toString() => '$amount $currency';
}

// Register complex mapping
mapper.addMap<ProductEntity, ProductDto>((ProductDto dto) {
  return ProductEntity(
    id: dto.product_id,
    name: dto.product_name,
    price: Money(
      amount: dto.price_amount,
      currency: dto.currency_code,
    ),
    categories: dto.category_tags,
  );
});

// Handle nested objects
final productDto = ProductDto(
  product_id: 'prod_123',
  product_name: 'Premium Widget',
  price_amount: 29.99,
  currency_code: 'USD',
  category_tags: ['electronics', 'gadgets'],
);

final productEntity = mapper.map<ProductEntity, ProductDto>(productDto);
print(productEntity.price.toString()); // Output: 29.99 USD
```

### View Model Mapping for UI

```dart
class TaskEntity {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final int priority;

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDate,
    required this.isCompleted,
    required this.priority,
  });
}

class TaskViewModel {
  final String id;
  final String title;
  final String truncatedDescription;
  final String createdAtFormatted;
  final String? dueDateFormatted;
  final bool isOverdue;
  final String priorityText;
  final Color priorityColor;

  TaskViewModel({
    required this.id,
    required this.title,
    required this.truncatedDescription,
    required this.createdAtFormatted,
    this.dueDateFormatted,
    required this.isOverdue,
    required this.priorityText,
    required this.priorityColor,
  });
}

// UI-focused mapping with formatting
mapper.addMap<TaskViewModel, TaskEntity>((TaskEntity entity) {
  final now = DateTime.now();
  final dateFormat = DateFormat('MMM dd, yyyy');

  return TaskViewModel(
    id: entity.id,
    title: entity.title,
    truncatedDescription: entity.description.length > 50
        ? '${entity.description.substring(0, 50)}...'
        : entity.description,
    createdAtFormatted: dateFormat.format(entity.createdAt),
    dueDateFormatted: entity.dueDate != null
        ? dateFormat.format(entity.dueDate!)
        : null,
    isOverdue: entity.dueDate != null
        && entity.dueDate!.isBefore(now)
        && !entity.isCompleted,
    priorityText: _getPriorityText(entity.priority),
    priorityColor: _getPriorityColor(entity.priority),
  );
});

String _getPriorityText(int priority) {
  switch (priority) {
    case 1: return 'Low';
    case 2: return 'Medium';
    case 3: return 'High';
    default: return 'Normal';
  }
}

Color _getPriorityColor(int priority) {
  switch (priority) {
    case 1: return Colors.green;
    case 2: return Colors.orange;
    case 3: return Colors.red;
    default: return Colors.grey;
  }
}
```

### Bidirectional Mapping

```dart
class UserRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
}

class User {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });
}

// Request to Entity mapping
mapper.addMap<User, UserRequest>((UserRequest request) {
  return User(
    id: const Uuid().v4(), // Generate new ID
    username: request.username,
    email: request.email,
    firstName: request.firstName,
    lastName: request.lastName,
    createdAt: DateTime.now(),
  );
});

// Entity to Response mapping (for API responses)
class UserResponse {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String createdAtFormatted;

  UserResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.createdAtFormatted,
  });
}

mapper.addMap<UserResponse, User>((User user) {
  return UserResponse(
    id: user.id,
    username: user.username,
    email: user.email,
    fullName: '${user.firstName} ${user.lastName}',
    createdAtFormatted: DateFormat('yyyy-MM-dd').format(user.createdAt),
  );
});
```

### Data Validation in Mapping

```dart
class ValidatedUser {
  final String username;
  final String email;
  final int age;

  ValidatedUser({
    required this.username,
    required this.email,
    required this.age,
  });
}

mapper.addMap<ValidatedUser, UserDto>((UserDto dto) {
  // Validate input data during mapping
  if (dto.first_name.isEmpty) {
    throw ArgumentError('First name cannot be empty');
  }

  if (!dto.email_address.contains('@')) {
    throw ArgumentError('Invalid email format');
  }

  if (dto.age < 0 || dto.age > 150) {
    throw ArgumentError('Age must be between 0 and 150');
  }

  return ValidatedUser(
    username: dto.first_name.toLowerCase().replaceAll(' ', '.'),
    email: dto.email_address.toLowerCase(),
    age: dto.age,
  );
});

// Safe mapping with error handling
ValidatedUser? safeMapUser(UserDto dto) {
  try {
    return mapper.map<ValidatedUser, UserDto>(dto);
  } on ArgumentError catch (e) {
    logger.warning('User validation failed: ${e.message}');
    return null;
  } catch (e) {
    logger.error('Unexpected mapping error: $e');
    return null;
  }
}
```

### Integration with Repository Pattern

```dart
class UserRepository {
  final IMapper _mapper;
  final IDataSource _dataSource;

  UserRepository(this._mapper, this._dataSource);

  Future<List<UserEntity>> getAllUsers() async {
    final userDtos = await _dataSource.getUsers();

    return userDtos
        .map((dto) => _mapper.map<UserEntity, UserDto>(dto))
        .toList();
  }

  Future<UserEntity?> getUserById(String id) async {
    final userDto = await _dataSource.getUserById(id);

    if (userDto == null) return null;

    return _mapper.map<UserEntity, UserDto>(userDto);
  }

  Future<void> saveUser(UserEntity user) async {
    final userDto = _mapper.map<UserDto, UserEntity>(user);
    await _dataSource.saveUser(userDto);
  }
}
```

## Advanced Patterns

### Composable Mapping Functions

```dart
// Reusable mapping utilities
extension MapperExtensions on IMapper {
  TDestination mapWithDefault<TDestination, TSource>(
    TSource source,
    TDestination defaultValue,
  ) {
    try {
      return map<TDestination, TSource>(source);
    } catch (e) {
      return defaultValue;
    }
  }

  List<TDestination> mapList<TDestination, TSource>(List<TSource> sources) {
    return sources
        .map((source) => map<TDestination, TSource>(source))
        .toList();
  }

  TDestination? mapNullable<TDestination, TSource>(TSource? source) {
    return source != null ? map<TDestination, TSource>(source) : null;
  }
}

// Usage with extensions
final users = mapper.mapList<UserEntity, UserDto>(userDtos);
final user = mapper.mapWithDefault<UserEntity, UserDto>(dto, defaultUser);
final nullableUser = mapper.mapNullable<UserEntity, UserDto>(dtoOrNull);
```

### Configuration-Driven Mapping

```dart
class MappingConfig {
  static void configureMapper(IMapper mapper) {
    // User mappings
    mapper.addMap<UserEntity, UserDto>(_mapUserDtoToEntity);
    mapper.addMap<UserDto, UserEntity>(_mapUserEntityToDto);
    mapper.addMap<UserViewModel, UserEntity>(_mapUserEntityToViewModel);

    // Product mappings
    mapper.addMap<ProductEntity, ProductDto>(_mapProductDtoToEntity);
    mapper.addMap<ProductDto, ProductEntity>(_mapProductEntityToDto);

    // Task mappings
    mapper.addMap<TaskEntity, TaskDto>(_mapTaskDtoToEntity);
    mapper.addMap<TaskViewModel, TaskEntity>(_mapTaskEntityToViewModel);
  }
}

// Initialize with configuration
final mapper = CoreMapper();
MappingConfig.configureMapper(mapper);
```

## Testing Mapping Logic

### Unit Testing Mappers

```dart
void main() {
  group('User Mapping Tests', () {
    late IMapper mapper;

    setUp(() {
      mapper = CoreMapper();
      mapper.addMap<UserEntity, UserDto>((UserDto dto) {
        return UserEntity(
          firstName: dto.first_name,
          lastName: dto.last_name,
          email: dto.email_address,
          age: dto.age,
        );
      });
    });

    test('should map user DTO to entity correctly', () {
      // Arrange
      final userDto = UserDto(
        first_name: 'Jane',
        last_name: 'Smith',
        email_address: 'jane.smith@example.com',
        age: 25,
      );

      // Act
      final userEntity = mapper.map<UserEntity, UserDto>(userDto);

      // Assert
      expect(userEntity.firstName, equals('Jane'));
      expect(userEntity.lastName, equals('Smith'));
      expect(userEntity.email, equals('jane.smith@example.com'));
      expect(userEntity.age, equals(25));
    });

    test('should throw exception for unregistered mapping', () {
      // Arrange
      final unregisteredDto = SomeOtherDto();

      // Act & Assert
      expect(
        () => mapper.map<UserEntity, SomeOtherDto>(unregisteredDto),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class SomeOtherDto {
  final String value;
  SomeOtherDto(this.value);
}
```

### Property-Based Testing

```dart
import 'package:test/test.dart';

void main() {
  group('Property-Based Mapping Tests', () {
    late IMapper mapper;

    setUp(() {
      mapper = CoreMapper();
      // Register mappings...
    });

    test('should preserve data integrity for various user inputs', () {
      for (int i = 0; i < 100; i++) {
        // Generate random test data
        final userDto = UserDto(
          first_name: 'User$i',
          last_name: 'Test$i',
          email_address: 'user$i@test.com',
          age: i % 100,
        );

        final userEntity = mapper.map<UserEntity, UserDto>(userDto);

        // Verify round-trip mapping if bidirectional
        final mappedBack = mapper.map<UserDto, UserEntity>(userEntity);

        expect(mappedBack.first_name, equals(userDto.first_name));
        expect(mappedBack.last_name, equals(userDto.last_name));
        expect(mappedBack.email_address, equals(userDto.email_address));
        expect(mappedBack.age, equals(userDto.age));
      }
    });
  });
}
```

## Best Practices

### 1. Organize Mappings by Feature

```dart
// ✅ Good: Organize mappings logically
class UserMappings {
  static void register(IMapper mapper) {
    mapper.addMap<UserEntity, UserDto>(_toEntity);
    mapper.addMap<UserDto, UserEntity>(_toDto);
    mapper.addMap<UserViewModel, UserEntity>(_toViewModel);
  }
}

class ProductMappings {
  static void register(IMapper mapper) {
    mapper.addMap<ProductEntity, ProductDto>(_toEntity);
    mapper.addMap<ProductDto, ProductEntity>(_toDto);
  }
}
```

### 2. Use Pure Functions

```dart
// ✅ Good: Pure mapping function
UserEntity _mapUserDtoToEntity(UserDto dto) {
  return UserEntity(
    firstName: dto.first_name.trim(),
    lastName: dto.last_name.trim(),
    email: dto.email_address.toLowerCase(),
    age: dto.age,
  );
}

// ❌ Bad: Function with side effects
UserEntity _badMapUserDtoToEntity(UserDto dto) {
  logger.info('Mapping user: ${dto.email_address}'); // Side effect
  final user = UserEntity(/*...*/);
  _cacheUser(user); // Side effect
  return user;
}
```

### 3. Handle Null Gracefully

```dart
// ✅ Good: Explicit null handling
mapper.addMap<UserViewModel, UserEntity>((UserEntity entity) {
  return UserViewModel(
    id: entity.id,
    displayName: entity.firstName.isNotEmpty
        ? entity.firstName
        : 'Unknown User',
    lastLogin: entity.lastLogin ?? DateTime.now(),
  );
});

// ❌ Bad: Potential null exceptions
UserViewModel badMapping(UserEntity entity) {
  return UserViewModel(
    id: entity.id,
    displayName: entity.firstName, // Could be empty
    lastLogin: entity.lastLogin!, // Could be null
  );
}
```

### 4. Validate Input Data

```dart
// ✅ Good: Include validation in mapping
mapper.addMap<ValidatedEmail, EmailString>((EmailString emailStr) {
  if (!emailStr.value.contains('@')) {
    throw ArgumentError('Invalid email format: ${emailStr.value}');
  }
  return ValidatedEmail(emailStr.value);
});
```

## Error Handling

### Common Exceptions and Solutions

```dart
class MappingException implements Exception {
  final String message;
  final Type sourceType;
  final Type destinationType;
  final Object? sourceObject;

  MappingException(
    this.message, {
    required this.sourceType,
    required this.destinationType,
    this.sourceObject,
  });

  @override
  String toString() {
    return 'MappingException: $message\n'
           'Source: $sourceType\n'
           'Destination: $destinationType\n'
           'Source Object: $sourceObject';
  }
}

// Enhanced mapper with better error handling
class SafeCoreMapper implements IMapper {
  final CoreMapper _inner = CoreMapper();
  final ILogger _logger;

  SafeCoreMapper(this._logger);

  @override
  void addMap<TDestination, TSource>(TDestination Function(TSource source) mapper) {
    _inner.addMap<TDestination, TSource>(mapper);
  }

  @override
  TDestination map<TDestination, TSource>(TSource sourceObject) {
    try {
      return _inner.map<TDestination, TSource>(sourceObject);
    } on Exception catch (e) {
      _logger.error('Mapping failed', e);
      throw MappingException(
        'Failed to map ${TSource.runtimeType} to ${TDestination.runtimeType}',
        sourceType: TSource,
        destinationType: TDestination,
        sourceObject: sourceObject,
      );
    }
  }
}
```

## Performance Considerations

### Mapping Performance Tips

1. **Reuse Mapper Instances**: Create mapper instances once and reuse them
2. **Avoid Complex Logic**: Keep mapping functions simple and fast
3. **Batch Operations**: Use list mapping for multiple objects
4. **Lazy Mapping**: Only map when necessary, not in advance

```dart
// ✅ Good: Efficient batch mapping
class UserBatchProcessor {
  final IMapper _mapper;

  UserBatchProcessor(this._mapper);

  List<UserEntity> processDtos(List<UserDto> dtos) {
    return dtos
        .map((dto) => _mapper.map<UserEntity, UserDto>(dto))
        .toList(growable: false);
  }
}

// ❌ Bad: Creating new mapper for each operation
UserEntity inefficientMapping(UserDto dto) {
  final mapper = CoreMapper(); // New instance every time
  mapper.addMap<UserEntity, UserDto>((dto) => /* mapping logic */);
  return mapper.map<UserEntity, UserDto>(dto);
}
```

## Dependency Integration

### Register Mapper with IoC Container

```dart
// Register as singleton in dependency injection container
void registerMapperServices(IContainer container) {
  container.registerSingleton<IMapper>((c) {
    final mapper = CoreMapper();

    // Register all mappings
    UserMappings.register(mapper);
    ProductMappings.register(mapper);
    TaskMappings.register(mapper);

    return mapper;
  });
}

// Use in services
class UserService {
  final IMapper _mapper;

  UserService(this._mapper);

  UserViewModel getUserViewModel(String userId) {
    final userEntity = _getUserEntity(userId);
    return _mapper.map<UserViewModel, UserEntity>(userEntity);
  }
}
```

---

**Related Documentation**
- [Repository Pattern](../repository/README.md)
- [Dependency Injection](../dependency_injection/README.md)
- [Error Handling](../errors/README.md)