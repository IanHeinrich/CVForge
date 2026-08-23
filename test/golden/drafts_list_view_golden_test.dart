@Tags(['golden'])
library;

import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/views/drafts_list/drafts_list_view.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/template_thumbnail_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/templates/compact/compact_template.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

/// A 1×1 transparent PNG — the smallest byte sequence `Image.memory` can
/// actually decode, so a stubbed thumbnail renders instead of throwing
/// mid-paint the way empty bytes would.
final _blankPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY'
  '42YAAAAASUVORK5CYII=',
);

void main() {
  late MockDraftService draftService;

  setUp(() {
    // registerServices() (not just getAndRegisterDraftService()) —
    // DraftsListView pulls in DialogService/RouterService/
    // TemplateRegistryService/VaultService/TemplateThumbnailService via
    // DraftsListViewModel, and it's easy to add another service
    // dependency later without remembering to update every golden test's
    // setUp individually — see `vault_view_golden_test.dart`'s setUp for
    // the same reasoning.
    registerServices();
    draftService = locator<DraftService>() as MockDraftService;
    // DraftsCardList reads each draft's template display name — the mock
    // TemplateRegistryService has no real templates to resolve `byId`
    // against, so it needs an explicit stub.
    when(
      (locator<TemplateRegistryService>() as MockTemplateRegistryService).byId(
        any,
      ),
    ).thenReturn(const CompactTemplate());
    // Each card composes its own thumbnail from the Vault, and renders it
    // through TemplateThumbnailService — both need a stub, or the grid
    // renders the "couldn't load" fallback icon instead of a page preview.
    when(
      (locator<VaultService>() as MockVaultService).vault,
    ).thenReturn(CvVault.empty());
    // DraftsCardList's "New CV"/search/empty-state copy reads
    // `AppSettings.defaultRegion` — unstubbed, the mock's dummy `AppSettings`
    // throws as soon as anything dereferences a field on it.
    when(
      (locator<SettingsService>() as MockSettingsService).settings,
    ).thenReturn(AppSettings.empty());
    when(
      (locator<TemplateThumbnailService>() as MockTemplateThumbnailService)
          .thumbnail(
            cv: anyNamed('cv'),
            templateId: anyNamed('templateId'),
            format: anyNamed('format'),
          ),
    ).thenAnswer((_) async => _blankPng);
  });
  tearDown(() => locator.reset());

  Future<void> pumpDraftsListView(WidgetTester tester) async {
    await loadAppFonts();
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1600, 1000),
          devicePixelRatio: 1.0,
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const DraftsListView(),
        ),
      ),
    );
  }

  testGoldens('DraftsListView - empty state', (tester) async {
    when(draftService.drafts).thenReturn(const []);

    await pumpDraftsListView(tester);

    await screenMatchesGolden(tester, 'drafts_list_view_empty');
  });

  testGoldens('DraftsListView - populated', (tester) async {
    when(draftService.drafts).thenReturn([
      CvDraft.empty(
        id: 'draft-1',
        templateId: 'compact',
        name: 'Acme — Backend Engineer',
      ).copyWith(
        notes: 'Tailored for the Acme application',
        updatedAt: DateTime(2026, 3, 2),
      ),
      CvDraft.empty(
        id: 'draft-2',
        templateId: 'compact',
        name: 'Globex — Platform Team',
      ).copyWith(updatedAt: DateTime(2026, 2, 18)),
    ]);

    await pumpDraftsListView(tester);

    await screenMatchesGolden(tester, 'drafts_list_view_populated');
  });
}
