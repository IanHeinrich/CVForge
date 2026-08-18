import 'dart:async';
import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/example_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/experience_bullet.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

/// Owns "The Vault" — the master career store. Reactive via
/// [ListenableServiceMixin]: a ViewModel that resolves this service and
/// mixes in `ReactiveViewModelMixin` with this in its `reactiveServices`
/// rebuilds automatically whenever [vault] changes.
///
/// Every read-path method awaits [_ready] first, making [load] an
/// optimisation rather than a correctness requirement — this is a web app
/// with real URLs, and refreshing on `/studio` bypasses `StartupView`
/// (and its explicit `load()` call) entirely.
class VaultService with ListenableServiceMixin {
  VaultService() {
    listenToReactiveValues([_vault]);
  }

  final _localStorage = locator<LocalStorageService>();
  final _uuid = const Uuid();

  final ReactiveValue<CvVault> _vault = ReactiveValue<CvVault>(CvVault.empty());
  CvVault get vault => _vault.value;

  Future<void>? _readyFuture;
  Timer? _writeDebounce;

  Future<void> _ready() => _readyFuture ??= _load();

  /// Explicit load, normally called once from `StartupViewModel`. Safe to
  /// call multiple times or not at all — every mutator/read below awaits
  /// the same underlying future via [_ready].
  Future<void> load() => _ready();

  Future<void> _load() async {
    await _localStorage.ensureInitialized();
    final raw = await _localStorage.read(
      StorageBoxes.vault,
      StorageKeys.vaultProfile,
    );
    if (raw == null) {
      _vault.value = CvVault.empty();
      return;
    }
    try {
      _vault.value = _migrate(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _quarantine(raw);
      _vault.value = CvVault.empty();
    }
  }

  CvVault _migrate(Map<String, dynamic> json) {
    // schemaVersion 1 is the only version that exists today. An unknown
    // version is treated the same as corruption (quarantine + fall back)
    // rather than risking CvVault.fromJson silently misinterpreting a
    // future, differently-shaped payload. A real v2 migration would add a
    // case here that upgrades the map before calling fromJson.
    final version = json['schemaVersion'];
    if (version != 1) {
      throw FormatException('Unsupported vault schemaVersion: $version');
    }
    return CvVault.fromJson(json);
  }

  Future<void> _quarantine(String raw) async {
    final key =
        '${StorageKeys.vaultProfile}_corrupt_${DateTime.now().millisecondsSinceEpoch}';
    await _localStorage.write(StorageBoxes.vault, key, raw);
  }

  Future<void> loadExampleVault() async {
    await _ready();
    _setVault((_) => buildExampleVault());
  }

  // --- basics ---

  Future<void> updateBasics(ContactBasics basics) async {
    await _ready();
    _setVault((v) => v.copyWith(basics: basics));
  }

  Future<ProfileLink> addProfileLink({
    required String label,
    required String url,
  }) async {
    await _ready();
    final link = ProfileLink(id: _uuid.v4(), label: label, url: url);
    _setVault(
      (v) => v.copyWith(
        basics: v.basics.copyWith(links: [...v.basics.links, link]),
      ),
    );
    return link;
  }

  Future<void> updateProfileLink(ProfileLink link) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        basics: v.basics.copyWith(
          links: [
            for (final l in v.basics.links)
              if (l.id == link.id) link else l,
          ],
        ),
      ),
    );
  }

  Future<void> deleteProfileLink(String id) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        basics: v.basics.copyWith(
          links: v.basics.links.where((l) => l.id != id).toList(),
        ),
      ),
    );
  }

  Future<void> updateReferencesNote(String? note) async {
    await _ready();
    _setVault((v) => v.copyWith(referencesNote: note));
  }

  // --- experiences ---

  Future<Experience> addExperience({
    required String role,
    required String company,
    required String location,
    required YearMonth start,
    YearMonth? end,
    bool isCurrent = false,
  }) async {
    await _ready();
    final experience = Experience(
      id: _uuid.v4(),
      role: role,
      company: company,
      location: location,
      start: start,
      end: end,
      isCurrent: isCurrent,
    );
    _setVault((v) => v.copyWith(experiences: [...v.experiences, experience]));
    return experience;
  }

  Future<void> updateExperience(Experience experience) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        experiences: [
          for (final e in v.experiences)
            if (e.id == experience.id) experience else e,
        ],
      ),
    );
  }

  Future<void> deleteExperience(String experienceId) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        experiences: v.experiences.where((e) => e.id != experienceId).toList(),
      ),
    );
  }

  // --- bullets ---

  Future<ExperienceBullet> addBullet(
    String experienceId, {
    String? label,
    required String text,
  }) async {
    await _ready();
    final bullet = ExperienceBullet(id: _uuid.v4(), label: label, text: text);
    _setVault(
      (v) => v.copyWith(
        experiences: [
          for (final e in v.experiences)
            if (e.id == experienceId)
              e.copyWith(bullets: [...e.bullets, bullet])
            else
              e,
        ],
      ),
    );
    return bullet;
  }

  Future<void> updateBullet(
    String experienceId,
    ExperienceBullet bullet,
  ) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        experiences: [
          for (final e in v.experiences)
            if (e.id == experienceId)
              e.copyWith(
                bullets: [
                  for (final b in e.bullets)
                    if (b.id == bullet.id) bullet else b,
                ],
              )
            else
              e,
        ],
      ),
    );
  }

  Future<void> deleteBullet(String experienceId, String bulletId) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        experiences: [
          for (final e in v.experiences)
            if (e.id == experienceId)
              e.copyWith(
                bullets: e.bullets.where((b) => b.id != bulletId).toList(),
              )
            else
              e,
        ],
      ),
    );
  }

  Future<void> reorderBullets(
    String experienceId,
    List<String> orderedBulletIds,
  ) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        experiences: [
          for (final e in v.experiences)
            if (e.id == experienceId)
              e.copyWith(
                bullets: [
                  for (final id in orderedBulletIds)
                    ...e.bullets.where((b) => b.id == id).take(1),
                ],
              )
            else
              e,
        ],
      ),
    );
  }

  // --- skill categories & skills ---

  Future<SkillCategory> addSkillCategory(String name) async {
    await _ready();
    final category = SkillCategory(id: _uuid.v4(), name: name);
    _setVault(
      (v) => v.copyWith(skillCategories: [...v.skillCategories, category]),
    );
    return category;
  }

  Future<void> updateSkillCategory(SkillCategory category) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        skillCategories: [
          for (final c in v.skillCategories)
            if (c.id == category.id) category else c,
        ],
      ),
    );
  }

  Future<void> deleteSkillCategory(String categoryId) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        skillCategories: v.skillCategories
            .where((c) => c.id != categoryId)
            .toList(),
      ),
    );
  }

  Future<Skill> addSkill(String categoryId, String label) async {
    await _ready();
    final skill = Skill(id: _uuid.v4(), label: label);
    _setVault(
      (v) => v.copyWith(
        skillCategories: [
          for (final c in v.skillCategories)
            if (c.id == categoryId)
              c.copyWith(skills: [...c.skills, skill])
            else
              c,
        ],
      ),
    );
    return skill;
  }

  Future<void> updateSkill(String categoryId, Skill skill) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        skillCategories: [
          for (final c in v.skillCategories)
            if (c.id == categoryId)
              c.copyWith(
                skills: [
                  for (final s in c.skills)
                    if (s.id == skill.id) skill else s,
                ],
              )
            else
              c,
        ],
      ),
    );
  }

  Future<void> deleteSkill(String categoryId, String skillId) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        skillCategories: [
          for (final c in v.skillCategories)
            if (c.id == categoryId)
              c.copyWith(
                skills: c.skills.where((s) => s.id != skillId).toList(),
              )
            else
              c,
        ],
      ),
    );
  }

  // --- education ---

  Future<Education> addEducation({
    required String qualification,
    required String institution,
    String? location,
    int? year,
    String? grade,
    String? details,
  }) async {
    await _ready();
    final education = Education(
      id: _uuid.v4(),
      qualification: qualification,
      institution: institution,
      location: location,
      year: year,
      grade: grade,
      details: details,
    );
    _setVault((v) => v.copyWith(education: [...v.education, education]));
    return education;
  }

  Future<void> updateEducation(Education education) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        education: [
          for (final e in v.education)
            if (e.id == education.id) education else e,
        ],
      ),
    );
  }

  Future<void> deleteEducation(String educationId) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        education: v.education.where((e) => e.id != educationId).toList(),
      ),
    );
  }

  // --- hobbies ---

  Future<HobbyItem> addHobby(String text) async {
    await _ready();
    final hobby = HobbyItem(id: _uuid.v4(), text: text);
    _setVault((v) => v.copyWith(hobbies: [...v.hobbies, hobby]));
    return hobby;
  }

  Future<void> updateHobby(HobbyItem hobby) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        hobbies: [
          for (final h in v.hobbies)
            if (h.id == hobby.id) hobby else h,
        ],
      ),
    );
  }

  Future<void> deleteHobby(String hobbyId) async {
    await _ready();
    _setVault(
      (v) =>
          v.copyWith(hobbies: v.hobbies.where((h) => h.id != hobbyId).toList()),
    );
  }

  // --- persistence plumbing ---

  void _setVault(CvVault Function(CvVault current) update) {
    _vault.value = update(_vault.value).copyWith(updatedAt: DateTime.now());
    _scheduleWrite();
  }

  void _scheduleWrite() {
    _writeDebounce?.cancel();
    _writeDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_persist());
    });
  }

  /// Forces any pending debounced write to happen immediately. Exists both
  /// for tests (deterministic persistence assertions without waiting on a
  /// real timer) and for production use before a point where losing an
  /// in-flight edit would matter (e.g. before navigating away).
  Future<void> flushPendingWrites() async {
    if (_writeDebounce == null) return;
    _writeDebounce!.cancel();
    _writeDebounce = null;
    await _persist();
  }

  Future<void> _persist() async {
    final json = jsonEncode(_vault.value.toJson());
    await _localStorage.write(
      StorageBoxes.vault,
      StorageKeys.vaultProfile,
      json,
    );
  }
}
