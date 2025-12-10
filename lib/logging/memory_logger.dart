import 'dart:collection';
import 'log_level.dart';
import 'i_logger.dart';

/// In-memory logger implementation that stores log entries in memory.
///
/// This logger is useful for displaying logs in the UI when file logging
/// is not available or as a fallback mechanism.
class MemoryLogger implements ILogger {
  /// The minimum log level that will be stored
  final LogLevel _minLevel;

  /// Whether to include timestamps in log entries
  final bool _includeTimestamp;

  /// Whether to include stack traces for errors
  final bool _includeStackTrace;

  /// Maximum number of log entries to keep in memory
  final int _maxEntries;

  /// Queue to store log entries (FIFO - oldest entries are removed first)
  final Queue<String> _logEntries = Queue<String>();

  /// Creates a memory logger with configurable options.
  ///
  /// [minLevel] - Minimum log level to store (default: debug)
  /// [includeTimestamp] - Whether to include timestamps (default: true)
  /// [includeStackTrace] - Whether to include stack traces for errors (default: true)
  /// [maxEntries] - Maximum number of entries to keep in memory (default: 1000)
  MemoryLogger({
    LogLevel minLevel = LogLevel.debug,
    bool includeTimestamp = true,
    bool includeStackTrace = true,
    int maxEntries = 1000,
  })  : _minLevel = minLevel,
        _includeTimestamp = includeTimestamp,
        _includeStackTrace = includeStackTrace,
        _maxEntries = maxEntries;

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

  /// Gets all log entries as a single string
  String getAllLogs() {
    return _logEntries.join('');
  }

  /// Gets the current number of log entries
  int get entryCount => _logEntries.length;

  /// Clears all log entries from memory
  void clear() {
    _logEntries.clear();
  }

  /// Gets a copy of all log entries as a list
  List<String> getLogEntries() {
    return List.unmodifiable(_logEntries);
  }

  /// Internal method to handle the actual logging logic
  void _log(LogLevel level, String message, Object? error, StackTrace? stackTrace, String? component) {
    // Don't log if below minimum level
    if (!level.isAtLeast(_minLevel)) {
      return;
    }

    final buffer = StringBuffer();

    // Add timestamp if enabled
    if (_includeTimestamp) {
      final now = DateTime.now();
      final timestamp = now.toIso8601String();
      buffer.write('[$timestamp] ');
    }

    // Add log level
    buffer.write('[${level.name}] ');

    // Add component if provided
    if (component != null && component.isNotEmpty) {
      buffer.write('[$component] ');
    }

    // Add main message
    buffer.write(message);

    // Add error information if provided
    if (error != null) {
      buffer.write(' | Error: $error');
    }

    // Add stack trace if enabled and provided
    if (_includeStackTrace && stackTrace != null) {
      buffer.write('\nStack trace:\n$stackTrace');
    }

    final logEntry = (buffer..writeln()).toString();

    // Add to queue
    _logEntries.add(logEntry);

    // Remove oldest entries if we exceed the maximum
    while (_logEntries.length > _maxEntries) {
      _logEntries.removeFirst();
    }
  }
}
