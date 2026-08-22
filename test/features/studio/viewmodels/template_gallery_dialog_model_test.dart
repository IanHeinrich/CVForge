import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/dialogs/template_gallery/template_gallery_dialog_data.dart';
import 'package:cv_forge/features/studio/dialogs/template_gallery/template_gallery_dialog_model.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pdf/pdf.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

final _cv = ResolvedCv(
  header: const ResolvedHeader(
    fullName: 'Jordan Ellery',
    headline: 'Senior Software Engineer',
    email: 'jordan.ellery@example.com',
    phone: '+44 7700 900123',
    location: 'Manchester',
  ),
  sections: const [],
);

void main() {
  group('TemplateGalleryDialogModel Tests -', () {
    late MockTemplateThumbnailService thumbnailService;

    setUp(() {
      registerServices();
      getAndRegisterTemplateRegistryService();
      thumbnailService = getAndRegisterTemplateThumbnailService();
    });
    tearDown(() => locator.reset());

    TemplateGalleryDialogModel buildModel({
      String currentTemplateId = 'compact',
    }) => TemplateGalleryDialogModel(
      data: TemplateGalleryDialogData(
        currentTemplateId: currentTemplateId,
        cv: _cv,
        pageFormat: PdfPageFormat.a4,
      ),
    );

    test('starts with the current template already selected', () {
      final model = buildModel(currentTemplateId: 'classic_centered');

      expect(model.selectedTemplateId, 'classic_centered');
    });

    test('selectTemplate updates selectedTemplateId and notifies', () {
      final model = buildModel();
      var notified = false;
      model.addListener(() => notified = true);

      model.selectTemplate('classic_centered');

      expect(model.selectedTemplateId, 'classic_centered');
      expect(notified, isTrue);
    });

    test('templates exposes every registered template, in registry order', () {
      final model = buildModel();

      expect(model.templates.map((t) => t.id), ['compact', 'classic_centered']);
    });

    test('thumbnailFor caches: the underlying service is only asked once '
        'per template id', () async {
      when(
        thumbnailService.thumbnail(
          cv: anyNamed('cv'),
          templateId: anyNamed('templateId'),
          format: anyNamed('format'),
        ),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      final model = buildModel();

      await model.thumbnailFor('compact');
      await model.thumbnailFor('compact');

      verify(
        thumbnailService.thumbnail(
          cv: anyNamed('cv'),
          templateId: anyNamed('templateId'),
          format: anyNamed('format'),
        ),
      ).called(1);
    });
  });
}
