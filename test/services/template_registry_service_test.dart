import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/ui/common/l10n/model_labels.dart';
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

    test('every registered template resolves to a name and a description '
        'in every supported locale — the copy lives in the ARB now, so a '
        'template added without it would render a blank card', () {
      final service = TemplateRegistryService();

      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        for (final template in service.available) {
          expect(
            templateDisplayName(l10n, template.id),
            isNot(template.id),
            reason:
                '${template.id} has no name in ${locale.languageCode} — the '
                'lookup fell through to the raw id',
          );
          expect(
            templateDescriptionFor(l10n, template.id),
            isNotEmpty,
            reason:
                '${template.id} has no description in '
                '${locale.languageCode}',
          );
        }
      }
    });

    test('a template tagged photo says so in its description, in every '
        'locale — the tag is a parseability claim and carries no warning of '
        'its own, so the market risk has to survive translation', () {
      final service = TemplateRegistryService();

      // Replaces an earlier rule forbidding atsSafe and photo together.
      // That conflated two different risks: whether a parser can read the
      // page (it can — real text, single column) and whether a human
      // screener in a given market wants a photograph on it. Withholding
      // the machine-readability tag to imply the second made both claims
      // unreadable, so the warning lives in prose instead.
      //
      // Asserted per locale rather than against one English source: the
      // description a reader sees is the translated one, so an English-only
      // check would pass while the Spanish card said nothing.
      const photoWord = {'en': 'photo', 'es': 'foto'};

      final withPhoto = service.available.where(
        (t) => t.tags.contains(TemplateTag.photo),
      );

      for (final locale in AppLocalizations.supportedLocales) {
        final needle = photoWord[locale.languageCode];
        expect(
          needle,
          isNotNull,
          reason:
              'no photo-word for ${locale.languageCode}; add one so this '
              'guarantee keeps holding for the new locale',
        );
        final l10n = lookupAppLocalizations(locale);
        for (final template in withPhoto) {
          expect(
            templateDescriptionFor(l10n, template.id).toLowerCase(),
            contains(needle!),
            reason:
                '${template.id} prints a photograph but never mentions it in '
                'the ${locale.languageCode} description a reader sees',
          );
        }
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
