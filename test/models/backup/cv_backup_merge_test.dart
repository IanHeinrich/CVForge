import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/backup/cv_backup_merge.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/settings/cv_preferences.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_photo.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:flutter_test/flutter_test.dart';

/// `mergeBackupBundles` is a pure truth table with no ViewModel or Service
/// above it whose public API expresses that table — the same carve-out
/// `ats_matrix_math_test.dart` documents. Routing these cases through
/// `DriveSyncService` would mean a full mock-Drive round trip each to
/// assert something the function states directly; the outside-in tests
/// there cover the *integration* (what gets applied, what gets pushed,
/// what the ancestor becomes), which is a different question.

final _t0 = DateTime.utc(2026, 1, 1);
final _t1 = DateTime.utc(2026, 1, 2);
final _t2 = DateTime.utc(2026, 1, 3);

Experience _job(
  String id, {
  String role = 'Engineer',
  List<CvBullet>? bullets,
}) => Experience(
  id: id,
  role: role,
  company: 'Acme',
  location: 'London',
  start: const YearMonth(year: 2020, month: 1),
  bullets: bullets ?? const [],
);

CvVault _v({
  List<Experience> experiences = const [],
  List<SkillCategory> skillCategories = const [],
  ContactBasics? basics,
  String? referencesNote,
  DocumentDefaults? documentDefaults,
  DateTime? at,
}) => CvVault(
  schemaVersion: 1,
  basics: basics ?? ContactBasics.empty(),
  experiences: experiences,
  skillCategories: skillCategories,
  referencesNote: referencesNote,
  documentDefaults: documentDefaults ?? const DocumentDefaults(),
  updatedAt: at ?? _t0,
);

CvDraft _draft(String id, {String name = 'CV', DateTime? at}) => CvDraft(
  schemaVersion: 1,
  id: id,
  name: name,
  templateId: 'classic',
  updatedAt: at ?? _t0,
);

CvBackupBundle _b(
  CvVault? vault, {
  List<CvDraft> drafts = const [],
  String? activeDraftId,
  CvPreferences? preferences,
}) => CvBackupBundle(
  app: 'cv-forge',
  bundleVersion: 1,
  exportedAt: _t0,
  appVersion: '1.0.0',
  vault: vault,
  drafts: drafts,
  activeDraftId: activeDraftId,
  preferences: preferences,
);

CvPreferences _prefs({String? providerId, String? localeTag, DateTime? at}) =>
    CvPreferences(
      aiAssistantProviderId: providerId,
      localeTag: localeTag,
      updatedAt: at ?? _t0,
    );

CvVault _mergedVault(
  CvBackupBundle base,
  CvBackupBundle local,
  CvBackupBundle remote,
) => mergeBackupBundles(base: base, local: local, remote: remote).vault!;

List<String> _ids(CvVault vault) => [for (final e in vault.experiences) e.id];

void main() {
  group('mergeBackupBundles - experiences truth table', () {
    final base = _b(_v(experiences: [_job('a'), _job('b')]));

    test('an entry added on one side only survives, from either side', () {
      final localAdd = _b(
        _v(experiences: [_job('a'), _job('b'), _job('new')], at: _t1),
      );
      expect(_ids(_mergedVault(base, localAdd, base)), ['a', 'b', 'new']);
      expect(_ids(_mergedVault(base, base, localAdd)), ['a', 'b', 'new']);
    });

    test('an entry deleted on one side and untouched on the other is gone', () {
      final without = _b(_v(experiences: [_job('a')], at: _t1));
      expect(_ids(_mergedVault(base, without, base)), ['a']);
      expect(_ids(_mergedVault(base, base, without)), ['a']);
    });

    test('an entry deleted on both sides stays gone', () {
      final without = _b(_v(experiences: [_job('a')], at: _t1));
      expect(_ids(_mergedVault(base, without, without)), ['a']);
    });

    test('an entry edited on one side and deleted on the other survives with '
        'the edit — edit beats delete, in both directions', () {
      final edited = _b(
        _v(
          experiences: [
            _job('a'),
            _job('b', role: 'Staff Engineer'),
          ],
          at: _t1,
        ),
      );
      final deleted = _b(_v(experiences: [_job('a')], at: _t1));

      final localEdits = _mergedVault(base, edited, deleted);
      expect(_ids(localEdits), ['a', 'b']);
      expect(localEdits.experiences[1].role, 'Staff Engineer');

      final remoteEdits = _mergedVault(base, deleted, edited);
      expect(_ids(remoteEdits), ['a', 'b']);
      expect(remoteEdits.experiences[1].role, 'Staff Engineer');
    });

    test('an entry edited on one side only takes that edit', () {
      final edited = _b(
        _v(
          experiences: [
            _job('a'),
            _job('b', role: 'Lead'),
          ],
          at: _t1,
        ),
      );
      expect(_mergedVault(base, edited, base).experiences[1].role, 'Lead');
      expect(_mergedVault(base, base, edited).experiences[1].role, 'Lead');
    });

    test('an entry edited on both sides goes to whichever vault is newer', () {
      final localEdit = _b(
        _v(
          experiences: [
            _job('a'),
            _job('b', role: 'Local'),
          ],
          at: _t2,
        ),
      );
      final remoteEdit = _b(
        _v(
          experiences: [
            _job('a'),
            _job('b', role: 'Remote'),
          ],
          at: _t1,
        ),
      );
      expect(
        _mergedVault(base, localEdit, remoteEdit).experiences[1].role,
        'Local',
      );
      expect(
        _mergedVault(base, remoteEdit, localEdit).experiences[1].role,
        'Local',
      );
    });

    test('the same edit made on both sides is not a contest', () {
      final edited = _b(
        _v(
          experiences: [
            _job('a'),
            _job('b', role: 'Lead'),
          ],
          at: _t1,
        ),
      );
      expect(_mergedVault(base, edited, edited).experiences[1].role, 'Lead');
    });
  });

  group('mergeBackupBundles - nested entities', () {
    test('bullets added under the same entry on each side both survive', () {
      final base = _b(
        _v(
          experiences: [
            _job(
              'a',
              bullets: const [CvBullet(id: 'b1', text: 'one')],
            ),
          ],
        ),
      );
      final local = _b(
        _v(
          experiences: [
            _job(
              'a',
              bullets: const [
                CvBullet(id: 'b1', text: 'one'),
                CvBullet(id: 'b2', text: 'two'),
              ],
            ),
          ],
          at: _t1,
        ),
      );
      final remote = _b(
        _v(
          experiences: [
            _job(
              'a',
              bullets: const [
                CvBullet(id: 'b1', text: 'one'),
                CvBullet(id: 'b3', text: 'three'),
              ],
            ),
          ],
          at: _t1,
        ),
      );

      final merged = _mergedVault(base, local, remote);
      expect(merged.experiences.single.bullets.map((b) => b.id), [
        'b1',
        'b2',
        'b3',
      ]);
    });

    test('a bullet deleted on one side stays deleted while the entry it sat '
        'under takes the other side\'s edit', () {
      final base = _b(
        _v(
          experiences: [
            _job(
              'a',
              bullets: const [
                CvBullet(id: 'b1', text: 'one'),
                CvBullet(id: 'b2', text: 'two'),
              ],
            ),
          ],
        ),
      );
      final local = _b(
        _v(
          experiences: [
            _job(
              'a',
              bullets: const [CvBullet(id: 'b1', text: 'one')],
            ),
          ],
          at: _t1,
        ),
      );
      final remote = _b(
        _v(
          experiences: [
            _job(
              'a',
              role: 'Principal',
              bullets: const [
                CvBullet(id: 'b1', text: 'one'),
                CvBullet(id: 'b2', text: 'two'),
              ],
            ),
          ],
          at: _t1,
        ),
      );

      final entry = _mergedVault(base, local, remote).experiences.single;
      expect(entry.role, 'Principal');
      expect(entry.bullets.map((b) => b.id), ['b1']);
    });

    test('a skill added remotely survives a category renamed locally, and '
        'linked bullet ids union', () {
      final base = _b(
        _v(
          skillCategories: const [
            SkillCategory(
              id: 'c1',
              name: 'Languages',
              skills: [
                Skill(id: 's1', label: 'Dart', linkedBulletIds: ['b1']),
              ],
            ),
          ],
        ),
      );
      final local = _b(
        _v(
          skillCategories: const [
            SkillCategory(
              id: 'c1',
              name: 'Programming languages',
              skills: [
                Skill(id: 's1', label: 'Dart', linkedBulletIds: ['b1', 'b2']),
              ],
            ),
          ],
          at: _t1,
        ),
      );
      final remote = _b(
        _v(
          skillCategories: const [
            SkillCategory(
              id: 'c1',
              name: 'Languages',
              skills: [
                Skill(id: 's1', label: 'Dart', linkedBulletIds: ['b1', 'b3']),
                Skill(id: 's2', label: 'Rust'),
              ],
            ),
          ],
          at: _t1,
        ),
      );

      final category = _mergedVault(base, local, remote).skillCategories.single;
      expect(category.name, 'Programming languages');
      expect(category.skills.map((s) => s.id), ['s1', 's2']);
      expect(category.skills.first.linkedBulletIds, ['b1', 'b2', 'b3']);
    });

    test('contact links added on each side both survive, and a headline '
        'changed on one side wins', () {
      const baseBasics = ContactBasics(
        fullName: 'Ada',
        headline: 'Engineer',
        email: 'a@example.com',
        phone: '',
        location: 'London',
      );
      final base = _b(_v(basics: baseBasics));
      final local = _b(
        _v(
          basics: baseBasics.copyWith(
            headline: 'Staff Engineer',
            links: const [ProfileLink(id: 'l1', label: 'GitHub', url: 'g')],
          ),
          at: _t1,
        ),
      );
      final remote = _b(
        _v(
          basics: baseBasics.copyWith(
            links: const [ProfileLink(id: 'l2', label: 'LinkedIn', url: 'l')],
          ),
          at: _t1,
        ),
      );

      final basics = _mergedVault(base, local, remote).basics;
      expect(basics.headline, 'Staff Engineer');
      expect(basics.links.map((l) => l.id), ['l1', 'l2']);
    });

    test('a photo added on one device only reaches the other — the Vault '
        'is how the photograph syncs, so a missed field here would be a '
        'silently unsynced upload', () {
      const photo = CvPhoto(jpegBase64: 'AAAA', widthPx: 420, heightPx: 540);
      final baseBasics = ContactBasics.empty().copyWith(fullName: 'Ada');
      final base = _b(_v(basics: baseBasics));
      final local = _b(
        _v(
          basics: baseBasics.copyWith(photo: photo),
          at: _t1,
        ),
      );
      final remote = _b(_v(basics: baseBasics, at: _t1));

      expect(_mergedVault(base, local, remote).basics.photo, photo);
      // Symmetric: which side uploaded it must not matter.
      expect(_mergedVault(base, remote, local).basics.photo, photo);
    });

    test('a photo replaced on both devices is settled by preferRemote, not '
        'silently merged into neither', () {
      const basePhoto = CvPhoto(jpegBase64: 'A', widthPx: 1, heightPx: 1);
      const localPhoto = CvPhoto(jpegBase64: 'L', widthPx: 2, heightPx: 2);
      const remotePhoto = CvPhoto(jpegBase64: 'R', widthPx: 3, heightPx: 3);
      final baseBasics = ContactBasics.empty().copyWith(photo: basePhoto);
      final base = _b(_v(basics: baseBasics));
      final local = _b(
        _v(
          basics: baseBasics.copyWith(photo: localPhoto),
          at: _t2,
        ),
      );
      final remote = _b(
        _v(
          basics: baseBasics.copyWith(photo: remotePhoto),
          at: _t1,
        ),
      );

      // The newer vault wins, same rule as every other contested field.
      expect(_mergedVault(base, local, remote).basics.photo, localPhoto);
    });

    test('a photo removed on one device stays removed rather than being '
        'resurrected by the other side still having it', () {
      const photo = CvPhoto(jpegBase64: 'AAAA', widthPx: 420, heightPx: 540);
      final baseBasics = ContactBasics.empty().copyWith(photo: photo);
      final base = _b(_v(basics: baseBasics));
      final local = _b(_v(basics: baseBasics.copyWith(photo: null), at: _t1));
      final remote = _b(_v(basics: baseBasics, at: _t1));

      expect(_mergedVault(base, local, remote).basics.photo, isNull);
    });

    test('a references note changed on both sides goes to the newer vault', () {
      final base = _b(_v(referencesNote: 'On request'));
      final local = _b(_v(referencesNote: 'Available on request', at: _t1));
      final remote = _b(_v(referencesNote: 'Supplied on request', at: _t2));

      expect(
        _mergedVault(base, local, remote).referencesNote,
        'Supplied on request',
      );
    });
  });

  group('mergeBackupBundles - ordering and timestamps', () {
    test('a reorder on one side is kept, and the other side\'s addition '
        'splices in after the entry it followed there', () {
      final base = _b(_v(experiences: [_job('a'), _job('b'), _job('c')]));
      final localAdd = _b(
        _v(
          experiences: [_job('a'), _job('b'), _job('new'), _job('c')],
          at: _t1,
        ),
      );
      final remoteReorder = _b(
        _v(experiences: [_job('c'), _job('a'), _job('b')], at: _t1),
      );

      expect(_ids(_mergedVault(base, localAdd, remoteReorder)), [
        'c',
        'a',
        'b',
        'new',
      ]);
    });

    test('a genuinely combined result is dated by the later side', () {
      final base = _b(_v(experiences: [_job('a')]));
      final local = _b(_v(experiences: [_job('a'), _job('b')], at: _t1));
      final remote = _b(_v(experiences: [_job('a'), _job('c')], at: _t2));

      expect(_mergedVault(base, local, remote).updatedAt, _t2);
    });

    test('a result identical to one side keeps that side\'s date rather than '
        'claiming to be fresher — this is what stops a device that was '
        'purely behind writing back a pointless update', () {
      final base = _b(_v(experiences: [_job('a')]));
      final local = _b(_v(experiences: [_job('a')], at: _t2));
      final remote = _b(_v(experiences: [_job('a'), _job('b')], at: _t1));

      final merged = _mergedVault(base, local, remote);
      expect(_ids(merged), ['a', 'b']);
      expect(merged.updatedAt, _t1);
    });
  });

  group('mergeBackupBundles - drafts', () {
    final base = _b(_v(), drafts: [_draft('d1')], activeDraftId: 'd1');

    test('a draft added on each side leaves both', () {
      final local = _b(
        _v(),
        drafts: [_draft('d1'), _draft('d2')],
        activeDraftId: 'd1',
      );
      final remote = _b(
        _v(),
        drafts: [_draft('d1'), _draft('d3')],
        activeDraftId: 'd1',
      );

      final merged = mergeBackupBundles(
        base: base,
        local: local,
        remote: remote,
      );
      expect(merged.drafts.map((d) => d.id), ['d1', 'd2', 'd3']);
    });

    test('a draft edited on both sides is taken whole from the later one', () {
      final local = _b(
        _v(),
        drafts: [_draft('d1', name: 'Local', at: _t1)],
        activeDraftId: 'd1',
      );
      final remote = _b(
        _v(),
        drafts: [_draft('d1', name: 'Remote', at: _t2)],
        activeDraftId: 'd1',
      );

      final merged = mergeBackupBundles(
        base: base,
        local: local,
        remote: remote,
      );
      expect(merged.drafts.single.name, 'Remote');
    });

    test('a draft deleted locally and untouched remotely stays gone', () {
      final local = _b(_v(), drafts: [], activeDraftId: null);
      final merged = mergeBackupBundles(base: base, local: local, remote: base);
      expect(merged.drafts, isEmpty);
      expect(merged.activeDraftId, isNull);
    });

    test('which CV is open prefers this device, and falls back to something '
        'that survived rather than pointing at a deleted draft', () {
      final local = _b(
        _v(),
        drafts: [_draft('d1'), _draft('d2')],
        activeDraftId: 'd2',
      );
      final remote = _b(
        _v(),
        drafts: [_draft('d1'), _draft('d3')],
        activeDraftId: 'd3',
      );
      expect(
        mergeBackupBundles(
          base: base,
          local: local,
          remote: remote,
        ).activeDraftId,
        'd2',
      );

      // Local's choice was deleted remotely and never edited here, so it
      // did not survive the merge — fall through rather than dangle.
      final localPointingAtDeleted = _b(
        _v(),
        drafts: [_draft('d1')],
        activeDraftId: 'd1',
      );
      final remoteDeletedIt = _b(_v(), drafts: [_draft('d3')]);
      final merged = mergeBackupBundles(
        base: base,
        local: localPointingAtDeleted,
        remote: remoteDeletedIt,
      );
      expect(merged.drafts.map((d) => d.id), ['d3']);
      expect(merged.activeDraftId, 'd3');
    });
  });

  group('mergeBackupBundles - no ancestor, and algebra', () {
    test('with no ancestor vault every id on both sides is kept — nothing '
        'is evidence of a deletion, which is the migration path', () {
      final base = _b(null);
      final local = _b(_v(experiences: [_job('a')], at: _t1));
      final remote = _b(_v(experiences: [_job('b')], at: _t1));

      expect(_ids(_mergedVault(base, local, remote)), ['a', 'b']);
    });

    test('an empty local side against a populated remote yields the remote '
        'verbatim, timestamp included', () {
      final base = _b(null);
      final local = _b(_v(at: _t2));
      final remote = _b(_v(experiences: [_job('a')], at: _t1));

      final merged = _mergedVault(base, local, remote);
      expect(merged, remote.vault);
    });

    test('merging a side with itself changes nothing', () {
      final base = _b(_v(experiences: [_job('a')]), drafts: [_draft('d1')]);
      final x = _b(
        _v(experiences: [_job('a'), _job('b')], at: _t1),
        drafts: [_draft('d1'), _draft('d2')],
        activeDraftId: 'd2',
      );

      final merged = mergeBackupBundles(base: base, local: x, remote: x);
      expect(merged.vault, x.vault);
      expect(merged.drafts, x.drafts);
      expect(merged.activeDraftId, x.activeDraftId);
    });

    test('a side that never moved off the ancestor yields the other side', () {
      final base = _b(_v(experiences: [_job('a')]), drafts: [_draft('d1')]);
      final moved = _b(
        _v(experiences: [_job('a'), _job('b')], at: _t1),
        drafts: [_draft('d1'), _draft('d2')],
      );

      final remoteMoved = mergeBackupBundles(
        base: base,
        local: base,
        remote: moved,
      );
      expect(remoteMoved.vault, moved.vault);
      expect(remoteMoved.drafts, moved.drafts);

      final localMoved = mergeBackupBundles(
        base: base,
        local: moved,
        remote: base,
      );
      expect(localMoved.vault, moved.vault);
      expect(localMoved.drafts, moved.drafts);
    });
  });

  group('mergeBackupBundles - preferences', () {
    final base = _b(_v(), preferences: _prefs());

    CvPreferences? mergedPrefs(CvBackupBundle local, CvBackupBundle remote) =>
        mergeBackupBundles(
          base: base,
          local: local,
          remote: remote,
        ).preferences;

    test('a preference changed on one side only takes that change', () {
      final changed = _b(
        _v(),
        preferences: _prefs(providerId: 'anthropic', at: _t1),
      );
      expect(mergedPrefs(changed, base)?.aiAssistantProviderId, 'anthropic');
      expect(mergedPrefs(base, changed)?.aiAssistantProviderId, 'anthropic');
    });

    test('an explicitly chosen UI language survives a sync', () {
      final chosen = _b(
        _v(),
        preferences: _prefs(localeTag: 'es', at: _t1),
      );

      expect(mergedPrefs(chosen, base)?.localeTag, 'es');
      expect(mergedPrefs(base, chosen)?.localeTag, 'es');
    });

    test('different preferences changed on each side both survive — no id '
        'to merge by, but the fields are independent', () {
      final local = _b(
        _v(),
        preferences: _prefs(localeTag: 'es', at: _t1),
      );
      final remote = _b(
        _v(),
        preferences: _prefs(providerId: 'anthropic', at: _t1),
      );

      final merged = mergedPrefs(local, remote)!;
      expect(merged.localeTag, 'es');
      expect(merged.aiAssistantProviderId, 'anthropic');
    });

    test('the same preference changed on both sides goes to the later one', () {
      final local = _b(
        _v(),
        preferences: _prefs(providerId: 'anthropic', at: _t1),
      );
      final remote = _b(
        _v(),
        preferences: _prefs(providerId: 'google', at: _t2),
      );
      expect(mergedPrefs(local, remote)?.aiAssistantProviderId, 'google');
      expect(mergedPrefs(remote, local)?.aiAssistantProviderId, 'google');
    });

    test('a side with no preferences at all means "nothing to say", never '
        '"clear them"', () {
      final withPrefs = _b(
        _v(),
        preferences: _prefs(providerId: 'anthropic', at: _t1),
      );
      final without = _b(_v());

      expect(
        mergedPrefs(withPrefs, without)?.aiAssistantProviderId,
        'anthropic',
      );
      expect(
        mergedPrefs(without, withPrefs)?.aiAssistantProviderId,
        'anthropic',
      );
      expect(
        mergeBackupBundles(
          base: _b(_v()),
          local: without,
          remote: without,
        ).preferences,
        isNull,
      );
    });

    test('a result identical to one side keeps that side\'s date, so a '
        'device that was purely behind writes nothing back', () {
      final local = _b(_v(), preferences: _prefs(at: _t2));
      final remote = _b(
        _v(),
        preferences: _prefs(providerId: 'anthropic', at: _t1),
      );

      expect(mergedPrefs(local, remote), remote.preferences);
    });
  });

  group('mergeBackupBundles - document defaults', () {
    DocumentDefaults? mergedDefaults(CvVault local, CvVault remote) =>
        mergeBackupBundles(
          base: _b(_v()),
          local: _b(local),
          remote: _b(remote),
        ).vault?.documentDefaults;

    test('a default changed on one side only takes that change', () {
      final changed = _v(
        documentDefaults: const DocumentDefaults(region: RegionProfile.us),
        at: _t1,
      );

      expect(mergedDefaults(changed, _v())?.region, RegionProfile.us);
      expect(mergedDefaults(_v(), changed)?.region, RegionProfile.us);
    });

    test('region and language changed on different devices both survive — '
        'the whole reason these merge field by field rather than as one '
        'object', () {
      final local = _v(
        documentDefaults: const DocumentDefaults(region: RegionProfile.dach),
        at: _t1,
      );
      final remote = _v(
        documentDefaults: const DocumentDefaults(language: DocumentLanguage.de),
        at: _t1,
      );

      final merged = mergedDefaults(local, remote)!;
      expect(merged.region, RegionProfile.dach);
      expect(merged.language, DocumentLanguage.de);
    });

    test('a default template picked on one device survives, and merges '
        'independently of the language picked on the other', () {
      final local = _v(
        documentDefaults: const DocumentDefaults(templateId: 'photo_header'),
        at: _t1,
      );
      final remote = _v(
        documentDefaults: const DocumentDefaults(language: DocumentLanguage.de),
        at: _t1,
      );

      final merged = mergedDefaults(local, remote)!;
      expect(merged.templateId, 'photo_header');
      expect(merged.language, DocumentLanguage.de);
    });

    test('the two header-field toggles merge like every other default — '
        'they returned local.copyWith and so silently dropped a remote '
        'change', () {
      final local = _v(
        documentDefaults: const DocumentDefaults(hideHeadline: true),
        at: _t1,
      );
      final remote = _v(
        documentDefaults: const DocumentDefaults(hideWorkAuthorization: true),
        at: _t1,
      );

      final merged = mergedDefaults(local, remote)!;
      expect(merged.hideHeadline, isTrue);
      expect(merged.hideWorkAuthorization, isTrue);

      // The direction that used to fail: the change is only on the remote
      // side, so a field left out of the merge kept the local `false`.
      final remoteOnly = _v(
        documentDefaults: const DocumentDefaults(hideHeadline: true),
        at: _t1,
      );
      expect(mergedDefaults(_v(), remoteOnly)?.hideHeadline, isTrue);

      final remoteOnlyWorkAuth = _v(
        documentDefaults: const DocumentDefaults(hideWorkAuthorization: true),
        at: _t1,
      );
      expect(
        mergedDefaults(_v(), remoteOnlyWorkAuth)?.hideWorkAuthorization,
        isTrue,
      );
    });

    test('the same default changed on both sides goes to the later vault', () {
      final local = _v(
        documentDefaults: const DocumentDefaults(language: DocumentLanguage.de),
        at: _t1,
      );
      final remote = _v(
        documentDefaults: const DocumentDefaults(language: DocumentLanguage.fr),
        at: _t2,
      );

      expect(mergedDefaults(local, remote)?.language, DocumentLanguage.fr);
      expect(mergedDefaults(remote, local)?.language, DocumentLanguage.fr);
    });

    test('changing a default lets that device win a contested bullet too — '
        'a consequence of the defaults living on the Vault, whose own '
        'updatedAt settles content, not an accident', () {
      final base = _b(_v(experiences: [_job('a', role: 'Engineer')]));
      final local = _b(
        _v(
          experiences: [_job('a', role: 'Local')],
          documentDefaults: const DocumentDefaults(
            language: DocumentLanguage.de,
          ),
          at: _t2,
        ),
      );
      final remote = _b(
        _v(
          experiences: [_job('a', role: 'Remote')],
          at: _t1,
        ),
      );

      final merged = mergeBackupBundles(
        base: base,
        local: local,
        remote: remote,
      ).vault!;
      expect(merged.experiences.single.role, 'Local');
      expect(merged.documentDefaults.language, DocumentLanguage.de);
    });
  });

  group('bundlesAreMergeable', () {
    test('rejects two vaults on different schema versions', () {
      final local = _b(_v());
      final remote = _b(
        CvVault(
          schemaVersion: 2,
          basics: ContactBasics.empty(),
          updatedAt: _t0,
        ),
      );
      expect(bundlesAreMergeable(local, remote), isFalse);
      expect(bundlesAreMergeable(local, local), isTrue);
    });

    test('a missing vault on either side is not a shape mismatch', () {
      expect(bundlesAreMergeable(_b(null), _b(_v())), isTrue);
      expect(bundlesAreMergeable(_b(_v()), _b(null)), isTrue);
    });
  });
}
