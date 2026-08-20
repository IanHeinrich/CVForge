import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('SettingsServiceTest -', () {
    late MockLocalStorageService storage;

    setUp(() => storage = getAndRegisterLocalStorageService());
    tearDown(() => locator.reset());

    test('When no stored payload exists, creates empty settings', () async {
      when(storage.read(any, any)).thenAnswer((_) async => null);

      final service = SettingsService();
      await service.load();

      expect(service.settings.schemaVersion, 1);
      expect(service.settings.defaultRegion, RegionProfile.uk);
      expect(service.settings.copilotProviderId, isNull);
      expect(service.settings.rememberApiKey, isFalse);
    });

    test('When the stored payload has an unrecognised schemaVersion, falls '
        'back to empty settings and quarantines the original', () async {
      const rawPayload = '{"schemaVersion": 99, "nonsense": true}';
      when(storage.read(any, any)).thenAnswer((_) async => rawPayload);
      when(
        storage.write(any, any, any),
      ).thenAnswer((_) => Future<void>.value());

      final service = SettingsService();
      await service.load();

      expect(service.settings.schemaVersion, 1);

      verify(
        storage.write(
          StorageBoxes.settings,
          argThat(startsWith('app_settings_corrupt_')),
          rawPayload,
        ),
      ).called(1);
    });

    test('Round-trips persistence — proves explicit_to_json handles the '
        'enum field', () async {
      when(storage.read(any, any)).thenAnswer((_) async => null);
      String? written;
      when(storage.write(any, any, any)).thenAnswer((invocation) async {
        written = invocation.positionalArguments[2] as String;
      });

      final service = SettingsService();
      await service.load();
      await service.persistImmediately(service.settings);

      final reloadedStorage = getAndRegisterLocalStorageService();
      when(reloadedStorage.read(any, any)).thenAnswer((_) async => written);

      final reloaded = SettingsService();
      await reloaded.load();

      expect(
        jsonDecode(written!) as Map<String, dynamic>,
        jsonDecode(jsonEncode(reloaded.settings.toJson())),
      );
    });
  });
}
