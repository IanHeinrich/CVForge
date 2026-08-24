import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/vault/cv_photo.dart';
import 'package:cv_forge/services/profile_photo_service.dart';

/// Owns the crop frame and turns whatever the user framed into a stored
/// [CvPhoto].
///
/// This is the only place in the app that handles a `dart:ui` image. The
/// conversion is deliberately shallow — take the cropper's bitmap, read it
/// as raw RGBA, hand it straight to [ProfilePhotoService] — so that
/// everything with a decision in it (orientation, resizing, quality)
/// stays in the service, where it is testable without a rasterizer.
class CropPhotoDialogModel extends BaseViewModel {
  CropPhotoDialogModel()
    : controller = CropController(
        // Locked, not merely suggested: the template draws a 35 x 45 mm
        // box, so any other ratio would have to be cropped again at
        // render time against a frame the user never saw.
        aspectRatio: ProfilePhotoService.cropAspectRatio,
      );

  final CropController controller;

  final _photoService = locator<ProfilePhotoService>();

  /// The framed region, encoded. Null only if the rasterizer declines to
  /// hand back pixel data at all — reported to the user rather than
  /// treated as a cancel, since the user did ask for something.
  Future<CvPhoto?> buildPhoto() => runBusyFuture(_encodeCurrentCrop());

  Future<CvPhoto?> _encodeCurrentCrop() async {
    final bitmap = await controller.croppedBitmap();
    try {
      final data = await bitmap.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return null;
      return _photoService.encodeCrop(
        rgbaBytes: data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        ),
        width: bitmap.width,
        height: bitmap.height,
      );
    } finally {
      // The bitmap is a full GPU-backed image that nothing else holds a
      // reference to once the bytes are out.
      bitmap.dispose();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
