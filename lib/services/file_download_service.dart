import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

/// The only file in this project that imports `file_saver`.
///
/// `FileSaver.instance` is a static singleton and therefore unmockable —
/// wrapping it here is the only way a test can assert what the PDF
/// exporter hands off, rather than mocking the singleton itself.
class FileDownloadService {
  /// [nameWithoutExtension] must NOT include the extension — passing e.g.
  /// "cv.pdf" here with fileExtension "pdf" produces "cv.pdf.pdf" on disk.
  Future<void> saveFile({
    required String nameWithoutExtension,
    required Uint8List bytes,
    required String extension,
    required MimeType mimeType,
  }) {
    return FileSaver.instance.saveFile(
      name: nameWithoutExtension,
      bytes: bytes,
      fileExtension: extension,
      mimeType: mimeType,
    );
  }
}
