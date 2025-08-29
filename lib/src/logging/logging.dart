/// Logging module providing flexible logging infrastructure.
///
/// This library provides a flexible logging system with:
/// - Abstract Logger interface for different implementations
/// - LogLevel enumeration for categorizing messages
/// - ConsoleLogger implementation for development and debugging
/// - FileLogger implementation for persistent logging
/// - CompositeLogger for logging to multiple destinations
///
/// Example usage:
/// ```dart
/// import 'package:acore/acore.dart';
///
/// final logger = CompositeLogger([
///   ConsoleLogger(minLevel: LogLevel.info),
///   FileLogger(filePath: '/path/to/logfile.log'),
/// ]);
///
/// logger.info('Application started');
/// logger.warning('This is a warning message');
/// logger.error('An error occurred', error, stackTrace);
/// ```
library;

export 'console_logger.dart';
export 'file_logger.dart';
export 'memory_logger.dart';
export 'composite_logger.dart';
export 'log_level.dart';
export 'i_logger.dart';
