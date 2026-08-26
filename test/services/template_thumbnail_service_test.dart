import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/services/pdf_export_service.dart';
import 'package:cv_forge/services/template_thumbnail_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

ResolvedCv _fixtureCv({String fullName = 'Jordan Ellery'}) => ResolvedCv(
  header: ResolvedHeader(
    fullName: fullName,
    headline: 'Senior Software Engineer',
    email: 'jordan.ellery@example.com',
    phone: '+44 7700 900123',
    location: 'Manchester',
    contactLabels: kEnglishContactLabels,
  ),
  sections: const [],
);

/// A tiny in-memory raster — real dimensions/pixels so `PdfRaster.toPng`
/// (which decodes through `dart:ui`) succeeds, standing in for
/// `Printing.raster`'s real, FFI-backed implementation that only runs on
/// macOS/iOS — see [TemplateThumbnailService]'s constructor doc comment.
Stream<PdfRaster> _fakeRaster(
  Uint8List document, {
  List<int>? pages,
  double dpi = PdfPageFormat.inch,
}) => Stream.value(PdfRaster(2, 2, Uint8List(2 * 2 * 4)));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TemplateThumbnailServiceTest -', () {
    late MockPdfExportService pdfExport;

    setUp(() {
      registerServices();
      pdfExport = getAndRegisterPdfExportService();
      when(
        pdfExport.render(
          cv: anyNamed('cv'),
          templateId: anyNamed('templateId'),
          format: anyNamed('format'),
          compress: anyNamed('compress'),
        ),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
    });
    tearDown(() => locator.reset());

    test('produces a thumbnail for a known template', () async {
      final service = TemplateThumbnailService(raster: _fakeRaster);

      final png = await service.thumbnail(
        cv: _fixtureCv(),
        templateId: 'compact',
        format: PdfPageFormat.a4,
      );

      expect(png, isNotEmpty);
    });

    test(
      'a second call for the same (templateId, cv) does not re-render',
      () async {
        final service = TemplateThumbnailService(raster: _fakeRaster);
        final cv = _fixtureCv();

        await service.thumbnail(
          cv: cv,
          templateId: 'compact',
          format: PdfPageFormat.a4,
        );
        await service.thumbnail(
          cv: cv,
          templateId: 'compact',
          format: PdfPageFormat.a4,
        );

        verify(
          pdfExport.render(
            cv: anyNamed('cv'),
            templateId: anyNamed('templateId'),
            format: anyNamed('format'),
            compress: anyNamed('compress'),
          ),
        ).called(1);
      },
    );

    test('a different cv does re-render', () async {
      final service = TemplateThumbnailService(raster: _fakeRaster);

      await service.thumbnail(
        cv: _fixtureCv(),
        templateId: 'compact',
        format: PdfPageFormat.a4,
      );
      await service.thumbnail(
        cv: _fixtureCv(fullName: 'Alex Rowe'),
        templateId: 'compact',
        format: PdfPageFormat.a4,
      );

      verify(
        pdfExport.render(
          cv: anyNamed('cv'),
          templateId: anyNamed('templateId'),
          format: anyNamed('format'),
          compress: anyNamed('compress'),
        ),
      ).called(2);
    });

    test('a PdfExportException propagates rather than returning empty '
        'bytes', () async {
      when(
        pdfExport.render(
          cv: anyNamed('cv'),
          templateId: anyNamed('templateId'),
          format: anyNamed('format'),
          compress: anyNamed('compress'),
        ),
      ).thenThrow(const PdfExportException(PdfExportStage.render, 'boom'));
      final service = TemplateThumbnailService(raster: _fakeRaster);

      await expectLater(
        service.thumbnail(
          cv: _fixtureCv(),
          templateId: 'compact',
          format: PdfPageFormat.a4,
        ),
        throwsA(isA<PdfExportException>()),
      );
    });
  });
}
