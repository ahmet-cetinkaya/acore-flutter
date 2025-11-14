# Storage

## Overview

The storage module provides a type-safe abstraction layer for key-value data persistence across different platforms. It offers a simple, consistent API for storing and retrieving application data while handling platform-specific implementations such as SharedPreferences, UserDefaults, and browser localStorage.

## Features

- 🔑 **Type-Safe Operations** - Generic storage with compile-time type safety
- 💾 **Cross-Platform Support** - Works on Android, iOS, Web, and Desktop
- 🔄 **Async Operations** - Non-blocking storage operations for better performance
- 🧹 **Simple API** - Minimal interface with just three core methods
- 🎯 **Dependency Injection Ready** - Easy to mock and test
- 📱 **Platform Optimizations** - Uses native storage solutions on each platform

## Core Interface

### StorageAbstract

```dart
abstract class StorageAbstract {
  /// Get stored value by key
  T? getValue<T>(String key);

  /// Store value by key
  Future<void> setValue<T>(String key, T value);

  /// Remove stored value by key
  Future<void> removeValue(String key);
}
```

## Usage Examples

### Basic Storage Operations

```dart
class AppSettings {
  final StorageAbstract _storage;

  AppSettings(this._storage);

  // Getters with default values
  String get theme => _storage.getValue<String>('theme') ?? 'light';
  String get language => _storage.getValue<String>('language') ?? 'en';
  bool get notificationsEnabled => _storage.getValue<bool>('notifications_enabled') ?? true;
  int get maxFileSize => _storage.getValue<int>('max_file_size') ?? 10 * 1024 * 1024; // 10MB

  // Setters
  Future<void> setTheme(String theme) async {
    await _storage.setValue('theme', theme);
  }

  Future<void> setLanguage(String language) async {
    await _storage.setValue('language', language);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.setValue('notifications_enabled', enabled);
  }

  Future<void> setMaxFileSize(int size) async {
    await _storage.setValue('max_file_size', size);
  }
}
```

### User Preferences Management

```dart
class UserPreferences {
  final StorageAbstract _storage;

  UserPreferences(this._storage);

  /// Save user preferences
  Future<void> saveUserPreferences(UserPreferencesData prefs) async {
    await _storage.setValue('user_name', prefs.name);
    await _storage.setValue('user_email', prefs.email);
    await _storage.setValue('user_avatar', prefs.avatarUrl);
    await _storage.setValue('theme_preference', prefs.theme);
    await _storage.setValue('auto_save', prefs.autoSave);
    await _storage.setValue('privacy_analytics', prefs.privacyAnalytics);
  }

  /// Load user preferences
  Future<UserPreferencesData> loadUserPreferences() async {
    return UserPreferencesData(
      name: _storage.getValue<String>('user_name') ?? '',
      email: _storage.getValue<String>('user_email') ?? '',
      avatarUrl: _storage.getValue<String>('user_avatar') ?? '',
      theme: _storage.getValue<String>('theme_preference') ?? 'system',
      autoSave: _storage.getValue<bool>('auto_save') ?? true,
      privacyAnalytics: _storage.getValue<bool>('privacy_analytics') ?? false,
    );
  }

  /// Clear all user preferences
  Future<void> clearUserPreferences() async {
    await _storage.removeValue('user_name');
    await _storage.removeValue('user_email');
    await _storage.removeValue('user_avatar');
    await _storage.removeValue('theme_preference');
    await _storage.removeValue('auto_save');
    await _storage.removeValue('privacy_analytics');
  }
}

class UserPreferencesData {
  final String name;
  final String email;
  final String avatarUrl;
  final String theme;
  final bool autoSave;
  final bool privacyAnalytics;

  const UserPreferencesData({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.theme,
    required this.autoSave,
    required this.privacyAnalytics,
  });
}
```

### Application State Management

```dart
class AppStateManager {
  final StorageAbstract _storage;

  AppStateManager(this._storage);

  /// Save application state
  Future<void> saveAppState(AppState state) async {
    await _storage.setValue('last_active_tab', state.lastActiveTab);
    await _storage.setValue('window_bounds', state.windowBounds.toJson());
    await _storage.setValue('last_sync_time', state.lastSyncTime.toIso8601String());
    await _storage.setValue('offline_mode', state.offlineMode);
    await _storage.setValue('user_session_token', state.sessionToken);
    await _storage.setValue('remember_me', state.rememberMe);
  }

  /// Load application state
  Future<AppState> loadAppState() async {
    final boundsJson = _storage.getValue<Map<String, dynamic>>('window_bounds');
    final lastSyncTimeString = _storage.getValue<String>('last_sync_time');

    return AppState(
      lastActiveTab: _storage.getValue<int>('last_active_tab') ?? 0,
      windowBounds: boundsJson != null ? WindowBounds.fromJson(boundsJson) : WindowBounds.default,
      lastSyncTime: lastSyncTimeString != null
        ? DateTime.parse(lastSyncTimeString)
        : DateTime.now(),
      offlineMode: _storage.getValue<bool>('offline_mode') ?? false,
      sessionToken: _storage.getValue<String>('user_session_token'),
      rememberMe: _storage.getValue<bool>('remember_me') ?? false,
    );
  }

  /// Clear sensitive state
  Future<void> clearSensitiveState() async {
    await _storage.removeValue('user_session_token');
    await _storage.removeValue('remember_me');
  }
}

class AppState {
  final int lastActiveTab;
  final WindowBounds windowBounds;
  final DateTime lastSyncTime;
  final bool offlineMode;
  final String? sessionToken;
  final bool rememberMe;

  const AppState({
    required this.lastActiveTab,
    required this.windowBounds,
    required this.lastSyncTime,
    required this.offlineMode,
    this.sessionToken,
    required this.rememberMe,
  });
}

class WindowBounds {
  final double width;
  final double height;
  final double x;
  final double y;

  const WindowBounds({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
  });

  static const WindowBounds default = WindowBounds(
    width: 800,
    height: 600,
    x: 100,
    y: 100,
  );

  Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
    'x': x,
    'y': y,
  };

  factory WindowBounds.fromJson(Map<String, dynamic> json) {
    return WindowBounds(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}
```

### Cache Management

```dart
class CacheManager {
  final StorageAbstract _storage;
  final Duration _defaultTtl;
  final Map<String, DateTime> _cacheTimestamps;

  CacheManager(this._storage, {Duration defaultTtl = const Duration(hours: 1)})
      : _defaultTtl = defaultTtl,
        _cacheTimestamps = {};

  /// Store data with expiration
  Future<void> setWithExpiration<T>(
    String key,
    T value, {
    Duration? ttl,
  }) async {
    final expirationTime = DateTime.now().add(ttl ?? _defaultTtl);
    final cacheEntry = CacheEntry<T>(
      value: value,
      expirationTime: expirationTime,
    );

    await _storage.setValue(key, cacheEntry.toJson());
    _cacheTimestamps[key] = expirationTime;
  }

  /// Retrieve cached data
  T? getWithExpiration<T>(String key) {
    final cacheJson = _storage.getValue<Map<String, dynamic>>(key);
    if (cacheJson == null) return null;

    try {
      final cacheEntry = CacheEntry<T>.fromJson(cacheJson);

      if (DateTime.now().isAfter(cacheEntry.expirationTime)) {
        // Cache expired, remove it
        removeExpired(key);
        return null;
      }

      return cacheEntry.value;
    } catch (e) {
      // Invalid cache format, remove it
      removeExpired(key);
      return null;
    }
  }

  /// Check if key exists and is not expired
  bool isValidKey<T>(String key) {
    final expirationTime = _cacheTimestamps[key];
    if (expirationTime == null) return false;

    if (DateTime.now().isAfter(expirationTime)) {
      removeExpired(key);
      return false;
    }

    return true;
  }

  /// Remove expired entries
  Future<void> cleanupExpired() async {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.isAfter(entry.value)) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      await _storage.removeValue(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Remove specific key
  Future<void> remove(String key) async {
    await _storage.removeValue(key);
    _cacheTimestamps.remove(key);
  }

  /// Remove expired entry (internal helper)
  void removeExpired(String key) {
    _storage.removeValue(key);
    _cacheTimestamps.remove(key);
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime expirationTime;

  CacheEntry({
    required this.value,
    required this.expirationTime,
  });

  Map<String, dynamic> toJson() => {
    'value': value,
    'expiration_time': expirationTime.toIso8601String(),
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      value: json['value'] as T,
      expirationTime: DateTime.parse(json['expiration_time'] as String),
    );
  }
}
```

### Recent Items Management

```dart
class RecentItemsManager<T> {
  final StorageAbstract _storage;
  final String _storageKey;
  final int _maxItems;

  RecentItemsManager({
    required StorageAbstract storage,
    required String storageKey,
    int maxItems = 10,
  }) : _storage = storage,
       _storageKey = storageKey,
       _maxItems = maxItems;

  /// Add item to recent list
  Future<void> addItem(T item) async {
    final items = await getRecentItems();

    // Remove if already exists
    items.removeWhere((existingItem) => existingItem.toString() == item.toString());

    // Add to beginning
    items.insert(0, item);

    // Limit to max items
    if (items.length > _maxItems) {
      items.removeRange(_maxItems, items.length);
    }

    await _saveRecentItems(items);
  }

  /// Get recent items list
  Future<List<T>> getRecentItems() async {
    final itemsJson = _storage.getValue<List<dynamic>>(_storageKey);
    if (itemsJson == null) return [];

    try {
      return itemsJson
          .map((itemJson) => _deserializeItem(itemJson))
          .whereType<T>()
          .toList();
    } catch (e) {
      // Invalid format, clear storage
      await _storage.removeValue(_storageKey);
      return [];
    }
  }

  /// Clear recent items
  Future<void> clearRecentItems() async {
    await _storage.removeValue(_storageKey);
  }

  /// Remove specific item
  Future<void> removeItem(T item) async {
    final items = await getRecentItems();
    items.removeWhere((existingItem) => existingItem.toString() == item.toString());
    await _saveRecentItems(items);
  }

  Future<void> _saveRecentItems(List<T> items) async {
    final itemsJson = items.map((item) => _serializeItem(item)).toList();
    await _storage.setValue(_storageKey, itemsJson);
  }

  dynamic _serializeItem(T item) {
    // Override in subclasses for custom serialization
    if (item is Map) {
      return item;
    }
    return item.toString();
  }

  T _deserializeItem(dynamic json) {
    // Override in subclasses for custom deserialization
    if (json is T) {
      return json;
    }
    // Default implementation - may not work for complex types
    throw Exception('Cannot deserialize item of type $T');
  }
}

// Example implementation for string recent items
class RecentFilesManager extends RecentItemsManager<String> {
  RecentFilesManager({
    required StorageAbstract storage,
    int maxItems = 10,
  }) : super(
    storage: storage,
    storageKey: 'recent_files',
    maxItems: maxItems,
  );
}
```

## Storage Implementation Examples

### SharedPreferences Implementation (Android)

```dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStorage implements StorageAbstract {
  final SharedPreferences _prefs;

  SharedPreferencesStorage(this._prefs);

  @override
  T? getValue<T>(String key) {
    try {
      if (T == String) {
        return _prefs.getString(key) as T?;
      } else if (T == int) {
        return _prefs.getInt(key) as T?;
      } else if (T == double) {
        return _prefs.getDouble(key) as T?;
      } else if (T == bool) {
        return _prefs.getBool(key) as T?;
      } else if (T == List<String>) {
        return _prefs.getStringList(key) as T?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setValue<T>(String key, T value) async {
    try {
      if (value == null) {
        await _prefs.remove(key);
      } else if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      } else {
        // For complex types, serialize to JSON
        final jsonString = jsonEncode(value);
        await _prefs.setString(key, jsonString);
      }
    } catch (e) {
      throw StorageException('Failed to set value', key, e);
    }
  }

  @override
  Future<void> removeValue(String key) async {
    await _prefs.remove(key);
  }
}
```

### Browser Storage Implementation (Web)

```dart
import 'dart:convert';

class BrowserStorage implements StorageAbstract {
  final html.Storage _storage;

  BrowserStorage() : _storage = html.window.localStorage;

  @override
  T? getValue<T>(String key) {
    try {
      final value = _storage[key];
      if (value == null) return null;

      if (T == String) {
        return value as T?;
      } else {
        // Try to deserialize from JSON
        return jsonDecode(value) as T?;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setValue<T>(String key, T value) async {
    try {
      String serializedValue;

      if (value == null) {
        _storage.remove(key);
        return;
      } else if (value is String) {
        serializedValue = value;
      } else {
        serializedValue = jsonEncode(value);
      }

      _storage[key] = serializedValue;
    } catch (e) {
      throw StorageException('Failed to set value', key, e);
    }
  }

  @override
  Future<void> removeValue(String key) async {
    _storage.remove(key);
  }
}
```

## Testing Storage Operations

### Mock Implementation

```dart
class MockStorage implements StorageAbstract {
  final Map<String, dynamic> _storage = {};
  final Map<String, DateTime> _timestamps = {};

  @override
  T? getValue<T>(String key) {
    return _storage[key] as T?;
  }

  @override
  Future<void> setValue<T>(String key, T value) async {
    _storage[key] = value;
    _timestamps[key] = DateTime.now();
  }

  @override
  Future<void> removeValue(String key) async {
    _storage.remove(key);
    _timestamps.remove(key);
  }

  // Test helper methods
  DateTime? getTimestamp(String key) => _timestamps[key];
  void clear() {
    _storage.clear();
    _timestamps.clear();
  }
}
```

### Unit Testing

```dart
void main() {
  group('AppSettings Tests', () {
    late AppSettings appSettings;
    late MockStorage mockStorage;

    setUp(() {
      mockStorage = MockStorage();
      appSettings = AppSettings(mockStorage);
    });

    test('should return default theme when not set', () {
      expect(appSettings.theme, equals('light'));
    });

    test('should set and get theme correctly', () async {
      // Act
      await appSettings.setTheme('dark');

      // Assert
      expect(appSettings.theme, equals('dark'));
    });

    test('should handle complex objects', () async {
      // Arrange
      final prefs = UserPreferencesData(
        name: 'John Doe',
        email: 'john@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        theme: 'dark',
        autoSave: true,
        privacyAnalytics: false,
      );
      final userPrefs = UserPreferences(mockStorage);

      // Act
      await userPrefs.saveUserPreferences(prefs);

      // Assert
      final loadedPrefs = await userPrefs.loadUserPreferences();
      expect(loadedPrefs.name, equals('John Doe'));
      expect(loadedPrefs.email, equals('john@example.com'));
      expect(loadedPrefs.theme, equals('dark'));
    });

    test('should remove values correctly', () async {
      // Arrange
      await appSettings.setNotificationsEnabled(false);
      expect(appSettings.notificationsEnabled, isFalse);

      // Act
      await mockStorage.removeValue('notifications_enabled');

      // Assert
      expect(appSettings.notificationsEnabled, isTrue); // Returns default
    });
  });
}
```

## Best Practices

### 1. Use Type Safety

```dart
// ✅ Good: Type-safe operations
await storage.setValue('user_age', 25);
final age = storage.getValue<int>('user_age');

// ❌ Bad: Untyped operations
await storage.setValue('user_age', '25'); // String instead of int
final age = storage.getValue('user_age'); // No type safety
```

### 2. Handle Null Values

```dart
// ✅ Good: Use default values
final theme = storage.getValue<String>('theme') ?? 'light';

// ✅ Good: Check for null before using
final token = storage.getValue<String>('auth_token');
if (token != null) {
  // Use token
  authenticate(token);
}

// ❌ Bad: Assume value exists
final token = storage.getValue<String>('auth_token')!;
authenticate(token); // May throw if null
```

### 3. Use Meaningful Keys

```dart
// ✅ Good: Descriptive keys
await storage.setValue('user_profile_name', 'John');
await storage.setValue('app_last_sync_time', '2023-12-01T10:00:00Z');

// ❌ Bad: Vague keys
await storage.setValue('data1', 'John');
await storage.setValue('t', '2023-12-01T10:00:00Z');
```

### 4. Implement Proper Error Handling

```dart
// ✅ Good: Handle exceptions
try {
  await storage.setValue('large_data', data);
} on StorageException catch (e) {
  logger.error('Storage operation failed', e);
  // Fallback handling
}

// ❌ Bad: Ignore exceptions
await storage.setValue('large_data', data); // May throw silently
```

---

**Related Documentation**

- [File Services](../file/README.md)
- [Dependency Injection](../dependency_injection/README.md)
- [Error Handling](../errors/README.md)
