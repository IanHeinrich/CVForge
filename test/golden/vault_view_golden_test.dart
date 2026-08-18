import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/vault/views/vault/vault_view.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUp(() => registerServices());
  tearDown(() => locator.reset());

  testGoldens('VaultView - empty state', (tester) async {
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

    await screenMatchesGolden(tester, 'vault_view_empty');
  });
}
