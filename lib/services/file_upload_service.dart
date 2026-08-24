import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

/// The only file in this project that imports `file_selector` — the
/// read-side counterpart to [FileDownloadService]. Wrapping the picker
/// here (rather than calling `openFile` directly from a caller) is what
/// lets a test mock file-picking without touching the real platform
/// picker.
class FileUploadService {
  /// Opens the platform's file picker restricted to `.json`, returning the
  /// picked file's bytes, or `null` if the user cancelled.
  Future<Uint8List?> pickJsonFile() =>
      _pickFile(const XTypeGroup(label: 'JSON', extensions: ['json']));

  /// Opens the platform's file picker restricted to `.pdf`, returning the
  /// picked file's bytes, or `null` if the user cancelled.
  Future<Uint8List?> pickPdfFile() =>
      _pickFile(const XTypeGroup(label: 'PDF', extensions: ['pdf']));

  /// Opens the platform's file picker restricted to still-image formats,
  /// returning the picked file's bytes, or `null` if the user cancelled.
  /// The extension filter is a convenience, not a guarantee — what the
  /// bytes actually are is `ProfilePhotoService.prepareForCrop`'s problem.
  Future<Uint8List?> pickImageFile() => _pickFile(
    const XTypeGroup(
      label: 'Image',
      extensions: ['png', 'jpg', 'jpeg', 'webp'],
    ),
  );

  Future<Uint8List?> _pickFile(XTypeGroup group) async {
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return null;
    return file.readAsBytes();
  }
}
