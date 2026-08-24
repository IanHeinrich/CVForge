import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

/// Everything a translation pass is allowed to rewrite, as
/// `id -> the text that currently prints`.
///
/// Built from the Vault *and* the draft, unlike
/// [AiAssistantVaultPayload] which sees only the Vault. Two reasons, and
/// both matter:
///
/// - It sends the **effective** text — the draft's override where there is
///   one — because translating the Vault's original would silently discard
///   a tailoring pass or a hand edit the user can see on the page.
/// - It sends only what this draft actually **includes**. A CV that prints
///   four of twenty roles should not be billed for the other sixteen.
///
/// Identity is never copied on, the same policy (and for the same reason)
/// as [AiAssistantVaultPayload]: no name, email, phone, location or links.
/// Nor are the fields that must survive translation untouched — employers,
/// institutions, publication titles and citations. A field that is never
/// in the payload cannot come back translated, which makes the
/// do-not-translate list a structural guarantee here rather than an
/// instruction the model has to be trusted to follow.
///
/// Deliberately a plain one-directional transform rather than `@freezed` —
/// the same carve-out [AiAssistantVaultPayload] documents. It is built,
/// serialized once, and discarded.
class CvTranslationPayload {
  const CvTranslationPayload._(this._json, this.fieldCount);

  factory CvTranslationPayload.from(CvVault vault, CvDraft draft) {
    String? effective(String? vaultValue, String? override) {
      final text = override ?? vaultValue;
      return (text == null || text.trim().isEmpty) ? null : text;
    }

    final headline = draft.hideHeadline
        ? null
        : effective(vault.basics.headline, draft.headlineOverride);
    final summary = effective(vault.basics.summary, draft.tailoredSummary);
    final references = effective(
      vault.referencesNote,
      draft.referencesOverride,
    );

    // Bullets are flat across their owners, matching `bulletOverrides`
    // itself — bullet ids are globally unique, so the owning entity adds
    // nothing a translator needs.
    final bulletsById = <String, CvBullet>{
      for (final e in vault.experiences)
        for (final b in e.bullets) b.id: b,
      for (final p in vault.projects)
        for (final b in p.bullets) b.id: b,
      for (final p in vault.publications)
        for (final b in p.bullets) b.id: b,
      for (final e in vault.education)
        for (final b in e.bullets) b.id: b,
    };

    final bullets = <String, String>{};
    void addBullets(Iterable<String> selectedIds) {
      for (final id in selectedIds) {
        final bullet = bulletsById[id];
        if (bullet == null) continue; // dangling id, as everywhere else
        final text = effective(bullet.text, draft.bulletOverrides[id]);
        if (text != null) bullets[id] = text;
      }
    }

    for (final expId in draft.experienceIds) {
      addBullets(draft.bulletIds[expId] ?? const []);
    }
    for (final projId in draft.projectIds) {
      addBullets(draft.projectBulletIds[projId] ?? const []);
    }
    for (final pubId in draft.publicationIds) {
      addBullets(draft.publicationBulletIds[pubId] ?? const []);
    }

    final roles = <String, String>{};
    for (final e in vault.experiences) {
      if (!draft.experienceIds.contains(e.id)) continue;
      final text = effective(e.role, draft.roleOverrides[e.id]);
      if (text != null) roles[e.id] = text;
    }

    final projectTitles = <String, String>{};
    for (final p in vault.projects) {
      if (!draft.projectIds.contains(p.id)) continue;
      final text = effective(p.title, draft.projectTitleOverrides[p.id]);
      if (text != null) projectTitles[p.id] = text;
    }

    final skills = <String, String>{};
    final skillCategories = <String, String>{};
    for (final category in vault.skillCategories) {
      var categoryUsed = false;
      for (final skill in category.skills) {
        if (!draft.skillIds.contains(skill.id)) continue;
        categoryUsed = true;
        final text = effective(
          skill.label,
          draft.skillLabelOverrides[skill.id],
        );
        if (text != null) skills[skill.id] = text;
      }
      if (!categoryUsed) continue;
      final name = effective(
        category.name,
        draft.skillCategoryNameOverrides[category.id],
      );
      if (name != null) skillCategories[category.id] = name;
    }

    final qualifications = <String, String>{};
    final grades = <String, String>{};
    final educationDetails = <String, String>{};
    for (final edu in vault.education) {
      if (!draft.educationIds.contains(edu.id)) continue;
      final qualification = effective(
        edu.qualification,
        draft.educationQualificationOverrides[edu.id],
      );
      if (qualification != null) qualifications[edu.id] = qualification;
      final grade = effective(edu.grade, draft.educationGradeOverrides[edu.id]);
      if (grade != null) grades[edu.id] = grade;
      final details = effective(
        edu.details,
        draft.educationDetailsOverrides[edu.id],
      );
      if (details != null) educationDetails[edu.id] = details;
      // Education bullets have no per-draft selection of their own — the
      // composer renders them all — so every one of them ships.
      addBullets(edu.bullets.map((b) => b.id));
    }

    final hobbies = <String, String>{};
    for (final h in vault.hobbies) {
      if (!draft.hobbyIds.contains(h.id)) continue;
      final text = effective(h.text, draft.hobbyOverrides[h.id]);
      if (text != null) hobbies[h.id] = text;
    }

    final json = <String, dynamic>{
      'headline': ?headline,
      'summary': ?summary,
      'referencesNote': ?references,
      if (roles.isNotEmpty) 'roles': roles,
      if (projectTitles.isNotEmpty) 'projectTitles': projectTitles,
      if (skillCategories.isNotEmpty) 'skillCategories': skillCategories,
      if (skills.isNotEmpty) 'skills': skills,
      if (qualifications.isNotEmpty) 'qualifications': qualifications,
      if (grades.isNotEmpty) 'grades': grades,
      if (educationDetails.isNotEmpty) 'educationDetails': educationDetails,
      if (hobbies.isNotEmpty) 'hobbies': hobbies,
      if (bullets.isNotEmpty) 'bullets': bullets,
    };

    final count =
        (headline == null ? 0 : 1) +
        (summary == null ? 0 : 1) +
        (references == null ? 0 : 1) +
        roles.length +
        projectTitles.length +
        skillCategories.length +
        skills.length +
        qualifications.length +
        grades.length +
        educationDetails.length +
        hobbies.length +
        bullets.length;

    return CvTranslationPayload._(json, count);
  }

  final Map<String, dynamic> _json;

  /// How many individual strings this payload carries. Used to tell the
  /// user how much of the CV a finished pass actually covered.
  final int fieldCount;

  Map<String, dynamic> toJson() => _json;
}
