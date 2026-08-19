import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/vault/views/vault/vault_viewmodel.dart';
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
  });
}
