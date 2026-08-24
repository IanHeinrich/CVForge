import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('TemplateRegistryServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    test('byId falls back to the default template for an unknown id, '
        'rather than throwing', () {
      final service = TemplateRegistryService();

      final template = service.byId('does-not-exist');

      expect(template.id, service.defaultTemplate.id);
    });

    test('byId resolves a known id to the matching template', () {
      final service = TemplateRegistryService();
      final knownId = service.defaultTemplate.id;

      expect(service.byId(knownId).id, knownId);
    });

    test('byId resolves classic_centered, not just the default template', () {
      final service = TemplateRegistryService();

      expect(service.byId('classic_centered').id, 'classic_centered');
    });

    test('byId resolves photo_header', () {
      final service = TemplateRegistryService();

      expect(service.byId('photo_header').id, 'photo_header');
    });

    test('the default template does not print a photo — a new draft must '
        'never start out carrying one', () {
      final service = TemplateRegistryService();

      expect(service.defaultTemplate.tags, isNot(contains(TemplateTag.photo)));
    });

    test('exactly one template declares TemplateTag.photo, since that tag '
        "is what StudioViewModel's region advisory keys on", () {
      final service = TemplateRegistryService();

      final withPhoto = service.available
          .where((t) => t.tags.contains(TemplateTag.photo))
          .map((t) => t.id);

      expect(withPhoto, ['photo_header']);
    });

    test('no template claims both atsSafe and photo — a photograph is a '
        'screening liability wherever it is not expected, so the pair '
        'would be a comfortable lie on the gallery card', () {
      final service = TemplateRegistryService();

      for (final template in service.available) {
        expect(
          template.tags.containsAll({TemplateTag.atsSafe, TemplateTag.photo}),
          isFalse,
          reason: '${template.id} declares both',
        );
      }
    });

    test('available lists every registered template, each with a distinct '
        'sectionOrder covering every CvSectionType exactly once', () {
      final service = TemplateRegistryService();

      final ids = service.available.map((t) => t.id).toList();
      expect(ids, containsAll(['compact', 'classic_centered', 'photo_header']));
      for (final template in service.available) {
        expect(
          template.sectionOrder.toSet(),
          CvSectionType.values.toSet(),
          reason:
              '${template.id}.sectionOrder must be a permutation of every '
              'CvSectionType, or CvComposer would silently drop whichever '
              "section is missing even when the user's draft includes it",
        );
      }
    });

    test('every registered template declares at least one tag, or the '
        'gallery would have nowhere to group it', () {
      final service = TemplateRegistryService();

      for (final template in service.available) {
        expect(
          template.tags,
          isNotEmpty,
          reason: '${template.id}.tags must be non-empty',
        );
      }
    });
  });
}
