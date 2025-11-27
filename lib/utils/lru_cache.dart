import 'dart:collection';

class LRUCache<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();

  LRUCache(this._maxSize) : assert(_maxSize > 0, 'Max size must be greater than 0');

  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  void put(K key, V value) {
    _cache.remove(key);
    _cache[key] = value;
    if (_cache.length > _maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  V? remove(K key) {
    return _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  int get length => _cache.length;

  bool get isEmpty => _cache.isEmpty;

  bool get isFull => _cache.length >= _maxSize;

  Iterable<K> get keys => _cache.keys;

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
