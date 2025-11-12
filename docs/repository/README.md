# Repository Pattern

## Overview

The repository module provides a standardized data access abstraction layer implementing the Repository pattern with built-in support for pagination, filtering, sorting, and soft delete functionality. It promotes clean separation between business logic and data access concerns.

## Features

- 📊 **Generic Repository** - Type-safe repository for any entity type
- 📄 **Pagination Support** - Built-in paginated data retrieval
- 🔍 **Custom Filtering** - Flexible where clause construction
- 📈 **Custom Sorting** - Configurable ordering options
- 🗑️ **Soft Delete** - Built-in soft delete functionality
- 🏷️ **Audit Trail** - Automatic creation/modification tracking

## Core Components

### IRepository Interface

```dart
abstract class IRepository<T extends BaseEntity<TId>, TId> {
  /// Get paginated list with optional filtering
  Future<PaginatedList<T>> getList(int pageIndex, int pageSize, {
    bool includeDeleted = false,
    CustomWhereFilter? customWhereFilter,
    List<CustomOrder>? customOrder
  });

  /// Get all entities with optional filtering
  Future<List<T>> getAll({
    bool includeDeleted = false,
    CustomWhereFilter? customWhereFilter,
    List<CustomOrder>? customOrder
  });

  /// Get entity by ID
  Future<T?> getById(TId id, {bool includeDeleted = false});

  /// Get first entity matching filter
  Future<T?> getFirst(CustomWhereFilter customWhereFilter, {bool includeDeleted = false});

  /// Add new entity
  Future<void> add(T item);

  /// Update existing entity
  Future<void> update(T item);

  /// Delete entity by ID
  Future<void> delete(T id);
}
```

### BaseEntity

```dart
abstract class BaseEntity<TId> {
  TId id;
  DateTime createdDate;
  DateTime? modifiedDate;
  DateTime? deletedDate;
  bool get isDeleted => deletedDate != null;

  Map<String, dynamic> toJson();
  static Map<String, dynamic> baseFromJson(Map<String, dynamic> json);
}
```

### PaginatedList

```dart
class PaginatedList<T> {
  final List<T> items;
  final int totalCount;
  final int pageIndex;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;
}
```

## Usage Examples

### Basic Entity Definition

```dart
class Task extends BaseEntity<String> {
  String title;
  String description;
  bool isCompleted;
  DateTime? dueDate;
  int priority;

  Task({
    required this.id,
    required this.title,
    required this.createdDate,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
    this.priority = 0,
    this.modifiedDate,
    this.deletedDate,
  });

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    createdDate: DateTime.parse(json['createdDate']),
    description: json['description'] ?? '',
    isCompleted: json['isCompleted'] ?? false,
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    priority: json['priority'] ?? 0,
    modifiedDate: json['modifiedDate'] != null ? DateTime.parse(json['modifiedDate']) : null,
    deletedDate: json['deletedDate'] != null ? DateTime.parse(json['deletedDate']) : null,
  );
}
```

### Repository Implementation

```dart
class TaskRepository extends IRepository<Task, String> {
  final DataSource _dataSource;

  TaskRepository(this._dataSource);

  @override
  Future<PaginatedList<Task>> getList(int pageIndex, int pageSize, {
    bool includeDeleted = false,
    CustomWhereFilter? customWhereFilter,
    List<CustomOrder>? customOrder
  }) async {
    // Implementation details...
  }

  @override
  Future<Task?> getById(String id, {bool includeDeleted = false}) async {
    // Implementation details...
  }

  // ... other method implementations
}
```

### Basic CRUD Operations

```dart
class TaskService {
  final IRepository<Task, String> _repository;

  TaskService(this._repository);

  /// Create new task
  Future<void> createTask(String title, String description) async {
    final task = Task(
      id: generateId(),
      title: title,
      description: description,
      createdDate: DateTime.now(),
    );

    await _repository.add(task);
  }

  /// Get active tasks (non-deleted)
  Future<List<Task>> getActiveTasks() async {
    return await _repository.getAll(
      includeDeleted: false,
      customWhereFilter: CustomWhereFilter('isCompleted = 0'),
      customOrder: [CustomOrder('priority', SortDirection.desc)],
    );
  }

  /// Get paginated tasks
  Future<PaginatedList<Task>> getTasksPage(int page, int pageSize) async {
    return await _repository.getList(page, pageSize);
  }

  /// Update task
  Future<void> updateTask(Task task) async {
    task.modifiedDate = DateTime.now();
    await _repository.update(task);
  }

  /// Soft delete task
  Future<void> deleteTask(String taskId) async {
    await _repository.delete(taskId);
  }
}
```

## Advanced Filtering and Sorting

### Custom Where Filters

```dart
// Simple filter
final activeTasksFilter = CustomWhereFilter('isCompleted = 0 AND deletedDate IS NULL');

// Filter with parameters
final priorityFilter = CustomWhereFilter('priority >= ?', [3]);

// Complex filter with multiple parameters
final dateRangeFilter = CustomWhereFilter(
  'createdDate >= ? AND createdDate <= ?',
  [startDate.toIso8601String(), endDate.toIso8601String()]
);

// Text search
final searchFilter = CustomWhereFilter(
  'title LIKE ? OR description LIKE ?',
  ['%$searchQuery%', '%$searchQuery%']
);
```

### Custom Ordering

```dart
// Single order
final priorityOrder = CustomOrder('priority', SortDirection.desc);

// Multiple orders
final multiOrder = [
  CustomOrder('isCompleted', SortDirection.asc),
  CustomOrder('priority', SortDirection.desc),
  CustomOrder('createdDate', SortDirection.desc),
];
```

### Complex Query Example

```dart
Future<PaginatedList<Task>> getFilteredTasks({
  required int page,
  required int pageSize,
  bool? isCompleted,
  int? minPriority,
  DateTime? startDate,
  DateTime? endDate,
  String? searchQuery,
}) async {
  final filters = <String>[];
  final parameters = <dynamic>[];

  // Build where clause
  if (isCompleted != null) {
    filters.add('isCompleted = ?');
    parameters.add(isCompleted ? 1 : 0);
  }

  if (minPriority != null) {
    filters.add('priority >= ?');
    parameters.add(minPriority);
  }

  if (startDate != null) {
    filters.add('createdDate >= ?');
    parameters.add(startDate.toIso8601String());
  }

  if (endDate != null) {
    filters.add('createdDate <= ?');
    parameters.add(endDate.toIso8601String());
  }

  if (searchQuery != null && searchQuery.isNotEmpty) {
    filters.add('(title LIKE ? OR description LIKE ?)');
    parameters.addAll(['%$searchQuery%', '%$searchQuery%']);
  }

  // Don't include deleted items
  filters.add('deletedDate IS NULL');

  final whereClause = filters.join(' AND ');
  final customFilter = CustomWhereFilter(whereClause, parameters);

  // Add ordering
  final orders = [
    CustomOrder('priority', SortDirection.desc),
    CustomOrder('createdDate', SortDirection.desc),
  ];

  return await _repository.getList(
    page,
    pageSize,
    includeDeleted: false,
    customWhereFilter: customFilter,
    customOrder: orders,
  );
}
```

## Pagination Usage

### Frontend Integration

```dart
class TaskListViewModel extends ChangeNotifier {
  final IRepository<Task, String> _repository;

  List<Task> _tasks = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _pageSize = 20;
  bool _hasNextPage = true;
  int _totalCount = 0;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get hasNextPage => _hasNextPage;
  int get totalCount => _totalCount;

  TaskListViewModel(this._repository);

  Future<void> loadFirstPage() async {
    _currentPage = 0;
    _tasks.clear();
    await _loadPage();
  }

  Future<void> loadNextPage() async {
    if (!_hasNextPage || _isLoading) return;
    _currentPage++;
    await _loadPage();
  }

  Future<void> _loadPage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getList(_currentPage, _pageSize);

      if (_currentPage == 0) {
        _tasks = result.items;
      } else {
        _tasks.addAll(result.items);
      }

      _hasNextPage = result.hasNextPage;
      _totalCount = result.totalCount;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### UI Integration

```dart
class TaskListView extends StatelessWidget {
  final TaskListViewModel viewModel;

  const TaskListView({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return ListView.builder(
          itemCount: viewModel.tasks.length + (viewModel.hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == viewModel.tasks.length) {
              // Load more indicator
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else {
                // Load next page when scrolled to bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  viewModel.loadNextPage();
                });
                return const SizedBox.shrink();
              }
            }

            final task = viewModel.tasks[index];
            return TaskTile(task: task);
          },
        );
      },
    );
  }
}
```

## Soft Delete Implementation

### Soft Delete Logic

```dart
class SoftDeleteRepository<T extends BaseEntity<TId>, TId>
    extends IRepository<T, TId> {
  final IRepository<T, TId> _baseRepository;

  SoftDeleteRepository(this._baseRepository);

  @override
  Future<void> delete(TId id) async {
    final entity = await _baseRepository.getById(id);
    if (entity != null) {
      entity.deletedDate = DateTime.now();
      entity.modifiedDate = DateTime.now();
      await _baseRepository.update(entity);
    }
  }

  @override
  Future<void> permanentDelete(TId id) async {
    await _baseRepository.delete(id);
  }

  @override
  Future<void> restore(TId id) async {
    final entity = await _baseRepository.getById(id, includeDeleted: true);
    if (entity != null) {
      entity.deletedDate = null;
      entity.modifiedDate = DateTime.now();
      await _baseRepository.update(entity);
    }
  }

  // Delegate other methods to base repository
  @override
  Future<PaginatedList<T>> getList(int pageIndex, int pageSize, {
    bool includeDeleted = false,
    CustomWhereFilter? customWhereFilter,
    List<CustomOrder>? customOrder
  }) async {
    return await _baseRepository.getList(
      pageIndex,
      pageSize,
      includeDeleted: includeDeleted,
      customWhereFilter: customWhereFilter,
      customOrder: customOrder,
    );
  }

  // ... other method delegations
}
```

## Testing Repository

### Mock Repository for Testing

```dart
class MockTaskRepository extends Mock implements IRepository<Task, String> {}

void main() {
  group('TaskService Tests', () {
    late TaskService taskService;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      taskService = TaskService(mockRepository);
    });

    test('should create task successfully', () async {
      // Arrange
      final expectedTask = Task(
        id: 'test-id',
        title: 'Test Task',
        createdDate: DateTime.now(),
      );

      when(() => mockRepository.add(any())).thenAnswer((_) async {});

      // Act
      await taskService.createTask('Test Task', 'Test Description');

      // Assert
      verify(() => mockRepository.add(argThat(
        predicate((task) =>
          task.title == 'Test Task' &&
          task.description == 'Test Description'
        )
      ))).called(1);
    });

    test('should get active tasks', () async {
      // Arrange
      final activeTasks = [
        Task(id: '1', title: 'Task 1', createdDate: DateTime.now()),
        Task(id: '2', title: 'Task 2', createdDate: DateTime.now()),
      ];

      when(() => mockRepository.getAll(
        includeDeleted: false,
        customWhereFilter: any(named: 'customWhereFilter'),
        customOrder: any(named: 'customOrder'),
      )).thenAnswer((_) async => activeTasks);

      // Act
      final result = await taskService.getActiveTasks();

      // Assert
      expect(result, equals(activeTasks));
      verify(() => mockRepository.getAll(
        includeDeleted: false,
        customWhereFilter: any(named: 'customWhereFilter'),
        customOrder: any(named: 'customOrder'),
      )).called(1);
    });
  });
}
```

## Performance Considerations

### Pagination Optimization

```dart
// ✅ Good: Use pagination for large datasets
final tasks = await repository.getList(0, 20);

// ❌ Bad: Load all data at once
final allTasks = await repository.getAll();
```

### Filtering Optimization

```dart
// ✅ Good: Apply filters early in the query
final tasks = await repository.getAll(
  customWhereFilter: CustomWhereFilter('priority >= 3'),
);

// ❌ Bad: Load all data and filter in memory
final allTasks = await repository.getAll();
final highPriorityTasks = allTasks.where((t) => t.priority >= 3).toList();
```

### Indexing Considerations

```dart
// For SQL databases, ensure proper indexes on:
// - Primary keys (id)
// - Foreign keys
// - Frequently filtered columns
// - Columns used in ordering
```

## Best Practices

### 1. Entity Design

```dart
// ✅ Good: Include audit fields
class Task extends BaseEntity<String> {
  // ... business fields

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(), // Include audit fields
      // ... business fields
    };
  }
}

// ❌ Bad: Missing audit information
class Task {
  String id;
  String title;
  // No createdDate, modifiedDate, deletedDate
}
```

### 2. Repository Usage

```dart
// ✅ Good: Use dependency injection
class TaskService {
  final IRepository<Task, String> _repository;

  TaskService(this._repository);
}

// ❌ Bad: Direct instantiation
class TaskService {
  final _repository = TaskRepository(); // Tightly coupled
}
```

### 3. Error Handling

```dart
// ✅ Good: Handle repository errors
Future<List<Task>> getTasks() async {
  try {
    return await _repository.getAll();
  } on RepositoryException catch (e) {
    logger.error('Failed to load tasks: ${e.message}');
    return []; // Fallback to empty list
  }
}

// ❌ Bad: Let exceptions bubble up
Future<List<Task>> getTasks() async {
  return await _repository.getAll(); // May crash the app
}
```

---

**Related Documentation**
- [BaseEntity](./models/base_entity.md)
- [CustomWhereFilter](./models/custom_where_filter.md)
- [CustomOrder](./models/custom_order.md)
- [PaginatedList](./models/paginated_list.md)

**See Also**
- [Dependency Injection](../dependency_injection/README.md)
- [Error Handling](../errors/README.md)