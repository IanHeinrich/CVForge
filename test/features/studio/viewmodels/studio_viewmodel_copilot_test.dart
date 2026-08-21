import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/dialogs/copilot_run/copilot_run_dialog_data.dart';
import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('StudioViewModel Tests - Copilot (4.5) -', () {
    late MockVaultService vaultService;
    late MockDraftService draftService;
    late MockDialogService dialogService;

    CvDraft draftWith({String? targetJobDescription}) => CvDraft(
      schemaVersion: 1,
      id: 'current',
      name: 'My CV',
      templateId: 'compact',
      targetJobDescription: targetJobDescription,
      updatedAt: DateTime.now(),
    );

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterTemplateRegistryService();
      getAndRegisterPdfExportService();
      getAndRegisterRouterService();
      dialogService = getAndRegisterDialogService();
      when(vaultService.vault).thenReturn(
        CvVault(
          schemaVersion: 1,
          basics: ContactBasics.empty(),
          updatedAt: DateTime.now(),
        ),
      );
      when(draftService.draft).thenReturn(draftWith());
      when(draftService.hasCopilotUndoFor(any)).thenAnswer((_) async => false);
    });
    tearDown(() => locator.reset());

    test('targetJobDescription/hasTargetJobDescription reflect the draft, '
        'defaulting to blank/false when unset', () {
      final model = StudioViewModel();

      expect(model.targetJobDescription, '');
      expect(model.hasTargetJobDescription, isFalse);
    });

    test('a non-empty targetJobDescription is reflected', () {
      when(
        draftService.draft,
      ).thenReturn(draftWith(targetJobDescription: 'We need a backend dev'));

      final model = StudioViewModel();

      expect(model.targetJobDescription, 'We need a backend dev');
      expect(model.hasTargetJobDescription, isTrue);
    });

    test('setTargetJobDescription normalizes blank input to null, same as '
        'every other override setter', () async {
      when(
        draftService.setTargetJobDescription(any),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.setTargetJobDescription('   ');

      verify(draftService.setTargetJobDescription(null)).called(1);
    });

    test('setTargetJobDescription persists genuinely non-empty input '
        'verbatim', () async {
      when(
        draftService.setTargetJobDescription(any),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.setTargetJobDescription('We need a backend dev');

      verify(
        draftService.setTargetJobDescription('We need a backend dev'),
      ).called(1);
    });

    test('clearTargetJobDescription delegates a null write', () async {
      when(
        draftService.setTargetJobDescription(null),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.clearTargetJobDescription();

      verify(draftService.setTargetJobDescription(null)).called(1);
    });

    test('hasCopilotUndo reflects DraftService.hasCopilotUndoFor once '
        'loaded', () async {
      when(vaultService.load()).thenAnswer((_) => Future<void>.value());
      when(draftService.load()).thenAnswer((_) => Future<void>.value());
      when(
        draftService.hasCopilotUndoFor('current'),
      ).thenAnswer((_) async => true);

      final model = StudioViewModel();
      model.initialise();
      await pumpEventQueue();

      expect(model.hasCopilotUndo, isTrue);
    });

    test('tailorWithAi opens the copilot_run dialog with the current job '
        'description, then refreshes hasCopilotUndo', () async {
      when(
        draftService.draft,
      ).thenReturn(draftWith(targetJobDescription: 'We need a backend dev'));
      when(
        dialogService.showCustomDialog(
          variant: anyNamed('variant'),
          data: anyNamed('data'),
        ),
      ).thenAnswer((_) async => DialogResponse(confirmed: true));
      when(
        draftService.hasCopilotUndoFor('current'),
      ).thenAnswer((_) async => true);

      final model = StudioViewModel();
      await model.tailorWithAi();

      final captured = verify(
        dialogService.showCustomDialog(
          variant: captureAnyNamed('variant'),
          data: captureAnyNamed('data'),
        ),
      ).captured;
      expect(captured[0], DialogType.copilotRun);
      expect(
        (captured[1] as CopilotRunDialogData).jobDescription,
        'We need a backend dev',
      );
      expect(model.hasCopilotUndo, isTrue);
    });

    test('undoCopilotChanges delegates to DraftService and refreshes '
        'hasCopilotUndo', () async {
      when(draftService.undoCopilotPass()).thenAnswer((_) async => true);
      when(
        draftService.hasCopilotUndoFor('current'),
      ).thenAnswer((_) async => false);

      final model = StudioViewModel();
      await model.undoCopilotChanges();

      verify(draftService.undoCopilotPass()).called(1);
      expect(model.hasCopilotUndo, isFalse);
    });
  });
}
