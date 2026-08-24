import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/vault/views/vault/vault_viewmodel.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
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

    setUp(() {
      vaultService = getAndRegisterVaultService();
      dialogService = getAndRegisterDialogService();
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

    group('year field validation -', () {
      final experience = Experience(
        id: 'exp-1',
        role: 'Engineer',
        company: 'Acme',
        location: 'London',
        start: const YearMonth(year: 2020, month: 1),
      );

      test('updateExperienceStartYear rejects an out-of-range year with an '
          'error, rather than silently discarding it — the field must be '
          'unreachable once the value is invalid, per 7.8', () async {
        final model = VaultViewModel();

        await model.updateExperienceStartYear(experience, '13000');

        expect(model.experienceStartYearError(experience.id), isNotNull);
        verifyNever(vaultService.updateExperience(any));
      });

      test('updateExperienceStartYear rejects non-numeric text with an '
          'error', () async {
        final model = VaultViewModel();

        await model.updateExperienceStartYear(experience, 'abc');

        expect(model.experienceStartYearError(experience.id), isNotNull);
        verifyNever(vaultService.updateExperience(any));
      });

      test('updateExperienceStartYear commits a valid year and clears the '
          'error', () async {
        when(
          vaultService.updateExperience(any),
        ).thenAnswer((_) => Future<void>.value());
        final model = VaultViewModel();
        await model.updateExperienceStartYear(experience, 'abc');
        expect(model.experienceStartYearError(experience.id), isNotNull);

        await model.updateExperienceStartYear(experience, '2019');

        expect(model.experienceStartYearError(experience.id), isNull);
        verify(
          vaultService.updateExperience(
            experience.copyWith(start: experience.start.copyWith(year: 2019)),
          ),
        ).called(1);
      });

      test('updateExperienceEndYear seeds a null end from the current year, '
          'not from start — adopting start\'s year silently produced a '
          "plausible-looking but wrong date (7.8's Failure 3)", () async {
        when(
          vaultService.updateExperience(any),
        ).thenAnswer((_) => Future<void>.value());
        final model = VaultViewModel();

        await model.updateExperienceEndYear(experience, '2022');

        final captured =
            verify(vaultService.updateExperience(captureAny)).captured.single
                as Experience;
        expect(captured.end?.year, 2022);
        expect(captured.end?.month, experience.start.month);
        expect(captured.end?.year, isNot(experience.start.year));
      });

      test('updateEducationYear treats an empty field as valid, clearing '
          "the year — it's optional, unlike a start/end year", () async {
        const education = Education(
          id: 'edu-1',
          qualification: 'BSc Computing',
          institution: 'Leeds',
          year: 2018,
        );
        when(
          vaultService.updateEducation(any),
        ).thenAnswer((_) => Future<void>.value());
        final model = VaultViewModel();

        await model.updateEducationYear(education, '');

        expect(model.educationYearError(education.id), isNull);
        verify(
          vaultService.updateEducation(education.copyWith(year: null)),
        ).called(1);
      });

      test('updateEducationYear rejects invalid non-empty text with an '
          'error', () async {
        const education = Education(
          id: 'edu-1',
          qualification: 'BSc Computing',
          institution: 'Leeds',
        );
        final model = VaultViewModel();

        await model.updateEducationYear(education, 'not a year');

        expect(model.educationYearError(education.id), isNotNull);
        verifyNever(vaultService.updateEducation(any));
      });
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
  });
}
