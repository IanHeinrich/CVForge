import 'dart:typed_data';

import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/features/studio/dialogs/region_gallery/region_gallery_dialog_data.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/vault/dialogs/crop_photo/crop_photo_dialog_data.dart';
import 'package:cv_forge/features/vault/views/vault/vault_viewmodel.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_photo.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

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
  });
}
