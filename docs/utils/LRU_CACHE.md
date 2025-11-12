# LRU Cache Utility

## Overview

The `LRUCache` is a generic, efficient implementation of a Least Recently Used (LRU) cache that automatically removes the least recently accessed items when the cache reaches its maximum capacity.

## Features

- ⚡ **O(1) Access Time** - Constant time complexity for get and put operations
- 🔄 **Automatic Eviction** - Removes least recently used items when cache is full
- 📊 **Cache Statistics** - Built-in monitoring and performance metrics
- 🎯 **Type Safe** - Generic implementation with compile-time type checking
- 🧹 **Memory Management** - Efficient memory usage with configurable size limits

## API Reference

### Constructor

```dart
LRUCache<K, V>(int maxSize)
```

- `maxSize`: Maximum number of items the cache can hold (must be > 0)

### Methods

#### `V? get(K key)`
Retrieves a value from the cache and updates its access time.
- Returns `null` if key doesn't exist
- Updates LRU order on access

#### `void put(K key, V value)`
Stores a value in the cache:
- Updates existing entries
- Evicts oldest entries if cache is full
- Updates access time for LRU tracking

#### `bool containsKey(K key)`
Checks if a key exists in the cache.

#### `V? remove(K key)`
Removes a specific key and returns its value.

#### `void clear()`
Removes all items from the cache and resets the access counter.

### Properties

- `int length` - Current number of items in cache
- `bool isEmpty` - True if cache has no items
- `bool isFull` - True if cache has reached maximum capacity
- `Iterable<K> keys` - All keys currently in cache (for debugging)

### `CacheStats get stats`
Returns cache statistics including:
- `size` - Current cache size
- `maxSize` - Maximum cache capacity
- `isFull` - Whether cache is full
- `utilizationRatio` - Size as percentage of max capacity

## Usage Examples

### Basic Usage

```dart
// Create a cache that holds up to 100 items
final cache = LRUCache<String, String>(100);

// Add items
cache.put('key1', 'value1');
cache.put('key2', 'value2');

// Get items
final value = cache.get('key1'); // Returns 'value1'
print(cache.containsKey('key1')); // true

// Check cache statistics
final stats = cache.stats;
print('Cache utilization: ${stats.utilizationRatio * 100}%');
```

### Performance Monitoring

```dart
final cache = LRUCache<int, ComplexObject>(50);

// ... use cache ...

final stats = cache.stats;
print('Cache performance:');
print('  Size: ${stats.size}/${stats.maxSize}');
print('  Utilization: ${stats.utilizationRatio.toStringAsFixed(1)}%');
print('  Is full: ${stats.isFull}');
```

### Memory Management

```dart
// Cache with automatic eviction
final cache = LRUCache<String, LargeDataObject>(10);

// Fill cache beyond capacity
for (int i = 0; i < 15; i++) {
  cache.put('key$i', LargeDataObject(i));
}

// Only 10 most recently used items remain
print(cache.length); // 10
print(cache.stats.utilizationRatio); // 1.0 (100%)
```

## Implementation Details

### Algorithm
- Uses `LinkedHashMap` for O(1) access and insertion
- Maintains an access counter for LRU tracking
- Evicts the item with the lowest access time when full

### Memory Efficiency
- Each cache entry stores: value, last access time
- Access counter uses integer arithmetic for minimal overhead
- Automatic cleanup prevents memory leaks

### Thread Safety
- **Not thread-safe** - use appropriate synchronization for multi-threaded scenarios
- Designed for single-threaded Flutter UI context

## Performance Characteristics

| Operation | Time Complexity | Space Complexity |
|-----------|----------------|------------------|
| get() | O(1) | O(1) |
| put() | O(1) (amortized) | O(1) |
| containsKey() | O(1) | O(1) |
| remove() | O(1) | O(1) |
| clear() | O(n) | O(1) |

## Use Cases

- **Image Caching** - Cache decoded images with automatic eviction
- **API Response Caching** - Cache network responses with size limits
- **Computation Results** - Cache expensive calculation results
- **Database Query Caching** - Cache frequently accessed database records
- **Configuration Caching** - Cache parsed configuration files

## Best Practices

1. **Choose appropriate cache size** based on memory constraints
2. **Monitor cache utilization** using the `stats` property
3. **Clear cache when memory pressure is detected**
4. **Use cache for read-heavy scenarios** with predictable access patterns
5. **Consider cache invalidation strategies** for data that changes frequently