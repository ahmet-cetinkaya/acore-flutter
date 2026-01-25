import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Converts a Color to a hex string without the alpha channel.
  String toHexString() {
    return toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
  }
}
