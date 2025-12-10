import 'i_logger.dart';

/// Composite implementation of the Logger interface.
///
/// This implementation forwards log messages to multiple child loggers,
/// allowing for simultaneous logging to different destinations (console, file, etc.).
class CompositeLogger implements ILogger {
  final List<ILogger> _loggers;

  CompositeLogger(List<ILogger> loggers) : _loggers = List.of(loggers);

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    for (final logger in List.of(_loggers)) {
      logger.debug(message, error, stackTrace, component);
    }
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    for (final logger in List.of(_loggers)) {
      logger.info(message, error, stackTrace, component);
    }
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    for (final logger in List.of(_loggers)) {
      logger.warning(message, error, stackTrace, component);
    }
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    for (final logger in List.of(_loggers)) {
      logger.error(message, error, stackTrace, component);
    }
  }

  @override
  void fatal(String message, [Object? error, StackTrace? stackTrace, String? component]) {
    for (final logger in List.of(_loggers)) {
      logger.fatal(message, error, stackTrace, component);
    }
  }

  void addLogger(ILogger logger) {
    _loggers.add(logger);
  }

  bool removeLogger(ILogger logger) {
    return _loggers.remove(logger);
  }

  int get loggerCount => _loggers.length;

  List<ILogger> get loggers => List.unmodifiable(_loggers);
}
