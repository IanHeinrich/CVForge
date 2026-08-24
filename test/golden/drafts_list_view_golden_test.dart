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
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

import '../helpers/golden_helpers.dart';
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

  testGoldens('DraftsListView - empty state', (tester) async {
    when(draftService.drafts).thenReturn(const []);

    await pumpGoldenScreen(tester, const DraftsListView());

    await screenMatchesGolden(tester, 'drafts_list_view_empty');
  });

  // Every `updatedAt` here is far enough in the past that
  // `formatRelativeTime` returns its absolute `on DD/MM/YYYY` form rather
  // than "N days ago", which is what keeps this golden deterministic. A
  // fixture dated within the last 30 days would render a different string
  // every day and fail on a schedule.
  testGoldens('DraftsListView - populated', (tester) async {
    when(draftService.drafts).thenReturn([
      CvDraft.empty(
        id: 'draft-1',
        templateId: 'compact',
        name: 'Acme — Backend Engineer',
      ).copyWith(
        notes: 'Tailored for the Acme application',
        targetJobDescription: 'Backend Engineer, Acme — 5+ years Dart…',
        updatedAt: DateTime(2026, 3, 2),
      ),
      CvDraft.empty(
        id: 'draft-2',
        templateId: 'compact',
        name: 'Globex — Platform Team',
      ).copyWith(updatedAt: DateTime(2026, 2, 18)),
      // No name and no job ad — covers the "Untitled CV" fallback and the
      // absence of the tailored marker in the same card.
      CvDraft.empty(
        id: 'draft-3',
        templateId: 'compact',
        name: '',
      ).copyWith(updatedAt: DateTime(2026, 1, 9)),
    ]);

    await pumpGoldenScreen(tester, const DraftsListView());

    await screenMatchesGolden(tester, 'drafts_list_view_populated');
  });
}
