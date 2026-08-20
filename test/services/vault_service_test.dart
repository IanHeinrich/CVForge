import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('VaultServiceTest -', () {
    late MockLocalStorageService storage;

    setUp(() => storage = getAndRegisterLocalStorageService());
    tearDown(() => locator.reset());

    group('load -', () {
      test('When no stored payload exists, creates an empty vault', () async {
        when(storage.read(any, any)).thenAnswer((_) async => null);

        final service = VaultService();
        await service.load();

        expect(service.vault.schemaVersion, 1);
        expect(service.vault.basics.fullName, '');
        expect(service.vault.experiences, isEmpty);
        expect(service.vault.skillCategories, isEmpty);
        expect(service.vault.education, isEmpty);
        expect(service.vault.hobbies, isEmpty);
      });

      test(
        'When the stored payload has an unrecognised schemaVersion, '
        'falls back to an empty vault and quarantines the original',
        () async {
          const rawPayload = '{"schemaVersion": 99, "nonsense": true}';
          when(storage.read(any, any)).thenAnswer((_) async => rawPayload);
          when(
            storage.write(any, any, any),
          ).thenAnswer((_) => Future<void>.value());

          final service = VaultService();
          await service.load();

          expect(service.vault.schemaVersion, 1);
          expect(service.vault.experiences, isEmpty);

          verify(
            storage.write(
              StorageBoxes.vault,
              argThat(startsWith('profile_corrupt_')),
              rawPayload,
            ),
          ).called(1);
        },
      );

      test('A failed load (storage genuinely unavailable) can be retried — '
          'the failure is not cached forever', () async {
        when(
          storage.ensureInitialized(),
        ).thenThrow(Exception('IndexedDB unavailable'));

        final service = VaultService();
        await expectLater(service.load(), throwsException);

        when(
          storage.ensureInitialized(),
        ).thenAnswer((_) => Future<void>.value());
        when(storage.read(any, any)).thenAnswer((_) async => null);

        // If the first failure's Future were still memoized, this would
        // replay the same rejection instead of actually retrying.
        await service.load();

        expect(service.vault.schemaVersion, 1);
      });
    });

    group('experiences -', () {
      test('add, update, and delete an experience', () async {
        when(storage.read(any, any)).thenAnswer((_) async => null);
        when(
          storage.write(any, any, any),
        ).thenAnswer((_) => Future<void>.value());

        final service = VaultService();
        await service.load();

        final experience = await service.addExperience(
          role: 'Engineer',
          company: 'Acme',
          location: 'London',
          start: const YearMonth(year: 2020, month: 1),
          isCurrent: true,
        );

        expect(service.vault.experiences, hasLength(1));
        expect(service.vault.experiences.single.role, 'Engineer');

        await service.updateExperience(
          experience.copyWith(role: 'Senior Engineer'),
        );
        expect(service.vault.experiences.single.role, 'Senior Engineer');

        await service.deleteExperience(experience.id);
        expect(service.vault.experiences, isEmpty);

        await service.flushPendingWrites();
      });
    });

    group('grouping -', () {
      test('groupExperience assigns a shared companyGroupId, reusing an '
          'existing group when adding a third member, and ungrouping only '
          'affects the one experience', () async {
        when(storage.read(any, any)).thenAnswer((_) async => null);
        when(
          storage.write(any, any, any),
        ).thenAnswer((_) => Future<void>.value());

        final service = VaultService();
        await service.load();

        final junior = await service.addExperience(
          role: 'Junior Engineer',
          company: 'Acme',
          location: 'London',
          start: const YearMonth(year: 2019, month: 1),
        );
        final mid = await service.addExperience(
          role: 'Engineer',
          company: 'Acme',
          location: 'London',
          start: const YearMonth(year: 2021, month: 1),
        );
        final senior = await service.addExperience(
          role: 'Senior Engineer',
          company: 'Acme',
          location: 'London',
          start: const YearMonth(year: 2023, month: 1),
          isCurrent: true,
        );

        Experience byId(String id) =>
            service.vault.experiences.firstWhere((e) => e.id == id);

        await service.groupExperience(mid.id, junior.id);
        final groupId = byId(mid.id).companyGroupId;
        expect(groupId, isNotNull);
        expect(byId(junior.id).companyGroupId, groupId);

        // Grouping a third experience with an already-grouped one joins
        // the same group rather than creating a new one.
        await service.groupExperience(senior.id, mid.id);
        expect(byId(senior.id).companyGroupId, groupId);

        await service.groupExperience(junior.id, null);
        expect(byId(junior.id).companyGroupId, isNull);
        expect(byId(mid.id).companyGroupId, groupId);
        expect(byId(senior.id).companyGroupId, groupId);

        await service.flushPendingWrites();
      });
    });

    group('bullets -', () {
      test('add, reorder, and delete bullets within an experience', () async {
        when(storage.read(any, any)).thenAnswer((_) async => null);
        when(
          storage.write(any, any, any),
        ).thenAnswer((_) => Future<void>.value());

        final service = VaultService();
        await service.load();

        final experience = await service.addExperience(
          role: 'Engineer',
          company: 'Acme',
          location: 'London',
          start: const YearMonth(year: 2020, month: 1),
        );

        final b1 = await service.addBullet(experience.id, text: 'First');
        final b2 = await service.addBullet(experience.id, text: 'Second');
        await service.addBullet(experience.id, text: 'Third');

        expect(service.vault.experiences.single.bullets.map((b) => b.text), [
          'First',
          'Second',
          'Third',
        ]);

        // Reordering to a subset also drops anything left out — 'Third'
        // is intentionally omitted here to exercise that.
        await service.reorderBullets(experience.id, [b2.id, b1.id]);
        expect(service.vault.experiences.single.bullets.map((b) => b.text), [
          'Second',
          'First',
        ]);

        await service.deleteBullet(experience.id, b1.id);
        expect(service.vault.experiences.single.bullets.map((b) => b.text), [
          'Second',
        ]);

        await service.flushPendingWrites();
      });
    });

    test('Deleting an experience does not touch a draft referencing it — '
        'VaultService and DraftService share no reference to one another, '
        'so the dangling id in the draft survives untouched', () async {
      when(storage.read(any, any)).thenAnswer((_) async => null);
      when(
        storage.write(any, any, any),
      ).thenAnswer((_) => Future<void>.value());

      final vaultService = VaultService();
      await vaultService.load();
      final experience = await vaultService.addExperience(
        role: 'Engineer',
        company: 'Acme',
        location: 'London',
        start: const YearMonth(year: 2020, month: 1),
      );

      // DraftService resolves TemplateRegistryService for real to stamp a
      // genuinely registered template id on the draft it seeds.
      locator.registerLazySingleton<TemplateRegistryService>(
        TemplateRegistryService.new,
      );
      when(
        getAndRegisterSettingsService().settings,
      ).thenReturn(AppSettings.empty());
      final draftService = DraftService();
      await draftService.load();
      await draftService.setExperienceIncluded(experience.id, included: true);
      expect(draftService.draft.experienceIds, [experience.id]);

      await vaultService.deleteExperience(experience.id);
      expect(vaultService.vault.experiences, isEmpty);

      // The draft never learns about the deletion — it still lists the
      // now-dangling id. CvComposer is responsible for silently
      // dropping it at render time, not this service.
      expect(draftService.draft.experienceIds, [experience.id]);

      await vaultService.flushPendingWrites();
      await draftService.flushPendingWrites();
    });

    group('persistence -', () {
      test(
        'Round-trips nested collections as real JSON objects, not '
        'stringified instances — proves explicit_to_json is active',
        () async {
          when(storage.read(any, any)).thenAnswer((_) async => null);
          when(
            storage.write(any, any, any),
          ).thenAnswer((_) => Future<void>.value());

          final service = VaultService();
          await service.load();

          final experience = await service.addExperience(
            role: 'Engineer',
            company: 'Acme',
            location: 'London',
            start: const YearMonth(year: 2020, month: 1),
          );
          await service.addBullet(
            experience.id,
            label: 'Impact',
            text: 'Did a thing',
          );

          await service.flushPendingWrites();

          final captured = verify(
            storage.write(
              StorageBoxes.vault,
              StorageKeys.vaultProfile,
              captureAny,
            ),
          ).captured;
          expect(captured, isNotEmpty);

          final decoded =
              jsonDecode(captured.last as String) as Map<String, dynamic>;
          final experiences = decoded['experiences'] as List<dynamic>;
          expect(experiences, hasLength(1));

          final firstExperience = experiences.single as Map<String, dynamic>;
          expect(firstExperience['role'], 'Engineer');

          final bullets = firstExperience['bullets'] as List<dynamic>;
          final firstBullet = bullets.single as Map<String, dynamic>;
          expect(firstBullet['label'], 'Impact');
          expect(firstBullet['text'], 'Did a thing');
        },
      );
    });
  });
}
