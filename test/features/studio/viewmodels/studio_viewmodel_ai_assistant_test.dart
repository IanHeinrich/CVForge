import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/dialogs/ai_assistant_run/ai_assistant_run_dialog_data.dart';
import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('StudioViewModel Tests - AI Assistant -', () {
    late MockVaultService vaultService;
    late MockDraftService draftService;
    late MockDialogService dialogService;

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterSettingsService();
      getAndRegisterTemplateRegistryService();
      getAndRegisterPdfExportService();
      getAndRegisterRouterService();
      dialogService = getAndRegisterDialogService();
      getAndRegisterLocalizationService();
      when(vaultService.vault).thenReturn(vaultWith());
      when(draftService.draft).thenReturn(draftWith());
      when(
        draftService.hasAiAssistantUndoFor(any),
      ).thenAnswer((_) async => false);
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

    test('hasAiAssistantUndo reflects DraftService.hasAiAssistantUndoFor once '
        'loaded', () async {
      when(vaultService.load()).thenAnswer((_) => Future<void>.value());
      when(draftService.load()).thenAnswer((_) => Future<void>.value());
      when(
        draftService.hasAiAssistantUndoFor('current'),
      ).thenAnswer((_) async => true);

      final model = StudioViewModel();
      model.initialise();
      await pumpEventQueue();

      expect(model.hasAiAssistantUndo, isTrue);
    });

    test('tailorWithAi opens the ai_assistant_run dialog with the current job '
        'description, then refreshes hasAiAssistantUndo', () async {
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
        draftService.hasAiAssistantUndoFor('current'),
      ).thenAnswer((_) async => true);

      final model = StudioViewModel();
      await model.tailorWithAi();

      final captured = verify(
        dialogService.showCustomDialog(
          variant: captureAnyNamed('variant'),
          data: captureAnyNamed('data'),
        ),
      ).captured;
      expect(captured[0], DialogType.aiAssistantRun);
      expect(
        (captured[1] as AiAssistantRunDialogData).jobDescription,
        'We need a backend dev',
      );
      expect(model.hasAiAssistantUndo, isTrue);
    });

    test('undoAiAssistantChanges delegates to DraftService and refreshes '
        'hasAiAssistantUndo', () async {
      when(draftService.undoAiAssistantPass()).thenAnswer((_) async => true);
      when(
        draftService.hasAiAssistantUndoFor('current'),
      ).thenAnswer((_) async => false);

      final model = StudioViewModel();
      await model.undoAiAssistantChanges();

      verify(draftService.undoAiAssistantPass()).called(1);
      expect(model.hasAiAssistantUndo, isFalse);
    });
  });
}
