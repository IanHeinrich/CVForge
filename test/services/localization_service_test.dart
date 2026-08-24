import 'dart:ui';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/settings/cv_preferences.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

AppSettings _settingsWith(String? localeTag) => AppSettings(
  schemaVersion: 1,
  preferences: CvPreferences(
    localeTag: localeTag,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalizationServiceTest -', () {
    late MockSettingsService settings;

    setUp(() {
      registerServices();
      settings = getAndRegisterSettingsService();
      when(settings.settings).thenReturn(_settingsWith(null));
    });

    tearDown(() {
      binding.platformDispatcher.clearLocalesTestValue();
      locator.reset();
    });

    test('A browser locale we do not ship resolves to a supported one rather '
        'than throwing — lookupAppLocalizations matches subtags exactly, so '
        'an unhandled en-GB or fr-CA would crash the app on startup', () async {
      binding.platformDispatcher.localesTestValue = const [
        Locale('fr', 'CA'),
        Locale('en', 'GB'),
      ];

      final service = LocalizationService();
      await service.initialise();

      expect(service.selectedLocale, isNull);
      expect(service.resolvedLocale, const Locale('en'));
      expect(service.strings.localeDisplayName, 'English');
    });

    test('A regional Spanish browser resolves to the Spanish we do ship — '
        'es-CO is what a Colombian browser sends, and it is not itself a '
        'supported locale', () async {
      binding.platformDispatcher.localesTestValue = const [Locale('es', 'CO')];

      final service = LocalizationService();
      await service.initialise();

      expect(service.resolvedLocale, const Locale('es'));
      expect(service.strings.localeDisplayName, 'Español');
    });

    test('An explicitly chosen language outranks the browser', () async {
      binding.platformDispatcher.localesTestValue = const [Locale('en')];
      when(settings.settings).thenReturn(_settingsWith('es'));

      final service = LocalizationService();
      await service.initialise();

      expect(service.selectedLocale, const Locale('es'));
      expect(service.strings.localeDisplayName, 'Español');
    });

    test('A stored tag naming a language this build no longer ships falls '
        'back to the platform instead of throwing', () async {
      binding.platformDispatcher.localesTestValue = const [Locale('en')];
      when(settings.settings).thenReturn(_settingsWith('xx-YZ'));

      final service = LocalizationService();
      await service.initialise();

      expect(service.resolvedLocale, const Locale('en'));
    });

    test('setLocale persists the tag and notifies, and null restores '
        '"follow the browser"', () async {
      binding.platformDispatcher.localesTestValue = const [Locale('en')];
      when(settings.setLocaleTag(any)).thenAnswer((_) => Future<void>.value());

      final service = LocalizationService();
      await service.initialise();

      var notifications = 0;
      service.addListener(() => notifications++);

      await service.setLocale(const Locale('en'));
      verify(settings.setLocaleTag('en')).called(1);

      await service.setLocale(null);
      verify(settings.setLocaleTag(null)).called(1);

      expect(service.selectedLocale, isNull);
      expect(notifications, greaterThan(0));
    });

    test('Adopts a locale changed underneath it — replacePreferences is how '
        'a Drive sync or backup import replaces the stored language without '
        'ever going through setLocale', () async {
      binding.platformDispatcher.localesTestValue = const [Locale('en')];

      final service = LocalizationService();
      await service.initialise();
      expect(service.selectedLocale, isNull);

      when(settings.settings).thenReturn(_settingsWith('en'));
      // SettingsService is a ListenableServiceMixin; this is what its
      // notifyListeners() reaches.
      final listener =
          verify(settings.addListener(captureAny)).captured.single
              as void Function();
      listener();

      expect(service.selectedLocale, const Locale('en'));
    });
  });
}
