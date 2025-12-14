# File Services

## Overview

The file services module provides a cross-platform abstraction layer for file
operations including file picking, reading, writing, and saving. It handles
platform-specific differences such as Android's Storage Access Framework and
provides a consistent API across all supported platforms.

## Features

- 📁 **Cross-Platform File Operations** - Unified API for Android, iOS, and
  Desktop
- 🎯 **File Picker Integration** - Native file selection dialogs with extension
  filtering
- 📝 **Text and Binary Support** - Handle both text and binary file operations
- 💾 **User-Saving Support** - Save files with user-selected locations
- 🔐 **Permission Handling** - Automatic permission management on different
  platforms
- 🌍 **Desktop Compatibility** - Traditional file dialogs for desktop platforms

## Core Interface

### IFileService

```dart
abstract class IFileService {
  /// Pick a file from the file system
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  });

  /// Read text file content
  Future<String> readFile(String filePath);

  /// Write text content to file (internal app files)
  Future<void> writeFile({
    required String filePath,
    required String content,
  });

  /// Read binary file content
  Future<Uint8List> readBinaryFile(String filePath);

  /// Write binary data to file (internal app files)
  Future<void> writeBinaryFile({
    required String filePath,
    required Uint8List data,
  });

  /// Save file with user-selected location
  Future<String?> saveFile({
    required String fileName,
    required Uint8List data,
    required String fileExtension,
    bool isTextFile = false,
  });
}
```

## Usage Examples

### Basic File Operations

```dart
class FileManager {
  final IFileService _fileService;
  final ILogger _logger;

  FileManager(this._fileService, this._logger);

  /// Read a configuration file
  Future<Map<String, dynamic>> loadConfiguration() async {
    try {
      final content = await _fileService.readFile('config/app_config.json');
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      _logger.error("Failed to load configuration", e, stackTrace);
      rethrow;
    }
  }

  /// Save configuration file
  Future<void> saveConfiguration(Map<String, dynamic> config) async {
    try {
      final content = jsonEncode(config);
      await _fileService.writeFile(
        filePath: 'config/app_config.json',
        content: content,
      );
      _logger.info("Configuration saved successfully");
    } catch (e, stackTrace) {
      _logger.error("Failed to save configuration", e, stackTrace);
      rethrow;
    }
  }
}
```

### File Picker with Extension Filtering

```dart
class DocumentImporter {
  final IFileService _fileService;

  DocumentImporter(this._fileService);

  /// Import CSV file with specific extension filtering
  Future<List<Map<String, dynamic>>> importCSV() async {
    final filePath = await _fileService.pickFile(
      allowedExtensions: ['csv', 'txt'],
      dialogTitle: 'Select CSV file to import',
    );

    if (filePath == null) {
      throw BusinessException(
        'No file selected',
        'FILE_NOT_SELECTED',
      );
    }

    final content = await _fileService.readFile(filePath);
    return _parseCSV(content);
  }

  /// Import JSON file
  Future<Map<String, dynamic>?> importJSON() async {
    final filePath = await _fileService.pickFile(
      allowedExtensions: ['json'],
      dialogTitle: 'Select JSON file',
    );

    if (filePath == null) return null;

    final content = await _fileService.readFile(filePath);
    return jsonDecode(content) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> _parseCSV(String content) {
    final lines = LineSplitter.split(content);
    if (lines.isEmpty) return [];

    final headers = lines.first.split(',');
    final data = <Map<String, dynamic>>[];

    for (var i = 1; i < lines.length; i++) {
      final values = lines[i].split(',');
      if (values.length == headers.length) {
        final row = <String, dynamic>{};
        for (var j = 0; j < headers.length; j++) {
          row[headers[j]] = values[j];
        }
        data.add(row);
      }
    }

    return data;
  }
}
```

### User-Facing File Export

```dart
class ReportExporter {
  final IFileService _fileService;
  final ILogger _logger;

  ReportExporter(this._fileService, this._logger);

  /// Export report to user-selected location
  Future<String?> exportReport(ReportData report, ReportFormat format) async {
    try {
      final fileName = _generateFileName(report, format);
      final data = await _generateReportData(report, format);

      final savedPath = await _fileService.saveFile(
        fileName: fileName,
        data: data,
        fileExtension: format.extension,
        isTextFile: format.isTextFormat,
      );

      if (savedPath != null) {
        _logger.info("Report exported successfully", savedPath);
      }

      return savedPath;
    } catch (e, stackTrace) {
      _logger.error("Failed to export report", e, stackTrace);
      rethrow;
    }
  }

  /// Export multiple reports as a ZIP archive
  Future<String?> exportReportsArchive(List<ReportData> reports) async {
    try {
      final archive = _createArchive(reports);
      final fileName = _generateArchiveFileName();

      final savedPath = await _fileService.saveFile(
        fileName: fileName,
        data: archive,
        fileExtension: 'zip',
      );

      if (savedPath != null) {
        _logger.info("Reports archive exported successfully", savedPath);
      }

      return savedPath;
    } catch (e, stackTrace) {
      _logger.error("Failed to export reports archive", e, stackTrace);
      rethrow;
    }
  }

  String _generateFileName(ReportData report, ReportFormat format) {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return '${report.title}_$timestamp.${format.extension}';
  }

  Future<Uint8List> _generateReportData(ReportData report, ReportFormat format) async {
    switch (format) {
      case ReportFormat.json:
        final jsonContent = jsonEncode(report.toJson());
        return Uint8List.fromList(utf8.encode(jsonContent));
      case ReportFormat.csv:
        final csvContent = _convertToCSV(report);
        return Uint8List.fromList(utf8.encode(csvContent));
      case ReportFormat.pdf:
        // Use PDF generation library
        return await _generatePDF(report);
    }
  }

  Uint8List _createArchive(List<ReportData> reports) {
    // Use archive library to create ZIP
    // Implementation depends on chosen archive package
    throw UnimplementedError('Archive creation not implemented');
  }
}

enum ReportFormat {
  json('json', true),
  csv('csv', true),
  pdf('pdf', false);

  const ReportFormat(this.extension, this.isTextFormat);
  final String extension;
  final bool isTextFormat;
}

class ReportData {
  final String title;
  final DateTime createdDate;
  final Map<String, dynamic> data;

  ReportData({
    required this.title,
    required this.createdDate,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'createdDate': createdDate.toIso8601String(),
    'data': data,
  };
}
```

### Image Handling

```dart
class ImageManager {
  final IFileService _fileService;

  ImageManager(this._fileService);

  /// Pick and save image
  Future<String?> pickAndSaveImage(String directory) async {
    final imagePath = await _fileService.pickFile(
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp'],
      dialogTitle: 'Select image',
    );

    if (imagePath == null) return null;

    // Read original image
    final imageData = await _fileService.readBinaryFile(imagePath);
    final originalFileName = imagePath.split('/').last;

    // Save to app directory
    final appImagePath = '$directory/$originalFileName';
    await _fileService.writeBinaryFile(
      filePath: appImagePath,
      data: imageData,
    );

    return appImagePath;
  }

  /// Save processed image
  Future<void> saveProcessedImage(
    Uint8List imageData,
    String fileName,
    String directory,
  ) async {
    final fullPath = '$directory/$fileName';
    await _fileService.writeBinaryFile(
      filePath: fullPath,
      data: imageData,
    );
  }

  /// Export image for user
  Future<String?> exportImageForUser(
    Uint8List imageData,
    String fileName,
    ImageFormat format,
  ) async {
    return await _fileService.saveFile(
      fileName: '$fileName.${format.extension}',
      data: imageData,
      fileExtension: format.extension,
    );
  }
}

enum ImageFormat {
  png('png'),
  jpg('jpg'),
  jpeg('jpeg'),
  gif('gif');

  const ImageFormat(this.extension);
  final String extension;
}
```

### Data Backup and Restore

```dart
class BackupManager {
  final IFileService _fileService;
  final ILogger _logger;

  BackupManager(this._fileService, this._logger);

  /// Create backup of application data
  Future<String?> createBackup(Map<String, dynamic> appData) async {
    try {
      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'data': appData,
      };

      final jsonData = jsonEncode(backupData);
      final backupFile = await _fileService.saveFile(
        fileName: _generateBackupFileName(),
        data: Uint8List.fromList(utf8.encode(jsonData)),
        fileExtension: 'json',
        isTextFile: true,
      );

      if (backupFile != null) {
        _logger.info("Backup created successfully", backupFile);
      }

      return backupFile;
    } catch (e, stackTrace) {
      _logger.error("Failed to create backup", e, stackTrace);
      rethrow;
    }
  }

  /// Restore application data from backup
  Future<Map<String, dynamic>?> restoreFromBackup() async {
    try {
      final backupPath = await _fileService.pickFile(
        allowedExtensions: ['json'],
        dialogTitle: 'Select backup file',
      );

      if (backupPath == null) return null;

      final backupContent = await _fileService.readFile(backupPath);
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;

      // Validate backup format
      if (!_isValidBackup(backupData)) {
        throw BusinessException(
          'Invalid backup file format',
          'INVALID_BACKUP_FORMAT',
        );
      }

      final appData = backupData['data'] as Map<String, dynamic>;

      _logger.info("Backup restored successfully", backupPath);
      return appData;
    } catch (e, stackTrace) {
      _logger.error("Failed to restore backup", e, stackTrace);
      rethrow;
    }
  }

  String _generateBackupFileName() {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return 'backup_$timestamp.json';
  }

  bool _isValidBackup(Map<String, dynamic> backupData) {
    return backupData.containsKey('timestamp') &&
           backupData.containsKey('version') &&
           backupData.containsKey('data');
  }
}
```

## Platform-Specific Considerations

### Android

- Uses Storage Access Framework (SAF) for file operations
- No explicit permissions required for user-selected files
- Internal file operations work within app's private storage

### iOS

- Uses document picker for file selection
- Files are saved to app's documents directory or user-selected location
- Proper sandboxing enforced by iOS

### Desktop (Windows, macOS, Linux)

- Uses native file dialogs
- Full filesystem access for user-selected files
- Internal files stored in appropriate app directories

### Web

- Limited file system access due to browser sandboxing
- Uses download functionality for file saving
- File picker depends on browser implementation

## Error Handling

### Common Exceptions

```dart
class FileServiceException implements Exception {
  final String message;
  final String? filePath;
  final Exception? cause;

  FileServiceException(this.message, {this.filePath, this.cause});

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('FileServiceException: $message');
    if (filePath != null) {
      buffer.write(' (file: $filePath)');
    }
    if (cause != null) {
      buffer.write(' - caused by: $cause');
    }
    return buffer.toString();
  }
}

// Usage in file service implementations
class FileServiceImpl implements IFileService {
  @override
  Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileServiceException(
          'File not found',
          filePath: filePath,
        );
      }
      return await file.readAsString();
    } catch (e) {
      throw FileServiceException(
        'Failed to read file',
        filePath: filePath,
        cause: e,
      );
    }
  }
}
```

## Testing File Operations

### Mock Implementation

```dart
class MockFileService implements IFileService {
  final Map<String, String> _textFiles = {};
  final Map<String, Uint8List> _binaryFiles = {};
  String? _pickedFile;

  @override
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    return _pickedFile;
  }

  @override
  Future<String> readFile(String filePath) async {
    final content = _textFiles[filePath];
    if (content == null) {
      throw FileServiceException('File not found', filePath: filePath);
    }
    return content;
  }

  @override
  Future<void> writeFile({
    required String filePath,
    required String content,
  }) async {
    _textFiles[filePath] = content;
  }

  @override
  Future<Uint8List> readBinaryFile(String filePath) async {
    final data = _binaryFiles[filePath];
    if (data == null) {
      throw FileServiceException('File not found', filePath: filePath);
    }
    return data;
  }

  @override
  Future<void> writeBinaryFile({
    required String filePath,
    required Uint8List data,
  }) async {
    _binaryFiles[filePath] = data;
  }

  @override
  Future<String?> saveFile({
    required String fileName,
    required Uint8List data,
    required String fileExtension,
    bool isTextFile = false,
  }) async {
    final savedPath = '/mock/path/$fileName.$fileExtension';
    _binaryFiles[savedPath] = data;
    return savedPath;
  }

  // Test helper methods
  void setPickedFile(String filePath) {
    _pickedFile = filePath;
  }

  void addTextFile(String filePath, String content) {
    _textFiles[filePath] = content;
  }

  void addBinaryFile(String filePath, Uint8List data) {
    _binaryFiles[filePath] = data;
  }

  void clearFiles() {
    _textFiles.clear();
    _binaryFiles.clear();
    _pickedFile = null;
  }
}
```

### Unit Testing

```dart
void main() {
  group('FileManager Tests', () {
    late FileManager fileManager;
    late MockFileService mockFileService;
    late MockLogger mockLogger;

    setUp(() {
      mockFileService = MockFileService();
      mockLogger = MockLogger();
      fileManager = FileManager(mockFileService, mockLogger);
    });

    test('should load configuration successfully', () async {
      // Arrange
      const configJson = '{"theme": "dark", "language": "en"}';
      mockFileService.addTextFile('config/app_config.json', configJson);

      // Act
      final config = await fileManager.loadConfiguration();

      // Assert
      expect(config, isA<Map<String, dynamic>>());
      expect(config['theme'], equals('dark'));
      expect(config['language'], equals('en'));
    });

    test('should handle file not found error', () async {
      // Act & Assert
      expect(
        () => fileManager.loadConfiguration(),
        throwsA(isA<FileServiceException>()),
      );
    });

    test('should save configuration successfully', () async {
      // Arrange
      final config = {'theme': 'light', 'language': 'fr'};

      // Act
      await fileManager.saveConfiguration(config);

      // Assert
      final savedContent = mockFileService._textFiles['config/app_config.json'];
      expect(savedContent, isNotNull);
      expect(jsonDecode(savedContent), equals(config));
    });
  });
}
```

## Best Practices

### 1. Use Appropriate Methods

```dart
// ✅ Good: Use saveFile for user-facing exports
await fileService.saveFile(
  fileName: 'report.pdf',
  data: pdfData,
  fileExtension: 'pdf',
);

// ✅ Good: Use writeFile for internal app files
await fileService.writeFile(
  filePath: 'internal/cache/data.json',
  content: jsonData,
);

// ❌ Bad: Use writeFile for user-facing exports
await fileService.writeFile(
  filePath: '/user/documents/report.pdf', // User directory
  content: pdfData,
);
```

### 2. Handle File Operations Safely

```dart
// ✅ Good: Proper error handling
try {
  final content = await fileService.readFile(filePath);
  return content;
} on FileServiceException catch (e) {
  logger.error("File operation failed", e);
  return null; // Fallback value
}

// ❌ Bad: No error handling
final content = await fileService.readFile(filePath); // May throw
```

### 3. Validate File Paths

```dart
// ✅ Good: Validate before operations
Future<String> safeReadFile(String filePath) async {
  if (filePath.isEmpty) {
    throw BusinessException('File path cannot be empty', 'EMPTY_FILE_PATH');
  }

  if (!isValidFilePath(filePath)) {
    throw BusinessException('Invalid file path', 'INVALID_FILE_PATH');
  }

  return await fileService.readFile(filePath);
}

bool isValidFilePath(String filePath) {
  // Implement path validation logic
  return !filePath.contains('..') && !filePath.startsWith('/');
}
```

### 4. Use Proper File Extensions

```dart
// ✅ Good: Include proper extensions
await fileService.saveFile(
  fileName: 'document',
  data: textData,
  fileExtension: 'txt',
);

// ❌ Bad: Missing extensions
await fileService.saveFile(
  fileName: 'document',
  data: textData,
  fileExtension: '', // Empty extension
);
```

---

### Related Documentation

- [Storage Abstractions](../storage/README.md)
- [Error Handling](../errors/README.md)
- [Dependency Injection](../dependency_injection/README.md)
