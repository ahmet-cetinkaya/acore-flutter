import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/markdown_editor_interfaces.dart';

/// Default implementation of markdown link handling with security validation
class MarkdownLinkHandler implements IMarkdownLinkHandler {
  // List of allowed URL schemes for security
  static const List<String> _allowedSchemes = [
    'http',
    'https',
    'mailto',
    'tel',
    'sms',
  ];

  // List of potentially dangerous schemes to block
  static const List<String> _blockedSchemes = [
    'javascript',
    'data',
    'vbscript',
    'file',
    'ftp',
  ];

  @override
  void handleLinkTap(String text, String? href, String title) {
    if (href != null && href.isNotEmpty) {
      launchUrl(href);
    }
  }

  @override
  Future<void> launchUrl(String url) async {
    try {
      if (url.isEmpty) {
        developer.log('Empty URL provided');
        return;
      }

      final uri = Uri.tryParse(url);
      if (uri == null) {
        developer.log('Invalid URL format: $url');
        return;
      }

      // Security validation
      if (!_isUrlSafe(uri)) {
        developer.log('Blocked potentially unsafe URL: $url');
        return;
      }

      // Additional validation for external URLs
      if (_isExternalUrl(uri)) {
        if (!await _validateExternalUrl(uri)) {
          developer.log('Could not validate external URL: $url');
          return;
        }
      }

      final launched = await url_launcher.launchUrl(
        uri,
        mode: url_launcher.LaunchMode.externalApplication,
      );

      if (!launched) {
        developer.log('Could not launch URL: $url');
      }
    } catch (e) {
      developer.log('Error launching URL $url: $e');
      if (!kReleaseMode) {
        debugPrint('URL Launch Error: $e');
      }
    }
  }

  /// Validates if a URL is safe to launch
  bool _isUrlSafe(Uri uri) {
    // Check for blocked schemes
    if (_blockedSchemes.contains(uri.scheme.toLowerCase())) {
      return false;
    }

    // Check if scheme is in allowed list
    if (uri.scheme.isEmpty) {
      return false; // No scheme specified
    }

    if (!_allowedSchemes.contains(uri.scheme.toLowerCase())) {
      developer.log('URL scheme not in allowed list: ${uri.scheme}');
      return false;
    }

    // Additional checks for HTTP/HTTPS URLs
    if (uri.scheme.toLowerCase() == 'http' || uri.scheme.toLowerCase() == 'https') {
      // Block localhost in release mode
      if (kReleaseMode && _isLocalhostUrl(uri)) {
        developer.log('Localhost URL blocked in release mode: $uri');
        return false;
      }
    }

    return true;
  }

  /// Checks if URL is external (not relative)
  bool _isExternalUrl(Uri uri) {
    return uri.scheme.isNotEmpty;
  }

  /// Validates external URLs can be launched
  Future<bool> _validateExternalUrl(Uri uri) async {
    try {
      return await url_launcher.canLaunchUrl(uri);
    } catch (e) {
      developer.log('Error validating URL $uri: $e');
      return false;
    }
  }

  /// Checks if URL points to localhost
  bool _isLocalhostUrl(Uri uri) {
    final host = uri.host.toLowerCase();
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        host.endsWith('.local');
  }

  /// Gets allowed schemes for testing/configuration
  static List<String> get allowedSchemes => List.unmodifiable(_allowedSchemes);

  /// Gets blocked schemes for testing/configuration
  static List<String> get blockedSchemes => List.unmodifiable(_blockedSchemes);
}
