import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

/// The only file in this project that imports `file_selector` — the
/// read-side counterpart to [FileDownloadService]. Wrapping the picker
/// here (rather than calling `openFile` directly from `BackupService`) is
/// what lets a test mock file-picking without touching the real platform
/// picker.
class FileUploadService {
  /// Opens the platform's file picker restricted to `.json`, returning the
  /// picked file's bytes, or `null` if the user cancelled.
  Future<Uint8List?> pickJsonFile() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (file == null) return null;
    return file.readAsBytes();
  }
}
