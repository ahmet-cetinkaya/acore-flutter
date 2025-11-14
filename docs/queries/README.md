# Queries

## Overview

The queries module provides essential query models and utilities for implementing CQRS (Command Query Responsibility Segregation) patterns in Flutter applications. It offers a clean separation between read operations (queries) and write operations (commands), enabling scalable and maintainable data access patterns.

## Features

- 🔍 **Query-Result Separation** - Clear distinction between query definitions and execution
- 🎯 **Type-Safe Operations** - Generic query models with compile-time type safety
- 📊 **Sorting Support** - Flexible sorting with field and direction specification
- 🏗️ **CQRS Ready** - Built to support Command Query Responsibility Segregation
- 🔧 **Extensible Design** - Easy to extend with custom query types
- 🚀 **Performance Focused** - Optimized for read-heavy operations

## Core Components

### SortOption

A generic sorting option that allows you to specify sorting by any field with configurable direction.

```dart
class SortOption<T> {
  final T field;
  final SortDirection direction;

  const SortOption({
    required this.field,
    this.direction = SortDirection.asc,
  });

  SortOption<T> withDirection(SortDirection direction);
}
```

**SortDirection Enum**:

```dart
enum SortDirection {
  asc,  // Ascending order
  desc, // Descending order
}
```

## Usage Examples

### Basic Sorting Operations

```dart
// Define enum for sortable fields
enum UserSortField {
  name,
  email,
  createdAt,
  lastLogin,
}

// Create sorting options
final sortByName = SortOption<UserSortField>(
  field: UserSortField.name,
  direction: SortDirection.asc,
);

final sortByCreatedDate = SortOption<UserSortField>(
  field: UserSortField.createdAt,
  direction: SortDirection.desc,
);

// Chain sorting options
final sortOptions = [
  SortOption<UserSortField>(field: UserSortField.name),
  SortOption<UserSortField>(field: UserSortField.createdAt, direction: SortDirection.desc),
];
```

### Query Base Classes

```dart
// Base query class for all queries
abstract class Query<TResult> {
  const Query();
}

// Query for retrieving users with sorting
class GetUsersQuery extends Query<List<UserEntity>> {
  final List<SortOption<UserSortField>> sortOptions;
  final int? limit;
  final int? offset;

  const GetUsersQuery({
    this.sortOptions = const [],
    this.limit,
    this.offset,
  });
}

// Query for finding user by ID
class GetUserByIdQuery extends Query<UserEntity?> {
  final String userId;

  const GetUserByIdQuery(this.userId);
}
```

### Query Handler Pattern

```dart
// Query handler interface
abstract class IQueryHandler<TQuery, TResult> {
  Future<TResult> handle(TQuery query);
}

// User query handler
class UserQueryHandler implements IQueryHandler<GetUsersQuery, List<UserEntity>> {
  final IUserRepository _userRepository;

  UserQueryHandler(this._userRepository);

  @override
  Future<List<UserEntity>> handle(GetUsersQuery query) async {
    return await _userRepository.getUsers(
      sortOptions: query.sortOptions,
      limit: query.limit,
      offset: query.offset,
    );
  }
}
```

### Query Bus Implementation

```dart
// Query bus for central query handling
class QueryBus {
  final Map<Type, dynamic> _handlers = {};

  void registerHandler<TQuery, TResult>(
    IQueryHandler<TQuery, TResult> handler,
  ) {
    _handlers[TQuery] = handler;
  }

  Future<TResult> send<TQuery, TResult>(TQuery query) async {
    final handler = _handlers[TQuery];
    if (handler == null) {
      throw Exception('No handler registered for query type ${TQuery.runtimeType}');
    }

    return await handler.handle(query);
  }
}

// Usage
final queryBus = QueryBus();
queryBus.registerHandler<GetUsersQuery, List<UserEntity>>(UserQueryHandler(repository));

final usersQuery = GetUsersQuery(
  sortOptions: [
    SortOption<UserSortField>(field: UserSortField.name),
    SortOption<UserSortField>(field: UserSortField.createdAt, direction: SortDirection.desc),
  ],
  limit: 50,
);

final users = await queryBus.send<GetUsersQuery, List<UserEntity>>(usersQuery);
```

### Advanced Query Patterns

#### Parameterized Queries

```dart
class GetUsersByRoleQuery extends Query<List<UserEntity>> {
  final UserRole role;
  final List<SortOption<UserSortField>> sortOptions;
  final bool includeInactive;

  const GetUsersByRoleQuery({
    required this.role,
    this.sortOptions = const [],
    this.includeInactive = false,
  });
}

class GetUsersByRoleHandler implements IQueryHandler<GetUsersByRoleQuery, List<UserEntity>> {
  final IUserRepository _userRepository;

  GetUsersByRoleHandler(this._userRepository);

  @override
  Future<List<UserEntity>> handle(GetUsersByRoleQuery query) async {
    return await _userRepository.getUsersByRole(
      role: query.role,
      sortOptions: query.sortOptions,
      includeInactive: query.includeInactive,
    );
  }
}
```

#### Filtered Queries

```dart
class UserFilter {
  final String? nameContains;
  final String? emailContains;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final List<UserRole>? roles;

  const UserFilter({
    this.nameContains,
    this.emailContains,
    this.createdAfter,
    this.createdBefore,
    this.roles,
  });
}

class GetUsersWithFilterQuery extends Query<List<UserEntity>> {
  final UserFilter filter;
  final List<SortOption<UserSortField>> sortOptions;
  final int? limit;
  final int? offset;

  const GetUsersWithFilterQuery({
    required this.filter,
    this.sortOptions = const [],
    this.limit,
    this.offset,
  });
}
```

#### Paginated Queries

```dart
class PaginatedQuery<T> extends Query<PaginatedList<T>> {
  final int page;
  final int pageSize;
  final List<SortOption<TSortField>> sortOptions;

  const PaginatedQuery({
    required this.page,
    required this.pageSize,
    this.sortOptions = const [],
  });
}

class GetPaginatedUsersQuery extends PaginatedQuery<UserEntity> {
  final UserFilter? filter;

  const GetPaginatedUsersQuery({
    required super.page,
    required super.pageSize,
    super.sortOptions = const [],
    this.filter,
  });
}

// Result type
class PaginatedList<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedList({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}
```

### Dynamic Field Sorting

```dart
// String-based field sorting for dynamic scenarios
class DynamicSortOption {
  final String fieldPath;
  final SortDirection direction;

  const DynamicSortOption({
    required this.fieldPath,
    this.direction = SortDirection.asc,
  });
}

// Usage with reflection or metadata
class UserSortFields {
  static const String name = 'name';
  static const String email = 'email';
  static const String createdAt = 'createdAt';
  static const String profileAge = 'profile.age'; // Nested field
}

final dynamicSort = DynamicSortOption(
  fieldPath: UserSortFields.profileAge,
  direction: SortDirection.desc,
);
```

### Query Caching

```dart
class CachedQueryHandler<TQuery, TResult> implements IQueryHandler<TQuery, TResult> {
  final IQueryHandler<TQuery, TResult> _innerHandler;
  final Duration cacheTtl;
  final Map<String, CachedResult<TResult>> _cache = {};

  CachedQueryHandler(this._innerHandler, {this.cacheTtl = const Duration(minutes: 5)});

  @override
  Future<TResult> handle(TQuery query) async {
    final cacheKey = _generateCacheKey(query);
    final cached = _cache[cacheKey];

    if (cached != null && !cached.isExpired) {
      return cached.result;
    }

    final result = await _innerHandler.handle(query);
    _cache[cacheKey] = CachedResult(result, DateTime.now().add(cacheTtl));

    return result;
  }

  String _generateCacheKey(TQuery query) {
    return '${TQuery.runtimeType}_${query.hashCode}';
  }
}

class CachedResult<T> {
  final T result;
  final DateTime expiresAt;

  CachedResult(this.result, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

### Query Validation

```dart
abstract class ValidatedQuery<TResult> extends Query<TResult> {
  const ValidatedQuery();

  /// Validate query parameters
  ValidationResult validate();
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  factory ValidationResult.success() => const ValidationResult(isValid: true);
  factory ValidationResult.failure(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);
}

class GetUsersQuery extends ValidatedQuery<List<UserEntity>> {
  final int? limit;
  final int? offset;

  const GetUsersQuery({
    this.limit,
    this.offset,
  });

  @override
  ValidationResult validate() {
    final errors = <String>[];

    if (limit != null && limit! <= 0) {
      errors.add('Limit must be greater than 0');
    }

    if (offset != null && offset! < 0) {
      errors.add('Offset cannot be negative');
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}

// Validating query handler
class ValidatingQueryHandler<TQuery extends ValidatedQuery<TResult>, TResult>
    implements IQueryHandler<TQuery, TResult> {
  final IQueryHandler<TQuery, TResult> _innerHandler;

  ValidatingQueryHandler(this._innerHandler);

  @override
  Future<TResult> handle(TQuery query) async {
    final validation = query.validate();

    if (!validation.isValid) {
      throw ValidationException(
        'Query validation failed: ${validation.errors.join(', ')}',
      );
    }

    return await _innerHandler.handle(query);
  }
}
```

### Integration with Repository Pattern

```dart
class UserRepository implements IUserRepository {
  final DataSource _dataSource;

  UserRepository(this._dataSource);

  @override
  Future<List<UserEntity>> getUsers({
    List<SortOption<UserSortField>> sortOptions = const [],
    int? limit,
    int? offset,
  }) async {
    final sortMappings = {
      UserSortField.name: 'name',
      UserSortField.email: 'email',
      UserSortField.createdAt: 'created_at',
      UserSortField.lastLogin: 'last_login',
    };

    final sqlSortOptions = sortOptions
        .map((option) => '${sortMappings[option.field]} ${option.direction.name.toUpperCase()}')
        .join(', ');

    return await _dataSource.queryUsers(
      orderBy: sqlSortOptions,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<UserEntity>> getUsersByRole({
    required UserRole role,
    List<SortOption<UserSortField>> sortOptions = const [],
    bool includeInactive = false,
  }) async {
    // Implementation similar to above
    final users = await _dataSource.queryUsersByRole(
      role: role.name,
      includeInactive: includeInactive,
      sortOptions: _convertSortOptions(sortOptions),
    );

    return users.map(_mapToEntity).toList();
  }

  List<String> _convertSortOptions(List<SortOption<UserSortField>> sortOptions) {
    final fieldMapping = {
      UserSortField.name: 'u.name',
      UserSortField.email: 'u.email',
      UserSortField.createdAt: 'u.created_at',
      UserSortField.lastLogin: 'u.last_login',
    };

    return sortOptions
        .map((option) => '${fieldMapping[option.field]} ${option.direction.name.toUpperCase()}')
        .toList();
  }
}
```

## Testing Query Patterns

### Unit Testing Queries

```dart
void main() {
  group('Query Tests', () {
    late MockUserRepository repository;
    late UserQueryHandler handler;

    setUp(() {
      repository = MockUserRepository();
      handler = UserQueryHandler(repository);
    });

    test('should handle get users query with sorting', () async {
      // Arrange
      final expectedUsers = [
        UserEntity(name: 'Alice', email: 'alice@example.com'),
        UserEntity(name: 'Bob', email: 'bob@example.com'),
      ];

      when(repository.getUsers(
        sortOptions: anyNamed('sortOptions'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => expectedUsers);

      final query = GetUsersQuery(
        sortOptions: [
          SortOption<UserSortField>(field: UserSortField.name),
        ],
        limit: 50,
      );

      // Act
      final result = await handler.handle(query);

      // Assert
      expect(result, equals(expectedUsers));
      verify(repository.getUsers(
        sortOptions: [
          SortOption<UserSortField>(field: UserSortField.name),
        ],
        limit: 50,
        offset: null,
      )).called(1);
    });

    test('should validate query parameters', () {
      // Arrange
      final invalidQuery = GetUsersQuery(limit: -1);

      // Act
      final result = invalidQuery.validate();

      // Assert
      expect(result.isValid, isFalse);
      expect(result.errors, contains('Limit must be greater than 0'));
    });
  });
}
```

### Integration Testing Query Bus

```dart
void main() {
  group('Query Bus Integration Tests', () {
    late QueryBus queryBus;
    late MockUserRepository repository;

    setUp(() {
      repository = MockUserRepository();
      queryBus = QueryBus();
      queryBus.registerHandler<GetUsersQuery, List<UserEntity>>(
        UserQueryHandler(repository),
      );
    });

    test('should route queries to correct handlers', () async {
      // Arrange
      final expectedUsers = [UserEntity(name: 'Test User', email: 'test@example.com')];
      when(repository.getUsers()).thenAnswer((_) async => expectedUsers);

      final query = GetUsersQuery();

      // Act
      final result = await queryBus.send<GetUsersQuery, List<UserEntity>>(query);

      // Assert
      expect(result, equals(expectedUsers));
    });

    test('should throw exception for unregistered query type', () async {
      // Arrange
      final unregisteredQuery = UnregisteredQuery();

      // Act & Assert
      expect(
        () => queryBus.send<UnregisteredQuery, void>(unregisteredQuery),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class UnregisteredQuery extends Query<void> {
  const UnregisteredQuery();
}
```

## Best Practices

### 1. Use Immutable Queries

```dart
// ✅ Good: Immutable query with const constructor
class GetUserByIdQuery extends Query<UserEntity?> {
  final String userId;

  const GetUserByIdQuery(this.userId);
}

// ❌ Bad: Mutable query
class BadGetUserQuery extends Query<UserEntity?> {
  String userId;

  BadGetUserQuery(this.userId);
}
```

### 2. Separate Query Definition from Execution

```dart
// ✅ Good: Clear separation
class GetUsersQuery extends Query<List<UserEntity>> {
  // Query definition only
  final List<SortOption<UserSortField>> sortOptions;
  const GetUsersQuery({this.sortOptions = const []});
}

class GetUsersHandler implements IQueryHandler<GetUsersQuery, List<UserEntity>> {
  // Execution logic
  @override
  Future<List<UserEntity>> handle(GetUsersQuery query) async {
    // Implementation
  }
}
```

### 3. Use Specific Result Types

```dart
// ✅ Good: Specific result type
class GetActiveUsersCountQuery extends Query<int> {
  const GetActiveUsersCountQuery();
}

// ❌ Bad: Generic result type
class GetUsersDataQuery extends Query<Map<String, dynamic>> {
  const GetUsersDataQuery();
}
```

### 4. Validate Input Parameters

```dart
// ✅ Good: Include validation
class GetUsersInRangeQuery extends ValidatedQuery<List<UserEntity>> {
  final int startAge;
  final int endAge;

  const GetUsersInRangeQuery({
    required this.startAge,
    required this.endAge,
  });

  @override
  ValidationResult validate() {
    if (startAge < 0 || endAge < 0) {
      return ValidationResult.failure(['Ages cannot be negative']);
    }

    if (startAge > endAge) {
      return ValidationResult.failure(['Start age cannot be greater than end age']);
    }

    return ValidationResult.success();
  }
}
```

## Performance Considerations

### Query Optimization Tips

1. **Use Pagination**: Always limit results with pagination for large datasets
2. **Index Sorting Fields**: Ensure database indexes exist for commonly sorted fields
3. **Cache Read-Only Queries**: Cache frequently accessed, read-only data
4. **Optimize Sort Options**: Sort by indexed fields first in multi-field sorting

```dart
// ✅ Good: Efficient query with pagination and caching
@override
Future<List<UserEntity>> handle(GetUsersQuery query) async {
  return await _cachedRepository.getUsers(
    sortOptions: query.sortOptions,
    limit: query.limit ?? 50, // Default limit
    offset: query.offset ?? 0,
  );
}
```

---

**Related Documentation**

- [Repository Pattern](../repository/README.md)
- [Error Handling](../errors/README.md)
- [Dependency Injection](../dependency_injection/README.md)
