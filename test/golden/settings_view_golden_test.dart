@Tags(['golden'])
library;

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/settings/views/settings/settings_view.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  setUp(() {
    // registerServices() — see `drafts_list_view_golden_test.dart`'s setUp
    // for why the broad helper, not a narrower one, is used here too.
    registerServices();
    when(
      (locator<SettingsService>() as MockSettingsService).load(),
    ).thenAnswer((_) => Future<void>.value());
  });
  tearDown(() => locator.reset());

  testGoldens('SettingsView - default', (tester) async {
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
          home: const SettingsView(),
        ),
      ),
    );

    await screenMatchesGolden(tester, 'settings_view_default');
  });
}
