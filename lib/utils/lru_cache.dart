import 'dart:collection';

/// LRU (Least Recently Used) Cache implementation
/// Efficiently caches items with a maximum size, removing least recently used items when full
class LRUCache<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, _CacheEntry<V>> _cache = LinkedHashMap();
  int _accessCounter = 0;

  LRUCache(this._maxSize) : assert(_maxSize > 0, 'Max size must be greater than 0');

  /// Get a value from the cache
  V? get(K key) {
    final entry = _cache[key];
    if (entry != null) {
      // Update access time for LRU tracking
      entry.lastAccessed = ++_accessCounter;
      return entry.value;
    }
    return null;
  }

  /// Put a value into the cache
  void put(K key, V value) {
    final existingEntry = _cache[key];

    if (existingEntry != null) {
      // Update existing entry
      existingEntry.value = value;
      existingEntry.lastAccessed = ++_accessCounter;
      return;
    }

    // Add new entry
    _cache[key] = _CacheEntry(value, ++_accessCounter);

    // Remove oldest entries if cache is full
    while (_cache.length > _maxSize) {
      _evictLeastRecentlyUsed();
    }
  }

  /// Check if key exists in cache
  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  /// Remove a specific key from cache
  V? remove(K key) {
    final entry = _cache.remove(key);
    return entry?.value;
  }

  /// Clear the entire cache
  void clear() {
    _cache.clear();
    _accessCounter = 0;
  }

  /// Get current cache size
  int get length => _cache.length;

  /// Check if cache is empty
  bool get isEmpty => _cache.isEmpty;

  /// Check if cache is full
  bool get isFull => _cache.length >= _maxSize;

  /// Get all keys (for debugging)
  Iterable<K> get keys => _cache.keys;

  /// Remove the least recently used entry
  void _evictLeastRecentlyUsed() {
    if (_cache.isEmpty) return;

    K? lruKey;
    int oldestAccess = _accessCounter + 1;

    for (final entry in _cache.entries) {
      if (entry.value.lastAccessed < oldestAccess) {
        oldestAccess = entry.value.lastAccessed;
        lruKey = entry.key;
      }
    }

    if (lruKey != null) {
      _cache.remove(lruKey);
    }
  }

  /// Get cache statistics
  CacheStats get stats => CacheStats(
        size: _cache.length,
        maxSize: _maxSize,
        isFull: isFull,
      );
}

/// Internal cache entry with access time tracking
class _CacheEntry<V> {
  V value;
  int lastAccessed;

  _CacheEntry(this.value, this.lastAccessed);
}

/// Cache statistics for monitoring and debugging
class CacheStats {
  final int size;
  final int maxSize;
  final bool isFull;

  CacheStats({
    required this.size,
    required this.maxSize,
    required this.isFull,
  });

  double get utilizationRatio => size / maxSize;

  @override
  String toString() {
    return 'CacheStats(size: $size/$maxSize, utilization: ${(utilizationRatio * 100).toStringAsFixed(1)}%)';
  }
}
