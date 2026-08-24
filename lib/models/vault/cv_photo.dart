import 'package:freezed_annotation/freezed_annotation.dart';

part 'cv_photo.freezed.dart';
part 'cv_photo.g.dart';

/// The one profile photograph the Vault holds, ready to hand straight to
/// `pw.MemoryImage` after a base64 decode.
///
/// [jpegBase64] is a `String`, not `Uint8List`, and that is load-bearing in
/// three places rather than a serialization convenience:
///  - freezed compares `Uint8List` by identity, so a `Uint8List` field would
///    make every freshly-composed `ResolvedCv` unequal to the last one, and
///    `TemplateThumbnailService`'s cache (which evicts on exactly that
///    comparison) would never hit;
///  - `DriveSyncService` decides whether it has anything to upload by
///    hashing the canonicalized bundle JSON, which needs a stable scalar;
///  - the Vault is persisted as one JSON string, so the bytes have to reach
///    a JSON-safe form regardless.
///
/// Always JPEG. `ProfilePhotoService` is the only writer and encodes nothing
/// else — see its doc comment for the size budget this type is sized to.
///
/// [widthPx]/[heightPx] describe [jpegBase64]'s own pixels. Nothing decodes
/// the image to find them, so a UI can reserve the right box before the
/// bytes are turned into anything.
@freezed
abstract class CvPhoto with _$CvPhoto {
  const factory CvPhoto({
    required String jpegBase64,
    required int widthPx,
    required int heightPx,
  }) = _CvPhoto;

  factory CvPhoto.fromJson(Map<String, dynamic> json) =>
      _$CvPhotoFromJson(json);
}
