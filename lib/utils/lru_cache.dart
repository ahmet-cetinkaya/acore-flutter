import 'dart:collection';

/// LRU (Least Recently Used) Cache implementation
/// Optimized cache with O(1) get/put operations using LinkedHashMap
class LRUCache<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();

  LRUCache(this._maxSize) : assert(_maxSize > 0, 'Max size must be greater than 0');

  /// Get a value from the cache and mark it as most recently used.
  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // Move to the end (most recently used)
    }
    return value;
  }

  /// Put a value into the cache. If the key exists, it's moved to the end.
  /// If the cache is full, the least recently used item is removed.
  void put(K key, V value) {
    _cache.remove(key);
    _cache[key] = value;
    if (_cache.length > _maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Check if key exists in cache
  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  /// Remove a specific key from cache
  V? remove(K key) {
    return _cache.remove(key);
  }

  /// Clear the entire cache
  void clear() {
    _cache.clear();
  }

  /// Get current cache size
  int get length => _cache.length;

  /// Check if cache is empty
  bool get isEmpty => _cache.isEmpty;

  /// Check if cache is full
  bool get isFull => _cache.length >= _maxSize;

  /// Get all keys (for debugging)
  Iterable<K> get keys => _cache.keys;

  /// Get cache statistics
  CacheStats get stats => CacheStats(
        size: _cache.length,
        maxSize: _maxSize,
        isFull: isFull,
      );
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
