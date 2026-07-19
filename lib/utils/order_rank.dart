class OrderRank {
  static const double minOrder = 0;
  static const double maxOrder = 1000000;
  static const double initialStep = 1000;
  static const double minimumOrderGap = 1;

  // Calculate midpoint between two orders
  static double between(double beforeOrder, double afterOrder) {
    if (beforeOrder >= afterOrder || (afterOrder - beforeOrder) < minimumOrderGap) {
      throw RankGapTooSmallException();
    }
    final result = beforeOrder + ((afterOrder - beforeOrder) / 2);
    return result;
  }

  // Get order value for first position
  static double first() {
    return initialStep;
  }

  // Get next available order after the given one
  static double after(double currentOrder) {
    if (currentOrder >= maxOrder - initialStep) {
      throw RankGapTooSmallException();
    }
    final result = currentOrder + initialStep;
    return result;
  }

  // Get next available order before the given one
  static double before(double currentOrder) {
    if (currentOrder <= initialStep) {
      return currentOrder / 2;
    }
    final result = currentOrder - initialStep;
    return result;
  }

  /// Computes a gap-safe order value that positions an item strictly between
  /// [beforeOrder] and [afterOrder].
  ///
  /// Both bounds are optional:
  /// - [beforeOrder] `null` means "insert at the very beginning" (before the
  ///   first sibling with order [afterOrder]).
  /// - [afterOrder] `null` means "insert at the very end" (after the last
  ///   sibling with order [beforeOrder]).
  /// - Both `null` means the list is empty; returns [initialStep].
  ///
  /// Throws [RankGapTooSmallException] when the two neighbors are too close (or
  /// equal/inverted) to fit a value between them. Callers are expected to catch
  /// this and renormalize the whole sibling set, then retry positionally.
  static double neighborRank({double? beforeOrder, double? afterOrder}) {
    if (beforeOrder == null && afterOrder == null) {
      return initialStep;
    }
    if (beforeOrder == null) {
      return before(afterOrder!);
    }
    if (afterOrder == null) {
      return after(beforeOrder);
    }
    // Both bounds present - place strictly between them.
    return between(beforeOrder, afterOrder);
  }

  // Find target order for moving an item to a specific position
  static double getTargetOrder(List<double> existingOrders, int targetPosition) {
    if (existingOrders.isEmpty) {
      return initialStep;
    }

    existingOrders.sort();

    if (targetPosition <= 0) {
      final firstOrder = existingOrders.first;
      return firstOrder - initialStep;
    }

    if (targetPosition >= existingOrders.length) {
      final result = existingOrders.last + initialStep * 2;
      return result;
    }

    final beforeOrder = existingOrders[targetPosition - 1];
    final afterOrder = existingOrders[targetPosition];
    try {
      final result = between(beforeOrder, afterOrder);
      return result;
    } catch (e) {
      if (targetPosition < existingOrders.length - 1) {
        final result = afterOrder - (minimumOrderGap / 2);
        return result;
      } else {
        final result = beforeOrder + initialStep;
        return result;
      }
    }
  }

  /// Returns `true` when [orders] contains any duplicate values or any adjacent
  /// gap smaller than [minimumOrderGap] once sorted, or any non-positive value.
  /// Such a set can no longer accept reliable midpoint insertions and must be
  /// renormalized before the next reorder.
  static bool needsNormalization(List<double> orders) {
    if (orders.isEmpty) return false;

    final sorted = List<double>.from(orders)..sort();
    if (sorted.first <= minOrder) return true;

    for (int i = 1; i < sorted.length; i++) {
      if ((sorted[i] - sorted[i - 1]) < minimumOrderGap) {
        return true;
      }
    }
    return false;
  }

  // Normalize all orders when gaps get too small
  static List<double> normalize(List<double> currentOrders) {
    if (currentOrders.isEmpty) return [];

    List<double> newOrders = [];
    double step = initialStep;

    for (int i = 0; i < currentOrders.length; i++) {
      newOrders.add(step);
      step += initialStep;
    }

    return newOrders;
  }
}

class RankGapTooSmallException implements Exception {
  final String message = 'Reordering needed - gaps between items too small';
}
