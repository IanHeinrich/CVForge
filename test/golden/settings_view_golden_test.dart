@Tags(['golden'])
library;

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/settings/views/settings/settings_view.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  late MockSettingsService settingsService;

  setUp(() {
    // registerServices() — see `drafts_list_view_golden_test.dart`'s setUp
    // for why the broad helper, not a narrower one, is used here too.
    registerServices();
    settingsService = locator<SettingsService>() as MockSettingsService;
    when(settingsService.load()).thenAnswer((_) => Future<void>.value());
    // AiAssistantSettingsCard (4.4) reads `settings` on every build.
    when(settingsService.settings).thenReturn(AppSettings.empty());
  });
  tearDown(() => locator.reset());

  Future<void> pumpSettings(WidgetTester tester) async {
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
  }

  testGoldens('SettingsView - default', (tester) async {
    await pumpSettings(tester);
    await screenMatchesGolden(tester, 'settings_view_default');
  });

  // The two AI Assistant states that used to render identically: a stored
  // key and no key at all both drew one empty password field. These are the
  // baselines that would catch that collapsing back.
  testGoldens('SettingsView - AI Assistant key remembered', (tester) async {
    when(
      settingsService.apiKeyOriginFor(any),
    ).thenReturn(ApiKeyOrigin.remembered);
    when(settingsService.maskedApiKeyFor(any)).thenReturn('••••••••a1b2');
    when(
      settingsService.settings,
    ).thenReturn(AppSettings.empty().copyWith(rememberApiKey: true));

    await pumpSettings(tester);
    await screenMatchesGolden(tester, 'settings_view_ai_key_remembered');
  });

  testGoldens('SettingsView - AI Assistant key session only', (tester) async {
    when(settingsService.apiKeyOriginFor(any)).thenReturn(ApiKeyOrigin.session);
    when(settingsService.maskedApiKeyFor(any)).thenReturn('••••••••a1b2');

    await pumpSettings(tester);
    await screenMatchesGolden(tester, 'settings_view_ai_key_session');
  });
}
