import 'dart:io';
import 'dart:async';

import 'log_level.dart';
import 'i_logger.dart';

/// File implementation of the Logger interface.
///
/// This implementation writes log messages to a file on disk
/// with automatic file rotation when the file size exceeds the configured limit.
class FileLogger implements ILogger {
  /// The minimum log level that will be output
  final LogLevel _minLevel;

  /// Whether to include timestamps in log output
  final bool _includeTimestamp;

  /// Whether to include stack traces for errors
  final bool _includeStackTrace;

  /// Maximum file size in bytes before rotation (default: 5 MB)
  final int _maxFileSizeBytes;

  /// Number of backup files to keep (default: 3)
  final int _maxBackupFiles;

  /// The log file path
  final String _filePath;

  /// Buffer to accumulate log messages before writing
  final StringBuffer _buffer = StringBuffer();

  /// Timer for periodic flushing
  Timer? _flushTimer;

  /// Lock for file operations
  var _fileLock = Future<void>.value();

  /// Creates a file logger with configurable options.
  ///
  /// [filePath] - Path to the log file
  /// [minLevel] - Minimum log level to output (default: debug)
  /// [includeTimestamp] - Whether to include timestamps (default: true)
  /// [includeStackTrace] - Whether to include stack traces for errors (default: true)
  /// [maxFileSizeBytes] - Maximum file size before rotation (default: 5 MB)
  /// [maxBackupFiles] - Number of backup files to keep (default: 3)
  FileLogger({
    required String filePath,
    LogLevel minLevel = LogLevel.debug,
    bool includeTimestamp = true,
    bool includeStackTrace = true,
    int maxFileSizeBytes = 5 * 1024 * 1024, // 5 MB
    int maxBackupFiles = 3,
  })  : _filePath = filePath,
        _minLevel = minLevel,
        _includeTimestamp = includeTimestamp,
        _includeStackTrace = includeStackTrace,
        _maxFileSizeBytes = maxFileSizeBytes,
        _maxBackupFiles = maxBackupFiles {
    // Initialize the log file immediately
    _initializeLogFile();

    // Start periodic flush timer (flush every 5 seconds)
    _flushTimer = Timer.periodic(const Duration(seconds: 5), (_) => _flushBuffer());
  }

  /// Gets the log file path
  String get filePath => _filePath;

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

  /// Disposes the logger and cleans up resources
  Future<void> dispose() async {
    _flushTimer?.cancel();
    await _flushBuffer();
  }

  /// Forces a flush of the buffer to disk
  Future<void> flush() async {
    await _flushBuffer();
  }

  /// Initializes the log file and directory structure
  Future<void> _initializeLogFile() async {
    try {
      final file = File(_filePath);
      final directory = file.parent;

      // Create directories if they don't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create log file if it doesn't exist
      if (!await file.exists()) {
        await file.create();

        // Write an initial log entry to indicate the file was created
        final timestamp = DateTime.now().toIso8601String();
        await file.writeAsString('[$timestamp] [INFO] Debug logging initialized\n');
      }
    } catch (e) {
      // If initialization fails, we'll continue without the file logger
      // The _flushBuffer method will handle creating the file later if needed
    }
  }

  /// Internal method to handle the actual logging logic
  void _log(LogLevel level, String message, Object? error, StackTrace? stackTrace, String? component) {
    // Don't log if below minimum level
    if (!level.isAtLeast(_minLevel)) {
      return;
    }

    // Add timestamp if enabled
    if (_includeTimestamp) {
      final now = DateTime.now();
      final timestamp = now.toIso8601String();
      _buffer.write('[$timestamp] ');
    }

    // Add log level with standardized format
    _buffer.write('[${level.name.toUpperCase()}] ');

    // Add component if provided
    if (component != null && component.isNotEmpty) {
      _buffer.write('[$component] ');
    }

    // Add main message
    _buffer.write(message);

    // Add error information if provided
    if (error != null) {
      _buffer.write(' | Error: $error');
    }

    // Add stack trace if enabled and provided
    if (_includeStackTrace && stackTrace != null) {
      _buffer.write('\nStack trace:\n$stackTrace');
    }

    // Add newline
    _buffer.writeln();
  }

  /// Flushes the buffer to the file
  Future<void> _flushBuffer() async {
    // Chain this operation to run after the previous one completes.
    _fileLock = _fileLock.then((_) async {
      if (_buffer.isEmpty) return;

      final content = _buffer.toString();
      _buffer.clear();

      try {
        // Create file and directories if they don't exist
        final file = File(_filePath);
        final directory = file.parent;
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Check if file rotation is needed
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize >= _maxFileSizeBytes) {
            await _rotateLogFile(file);
          }
        }

        // Write to file
        await file.writeAsString(content, mode: FileMode.append, flush: true);
      } catch (e) {
        // If file writing fails, we'll just ignore the error to prevent logging loops
        // In a production app, you might want to handle this more gracefully
      }
    });

    // Await the completion of the chained future.
    return _fileLock;
  }

  /// Rotates the log file by moving it to a backup and creating a new one
  Future<void> _rotateLogFile(File currentFile) async {
    try {
      if (_maxBackupFiles <= 0) {
        if (await currentFile.exists()) {
          await currentFile.delete();
        }
        return;
      }

      // Delete the oldest backup file if it exists
      final oldestBackup = File('$_filePath.$_maxBackupFiles');
      if (await oldestBackup.exists()) {
        await oldestBackup.delete();
      }

      // Move existing backup files up by one index
      for (int i = _maxBackupFiles - 1; i >= 1; i--) {
        final currentBackup = File('$_filePath.$i');
        if (await currentBackup.exists()) {
          final nextBackup = File('$_filePath.${i + 1}');
          await currentBackup.rename(nextBackup.path);
        }
      }

      // Move current log file to .1 backup
      if (await currentFile.exists()) {
        await currentFile.rename('$_filePath.1');
      }
    } catch (e) {
      // If rotation fails, continue without rotation
      // In a production app, you might want to handle this more gracefully
    }
  }
}
