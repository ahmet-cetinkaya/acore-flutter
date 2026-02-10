import 'dart:developer' as developer;

import 'log_level.dart';
import 'i_logger.dart';

/// Console implementation of the Logger interface.
///
/// This implementation outputs log messages to the console/debug output
/// with formatted timestamps, log levels, and optional error information.
class ConsoleLogger implements ILogger {
  /// The minimum log level that will be output
  final LogLevel _minLevel;

  /// Whether to include timestamps in log output
  final bool _includeTimestamp;

  /// Whether to include stack traces for errors
  final bool _includeStackTrace;

  /// Creates a console logger with configurable options.
  ///
  /// [minLevel] - Minimum log level to output (default: debug)
  /// [includeTimestamp] - Whether to include timestamps (default: true)
  /// [includeStackTrace] - Whether to include stack traces for errors (default: true)
  const ConsoleLogger({
    LogLevel minLevel = LogLevel.debug,
    bool includeTimestamp = true,
    bool includeStackTrace = true,
  })  : _minLevel = minLevel,
        _includeTimestamp = includeTimestamp,
        _includeStackTrace = includeStackTrace;

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    _log(LogLevel.debug, message, error, stackTrace, component);
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    _log(LogLevel.info, message, error, stackTrace, component);
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    _log(LogLevel.warning, message, error, stackTrace, component);
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    _log(LogLevel.error, message, error, stackTrace, component);
  }

  @override
  void fatal(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    _log(LogLevel.fatal, message, error, stackTrace, component);
  }

  /// Internal method to handle the actual logging logic
  void _log(LogLevel level, String message, Object? error, StackTrace? stackTrace, String? component) {
    // Don't log if below minimum level
    if (!level.isAtLeast(_minLevel)) {
      return;
    }

    final buffer = StringBuffer();

    if (_includeTimestamp) {
      final now = DateTime.now();
      final timestamp = now.toIso8601String();
      buffer.write('[$timestamp] ');
    }

    buffer.write('[${level.name}] ');

    if (component != null && component.isNotEmpty) {
      buffer.write('[$component] ');
    }

    buffer.write(message);

    if (error != null) {
      buffer.write(' | Error: $error');
    }

    final logMessage = buffer.toString();

    developer.log(
      logMessage,
      level: _getDeveloperLogLevel(level),
      error: error,
      stackTrace: (_includeStackTrace && stackTrace != null) ? stackTrace : null,
    );
  }

  /// Maps our LogLevel to dart:developer log levels
  int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500; // FINE level
      case LogLevel.info:
        return 800; // INFO level
      case LogLevel.warning:
        return 900; // WARNING level
      case LogLevel.error:
        return 1000; // SEVERE level
      case LogLevel.fatal:
        return 1200; // SHOUT level
    }
  }
}
