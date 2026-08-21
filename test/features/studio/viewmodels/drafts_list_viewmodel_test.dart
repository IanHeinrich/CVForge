import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/features/studio/dialogs/edit_draft/edit_draft_dialog_data.dart';
import 'package:cv_forge/features/studio/views/drafts_list/drafts_list_viewmodel.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/templates/compact/compact_template.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('DraftsListViewModel Tests -', () {
    late MockDraftService draftService;
    late MockTemplateRegistryService templateRegistry;
    late MockDialogService dialogService;
    late MockRouterService routerService;

    CvDraft draftWith({
      String id = 'draft-1',
      String name = 'My CV',
      String notes = '',
    }) => CvDraft(
      schemaVersion: 1,
      id: id,
      name: name,
      notes: notes,
      templateId: 'compact',
      updatedAt: DateTime(2026, 1, 1),
    );

    setUp(() {
      draftService = getAndRegisterDraftService();
      templateRegistry = getAndRegisterTemplateRegistryService();
      dialogService = getAndRegisterDialogService();
      routerService = getAndRegisterRouterService();
    });
    tearDown(() => locator.reset());

    test('initialise loads DraftService', () async {
      when(draftService.load()).thenAnswer((_) => Future<void>.value());
      when(draftService.drafts).thenReturn([]);

      final model = DraftsListViewModel();
      model.initialise();
      await pumpEventQueue();

      verify(draftService.load()).called(1);
      expect(model.isLoading, isFalse);
      expect(model.hasLoadError, isFalse);
    });

    test('drafts/isEmpty read through to DraftService', () {
      when(draftService.drafts).thenReturn([draftWith()]);

      final model = DraftsListViewModel();

      expect(model.isEmpty, isFalse);
      expect(model.drafts, hasLength(1));
    });

    test('templateName delegates to TemplateRegistryService', () {
      when(
        templateRegistry.byId('compact'),
      ).thenReturn(const CompactTemplate());

      final model = DraftsListViewModel();

      expect(model.templateName('compact'), 'Compact');
    });

    group('createDraft -', () {
      test(
        'confirming creates a draft via the default template and opens it',
        () async {
          when(
            dialogService.showCustomDialog(
              variant: anyNamed('variant'),
              title: anyNamed('title'),
              data: anyNamed('data'),
              mainButtonTitle: anyNamed('mainButtonTitle'),
              secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
            ),
          ).thenAnswer(
            (_) async => DialogResponse<EditDraftDialogData>(
              confirmed: true,
              data: const EditDraftDialogData(name: 'New CV', notes: 'note'),
            ),
          );
          when(
            templateRegistry.defaultTemplate,
          ).thenReturn(const CompactTemplate());
          when(
            draftService.createDraft(
              name: anyNamed('name'),
              notes: anyNamed('notes'),
              templateId: anyNamed('templateId'),
            ),
          ).thenAnswer((_) async => 'new-id');
          when(routerService.replaceWith(any)).thenAnswer((_) async => null);

          final model = DraftsListViewModel();
          await model.createDraft();

          verify(
            draftService.createDraft(
              name: 'New CV',
              notes: 'note',
              templateId: 'compact',
            ),
          ).called(1);
          verify(routerService.replaceWith(argThat(isA<StudioViewRoute>())));
        },
      );

      test('cancelling creates nothing', () async {
        when(
          dialogService.showCustomDialog(
            variant: anyNamed('variant'),
            title: anyNamed('title'),
            data: anyNamed('data'),
            mainButtonTitle: anyNamed('mainButtonTitle'),
            secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
          ),
        ).thenAnswer(
          (_) async => DialogResponse<EditDraftDialogData>(confirmed: false),
        );

        final model = DraftsListViewModel();
        await model.createDraft();

        verifyNever(
          draftService.createDraft(
            name: anyNamed('name'),
            notes: anyNamed('notes'),
            templateId: anyNamed('templateId'),
          ),
        );
        verifyNever(routerService.replaceWith(any));
      });
    });

    test('openDraft opens the draft and navigates to Studio', () async {
      when(draftService.openDraft(any)).thenAnswer((_) => Future<void>.value());
      when(routerService.replaceWith(any)).thenAnswer((_) async => null);

      final model = DraftsListViewModel();
      await model.openDraft('draft-1');

      verify(draftService.openDraft('draft-1')).called(1);
      verify(routerService.replaceWith(argThat(isA<StudioViewRoute>())));
    });

    test('editDraft updates the given draft via DraftService', () async {
      when(
        dialogService.showCustomDialog(
          variant: anyNamed('variant'),
          title: anyNamed('title'),
          data: anyNamed('data'),
          mainButtonTitle: anyNamed('mainButtonTitle'),
          secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
        ),
      ).thenAnswer(
        (_) async => DialogResponse<EditDraftDialogData>(
          confirmed: true,
          data: const EditDraftDialogData(name: 'Renamed', notes: 'n'),
        ),
      );
      when(
        draftService.updateDraftDetails(
          any,
          name: anyNamed('name'),
          notes: anyNamed('notes'),
        ),
      ).thenAnswer((_) => Future<void>.value());

      final model = DraftsListViewModel();
      await model.editDraft(draftWith(id: 'draft-1'));

      verify(
        draftService.updateDraftDetails('draft-1', name: 'Renamed', notes: 'n'),
      ).called(1);
    });

    test(
      'duplicateDraft duplicates via DraftService and opens the copy',
      () async {
        when(
          draftService.duplicateDraft(any),
        ).thenAnswer((_) async => 'copy-id');
        when(routerService.replaceWith(any)).thenAnswer((_) async => null);

        final model = DraftsListViewModel();
        await model.duplicateDraft(draftWith(id: 'draft-1'));

        verify(draftService.duplicateDraft('draft-1')).called(1);
        verify(routerService.replaceWith(argThat(isA<StudioViewRoute>())));
      },
    );

    group('deleteDraft -', () {
      test('confirming deletes via DraftService', () async {
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
          draftService.deleteDraft(any),
        ).thenAnswer((_) => Future<void>.value());

        final model = DraftsListViewModel();
        await model.deleteDraft(draftWith(id: 'draft-1'));

        verify(draftService.deleteDraft('draft-1')).called(1);
      });

      test('cancelling deletes nothing', () async {
        when(
          dialogService.showCustomDialog(
            variant: anyNamed('variant'),
            title: anyNamed('title'),
            description: anyNamed('description'),
            mainButtonTitle: anyNamed('mainButtonTitle'),
            secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
          ),
        ).thenAnswer((_) async => DialogResponse(confirmed: false));

        final model = DraftsListViewModel();
        await model.deleteDraft(draftWith(id: 'draft-1'));

        verifyNever(draftService.deleteDraft(any));
      });
    });
  });
}
