import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

/// Drops entries the user created but never filled in, so a stray "+"
/// click can't leave a permanent blank row in the Vault.
///
/// This runs on the way *out* to storage rather than by refusing to create
/// the entry up front: every editor panel binds its fields to a real,
/// id-bearing entry the moment "+" is pressed, so deferring creation would
/// mean a separate "pending entry" state per entity type — a far larger
/// surface than one pure function over the whole aggregate. The trade is
/// deliberate and visible: a blank entry stays on screen and editable for
/// as long as the session keeps it, and simply never survives a reload.
///
/// Applied by `VaultService.writeToStorage` (so it covers the debounced
/// write, an explicit flush, and an import alike) and by `BackupService`'s
/// export, which reads in-memory state directly rather than going back
/// through storage.
extension CvVaultPruning on CvVault {
  CvVault withoutBlankEntries() {
    final experiences = _pruned(
      this.experiences,
      (e) => e.copyWith(bullets: _prunedBullets(e.bullets)),
      (e) =>
          _isBlank(e.role) &&
          _isBlank(e.company) &&
          _isBlank(e.location) &&
          e.bullets.isEmpty,
    );
    final projects = _pruned(
      this.projects,
      (p) => p.copyWith(bullets: _prunedBullets(p.bullets)),
      (p) => _isBlank(p.title) && _isBlank(p.link) && p.bullets.isEmpty,
    );
    final education = _pruned(
      this.education,
      (e) => e.copyWith(bullets: _prunedBullets(e.bullets)),
      (e) =>
          _isBlank(e.qualification) &&
          _isBlank(e.institution) &&
          _isBlank(e.location) &&
          _isBlank(e.grade) &&
          _isBlank(e.details) &&
          e.year == null &&
          e.bullets.isEmpty,
    );
    final publications = _pruned(
      this.publications,
      (p) => p.copyWith(bullets: _prunedBullets(p.bullets)),
      (p) =>
          _isBlank(p.title) &&
          _isBlank(p.citation) &&
          _isBlank(p.link) &&
          p.bullets.isEmpty,
    );

    // Computed after the four owners above are pruned, so dropping a blank
    // bullet can't leave a skill pointing at an id that no longer exists.
    final liveBulletIds = <String>{
      for (final e in experiences) ...e.bullets.map((b) => b.id),
      for (final p in projects) ...p.bullets.map((b) => b.id),
      for (final e in education) ...e.bullets.map((b) => b.id),
      for (final p in publications) ...p.bullets.map((b) => b.id),
    };

    return copyWith(
      basics: basics.copyWith(
        links: _pruned(
          basics.links,
          (l) => l,
          (l) => _isBlank(l.label) && _isBlank(l.url),
        ),
      ),
      experiences: experiences,
      projects: projects,
      education: education,
      publications: publications,
      skillCategories: _pruned(
        skillCategories,
        (c) => c.copyWith(
          skills: _pruned(
            c.skills,
            (s) => s.copyWith(
              linkedBulletIds: s.linkedBulletIds
                  .where(liveBulletIds.contains)
                  .toList(),
            ),
            (s) => _isBlank(s.label),
          ),
        ),
        // A category earns its place by having a name *or* surviving
        // skills — naming one but not filling it in yet is still intent.
        (c) => _isBlank(c.name) && c.skills.isEmpty,
      ),
      hobbies: _pruned(hobbies, (h) => h, (h) => _isBlank(h.text)),
    );
  }
}

bool _isBlank(String? value) => value == null || value.trim().isEmpty;

/// A bullet with neither text nor a label is nothing but its own id.
List<CvBullet> _prunedBullets(List<CvBullet> bullets) =>
    _pruned(bullets, (b) => b, (b) => _isBlank(b.text) && _isBlank(b.label));

/// Keeps each of [items] that [isBlank] rejects, judged *after*
/// [pruneChildren] has rebuilt it — so a parent whose only children were
/// themselves blank is correctly seen as blank too.
List<T> _pruned<T>(
  List<T> items,
  T Function(T item) pruneChildren,
  bool Function(T item) isBlank,
) => [
  for (final item in items)
    if (pruneChildren(item) case final pruned when !isBlank(pruned)) pruned,
];
