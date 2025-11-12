# CollectionUtils

## Overview

`CollectionUtils` provides static utility methods for comparing collections and detecting changes in complex data structures. It offers type-safe operations for lists, sets, maps, and individual values with proper null handling and deep comparison capabilities.

## Features

- 🔍 **Deep Collection Comparison** - Compare lists and sets by their contents, not just references
- ⚡ **Change Detection** - Efficiently detect changes between complex data structures
- 🛡️ **Null-Safe Operations** - All methods handle null values gracefully
- 🎯 **Type Safety** - Generic methods with compile-time type checking
- 🔄 **Map Change Tracking** - Comprehensive map comparison with nested collection support
- 📊 **Performance Optimized** - Efficient algorithms for large collections

## Core Methods

### List Comparison

```dart
/// Compares two lists for equality by checking their contents
static bool areListsEqual<T>(List<T>? list1, List<T>? list2);
```

### Set Comparison

```dart
/// Compares two sets for equality by checking their contents
static bool areSetsEqual<T>(Set<T>? set1, Set<T>? set2);
```

### Value Change Detection

```dart
/// Compares two values for equality, handling null cases
static bool hasValueChanged<T>(T? oldValue, T? newValue);
```

### Map Change Detection

```dart
/// Checks if any value in a map has changed by comparing each value
static bool hasAnyMapValueChanged(Map<String, dynamic> oldMap, Map<String, dynamic> newMap);
```

## Usage Examples

### Basic List Comparison

```dart
class TodoListManager {
  List<String> _currentTodos = [];

  /// Check if todo list has changed
  bool hasTodosChanged(List<String> newTodos) {
    return !CollectionUtils.areListsEqual(_currentTodos, newTodos);
  }

  /// Update todos only if changed
  void updateTodos(List<String> newTodos) {
    if (hasTodosChanged(newTodos)) {
      _currentTodos = List.from(newTodos);
      _saveTodos();
      _notifyListeners();
    }
  }

  void _saveTodos() {
    // Persist todos to storage
  }

  void _notifyListeners() {
    // Notify UI of changes
  }
}
```

### Complex Object Comparison

```dart
class User {
  final String id;
  final String name;
  final List<String> tags;

  User({required this.id, required this.name, required this.tags});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class UserManager {
  List<User> _users = [];

  /// Check if user list has changed (ignoring order)
  bool hasUsersChanged(List<User> newUsers) {
    return !CollectionUtils.areListsEqual(_users, newUsers);
  }

  /// Batch update users efficiently
  Future<void> updateUsers(List<User> newUsers) async {
    if (!hasUsersChanged(newUsers)) return;

    // Detailed change analysis
    final oldUsersMap = {for (var user in _users) user.id: user};
    final newUsersMap = {for (var user in newUsers) user.id: user};

    // Find added users
    final addedUsers = newUsers.where((user) => !oldUsersMap.containsKey(user.id));
    // Find removed users
    final removedUsers = _users.where((user) => !newUsersMap.containsKey(user.id));
    // Find modified users
    final modifiedUsers = newUsers.where((newUser) {
      final oldUser = oldUsersMap[newUser.id];
      return oldUser != null && !CollectionUtils.areListsEqual(oldUser.tags, newUser.tags);
    });

    // Apply changes
    await _processUserChanges(addedUsers, removedUsers, modifiedUsers);

    _users = List.from(newUsers);
    _notifyUserListChanged();
  }

  Future<void> _processUserChanges(
    Iterable<User> added,
    Iterable<User> removed,
    Iterable<User> modified,
  ) async {
    // Process each type of change
    for (final user in added) {
      await _createUser(user);
    }

    for (final user in removed) {
      await _deleteUser(user);
    }

    for (final user in modified) {
      await _updateUser(user);
    }
  }

  Future<void> _createUser(User user) async {
    // Create user in backend
  }

  Future<void> _deleteUser(User user) async {
    // Delete user from backend
  }

  Future<void> _updateUser(User user) async {
    // Update user in backend
  }

  void _notifyUserListChanged() {
    // Notify listeners
  }
}
```

### Configuration Change Detection

```dart
class AppConfig {
  final bool darkMode;
  final String language;
  final List<String> enabledFeatures;
  final Set<String> permissions;

  AppConfig({
    required this.darkMode,
    required this.language,
    required this.enabledFeatures,
    required this.permissions,
  });

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'language': language,
      'enabledFeatures': enabledFeatures,
      'permissions': permissions,
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      darkMode: map['darkMode'] ?? false,
      language: map['language'] ?? 'en',
      enabledFeatures: List<String>.from(map['enabledFeatures'] ?? []),
      permissions: Set<String>.from(map['permissions'] ?? []),
    );
  }
}

class SettingsManager {
  AppConfig _currentConfig = AppConfig(
    darkMode: false,
    language: 'en',
    enabledFeatures: [],
    permissions: {},
  );

  /// Check if configuration has changed
  bool hasConfigurationChanged(AppConfig newConfig) {
    return CollectionUtils.hasAnyMapValueChanged(
      _currentConfig.toMap(),
      newConfig.toMap(),
    );
  }

  /// Apply configuration changes
  Future<void> applyConfiguration(AppConfig newConfig) async {
    if (!hasConfigurationChanged(newConfig)) return;

    final oldConfig = _currentConfig;
    _currentConfig = newConfig;

    // Apply specific changes
    if (oldConfig.darkMode != newConfig.darkMode) {
      await _applyThemeChange(newConfig.darkMode);
    }

    if (oldConfig.language != newConfig.language) {
      await _applyLanguageChange(newConfig.language);
    }

    if (!CollectionUtils.areListsEqual(oldConfig.enabledFeatures, newConfig.enabledFeatures)) {
      await _applyFeaturesChange(newConfig.enabledFeatures);
    }

    if (!CollectionUtils.areSetsEqual(oldConfig.permissions, newConfig.permissions)) {
      await _applyPermissionsChange(newConfig.permissions);
    }

    await _saveConfiguration();
    _notifyConfigurationChanged();
  }

  Future<void> _applyThemeChange(bool darkMode) async {
    // Apply theme changes
  }

  Future<void> _applyLanguageChange(String language) async {
    // Apply language changes
  }

  Future<void> _applyFeaturesChange(List<String> features) async {
    // Apply feature changes
  }

  Future<void> _applyPermissionsChange(Set<String> permissions) async {
    // Apply permission changes
  }

  Future<void> _saveConfiguration() async {
    // Persist configuration
  }

  void _notifyConfigurationChanged() {
    // Notify listeners
  }
}
```

### Form State Management

```dart
class FormField<T> {
  final String key;
  T value;
  List<T>? availableOptions;
  bool isDirty = false;

  FormField({required this.key, required this.value, this.availableOptions});

  /// Update value and track dirty state
  void updateValue(T newValue) {
    if (CollectionUtils.hasValueChanged(value, newValue)) {
      value = newValue;
      isDirty = true;
    }
  }

  /// Reset dirty state
  void markClean() {
    isDirty = false;
  }
}

class DynamicForm {
  final Map<String, FormField> _fields = {};

  /// Add field to form
  void addField<T>(String key, T initialValue, {List<T>? options}) {
    _fields[key] = FormField(key: key, value: initialValue, availableOptions: options);
  }

  /// Update field value
  void updateField<T>(String key, T value) {
    final field = _fields[key];
    if (field != null) {
      field.updateValue(value);
    }
  }

  /// Check if form is dirty
  bool get isDirty {
    return _fields.values.any((field) => field.isDirty);
  }

  /// Get form data as map
  Map<String, dynamic> getFormData() {
    return _fields.map((key, field) => MapEntry(key, field.value));
  }

  /// Check if form data has changed from initial values
  bool hasDataChanged(Map<String, dynamic> newData) {
    return CollectionUtils.hasAnyMapValueChanged(getFormData(), newData);
  }

  /// Reset all fields
  void resetForm() {
    for (final field in _fields.values) {
      field.markClean();
    }
  }

  /// Validate form and get errors
  Map<String, String> validateForm() {
    final errors = <String, String>{};

    for (final entry in _fields.entries) {
      final key = entry.key;
      final field = entry.value;

      if (field.value == null || (field.value is String && (field.value as String).isEmpty)) {
        errors[key] = '$key is required';
      }
    }

    return errors;
  }
}
```

### Caching with Change Detection

```dart
class CacheManager<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  final Duration _defaultTtl;

  CacheManager({Duration defaultTtl = const Duration(minutes: 5)})
      : _defaultTtl = defaultTtl;

  /// Get cached item if still valid and unchanged
  T? get(String key, T newValue) {
    final entry = _cache[key];

    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) return null;
    if (CollectionUtils.hasValueChanged(entry.value, newValue)) return null;

    return entry.value;
  }

  /// Put item in cache
  void put(String key, T value, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? _defaultTtl),
    );
  }

  /// Invalidate cache entry
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Clear expired entries
  void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => now.isAfter(entry.expiresAt));
  }

  /// Check if cache contains valid entry for key
  bool contains(String key) {
    final entry = _cache[key];
    return entry != null && !DateTime.now().isAfter(entry.expiresAt);
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  CacheEntry({required this.value, required this.expiresAt});
}
```

### Real-time Data Synchronization

```dart
class DataSyncService {
  final Map<String, dynamic> _lastSyncedData = {};
  final Stream<Map<String, dynamic>> _dataStream;

  DataSyncService(this._dataStream) {
    _dataStream.listen(_handleDataUpdate);
  }

  /// Handle incoming data updates
  void _handleDataUpdate(Map<String, dynamic> newData) {
    if (CollectionUtils.hasAnyMapValueChanged(_lastSyncedData, newData)) {
      _processDataChanges(_lastSyncedData, newData);
      _lastSyncedData = Map.from(newData);
    }
  }

  /// Process specific data changes
  void _processDataChanges(Map<String, dynamic> oldData, Map<String, dynamic> newData) {
    for (final key in newData.keys) {
      final oldValue = oldData[key];
      final newValue = newData[key];

      if (oldValue is List && newValue is List) {
        if (!CollectionUtils.areListsEqual(oldValue, newValue)) {
          _handleListChange(key, oldValue as List, newValue as List);
        }
      } else if (oldValue is Set && newValue is Set) {
        if (!CollectionUtils.areSetsEqual(oldValue, newValue)) {
          _handleSetChange(key, oldValue as Set, newValue as Set);
        }
      } else if (CollectionUtils.hasValueChanged(oldValue, newValue)) {
        _handleValueChange(key, oldValue, newValue);
      }
    }
  }

  void _handleListChange(String key, List oldList, List newList) {
    // Handle list-specific changes
    print('List $key changed: $oldList -> $newList');
  }

  void _handleSetChange(String key, Set oldSet, Set newSet) {
    // Handle set-specific changes
    print('Set $key changed: $oldSet -> $newSet');
  }

  void _handleValueChange(String key, dynamic oldValue, dynamic newValue) {
    // Handle single value changes
    print('Value $key changed: $oldValue -> $newValue');
  }
}
```

## Testing Collection Utilities

### Unit Tests

```dart
void main() {
  group('CollectionUtils Tests', () {
    group('areListsEqual', () {
      test('should return true for identical lists', () {
        final list1 = [1, 2, 3];
        final list2 = [1, 2, 3];

        expect(CollectionUtils.areListsEqual(list1, list2), isTrue);
      });

      test('should return true for lists with same elements but different order', () {
        final list1 = [1, 2, 3];
        final list2 = [3, 1, 2];

        expect(CollectionUtils.areListsEqual(list1, list2), isTrue);
      });

      test('should return false for lists with different elements', () {
        final list1 = [1, 2, 3];
        final list2 = [1, 2, 4];

        expect(CollectionUtils.areListsEqual(list1, list2), isFalse);
      });

      test('should handle null lists', () {
        expect(CollectionUtils.areListsEqual(null, null), isTrue);
        expect(CollectionUtils.areListsEqual([], null), isFalse);
        expect(CollectionUtils.areListsEqual(null, []), isFalse);
      });

      test('should handle duplicate elements correctly', () {
        final list1 = [1, 2, 2, 3];
        final list2 = [1, 2, 3, 3];

        expect(CollectionUtils.areListsEqual(list1, list2), isFalse);
      });
    });

    group('areSetsEqual', () {
      test('should return true for identical sets', () {
        final set1 = {1, 2, 3};
        final set2 = {3, 1, 2};

        expect(CollectionUtils.areSetsEqual(set1, set2), isTrue);
      });

      test('should return false for sets with different elements', () {
        final set1 = {1, 2, 3};
        final set2 = {1, 2, 4};

        expect(CollectionUtils.areSetsEqual(set1, set2), isFalse);
      });

      test('should handle null sets', () {
        expect(CollectionUtils.areSetsEqual(null, null), isTrue);
        expect(CollectionUtils.areSetsEqual({}, null), isFalse);
        expect(CollectionUtils.areSetsEqual(null, {}), isFalse);
      });
    });

    group('hasValueChanged', () {
      test('should return true for different values', () {
        expect(CollectionUtils.hasValueChanged(1, 2), isTrue);
        expect(CollectionUtils.hasValueChanged('hello', 'world'), isTrue);
      });

      test('should return false for same values', () {
        expect(CollectionUtils.hasValueChanged(1, 1), isFalse);
        expect(CollectionUtils.hasValueChanged('hello', 'hello'), isFalse);
      });

      test('should handle null values correctly', () {
        expect(CollectionUtils.hasValueChanged(null, null), isFalse);
        expect(CollectionUtils.hasValueChanged(null, 1), isTrue);
        expect(CollectionUtils.hasValueChanged(1, null), isTrue);
      });
    });

    group('hasAnyMapValueChanged', () {
      test('should detect changes in simple values', () {
        final oldMap = {'name': 'John', 'age': 30};
        final newMap = {'name': 'John', 'age': 31};

        expect(CollectionUtils.hasAnyMapValueChanged(oldMap, newMap), isTrue);
      });

      test('should detect changes in lists', () {
        final oldMap = {'tags': ['a', 'b']};
        final newMap = {'tags': ['a', 'c']};

        expect(CollectionUtils.hasAnyMapValueChanged(oldMap, newMap), isTrue);
      });

      test('should detect changes in sets', () {
        final oldMap = {'permissions': {'read', 'write'}};
        final newMap = {'permissions': {'read', 'execute'}};

        expect(CollectionUtils.hasAnyMapValueChanged(oldMap, newMap), isTrue);
      });

      test('should return false for identical maps', () {
        final oldMap = {'name': 'John', 'tags': ['a', 'b']};
        final newMap = {'name': 'John', 'tags': ['b', 'a']}; // Different order

        expect(CollectionUtils.hasAnyMapValueChanged(oldMap, newMap), isFalse);
      });

      test('should handle added and removed keys', () {
        final oldMap = {'a': 1, 'b': 2};
        final newMap = {'a': 1, 'c': 3};

        expect(CollectionUtils.hasAnyMapValueChanged(oldMap, newMap), isTrue);
      });
    });
  });
}
```

### Performance Tests

```dart
void main() {
  group('CollectionUtils Performance Tests', () {
    test('should handle large lists efficiently', () {
      final stopwatch = Stopwatch()..start();

      final largeList1 = List.generate(10000, (i) => i);
      final largeList2 = List.generate(10000, (i) => i);

      stopwatch.start();
      final result = CollectionUtils.areListsEqual(largeList1, largeList2);
      stopwatch.stop();

      expect(result, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast

      print('Large list comparison took ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should handle complex nested data structures', () {
      final stopwatch = Stopwatch()..start();

      final complexMap1 = {
        'users': List.generate(1000, (i) => {'id': i, 'name': 'User $i'}),
        'settings': {'theme': 'dark', 'notifications': true},
        'tags': List.generate(100, (i) => 'tag_$i'),
      };

      final complexMap2 = Map.from(complexMap1);

      stopwatch.start();
      final result = CollectionUtils.hasAnyMapValueChanged(complexMap1, complexMap2);
      stopwatch.stop();

      expect(result, isFalse);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));

      print('Complex map comparison took ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
```

## Best Practices

### 1. Use for Performance Optimization

```dart
// ✅ Good: Check before expensive operations
if (CollectionUtils.areListsEqual(oldList, newList)) {
  return; // Skip expensive UI rebuild
}

await _updateUI(newList);
```

### 2. Handle Null Cases Gracefully

```dart
// ✅ Good: All CollectionUtils methods handle null
final hasChanged = CollectionUtils.hasValueChanged(oldConfig?.settings, newConfig?.settings);

// ❌ Bad: Manual null checking
final hasChanged = oldConfig?.settings != newConfig?.settings ||
    oldConfig?.settings?.length != newConfig?.settings?.length;
```

### 3. Use Appropriate Comparison Method

```dart
// ✅ Good: Use areListsEqual for order-independent comparison
if (CollectionUtils.areListsEqual(userTags, newTags)) {
  return;
}

// ✅ Good: Use direct comparison for order-sensitive comparison
if (listEquals(userActions, newActions)) {
  return;
}
```

### 4. Consider Performance with Large Collections

```dart
// ✅ Good: Use hasAnyMapValueChanged for partial comparison
if (!CollectionUtils.hasAnyMapValueChanged(oldData, newData, keys: ['criticalField'])) {
  // Skip full comparison if critical fields haven't changed
  return;
}
```

## Performance Considerations

### Optimization Tips

1. **Use Sets for Lookups**: Convert lists to sets for faster membership testing
2. **Early Exit**: Return early when differences are detected
3. **Cache Results**: Cache comparison results for frequently accessed data
4. **Incremental Updates**: Track changes incrementally rather than full comparisons

```dart
class OptimizedCollectionComparator {
  final Map<String, int> _listHashes = {};

  bool hasListChanged(String key, List list) {
    final currentHash = _calculateListHash(list);
    final previousHash = _listHashes[key];

    if (previousHash == null) {
      _listHashes[key] = currentHash;
      return true;
    }

    if (previousHash != currentHash) {
      _listHashes[key] = currentHash;
      return true;
    }

    return false;
  }

  int _calculateListHash(List list) {
    return list.fold(0, (hash, item) => hash ^ item.hashCode);
  }
}
```

---

**Related Documentation**
- [Async Utils](./ASYNC_UTILS.md)
- [LRU Cache](./LRU_CACHE.md)
- [Error Handling](../errors/README.md)