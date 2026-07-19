/// Utilities for computing collision-safe fractional `order` values used to
/// persist a user-defined custom ordering of items (drag-and-drop reordering).
///
/// The core idea: items carry a `double order`; inserting between two items
/// takes the midpoint of their orders. Repeated midpoint insertions eventually
/// collapse the gap below [minimumOrderGap], at which point the whole set must
/// be renormalized to clean [initialStep] multiples. [needsNormalization]
/// detects that state; [neighborRank] computes a single gap-safe insertion.
class OrderRank {
  /// Smallest legal order value. Values at or below this are treated as
  /// invalid/uninitialized and force a renormalization.
  static const double minOrder = 0;

  /// Largest order value before appending must renormalize to avoid overflow.
  static const double maxOrder = 1000000;

  /// Default spacing between consecutive items after normalization.
  static const double initialStep = 1000;

  /// Minimum spacing two neighbors must have for a midpoint to be insertable.
  static const double minimumOrderGap = 1;

  /// Absolute tolerance below which a positive order is considered effectively
  /// zero (uninitialized / precision-collapsed) and needs normalization.
  static const double nearZeroTolerance = 1e-6;

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
  /// Throws [InvalidNeighborOrderException] when `beforeOrder >= afterOrder`
  /// (the caller supplied an inverted/degenerate pair — a programming error,
  /// distinct from the data-driven gap-too-small case).
  ///
  /// Throws [RankGapTooSmallException] when the two neighbors are correctly
  /// ordered but too close to fit a value between them. Callers are expected to
  /// catch this and renormalize the whole sibling set, then retry positionally.
  static double neighborRank({double? beforeOrder, double? afterOrder}) {
    if (beforeOrder == null && afterOrder == null) {
      return initialStep;
    }
    if (beforeOrder == null) {
      return _before(afterOrder!);
    }
    if (afterOrder == null) {
      return _after(beforeOrder);
    }
    if (beforeOrder >= afterOrder) {
      throw InvalidNeighborOrderException(beforeOrder, afterOrder);
    }
    if ((afterOrder - beforeOrder) < minimumOrderGap) {
      throw RankGapTooSmallException();
    }
    return beforeOrder + ((afterOrder - beforeOrder) / 2);
  }

  /// Whether a value cannot be inserted between [beforeOrder] and [afterOrder]
  /// without first renormalizing. `true` when the neighbors are inverted/equal,
  /// too close together, or when appending ([afterOrder] `null`) would overflow
  /// past [maxOrder]. Open-ended lower insertions (before the first item) are
  /// always fittable via bisection toward zero.
  static bool cannotFit({double? beforeOrder, double? afterOrder}) {
    // Appending at the tail: only unfittable if we'd overflow maxOrder.
    if (afterOrder == null) {
      if (beforeOrder == null) return false;
      return beforeOrder >= maxOrder - initialStep;
    }
    // Prepending at the head is always fittable (bisect toward zero).
    if (beforeOrder == null) return false;
    // Both present: unfittable if inverted/equal or gap too small.
    return (afterOrder - beforeOrder) < minimumOrderGap;
  }

  /// Returns `true` when [orders] can no longer accept reliable midpoint
  /// insertions and should be renormalized: any non-positive/near-zero value,
  /// any duplicate, any adjacent gap below [minimumOrderGap], or any value at
  /// or beyond [maxOrder].
  static bool needsNormalization(List<double> orders) {
    if (orders.isEmpty) return false;

    final sorted = List<double>.from(orders)..sort();
    if (sorted.first <= minOrder || sorted.first.abs() < nearZeroTolerance) return true;
    if (sorted.last >= maxOrder) return true;

    for (int i = 1; i < sorted.length; i++) {
      if ((sorted[i] - sorted[i - 1]) < minimumOrderGap) {
        return true;
      }
    }
    return false;
  }

  /// Returns `true` when any order is effectively zero (uninitialized) or
  /// positive-but-below [nearZeroTolerance] (precision collapsed toward zero).
  static bool hasNearZeroOrder(List<double> orders) {
    return orders.any((order) => order.abs() < 1e-10 || (order > 0 && order < nearZeroTolerance));
  }

  /// Assigns clean, evenly spaced [initialStep] multiples to [items] in their
  /// current order via [setOrder]. Returns the order assigned to the item for
  /// which [isPlaced] returns `true` (the moved item), or [initialStep] if none.
  static double assignSequential<T>(
    List<T> items, {
    required void Function(T item, double order) setOrder,
    bool Function(T item)? isPlaced,
  }) {
    double step = initialStep;
    double placedOrder = initialStep;
    for (final item in items) {
      setOrder(item, step);
      if (isPlaced != null && isPlaced(item)) placedOrder = step;
      step += initialStep;
    }
    return placedOrder;
  }

  // Midpoint toward zero for prepending before the first item.
  static double _before(double currentOrder) {
    if (currentOrder <= initialStep) {
      return currentOrder / 2;
    }
    return currentOrder - initialStep;
  }

  // Next slot after the last item; throws if it would overflow maxOrder.
  static double _after(double currentOrder) {
    if (currentOrder >= maxOrder - initialStep) {
      throw RankGapTooSmallException();
    }
    return currentOrder + initialStep;
  }
}

/// Thrown when a caller passes an inverted or equal neighbor pair to
/// [OrderRank.neighborRank] (`beforeOrder >= afterOrder`). Indicates a
/// programming error at the call site, distinct from the data-driven
/// [RankGapTooSmallException].
class InvalidNeighborOrderException implements Exception {
  final double beforeOrder;
  final double afterOrder;

  InvalidNeighborOrderException(this.beforeOrder, this.afterOrder);

  String get message =>
      'Invalid neighbor order: beforeOrder ($beforeOrder) must be strictly less than afterOrder ($afterOrder)';

  @override
  String toString() => 'InvalidNeighborOrderException: $message';
}

class RankGapTooSmallException implements Exception {
  final String message = 'Reordering needed - gaps between items too small';
}
