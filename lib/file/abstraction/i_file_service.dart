import 'dart:typed_data';

abstract class IFileService {
  /// Pick a file from the file system
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  });

  /// Read text file content
  Future<String> readFile(String filePath);

  /// Write text content to file (for internal app files only)
  /// For user-facing exports, use saveFile() instead
  Future<void> writeFile({
    required String filePath,
    required String content,
  });

  /// Read binary file content
  Future<Uint8List> readBinaryFile(String filePath);

  /// Write binary data to file (for internal app files only)
  /// For user-facing exports, use saveFile() instead
  Future<void> writeBinaryFile({
    required String filePath,
    required Uint8List data,
  });

  /// Save file with user-selected location (recommended for exports)
  /// Returns the saved file path or null if cancelled
  /// On Android, uses SAF (Storage Access Framework) - no permissions required
  /// On Desktop, uses traditional file picker
  Future<String?> saveFile({
    required String fileName,
    required Uint8List data,
    required String fileExtension,
    bool isTextFile = false,
  });
}
