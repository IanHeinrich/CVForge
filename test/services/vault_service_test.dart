import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
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
