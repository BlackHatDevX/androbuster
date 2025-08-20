import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'scanning_service.dart';

class FileService {
  static const int _maxFileSize = 50 * 1024 * 1024; 
  static const int _previewThreshold = 1024 * 1024; 

  static Future<FilePickerResult?> pickTextFile() async {
    try {
      return await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        allowMultiple: false,
      );
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  static Future<FileInfo> processFile(FilePickerResult result) async {
    final File file = File(result.files.single.path!);

    final int fileSize = await file.length();
    if (fileSize > _maxFileSize) {
      throw Exception('File too large (max ${_maxFileSize ~/ (1024 * 1024)}MB)');
    }

    final String content = await ScanningService.readFileInChunks(file);

    final String previewText = fileSize > _previewThreshold
        ? 'File uploaded is more than ${_previewThreshold ~/ (1024 * 1024)}MB. Data preview unavailable. You can start scan.'
        : content;

    return FileInfo(
      name: result.files.single.name,
      size: fileSize,
      content: content,
      previewText: previewText,
    );
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class FileInfo {
  final String name;
  final int size;
  final String content;
  final String previewText;

  const FileInfo({
    required this.name,
    required this.size,
    required this.content,
    required this.previewText,
  });

  String get formattedSize => FileService.formatFileSize(size);
}