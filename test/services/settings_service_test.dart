import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/region/region_profile.dart';
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

      test('load rehydrates a remembered key from storage, simulating a page '
          'reload — and reports it as remembered, not session', () async {
        when(
          storage.keysWithPrefix(
            StorageBoxes.settings,
            StorageKeys.apiKeyPrefix,
          ),
        ).thenAnswer((_) async => [StorageKeys.apiKeyFor('anthropic')]);
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
        expect(
          freshService.apiKeyOriginFor('anthropic'),
          ApiKeyOrigin.remembered,
        );
        // Masked for display, never the key itself.
        expect(freshService.maskedApiKeyFor('anthropic'), endsWith('ered'));
      });

      test('a provider with no key reports none, so Settings can tell '
          '"nothing stored" from "stored but unreadable"', () async {
        final service = SettingsService();
        await service.load();

        expect(service.apiKeyOriginFor('gemini'), ApiKeyOrigin.none);
        expect(service.maskedApiKeyFor('gemini'), isNull);
      });

      test('a key entered with rememberApiKey off reports session, and '
          'turning the toggle on promotes it to remembered without the '
          'user retyping it', () async {
        when(storage.write(any, any, any)).thenAnswer((_) async {});

        final service = SettingsService();
        await service.load();
        await service.setApiKey('anthropic', 'sk-ant-session');

        expect(service.apiKeyOriginFor('anthropic'), ApiKeyOrigin.session);
        verifyNever(
          storage.write(
            StorageBoxes.settings,
            StorageKeys.apiKeyFor('anthropic'),
            any,
          ),
        );

        await service.setRememberApiKey(true);

        expect(service.apiKeyOriginFor('anthropic'), ApiKeyOrigin.remembered);
        verify(
          storage.write(
            StorageBoxes.settings,
            StorageKeys.apiKeyFor('anthropic'),
            'sk-ant-session',
          ),
        ).called(1);
      });

      test('turning rememberApiKey off deletes every stored key row, not '
          "just the selected provider's — the toggle is one global flag, "
          'so leaving another key on disk would contradict it', () async {
        when(storage.write(any, any, any)).thenAnswer((_) async {});
        when(storage.delete(any, any)).thenAnswer((_) async {});

        final service = SettingsService();
        await service.load();
        await service.setRememberApiKey(true);
        await service.setApiKey('anthropic', 'sk-ant-test');
        await service.setApiKey('gemini', 'AIza-test');

        await service.setRememberApiKey(false);

        for (final providerId in ['anthropic', 'gemini']) {
          verify(
            storage.delete(
              StorageBoxes.settings,
              StorageKeys.apiKeyFor(providerId),
            ),
          ).called(1);
          // Still usable this session — "stop remembering" is not "discard".
          expect(service.apiKeyOriginFor(providerId), ApiKeyOrigin.session);
        }
      });

      test('markAiAssistantConfigured is write-once, so re-testing an '
          'existing key never moves the date a second device reads', () async {
        final service = SettingsService();
        await service.load();

        await service.markAiAssistantConfigured();
        final first = service.settings.preferences.aiAssistantConfiguredAt;
        expect(first, isNotNull);

        await service.markAiAssistantConfigured();

        expect(service.settings.preferences.aiAssistantConfiguredAt, first);
      });
    });
  });
}
