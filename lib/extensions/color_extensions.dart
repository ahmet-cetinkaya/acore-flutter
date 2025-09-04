import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Converts a Color to a hex string without the alpha channel.
  String toHexString() {
    final hexValue = toARGB32().toRadixString(16).toUpperCase();
    return hexValue.length == 8 ? hexValue.substring(2) : hexValue;
  }
}
