import 'dart:typed_data';

abstract class IFileService {
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  });

  Future<String?> getSavePath({
    required String fileName,
    required List<String> allowedExtensions,
    String? dialogTitle,
  });

  Future<String> readFile(String filePath);

  Future<void> writeFile({
    required String filePath,
    required String content,
  });

  // Binary file operations for backup files
  Future<Uint8List> readBinaryFile(String filePath);

  Future<void> writeBinaryFile({
    required String filePath,
    required Uint8List data,
  });
}
