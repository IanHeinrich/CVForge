import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_photo.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('VaultServiceTest -', () {
    late MockLocalStorageService storage;
    late Map<String, String> memory;

    setUp(() {
      storage = getAndRegisterLocalStorageService();
      getAndRegisterLocalizationService();
      memory = stubInMemoryStorage(storage);
    });
    tearDown(() => locator.reset());

    group('load -', () {
      test('When no stored payload exists, creates an empty vault', () async {
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
          memory['${StorageBoxes.vault}/${StorageKeys.vaultProfile}'] =
              rawPayload;

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

        // If the first failure's Future were still memoized, this would
        // replay the same rejection instead of actually retrying.
        await service.load();

        expect(service.vault.schemaVersion, 1);
      });
    });

    group('experiences -', () {
      test('add, update, and delete an experience', () async {
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
        final service = VaultService();
        await service.load();

        final experience = await service.addExperience(
          role: 'Engineer',
          company: 'Acme',
          location: 'London',
          start: const YearMonth(year: 2020, month: 1),
        );

        final b1 = await service.addBullet(
          BulletOwner.experience,
          experience.id,
          text: 'First',
        );
        final b2 = await service.addBullet(
          BulletOwner.experience,
          experience.id,
          text: 'Second',
        );
        await service.addBullet(
          BulletOwner.experience,
          experience.id,
          text: 'Third',
        );

        expect(service.vault.experiences.single.bullets.map((b) => b.text), [
          'First',
          'Second',
          'Third',
        ]);

        // Reordering to a subset also drops anything left out — 'Third'
        // is intentionally omitted here to exercise that.
        await service.reorderBullets(BulletOwner.experience, experience.id, [
          b2.id,
          b1.id,
        ]);
        expect(service.vault.experiences.single.bullets.map((b) => b.text), [
          'Second',
          'First',
        ]);

        await service.deleteBullet(
          BulletOwner.experience,
          experience.id,
          b1.id,
        );
        expect(service.vault.experiences.single.bullets.map((b) => b.text), [
          'Second',
        ]);

        await service.flushPendingWrites();
      });
    });

    test('Deleting an experience does not touch a draft referencing it — '
        'VaultService and DraftService share no reference to one another, '
        'so the dangling id in the draft survives untouched', () async {
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
      final settingsService = getAndRegisterSettingsService();
      when(settingsService.settings).thenReturn(AppSettings.empty());
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
          final service = VaultService();
          await service.load();

          final experience = await service.addExperience(
            role: 'Engineer',
            company: 'Acme',
            location: 'London',
            start: const YearMonth(year: 2020, month: 1),
          );
          await service.addBullet(
            BulletOwner.experience,
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

      test('A photo survives the write/read round trip through storage — '
          'this is the same serialization Drive sync and JSON export both '
          'ride, so a photo that did not round-trip here would not sync '
          'either', () async {
        const photo = CvPhoto(
          jpegBase64: 'AQIDBAU=',
          widthPx: 420,
          heightPx: 540,
        );
        final service = VaultService();
        await service.load();

        await service.updateBasics(
          ContactBasics.empty().copyWith(fullName: 'Ada', photo: photo),
        );
        await service.flushPendingWrites();

        final captured = verify(
          storage.write(
            StorageBoxes.vault,
            StorageKeys.vaultProfile,
            captureAny,
          ),
        ).captured;
        final raw = captured.last as String;

        // The nested object shape, not a stringified instance — the same
        // `explicit_to_json` guarantee the test above establishes for
        // experiences.
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final basics = decoded['basics'] as Map<String, dynamic>;
        final written = basics['photo'] as Map<String, dynamic>;
        expect(written['jpegBase64'], photo.jpegBase64);
        expect(written['widthPx'], 420);
        expect(written['heightPx'], 540);

        // And back, which is what a reload (or a Drive download) does.
        expect(CvVault.fromJson(decoded).basics.photo, photo);
      });

      test(
        'A Vault holding only a photo does not read as empty — the '
        'empty state offers "Load example CV", which would replace it',
        () async {
          const photo = CvPhoto(jpegBase64: 'AQ==', widthPx: 1, heightPx: 1);

          final vault = CvVault.empty().copyWith(
            basics: ContactBasics.empty().copyWith(photo: photo),
          );

          expect(vault.isEmpty, isFalse);
          expect(CvVault.empty().isEmpty, isTrue);
        },
      );

      Map<String, dynamic> lastWrittenVault() {
        final captured = verify(
          storage.write(
            StorageBoxes.vault,
            StorageKeys.vaultProfile,
            captureAny,
          ),
        ).captured;
        return jsonDecode(captured.last as String) as Map<String, dynamic>;
      }

      test('Entries added but never filled in are dropped on write, so a '
          'stray "+" click leaves nothing behind', () async {
        final service = VaultService();
        await service.load();

        await service.addExperience(
          role: '',
          company: '',
          location: '',
          start: const YearMonth(year: 2020, month: 1),
        );
        await service.addProject(title: '');
        await service.addEducation(qualification: '', institution: '');
        await service.addPublication(title: '');
        await service.addHobby('');
        await service.addProfileLink(label: '', url: '');
        await service.addSkillCategory('');

        await service.flushPendingWrites();

        final decoded = lastWrittenVault();
        expect(decoded['experiences'], isEmpty);
        expect(decoded['projects'], isEmpty);
        expect(decoded['education'], isEmpty);
        expect(decoded['publications'], isEmpty);
        expect(decoded['hobbies'], isEmpty);
        expect(decoded['skillCategories'], isEmpty);
        expect((decoded['basics'] as Map<String, dynamic>)['links'], isEmpty);

        // Still in memory: the editor panel that was opened on "+" is
        // bound to this entry and has to keep working until it's filled
        // in or abandoned.
        expect(service.vault.experiences, hasLength(1));
      });

      test('A blank bullet is dropped from an entry that does have content, '
          'and no skill is left pointing at the id that went away', () async {
        final service = VaultService();
        await service.load();

        final experience = await service.addExperience(
          role: 'Engineer',
          company: 'Acme',
          location: 'London',
          start: const YearMonth(year: 2020, month: 1),
        );
        final real = await service.addBullet(
          BulletOwner.experience,
          experience.id,
          text: 'Did a thing',
        );
        final blank = await service.addBullet(
          BulletOwner.experience,
          experience.id,
          text: '',
        );

        final category = await service.addSkillCategory('Languages');
        final skill = await service.addSkill(category.id, 'Dart');
        await service.updateSkill(
          category.id,
          skill.copyWith(linkedBulletIds: [real.id, blank.id]),
        );

        await service.flushPendingWrites();

        final decoded = lastWrittenVault();
        final experiences = decoded['experiences'] as List<dynamic>;
        final bullets =
            (experiences.single as Map<String, dynamic>)['bullets']
                as List<dynamic>;
        expect(bullets, hasLength(1));
        expect((bullets.single as Map<String, dynamic>)['text'], 'Did a thing');

        final categories = decoded['skillCategories'] as List<dynamic>;
        final skills =
            (categories.single as Map<String, dynamic>)['skills']
                as List<dynamic>;
        expect((skills.single as Map<String, dynamic>)['linkedBulletIds'], [
          real.id,
        ]);
      });

      test('A category left unnamed still persists once it has a skill in it '
          '— content anywhere in an entry is enough to keep it', () async {
        final service = VaultService();
        await service.load();

        final category = await service.addSkillCategory('');
        await service.addSkill(category.id, 'Dart');
        await service.addSkill(category.id, '');

        await service.flushPendingWrites();

        final categories =
            lastWrittenVault()['skillCategories'] as List<dynamic>;
        expect(categories, hasLength(1));
        final skills =
            (categories.single as Map<String, dynamic>)['skills']
                as List<dynamic>;
        expect(skills, hasLength(1));
        expect((skills.single as Map<String, dynamic>)['label'], 'Dart');
      });
    });
  });
}
