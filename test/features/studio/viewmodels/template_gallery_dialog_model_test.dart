import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/dialogs/template_gallery/template_gallery_dialog_data.dart';
import 'package:cv_forge/features/studio/dialogs/template_gallery/template_gallery_dialog_model.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/templates/cv_template.dart';
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

    test('tagGroups files every template under its first declared tag, in '
        "TemplateTag's own declaration order", () {
      final model = buildModel();

      final groups = model.tagGroups;

      // compact declares {atsSafe, compact}; classic_centered declares
      // {traditional, academic} — atsSafe sorts before traditional in
      // TemplateTag.values, so compact's group must come first regardless
      // of registration order.
      expect(groups.map((g) => g.key), [
        TemplateTag.atsSafe,
        TemplateTag.traditional,
      ]);
      expect(groups[0].value.map((t) => t.id), ['compact']);
      expect(groups[1].value.map((t) => t.id), ['classic_centered']);
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
