/// Utilities for canonical, lexicographically sortable fractional order ranks.
class OrderRank {
  static const _alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  static const _base = _alphabet.length;
  static const initialRank = 'U';
  static const maxRankLength = 32;

  static String neighborRank({String? beforeOrder, String? afterOrder}) {
    if (!_isCanonical(beforeOrder) || !_isCanonical(afterOrder))
      throw InvalidNeighborOrderException(beforeOrder, afterOrder);
    if (beforeOrder != null && afterOrder != null && beforeOrder.compareTo(afterOrder) >= 0)
      throw InvalidNeighborOrderException(beforeOrder, afterOrder);
    if (beforeOrder == null && afterOrder == null) return initialRank;

    final rank = _midpoint(beforeOrder ?? '', afterOrder);
    if (rank.length > maxRankLength) throw RankGapTooSmallException();
    return rank;
  }

  static bool cannotFit({String? beforeOrder, String? afterOrder}) {
    if (!_isCanonical(beforeOrder) || !_isCanonical(afterOrder)) return true;
    if (beforeOrder != null && afterOrder != null && beforeOrder.compareTo(afterOrder) >= 0)
      return true;
    if (beforeOrder == null && afterOrder == null) return false;
    return _midpoint(beforeOrder ?? '', afterOrder).length > maxRankLength;
  }

  static bool needsNormalization(List<String> orders) {
    String? previous;
    for (final order in orders) {
      if (!_isCanonical(order) || order.length > maxRankLength) return true;
      if (previous != null && previous.compareTo(order) >= 0) return true;
      previous = order;
    }
    return false;
  }

  static String fromLegacyDouble(double value) {
    if (!value.isFinite) return initialRank;

    var fraction = value.clamp(0, 1000000).toDouble() / 1000001;
    final digits = StringBuffer();
    for (var index = 0; index < 6; index++) {
      fraction *= _base;
      final digit = fraction.floor();
      digits.write(_alphabet[digit]);
      fraction -= digit;
    }

    final rank = digits.toString().replaceFirst(RegExp(r'0+$'), '');
    return rank.isEmpty ? '0000001' : rank;
  }

  static String assignSequential<T>(
    List<T> items, {
    required void Function(T, String) setOrder,
    bool Function(T)? isPlaced,
  }) {
    if (items.isEmpty) return initialRank;

    final width = _sequentialWidth(items.length);
    final capacity = _power(_base, width);
    String placedRank = initialRank;
    for (var index = 0; index < items.length; index++) {
      final rank = _canonicalInteger((index + 1) * capacity ~/ (items.length + 1), width);
      setOrder(items[index], rank);
      if (isPlaced?.call(items[index]) ?? false) placedRank = rank;
    }
    return placedRank;
  }

  static String _midpoint(String lower, String? upper) {
    final prefix = StringBuffer();
    var upperIsAbsent = upper == null;
    for (var index = 0;; index++) {
      final lowerDigit = index < lower.length ? _digitValue(lower[index]) : 0;
      final upperDigit = upperIsAbsent
          ? _base
          : index < upper!.length
          ? _digitValue(upper[index])
          : 0;
      final gap = upperDigit - lowerDigit;
      if (gap >= 2) return '$prefix${_alphabet[lowerDigit + gap ~/ 2]}';
      prefix.write(_alphabet[lowerDigit]);
      if (gap == 1) upperIsAbsent = true;
    }
  }

  static bool _isCanonical(String? rank) {
    if (rank == null) return true;
    if (rank.isEmpty || rank.endsWith('0')) return false;
    var hasNonZeroDigit = false;
    for (final codeUnit in rank.codeUnits) {
      final digit = _alphabet.indexOf(String.fromCharCode(codeUnit));
      if (digit < 0) return false;
      hasNonZeroDigit |= digit > 0;
    }
    return hasNonZeroDigit;
  }

  static int _digitValue(String digit) => _alphabet.indexOf(digit);

  static int _sequentialWidth(int itemCount) {
    var width = 1;
    var capacity = _base;
    while (capacity <= itemCount) {
      width++;
      capacity *= _base;
    }
    return width;
  }

  static int _power(int base, int exponent) {
    var result = 1;
    for (var index = 0; index < exponent; index++) result *= base;
    return result;
  }

  static String _canonicalInteger(int value, int width) {
    final digits = List.filled(width, '0');
    for (var index = width - 1; index >= 0; index--) {
      digits[index] = _alphabet[value % _base];
      value ~/= _base;
    }
    return digits.join().replaceFirst(RegExp(r'0+$'), '');
  }
}

class InvalidNeighborOrderException implements Exception {
  final String? beforeOrder;
  final String? afterOrder;

  InvalidNeighborOrderException(this.beforeOrder, this.afterOrder);

  @override
  String toString() => 'InvalidNeighborOrderException: invalid rank bounds';
}

class RankGapTooSmallException implements Exception {
  @override
  String toString() => 'RankGapTooSmallException: rank exceeds maximum length';
}
