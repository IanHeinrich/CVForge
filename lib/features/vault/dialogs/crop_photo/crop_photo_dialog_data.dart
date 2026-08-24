import 'dart:typed_data';

/// What [CropPhotoDialog] is handed: the already-decoded, already-uprighted
/// JPEG from `ProfilePhotoService.prepareForCrop`, never the raw bytes the
/// user picked.
///
/// A separate data class rather than passing bytes through
/// `DialogRequest.data` untyped, matching `TemplateGalleryDialogData`.
class CropPhotoDialogData {
  const CropPhotoDialogData({required this.preparedJpeg});

  final Uint8List preparedJpeg;
}
