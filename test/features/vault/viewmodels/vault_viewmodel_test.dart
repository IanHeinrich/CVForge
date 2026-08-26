import 'dart:typed_data';

import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/features/studio/dialogs/region_gallery/region_gallery_dialog_data.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/features/studio/dialogs/template_gallery/template_gallery_dialog_data.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/vault/dialogs/crop_photo/crop_photo_dialog_data.dart';
import 'package:cv_forge/features/vault/views/vault/vault_viewmodel.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_photo.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('VaultViewModel Tests -', () {
    late MockVaultService vaultService;
    late MockDialogService dialogService;
    late MockFileUploadService fileUpload;
    late MockProfilePhotoService photoService;

    setUp(() {
      vaultService = getAndRegisterVaultService();
      dialogService = getAndRegisterDialogService();
      getAndRegisterLocalizationService();
      getAndRegisterTemplateRegistryService();
      fileUpload = getAndRegisterFileUploadService();
      photoService = getAndRegisterProfilePhotoService();
      when(vaultService.vault).thenReturn(CvVault.empty());
    });
    tearDown(() => locator.reset());

    group('initialise -', () {
      test(
        'loads VaultService — this is what makes a deep-link/refresh '
        'straight to /vault work rather than showing a false empty state',
        () async {
          when(vaultService.load()).thenAnswer((_) => Future<void>.value());

          final model = VaultViewModel();
          model.initialise();
          expect(model.isLoading, isTrue);

          await pumpEventQueue();

          verify(vaultService.load()).called(1);
          expect(model.isLoading, isFalse);
          expect(model.hasLoadError, isFalse);
        },
      );

      test(
        'a failed load surfaces via hasLoadError, and is retryable by '
        'calling initialise again — the failure must not be a dead end',
        () async {
          when(vaultService.load()).thenThrow(Exception('boom'));

          final model = VaultViewModel();
          model.initialise();
          await pumpEventQueue();

          expect(model.hasLoadError, isTrue);

          when(vaultService.load()).thenAnswer((_) => Future<void>.value());
          model.initialise();
          await pumpEventQueue();

          expect(model.hasLoadError, isFalse);
        },
      );

      test('showEmptyState stays false while a load is in flight, even though '
          'CvVault.empty() is the placeholder value until it resolves — '
          'otherwise "Load example CV" could overwrite real data still '
          'loading in the background', () async {
        when(vaultService.load()).thenAnswer((_) => Future<void>.value());

        final model = VaultViewModel();
        model.initialise();

        expect(model.isLoading, isTrue);
        expect(model.showEmptyState, isFalse);
      });
    });

    test('addExperience creates a blank experience via VaultService and '
        'opens its editor', () async {
      final created = Experience(
        id: 'exp-new',
        role: '',
        company: '',
        location: '',
        start: const YearMonth(year: 2026, month: 1),
      );
      when(
        vaultService.addExperience(
          role: anyNamed('role'),
          company: anyNamed('company'),
          location: anyNamed('location'),
          start: anyNamed('start'),
        ),
      ).thenAnswer((_) async => created);

      final model = VaultViewModel();
      await model.addExperience();

      verify(
        vaultService.addExperience(
          role: '',
          company: '',
          location: '',
          start: anyNamed('start'),
        ),
      ).called(1);
      expect(model.openTarget, VaultEditorTarget.experience);
      expect(model.openId, 'exp-new');
    });

    test('updateExperience delegates the exact object passed', () async {
      final experience = Experience(
        id: 'exp-1',
        role: 'Senior Engineer',
        company: 'Acme',
        location: 'London',
        start: const YearMonth(year: 2020, month: 1),
      );
      when(
        vaultService.updateExperience(any),
      ).thenAnswer((_) => Future<void>.value());

      final model = VaultViewModel();
      await model.updateExperience(experience);

      verify(vaultService.updateExperience(experience)).called(1);
    });

    test('deleteExperience prompts for confirmation and only deletes when '
        'confirmed', () async {
      when(
        dialogService.showCustomDialog(
          variant: anyNamed('variant'),
          title: anyNamed('title'),
          description: anyNamed('description'),
          mainButtonTitle: anyNamed('mainButtonTitle'),
          secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
        ),
      ).thenAnswer((_) async => DialogResponse(confirmed: true));
      when(
        vaultService.deleteExperience(any),
      ).thenAnswer((_) => Future<void>.value());

      final model = VaultViewModel();
      await model.deleteExperience('exp-1');

      verify(
        dialogService.showCustomDialog(
          variant: anyNamed('variant'),
          title: anyNamed('title'),
          description: anyNamed('description'),
          mainButtonTitle: anyNamed('mainButtonTitle'),
          secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
        ),
      ).called(1);
      verify(vaultService.deleteExperience('exp-1')).called(1);
    });

    test('cancelling the confirmation dialog deletes nothing', () async {
      when(
        dialogService.showCustomDialog(
          variant: anyNamed('variant'),
          title: anyNamed('title'),
          description: anyNamed('description'),
          mainButtonTitle: anyNamed('mainButtonTitle'),
          secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
        ),
      ).thenAnswer((_) async => DialogResponse(confirmed: false));

      final model = VaultViewModel();
      await model.deleteExperience('exp-1');

      verifyNever(vaultService.deleteExperience(any));
    });

    test(
      'loadExampleVault populates the vault and dismisses the empty state',
      () async {
        when(
          vaultService.loadExampleVault(),
        ).thenAnswer((_) => Future<void>.value());

        final model = VaultViewModel();
        expect(model.showEmptyState, isTrue);

        await model.loadExampleVault();

        verify(vaultService.loadExampleVault()).called(1);
        expect(model.showEmptyState, isFalse);
      },
    );

    group('photo -', () {
      final picked = Uint8List.fromList([1, 2, 3]);
      final prepared = Uint8List.fromList([4, 5, 6]);
      const photo = CvPhoto(jpegBase64: 'AAAA', widthPx: 420, heightPx: 540);

      void stubCropDialog(DialogResponse<CvPhoto>? response) {
        when(
          dialogService.showCustomDialog<CvPhoto, CropPhotoDialogData>(
            variant: anyNamed('variant'),
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => response);
      }

      test('a cancelled file picker leaves the Vault untouched', () async {
        when(fileUpload.pickImageFile()).thenAnswer((_) async => null);

        await VaultViewModel().pickPhoto();

        verifyNever(vaultService.updateBasics(any));
        verifyNever(photoService.prepareForCrop(argThat(isA<Uint8List>())));
      });

      test('a cancelled crop dialog leaves the Vault untouched — backing '
          'out of framing must not clear an existing photo', () async {
        when(fileUpload.pickImageFile()).thenAnswer((_) async => picked);
        when(photoService.prepareForCrop(picked)).thenReturn(prepared);
        stubCropDialog(DialogResponse<CvPhoto>(confirmed: false));

        await VaultViewModel().pickPhoto();

        verifyNever(vaultService.updateBasics(any));
      });

      test('a confirmed crop stores the photo on the Vault basics', () async {
        when(fileUpload.pickImageFile()).thenAnswer((_) async => picked);
        when(photoService.prepareForCrop(picked)).thenReturn(prepared);
        stubCropDialog(DialogResponse<CvPhoto>(confirmed: true, data: photo));

        final model = VaultViewModel();
        await model.pickPhoto();

        final captured =
            verify(vaultService.updateBasics(captureAny)).captured.single
                as ContactBasics;
        expect(captured.photo, photo);
        expect(model.photoError, isNull);
        expect(model.photoBusy, isFalse);
      });

      test('an undecodable file is reported rather than silently dropped, '
          'and never reaches the crop dialog', () async {
        when(fileUpload.pickImageFile()).thenAnswer((_) async => picked);
        when(photoService.prepareForCrop(picked)).thenReturn(null);

        final model = VaultViewModel();
        await model.pickPhoto();

        expect(model.photoError, isNotNull);
        expect(model.photoBusy, isFalse);
        verifyNever(vaultService.updateBasics(any));
        verifyNever(
          dialogService.showCustomDialog<CvPhoto, CropPhotoDialogData>(
            variant: anyNamed('variant'),
            data: anyNamed('data'),
          ),
        );
      });

      test('a previous error clears when the next pick succeeds', () async {
        when(fileUpload.pickImageFile()).thenAnswer((_) async => picked);
        when(photoService.prepareForCrop(picked)).thenReturn(null);
        final model = VaultViewModel();
        await model.pickPhoto();
        expect(model.photoError, isNotNull);

        when(photoService.prepareForCrop(picked)).thenReturn(prepared);
        stubCropDialog(DialogResponse<CvPhoto>(confirmed: true, data: photo));
        await model.pickPhoto();

        expect(model.photoError, isNull);
      });

      test('removePhoto clears the field rather than leaving the old bytes '
          'behind', () async {
        when(vaultService.vault).thenReturn(
          CvVault.empty().copyWith(
            basics: ContactBasics.empty().copyWith(photo: photo),
          ),
        );

        await VaultViewModel().removePhoto();

        final captured =
            verify(vaultService.updateBasics(captureAny)).captured.single
                as ContactBasics;
        expect(captured.photo, isNull);
      });
    });

    group('consumeInvalidUrlNotice -', () {
      test('is false for a plain visit — the toast only fires when the '
          'wildcard redirect actually sent someone here', () {
        final model = VaultViewModel();

        expect(model.consumeInvalidUrlNotice(), isFalse);
      });

      test('fires exactly once when constructed via the invalid-URL redirect '
          '— a rebuild (e.g. once loading finishes) must not show the toast '
          'again', () {
        final model = VaultViewModel(cameFromInvalidUrl: true);

        expect(model.consumeInvalidUrlNotice(), isTrue);
        expect(model.consumeInvalidUrlNotice(), isFalse);
        expect(model.consumeInvalidUrlNotice(), isFalse);
      });
    });

    group('document defaults -', () {
      void stubPicker(DialogResponse<RegionProfile>? response) {
        when(
          dialogService
              .showCustomDialog<RegionProfile, RegionGalleryDialogData>(
                variant: anyNamed('variant'),
                data: anyNamed('data'),
              ),
        ).thenAnswer((_) async => response);
      }

      test('the defaults card opens the panel, like every other card', () {
        final model = VaultViewModel();

        model.openDocumentDefaultsEditor();

        expect(model.openTarget, VaultEditorTarget.documentDefaults);
        expect(model.isEditorOpen, isTrue);
      });

      test('openDefaultRegionPicker opens the shared picker in its '
          'vaultDefault context, seeded with the current default', () async {
        when(vaultService.vault).thenReturn(
          CvVault.empty().copyWith(
            documentDefaults: const DocumentDefaults(
              region: RegionProfile.nordics,
            ),
          ),
        );
        stubPicker(DialogResponse<RegionProfile>(confirmed: false));

        await VaultViewModel().openDefaultRegionPicker();

        final data =
            verify(
                  dialogService
                      .showCustomDialog<RegionProfile, RegionGalleryDialogData>(
                        variant: DialogType.regionGallery,
                        data: captureAnyNamed('data'),
                      ),
                ).captured.single
                as RegionGalleryDialogData;

        expect(data.context, RegionGalleryContext.vaultDefault);
        expect(data.currentRegion, RegionProfile.nordics);
      });

      test('a confirmed region lands on the Vault without disturbing the '
          'language beside it', () async {
        when(vaultService.vault).thenReturn(
          CvVault.empty().copyWith(
            documentDefaults: const DocumentDefaults(
              language: DocumentLanguage.nl,
            ),
          ),
        );
        stubPicker(
          DialogResponse<RegionProfile>(
            confirmed: true,
            data: RegionProfile.dach,
          ),
        );
        when(
          vaultService.setDocumentDefaults(any),
        ).thenAnswer((_) => Future<void>.value());

        await VaultViewModel().openDefaultRegionPicker();

        final saved =
            verify(vaultService.setDocumentDefaults(captureAny)).captured.single
                as DocumentDefaults;
        expect(saved.region, RegionProfile.dach);
        expect(saved.language, DocumentLanguage.nl);
      });

      test('cancelling leaves the defaults alone', () async {
        stubPicker(DialogResponse<RegionProfile>(confirmed: false));

        await VaultViewModel().openDefaultRegionPicker();

        verifyNever(vaultService.setDocumentDefaults(any));
      });

      test('setDocumentLanguage keeps the region beside it', () async {
        when(vaultService.vault).thenReturn(
          CvVault.empty().copyWith(
            documentDefaults: const DocumentDefaults(
              region: RegionProfile.latamA4,
            ),
          ),
        );
        when(
          vaultService.setDocumentDefaults(any),
        ).thenAnswer((_) => Future<void>.value());

        await VaultViewModel().setDocumentLanguage(DocumentLanguage.ptBr);

        final saved =
            verify(vaultService.setDocumentDefaults(captureAny)).captured.single
                as DocumentDefaults;
        expect(saved.language, DocumentLanguage.ptBr);
        expect(saved.region, RegionProfile.latamA4);
      });
    });

    group('default template and sections -', () {
      void stubVault(DocumentDefaults defaults) {
        when(
          vaultService.vault,
        ).thenReturn(CvVault.empty().copyWith(documentDefaults: defaults));
        when(
          vaultService.setDocumentDefaults(any),
        ).thenAnswer((_) => Future<void>.value());
      }

      DocumentDefaults captureSaved() =>
          verify(vaultService.setDocumentDefaults(captureAny)).captured.single
              as DocumentDefaults;

      test('defaultTemplate falls back to the registry when none is set', () {
        stubVault(const DocumentDefaults());

        expect(
          VaultViewModel().defaultTemplate.id,
          TemplateRegistryService().defaultTemplate.id,
        );
      });

      test('defaultTemplate falls back for an id no longer registered, '
          'rather than leaving the panel with nothing to show', () {
        stubVault(const DocumentDefaults(templateId: 'deleted_template'));

        expect(
          VaultViewModel().defaultTemplate.id,
          TemplateRegistryService().defaultTemplate.id,
        );
      });

      test('defaultSectionOrder is complete even when the stored one '
          'predates a section type', () {
        stubVault(
          const DocumentDefaults(
            sectionOrder: [CvSectionType.skills, CvSectionType.summary],
          ),
        );

        final order = VaultViewModel().defaultSectionOrder;

        expect(order.take(2), [CvSectionType.skills, CvSectionType.summary]);
        expect(order.toSet(), CvSectionType.values.toSet());
      });

      test('reorderDefaultSections writes the whole order', () async {
        stubVault(const DocumentDefaults(sectionOrder: CvSectionType.values));

        // Move the last section to the front.
        await VaultViewModel().reorderDefaultSections(
          CvSectionType.values.length - 1,
          0,
        );

        expect(captureSaved().sectionOrder!.first, CvSectionType.values.last);
      });

      test('toggleDefaultSectionHidden hides, then shows again', () async {
        stubVault(const DocumentDefaults(sectionOrder: CvSectionType.values));

        await VaultViewModel().toggleDefaultSectionHidden(
          CvSectionType.hobbies,
        );
        expect(captureSaved().hiddenSections, {CvSectionType.hobbies});

        stubVault(
          const DocumentDefaults(
            sectionOrder: CvSectionType.values,
            hiddenSections: {CvSectionType.hobbies},
          ),
        );
        await VaultViewModel().toggleDefaultSectionHidden(
          CvSectionType.hobbies,
        );
        expect(captureSaved().hiddenSections, isEmpty);
      });

      test('hiding a section pins the order that was only implied by the '
          'template, so a later template change cannot reorder it', () async {
        stubVault(const DocumentDefaults());

        await VaultViewModel().toggleDefaultSectionHidden(
          CvSectionType.hobbies,
        );

        expect(captureSaved().sectionOrder, isNotNull);
      });

      test(
        'the template picker saves the chosen id and keeps the rest',
        () async {
          stubVault(
            const DocumentDefaults(
              region: RegionProfile.dach,
              language: DocumentLanguage.deAt,
            ),
          );
          when(
            dialogService.showCustomDialog<String, TemplateGalleryDialogData>(
              variant: anyNamed('variant'),
              data: anyNamed('data'),
            ),
          ).thenAnswer(
            (_) async =>
                DialogResponse<String>(confirmed: true, data: 'photo_header'),
          );

          await VaultViewModel().openDefaultTemplatePicker();

          final saved = captureSaved();
          expect(saved.templateId, 'photo_header');
          expect(saved.region, RegionProfile.dach);
          expect(saved.language, DocumentLanguage.deAt);
        },
      );

      test(
        'cancelling the template picker leaves the defaults alone',
        () async {
          stubVault(const DocumentDefaults());
          when(
            dialogService.showCustomDialog<String, TemplateGalleryDialogData>(
              variant: anyNamed('variant'),
              data: anyNamed('data'),
            ),
          ).thenAnswer((_) async => DialogResponse<String>(confirmed: false));

          await VaultViewModel().openDefaultTemplatePicker();

          verifyNever(vaultService.setDocumentDefaults(any));
        },
      );
    });

    group('search -', () {
      const languages = SkillCategory(
        id: 'cat-1',
        name: 'Languages',
        skills: [
          Skill(id: 's1', label: 'Dart'),
          Skill(id: 's2', label: 'Python'),
        ],
      );
      const tooling = SkillCategory(
        id: 'cat-2',
        name: 'Tooling',
        skills: [Skill(id: 's3', label: 'Docker')],
      );

      VaultViewModel modelSearching(String? query) {
        when(vaultService.vault).thenReturn(
          vaultWith(
            skillCategories: const [languages, tooling],
            hobbies: const [
              HobbyItem(id: 'h1', text: 'Climbing'),
              HobbyItem(id: 'h2', text: 'Chess'),
            ],
            basics: const ContactBasics(
              fullName: 'Jordan Ellery',
              headline: 'Senior Engineer',
              email: 'jordan@example.com',
              phone: '',
              location: '',
              summary: 'Builds reliable systems.',
            ),
          ),
        );
        final model = VaultViewModel();
        if (query != null) model.setQuery(query);
        return model;
      }

      test('an empty query leaves every section unfiltered', () {
        final model = modelSearching(null);

        expect(model.isSearching, isFalse);
        expect(model.filteredSkillCategories, hasLength(2));
        expect(model.filteredHobbies, hasLength(2));
        expect(model.basicsMatchQuery, isTrue);
      });

      test(
        'a query matching a category name keeps all of its skills — the '
        'category is what matched, so narrowing it would hide the reason',
        () {
          final model = modelSearching('tooling');

          expect(model.filteredSkillCategories, hasLength(1));
          expect(model.filteredSkillCategories.single.name, 'Tooling');
          expect(model.filteredSkillCategories.single.skills, hasLength(1));
        },
      );

      test('a query matching one skill keeps only that skill', () {
        final model = modelSearching('python');

        expect(model.filteredSkillCategories, hasLength(1));
        final category = model.filteredSkillCategories.single;
        expect(category.name, 'Languages');
        expect(category.skills.map((s) => s.label), ['Python']);
      });

      test('a query matching no skill or category empties the list', () {
        expect(modelSearching('kubernetes').filteredSkillCategories, isEmpty);
      });

      test('hobbies filter on their text', () {
        expect(modelSearching('chess').filteredHobbies.single.text, 'Chess');
        expect(modelSearching('sailing').filteredHobbies, isEmpty);
      });

      test('basics match on name, headline, email or summary', () {
        expect(modelSearching('ellery').basicsMatchQuery, isTrue);
        expect(modelSearching('senior').basicsMatchQuery, isTrue);
        expect(modelSearching('example.com').basicsMatchQuery, isTrue);
        expect(modelSearching('reliable').basicsMatchQuery, isTrue);
        expect(modelSearching('kubernetes').basicsMatchQuery, isFalse);
      });

      test(
        'search reads what a field prints, not the emphasis markers around '
        'it — a word someone bolded is still the word they will look for',
        () {
          when(vaultService.vault).thenReturn(
            vaultWith(
              experiences: const [
                Experience(
                  id: 'e1',
                  role: '**Senior** Platform Engineer',
                  company: 'Acme',
                  location: 'London',
                  start: YearMonth(year: 2020, month: 1),
                ),
              ],
              hobbies: const [HobbyItem(id: 'h1', text: 'Competitive *chess*')],
              basics: const ContactBasics(
                fullName: 'Jordan Ellery',
                headline: 'Builds **reliable** systems',
                email: 'jordan@example.com',
                phone: '',
                location: '',
              ),
            ),
          );

          final model = VaultViewModel()..setQuery('senior');
          expect(model.filteredExperiences, hasLength(1));

          expect(
            (VaultViewModel()..setQuery('chess')).filteredHobbies,
            hasLength(1),
          );
          expect(
            (VaultViewModel()..setQuery('reliable')).basicsMatchQuery,
            isTrue,
          );
        },
      );

      test('a query spanning a marker finds nothing, because that is not what '
          'the field says', () {
        when(vaultService.vault).thenReturn(
          vaultWith(
            experiences: const [
              Experience(
                id: 'e1',
                role: '**Senior** Engineer',
                company: 'Acme',
                location: 'London',
                start: YearMonth(year: 2020, month: 1),
              ),
            ],
          ),
        );

        expect(
          (VaultViewModel()..setQuery('**senior')).filteredExperiences,
          isEmpty,
        );
      });
    });
  });
}
