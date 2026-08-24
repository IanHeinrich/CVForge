import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'package:cv_forge/models/vault/cv_photo.dart';

/// Turns whatever the user picked off disk into the one small, upright,
/// opaque JPEG the Vault stores.
///
/// Deliberately synchronous and free of `dart:ui`: every method takes and
/// returns plain bytes, so this is testable on the Flutter VM and mockable
/// without faking an image codec. Converting a cropper's `ui.Image` into
/// raw RGBA is the caller's job (see `CropPhotoDialog`), which keeps the
/// only `dart:ui` image handling in the one widget that already has it.
///
/// ### The size budget
///
/// [encodeCrop]'s output lands in `ContactBasics.photo`, which sits inside
/// the Vault — one JSON string that is re-encoded on every debounced write,
/// hashed on every Drive sync, and stored a second time in the
/// `drive_sync_base` ancestor row (already flagged in `storage_keys.dart`
/// as the row to move to a lazy box if it grows). So the stored image is
/// capped at [maxStoredEdgePx] square — the printed circle's diameter at
/// roughly 300 dpi, which is as much detail as the PDF can show — and
/// re-encoded at falling quality if it still exceeds [_maxEncodedBytes].
/// That keeps the base64 payload well under 200 KB however large the
/// original was.
class ProfilePhotoService {
  /// Square, because the template renders the photo as a circle — the only
  /// shape a circular mask can take without silently cropping something
  /// the user framed deliberately. The cropper locks to this, so the
  /// stored image already matches the box the template draws and
  /// `pw.BoxFit.cover` has nothing left to trim.
  ///
  /// A deliberate departure from the 35x45 mm passport-photo standard,
  /// which exists for a physical print trimmed with scissors. The
  /// reference Lebenslauf layouts this template is modelled on use a
  /// circle.
  static const cropAspectRatio = 1.0;

  /// One value, since [cropAspectRatio] is square — roughly the printed
  /// circle's diameter (see `photoDiameterMm` in
  /// `photo_header_tokens.dart`) at 300 dpi.
  static const maxStoredEdgePx = 512;

  /// What [prepareForCrop] downsizes to. Large enough that the cropper
  /// still shows real detail, small enough that a 12-megapixel phone photo
  /// isn't held in memory at full size while the user drags the frame.
  static const _maxWorkingEdgePx = 1200;

  static const _maxEncodedBytes = 250 * 1024;

  /// Tried in order until one lands under [_maxEncodedBytes]; the last is
  /// used regardless. 85 is visually indistinguishable at this size, and
  /// even 65 is fine for a photo printed as a ~43 mm circle.
  static const _qualitySteps = [85, 75, 65];

  /// Decodes an arbitrary picked image and returns a modest JPEG to hand
  /// the cropper, or `null` if the bytes aren't an image this can read.
  ///
  /// This is the only full-size decode in the pipeline, and it does three
  /// things the browser can't be relied on to do for us:
  ///  - [img.bakeOrientation] applies the EXIF rotation phone cameras
  ///    write instead of rotating pixels, so a portrait photo doesn't
  ///    arrive on its side;
  ///  - a transparent PNG is flattened onto white, because JPEG has no
  ///    alpha channel and would otherwise composite it onto black;
  ///  - the result is bounded by [_maxWorkingEdgePx].
  ///
  /// Returning `null` rather than throwing keeps "the user picked a file
  /// we can't read" an ordinary outcome the caller reports, not an
  /// exception it has to catch.
  Uint8List? prepareForCrop(Uint8List original) {
    final decoded = _decode(original);
    if (decoded == null) return null;
    final upright = img.bakeOrientation(decoded);
    final opaque = _flattenOntoWhite(upright);
    final bounded = _fitWithin(opaque, _maxWorkingEdgePx, _maxWorkingEdgePx);
    return img.encodeJpg(bounded, quality: 90);
  }

  /// Encodes a cropped region, handed over as raw RGBA rows, into the
  /// stored [CvPhoto].
  ///
  /// Raw RGBA rather than an encoded image because that is what
  /// `ui.Image.toByteData` produces — re-encoding to PNG on the way in
  /// just to decode it again here would be pure waste.
  CvPhoto encodeCrop({
    required Uint8List rgbaBytes,
    required int width,
    required int height,
  }) {
    final expected = width * height * 4;
    if (width <= 0 || height <= 0 || rgbaBytes.length != expected) {
      throw ArgumentError(
        'Expected $expected bytes of RGBA for ${width}x$height, '
        'got ${rgbaBytes.length}',
      );
    }

    final cropped = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: rgbaBytes.buffer,
      bytesOffset: rgbaBytes.offsetInBytes,
      numChannels: 4,
      order: img.ChannelOrder.rgba,
    );
    final sized = _fitWithin(cropped, maxStoredEdgePx, maxStoredEdgePx);

    var encoded = img.encodeJpg(sized, quality: _qualitySteps.first);
    for (final quality in _qualitySteps.skip(1)) {
      if (encoded.length <= _maxEncodedBytes) break;
      encoded = img.encodeJpg(sized, quality: quality);
    }

    return CvPhoto(
      jpegBase64: base64Encode(encoded),
      widthPx: sized.width,
      heightPx: sized.height,
    );
  }

  /// `image`'s own `decodeImage` does not reliably return `null` for
  /// input it can't read: format detection runs each decoder's
  /// `isValidFile` in turn, and several of those (PSD, confirmed against
  /// `image` 4.9.2) read past the end of a buffer too short to hold their
  /// header and throw `RangeError` instead. The bytes here come straight
  /// from a file picker, so "not actually an image" is an ordinary input,
  /// not a programming error — this is what makes [prepareForCrop]'s
  /// nullable return mean what it says.
  img.Image? _decode(Uint8List bytes) {
    try {
      return img.decodeImage(bytes);
    } catch (_) {
      return null;
    }
  }

  /// JPEG has no alpha channel, and `encodeJpg` on an image that has one
  /// leaves transparent pixels reading as black — so a logo-style PNG with
  /// a cut-out background would come back with a black surround.
  img.Image _flattenOntoWhite(img.Image source) {
    if (!source.hasAlpha) return source;
    final canvas = img.Image(
      width: source.width,
      height: source.height,
      numChannels: 3,
    );
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(canvas, source);
    return canvas;
  }

  /// Scales down to fit inside the box, preserving aspect ratio. Never
  /// scales *up*: enlarging a small photo adds no detail, only bytes.
  img.Image _fitWithin(img.Image source, int maxWidth, int maxHeight) {
    final scale = [
      1.0,
      maxWidth / source.width,
      maxHeight / source.height,
    ].reduce((a, b) => a < b ? a : b);
    if (scale >= 1.0) return source;
    return img.copyResize(
      source,
      width: (source.width * scale).round().clamp(1, maxWidth),
      height: (source.height * scale).round().clamp(1, maxHeight),
      // A box filter, which is what you want when shrinking by a large
      // factor — cubic sharpens edges that aren't really there.
      interpolation: img.Interpolation.average,
    );
  }
}
