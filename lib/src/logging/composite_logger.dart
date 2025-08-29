import 'i_logger.dart';

/// Composite implementation of the Logger interface.
///
/// This implementation forwards log messages to multiple child loggers,
/// allowing for simultaneous logging to different destinations (console, file, etc.).
class CompositeLogger implements ILogger {
  /// List of child loggers to forward messages to
  final List<ILogger> _loggers;

  /// Creates a composite logger with a list of child loggers.
  ///
  /// [loggers] - List of child loggers to forward messages to
  const CompositeLogger(this._loggers);

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    for (final logger in _loggers) {
      logger.debug(message, error, stackTrace);
    }
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    for (final logger in _loggers) {
      logger.info(message, error, stackTrace);
    }
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    for (final logger in _loggers) {
      logger.warning(message, error, stackTrace);
    }
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    for (final logger in _loggers) {
      logger.error(message, error, stackTrace);
    }
  }

  @override
  void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    for (final logger in _loggers) {
      logger.fatal(message, error, stackTrace);
    }
  }

  /// Adds a new logger to the composite
  void addLogger(ILogger logger) {
    _loggers.add(logger);
  }

  /// Removes a logger from the composite
  bool removeLogger(ILogger logger) {
    return _loggers.remove(logger);
  }

  /// Gets the number of child loggers
  int get loggerCount => _loggers.length;

  /// Gets a copy of the child loggers list
  List<ILogger> get loggers => List.unmodifiable(_loggers);
}
