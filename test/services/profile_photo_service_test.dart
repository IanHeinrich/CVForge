import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/profile_photo_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../helpers/test_helpers.dart';

/// A solid-colour image of the given size, as raw RGBA rows — the shape
/// `ui.Image.toByteData(format: rawRgba)` hands back, which is the only
/// input [ProfilePhotoService.encodeCrop] ever sees.
Uint8List _rgba(int width, int height, {int r = 200, int g = 60, int b = 40}) {
  final image = img.Image(width: width, height: height, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(r, g, b, 255));
  return image.getBytes(order: img.ChannelOrder.rgba);
}

void main() {
  group('ProfilePhotoServiceTest -', () {
    late ProfilePhotoService service;

    setUp(() {
      registerServices();
      service = ProfilePhotoService();
    });
    tearDown(() => locator.reset());

    group('prepareForCrop -', () {
      test('returns null for bytes that are not an image, so the caller '
          'can report it rather than catch it', () {
        // Four bytes specifically: short enough that `image`'s own format
        // detection throws RangeError reading a header rather than
        // reporting no match, which is the case the service has to
        // absorb. See `ProfilePhotoService._decode`.
        expect(
          service.prepareForCrop(Uint8List.fromList([1, 2, 3, 4])),
          isNull,
        );
      });

      test('returns null for a well-formed file that is simply not an '
          'image', () {
        final notAnImage = Uint8List.fromList(
          utf8.encode('%PDF-1.7\nnot an image at all, but long enough\n' * 40),
        );

        expect(service.prepareForCrop(notAnImage), isNull);
      });

      test('bounds the long edge, so a phone-camera photo is not held at '
          'full size while the user drags the crop frame', () {
        final huge = img.Image(width: 4000, height: 3000);
        img.fill(huge, color: img.ColorRgb8(10, 120, 200));

        final prepared = service.prepareForCrop(
          Uint8List.fromList(img.encodeJpg(huge)),
        );

        final decoded = img.decodeImage(prepared!)!;
        expect(decoded.width, 1200);
        expect(decoded.height, 900);
      });

      test('leaves a photo already under the bound at its own size', () {
        final small = img.Image(width: 300, height: 400);
        img.fill(small, color: img.ColorRgb8(10, 120, 200));

        final decoded = img.decodeImage(
          service.prepareForCrop(Uint8List.fromList(img.encodeJpg(small)))!,
        )!;

        expect(decoded.width, 300);
        expect(decoded.height, 400);
      });

      test('applies EXIF orientation, so a portrait photo off a phone does '
          'not arrive on its side', () {
        // 6 is "rotate 90° clockwise" — what a phone held upright writes
        // rather than rotating the pixels itself.
        final landscape = img.Image(width: 400, height: 200);
        img.fill(landscape, color: img.ColorRgb8(10, 120, 200));
        landscape.exif.imageIfd.orientation = 6;

        final decoded = img.decodeImage(
          service.prepareForCrop(Uint8List.fromList(img.encodeJpg(landscape)))!,
        )!;

        expect(decoded.width, 200);
        expect(decoded.height, 400);
      });

      test('flattens transparency onto white — JPEG has no alpha channel, '
          'so a cut-out PNG would otherwise come back on black', () {
        final transparent = img.Image(width: 100, height: 100, numChannels: 4);
        img.fill(transparent, color: img.ColorRgba8(0, 0, 0, 0));

        final decoded = img.decodeImage(
          service.prepareForCrop(
            Uint8List.fromList(img.encodePng(transparent)),
          )!,
        )!;

        final pixel = decoded.getPixel(50, 50);
        // JPEG is lossy, so this asserts "white" rather than exactly 255.
        expect(pixel.r, greaterThan(240));
        expect(pixel.g, greaterThan(240));
        expect(pixel.b, greaterThan(240));
      });
    });

    group('encodeCrop -', () {
      test('caps the stored image at the printed circle, so the Vault JSON '
          'that Drive syncs stays small', () {
        final photo = service.encodeCrop(
          rgbaBytes: _rgba(1600, 1600),
          width: 1600,
          height: 1600,
        );

        expect(photo.widthPx, ProfilePhotoService.maxStoredEdgePx);
        expect(photo.heightPx, ProfilePhotoService.maxStoredEdgePx);
        expect(base64Decode(photo.jpegBase64).length, lessThan(250 * 1024));
      });

      test('the crop ratio is square, because the template masks the photo '
          'to a circle — any other ratio would be cropped a second time '
          'against a frame the user never saw', () {
        expect(ProfilePhotoService.cropAspectRatio, 1.0);
      });

      test('reports the dimensions of what it actually stored, not of what '
          'it was handed', () {
        final photo = service.encodeCrop(
          rgbaBytes: _rgba(240, 240),
          width: 240,
          height: 240,
        );

        expect(photo.widthPx, 240);
        expect(photo.heightPx, 240);
        final decoded = img.decodeImage(base64Decode(photo.jpegBase64))!;
        expect(decoded.width, photo.widthPx);
        expect(decoded.height, photo.heightPx);
      });

      test('stays square when it downsizes — the circular mask has no way '
          'to show a photo that drifted off square', () {
        final photo = service.encodeCrop(
          rgbaBytes: _rgba(900, 900),
          width: 900,
          height: 900,
        );

        expect(photo.widthPx, photo.heightPx);
      });

      test('preserves a non-square ratio it is handed anyway, rather than '
          'squashing it — the cropper locks to square, but a photo stored '
          'before it did must still round-trip its own shape', () {
        final photo = service.encodeCrop(
          rgbaBytes: _rgba(700, 900),
          width: 700,
          height: 900,
        );

        expect(photo.widthPx / photo.heightPx, closeTo(700 / 900, 0.01));
      });

      test('round-trips the pixels it was given', () {
        final photo = service.encodeCrop(
          rgbaBytes: _rgba(210, 270, r: 200, g: 60, b: 40),
          width: 210,
          height: 270,
        );

        final pixel = img
            .decodeImage(base64Decode(photo.jpegBase64))!
            .getPixel(105, 135);
        expect(pixel.r, closeTo(200, 8));
        expect(pixel.g, closeTo(60, 8));
        expect(pixel.b, closeTo(40, 8));
      });

      test('throws on a byte count that does not match the stated size — a '
          'caller bug, not a user-facing outcome', () {
        expect(
          () => service.encodeCrop(
            rgbaBytes: _rgba(10, 10),
            width: 20,
            height: 20,
          ),
          throwsArgumentError,
        );
      });
    });
  });
}
