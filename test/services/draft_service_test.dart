import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('DraftServiceTest -', () {
    late MockLocalStorageService storage;

    setUp(() => storage = getAndRegisterLocalStorageService());
    tearDown(() => locator.reset());

    test('When no stored payload exists, creates an empty draft', () async {
      when(storage.read(any, any)).thenAnswer((_) async => null);

      final service = DraftService();
      await service.load();

      expect(service.draft.schemaVersion, 1);
      expect(service.draft.experienceIds, isEmpty);
      expect(service.draft.hiddenSections, isEmpty);
    });

    test(
      'Toggling an experience id includes/excludes it, with its bullets',
      () async {
        when(storage.read(any, any)).thenAnswer((_) async => null);
        when(
          storage.write(any, any, any),
        ).thenAnswer((_) => Future<void>.value());

        final service = DraftService();
        await service.load();

        await service.setExperienceIncluded(
          'exp-1',
          included: true,
          bulletIds: ['b1', 'b2'],
        );
        expect(service.draft.experienceIds, ['exp-1']);
        expect(service.draft.bulletIds['exp-1'], ['b1', 'b2']);

        await service.setExperienceIncluded('exp-1', included: false);
        expect(service.draft.experienceIds, isEmpty);
        expect(service.draft.bulletIds.containsKey('exp-1'), isFalse);

        await service.flushPendingWrites();
      },
    );

    test('Toggling a section hides/shows it', () async {
      when(storage.read(any, any)).thenAnswer((_) async => null);
      when(
        storage.write(any, any, any),
      ).thenAnswer((_) => Future<void>.value());

      final service = DraftService();
      await service.load();

      await service.setSectionHidden(CvSectionType.education, hidden: true);
      expect(service.draft.hiddenSections, {CvSectionType.education});

      await service.setSectionHidden(CvSectionType.education, hidden: false);
      expect(service.draft.hiddenSections, isEmpty);

      await service.flushPendingWrites();
    });

    test('Selections survive a reload from storage', () async {
      when(storage.read(any, any)).thenAnswer((_) async => null);
      when(
        storage.write(any, any, any),
      ).thenAnswer((_) => Future<void>.value());

      final first = DraftService();
      await first.load();
      await first.setExperienceIncluded('exp-1', included: true);
      await first.setSkillIncluded('skill-1', included: true);
      await first.flushPendingWrites();

      final persisted =
          verify(storage.write(any, any, captureAny)).captured.last as String;

      // Simulate a fresh page load: a new service instance reads back
      // exactly what was persisted.
      when(storage.read(any, any)).thenAnswer((_) async => persisted);
      final second = DraftService();
      await second.load();

      expect(second.draft.experienceIds, ['exp-1']);
      expect(second.draft.skillIds, ['skill-1']);
    });

    test(
      'A bulletOverride wins over nothing set — round-trips correctly',
      () async {
        when(storage.read(any, any)).thenAnswer((_) async => null);
        when(
          storage.write(any, any, any),
        ).thenAnswer((_) => Future<void>.value());

        final service = DraftService();
        await service.load();

        await service.setBulletOverride('bullet-1', 'Rewritten text');
        expect(service.draft.bulletOverrides['bullet-1'], 'Rewritten text');

        await service.setBulletOverride('bullet-1', null);
        expect(service.draft.bulletOverrides.containsKey('bullet-1'), isFalse);

        await service.flushPendingWrites();
      },
    );
  });
}
