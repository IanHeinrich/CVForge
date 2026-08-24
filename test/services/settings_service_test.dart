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
      expect(service.settings.preferences.defaultRegion, RegionProfile.uk);
      expect(service.settings.preferences.aiAssistantProviderId, isNull);
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

    group('AI Assistant mutators (4.4) -', () {
      test(
        'setAiAssistantProvider/setAiAssistantModel update settings',
        () async {
          when(storage.read(any, any)).thenAnswer((_) async => null);

          final service = SettingsService();
          await service.load();

          await service.setAiAssistantProvider('anthropic');
          await service.setAiAssistantModel('claude-opus-5');

          expect(
            service.settings.preferences.aiAssistantProviderId,
            'anthropic',
          );
          expect(
            service.settings.preferences.aiAssistantModelId,
            'claude-opus-5',
          );
        },
      );

      test('setRememberApiKey updates settings', () async {
        when(storage.read(any, any)).thenAnswer((_) async => null);

        final service = SettingsService();
        await service.load();
        expect(service.settings.rememberApiKey, isFalse);

        await service.setRememberApiKey(true);
        expect(service.settings.rememberApiKey, isTrue);
      });

      test(
        'setApiKey with rememberApiKey false keeps the key in memory only',
        () async {
          when(storage.read(any, any)).thenAnswer((_) async => null);

          final service = SettingsService();
          await service.load();

          await service.setApiKey('anthropic', 'sk-ant-test');

          verifyNever(storage.write(any, any, any));
          expect(await service.apiKeyFor('anthropic'), 'sk-ant-test');
        },
      );

      test(
        'setApiKey with rememberApiKey true also persists the key',
        () async {
          when(storage.read(any, any)).thenAnswer((_) async => null);
          when(
            storage.write(any, any, any),
          ).thenAnswer((_) => Future<void>.value());

          final service = SettingsService();
          await service.load();
          await service.setRememberApiKey(true);

          await service.setApiKey('anthropic', 'sk-ant-test');

          verify(
            storage.write(
              StorageBoxes.settings,
              StorageKeys.apiKeyFor('anthropic'),
              'sk-ant-test',
            ),
          ).called(1);
        },
      );

      test('clearApiKey deletes the stored row immediately', () async {
        when(storage.read(any, any)).thenAnswer((_) async => null);
        when(
          storage.write(any, any, any),
        ).thenAnswer((_) => Future<void>.value());
        when(storage.delete(any, any)).thenAnswer((_) => Future<void>.value());

        final service = SettingsService();
        await service.load();
        await service.setRememberApiKey(true);
        await service.setApiKey('anthropic', 'sk-ant-test');

        await service.clearApiKey('anthropic');

        verify(
          storage.delete(
            StorageBoxes.settings,
            StorageKeys.apiKeyFor('anthropic'),
          ),
        ).called(1);
        expect(await service.apiKeyFor('anthropic'), isNull);
      });

      test('apiKeyFor lazily reloads a remembered key from storage on first '
          'access, simulating a page reload', () async {
        when(storage.read(any, any)).thenAnswer((invocation) async {
          final key = invocation.positionalArguments[1] as String;
          if (key == StorageKeys.apiKeyFor('anthropic')) {
            return 'sk-ant-remembered';
          }
          return null;
        });

        final freshService = SettingsService();
        await freshService.load();

        expect(await freshService.apiKeyFor('anthropic'), 'sk-ant-remembered');
      });
    });
  });
}
