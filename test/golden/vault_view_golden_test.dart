/// Run `flutter test --exclude-tags=golden` locally to skip these, or
/// `--tags=golden` to run just them. See [pumpGoldenScreen] for why they
/// only compare meaningfully on Linux.
@Tags(['golden'])
library;

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/vault/views/vault/vault_view.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/fixtures/example_vault.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

import '../helpers/golden_helpers.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  late MockVaultService vaultService;

  setUp(() {
    // registerServices() (not just getAndRegisterVaultService()) — VaultView
    // pulls in DialogService via VaultViewModel's delete-confirmation flow,
    // and it's easy to add another service dependency later without
    // remembering to update every golden test's setUp individually.
    registerServices();
    vaultService = locator<VaultService>() as MockVaultService;
    // AppChrome's nav rail reads the Vault's default region for the
    // drafts tab's "CVs"/"Résumés" label, and each test stubs
    // `vaultService.vault` for its own case. Settings is still stubbed
    // because SettingsViewModel-adjacent chrome dereferences it, and the
    // mock's dummy `AppSettings` throws on the first field read.
    when(
      (locator<SettingsService>() as MockSettingsService).settings,
    ).thenReturn(AppSettings.empty());
  });
  tearDown(() => locator.reset());

  testGoldens('VaultView - empty state', (tester) async {
    when(vaultService.vault).thenReturn(CvVault.empty());

    await pumpGoldenScreen(tester, const VaultView());

    await screenMatchesGolden(tester, 'vault_view_empty');
  });

  testGoldens('VaultView - populated from example vault', (tester) async {
    when(vaultService.vault).thenReturn(buildExampleVault());

    await pumpGoldenScreen(tester, const VaultView());

    await screenMatchesGolden(tester, 'vault_view_populated');
  });

  testGoldens('VaultView - CV defaults panel open', (tester) async {
    when(vaultService.vault).thenReturn(buildExampleVault());

    await pumpGoldenScreen(tester, const VaultView());
    await tester.pumpAndSettle();

    // The defaults card is the only thing in the list carrying a
    // RegionFlagStack, which makes it the one stable handle on it — its
    // title is a region name that changes with the fixture, and the
    // AppSummaryCard under it is private to VaultCardList.
    await tester.tap(find.byType(RegionFlagStack));
    await tester.pumpAndSettle();

    await screenMatchesGolden(tester, 'vault_view_cv_defaults_open');
  });
}
