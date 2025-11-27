class CollectionUtils {
  static bool areListsEqual<T>(List<T>? list1, List<T>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    return Set<T>.from(list1).containsAll(list2);
  }

  static bool areSetsEqual<T>(Set<T>? set1, Set<T>? set2) {
    if (set1 == null && set2 == null) return true;
    if (set1 == null || set2 == null) return false;
    if (set1.length != set2.length) return false;
    return set1.containsAll(set2);
  }

  static bool hasValueChanged<T>(T? oldValue, T? newValue) {
    if (oldValue == null && newValue == null) return false;
    if (oldValue == null || newValue == null) return true;
    return oldValue != newValue;
  }

  static bool hasAnyMapValueChanged(Map<String, dynamic> oldMap, Map<String, dynamic> newMap) {
    final allKeys = {...oldMap.keys, ...newMap.keys};

    for (final key in allKeys) {
      final oldValue = oldMap[key];
      final newValue = newMap[key];

      if (oldValue is List && newValue is List) {
        if (!areListsEqual(oldValue, newValue)) return true;
      } else if (oldValue is Set && newValue is Set) {
        if (!areSetsEqual(oldValue, newValue)) return true;
      } else {
        if (hasValueChanged(oldValue, newValue)) return true;
      }
    }

    return false;
  }
}
