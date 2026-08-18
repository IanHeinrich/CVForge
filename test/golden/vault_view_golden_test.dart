import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/vault/views/vault/vault_view.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/example_vault.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

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
  });
  tearDown(() => locator.reset());

  Future<void> pumpVaultView(WidgetTester tester) async {
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
          home: const VaultView(),
        ),
      ),
    );
  }

  testGoldens('VaultView - empty state', (tester) async {
    when(vaultService.vault).thenReturn(CvVault.empty());

    await pumpVaultView(tester);

    await screenMatchesGolden(tester, 'vault_view_empty');
  });

  testGoldens('VaultView - populated from example vault', (tester) async {
    when(vaultService.vault).thenReturn(buildExampleVault());

    await pumpVaultView(tester);

    await screenMatchesGolden(tester, 'vault_view_populated');
  });
}
