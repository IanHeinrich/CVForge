import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

/// The most strings one request will carry.
///
/// A ceiling, not a target: most sections come in well under it and travel
/// as a single request. It exists so one very long Experience section
/// cannot grow into a request big enough to approach Anthropic's
/// `max_tokens` ceiling, or big enough to tempt the model back into
/// summarising the document rather than translating its fields.
const _maxFieldsPerChunk = 20;

/// Everything a translation pass is allowed to rewrite, as
/// `id -> the text that currently prints`, split into one request per
/// section.
///
/// Built from the Vault *and* the draft, unlike [AiAssistantVaultPayload]
/// which sees only the Vault. Two reasons, and both matter:
///
/// - It sends the **effective** text — the draft's override where there is
///   one — because translating the Vault's original would silently discard
///   a tailoring pass or a hand edit the user can see on the page.
/// - It sends only what this draft actually **includes**. A CV that prints
///   four of twenty roles should not be billed for the other sixteen.
///
/// ## Why several requests rather than one
///
/// Chiefly because it makes a whole class of failure impossible rather
/// than merely unlikely. Handed the entire document and a single
/// prose-shaped `summary` slot, a model will sometimes return the whole
/// translation inside that one field — which produced a CV that could not
/// be rendered at all. `CvTranslationResult`'s length guard catches that
/// after the fact; this stops it arising, because a request carrying only
/// Experience has no `summary` key to put anything in.
///
/// It also keeps every request clear of Anthropic's hard
/// `max_tokens: 16000`, and lets the requests run concurrently, which is
/// what shortens the wait — output tokens dominate it.
///
/// **A section is the unit, and an entry is never split across requests.**
/// A role and its own bullets are exactly where a wandering translation
/// would show most, so they always travel together.
///
/// Identity is never copied on, the same policy (and for the same reason)
/// as [AiAssistantVaultPayload]: no name, email, phone, location or links.
/// Nor are the fields that must survive translation untouched — employers,
/// institutions, and a publication's own title and citation. A field that is never
/// in a payload cannot come back translated, which makes the
/// do-not-translate list a structural guarantee rather than an instruction
/// the model has to be trusted to follow.
///
/// Deliberately a plain one-directional transform rather than `@freezed` —
/// the same carve-out [AiAssistantVaultPayload] documents. It is built,
/// serialized once, and discarded.
class CvTranslationPayload {
  const CvTranslationPayload._(this._json, this.fieldCount);

  final Map<String, dynamic> _json;

  /// How many individual strings this request carries.
  final int fieldCount;

  Map<String, dynamic> toJson() => _json;

  /// Every request needed to translate what [draft] prints, in the order
  /// the sections appear on the page. Empty when there is nothing to
  /// translate at all.
  static List<CvTranslationPayload> chunksFor(CvVault vault, CvDraft draft) {
    String? effective(String? vaultValue, String? override) {
      final text = override ?? vaultValue;
      return (text == null || text.trim().isEmpty) ? null : text;
    }

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

    Map<String, String> bulletsFor(Iterable<String> ids) {
      final result = <String, String>{};
      for (final id in ids) {
        final bullet = bulletsById[id];
        if (bullet == null) continue; // dangling id, as everywhere else
        final text = effective(bullet.text, draft.bulletOverrides[id]);
        if (text != null) result[id] = text;
      }
      return result;
    }

    final chunks = <CvTranslationPayload>[];

    // Summary — the headline rides with it, matching where Studio puts it.
    final headline = draft.hideHeadline
        ? null
        : effective(vault.basics.headline, draft.headlineOverride);
    final summary = effective(vault.basics.summary, draft.tailoredSummary);
    if (headline != null || summary != null) {
      chunks.add(
        CvTranslationPayload._({
          'headline': ?headline,
          'summary': ?summary,
        }, (headline == null ? 0 : 1) + (summary == null ? 0 : 1)),
      );
    }

    // Skills — a category and its own skills stay together.
    final skillUnits = <_Unit>[];
    for (final category in vault.skillCategories) {
      final skills = <String, String>{};
      for (final skill in category.skills) {
        if (!draft.skillIds.contains(skill.id)) continue;
        final text = effective(
          skill.label,
          draft.skillLabelOverrides[skill.id],
        );
        if (text != null) skills[skill.id] = text;
      }
      if (skills.isEmpty) continue;
      final name = effective(
        category.name,
        draft.skillCategoryNameOverrides[category.id],
      );
      skillUnits.add(
        _Unit({
          'skillCategories': {category.id: ?name},
          'skills': skills,
        }),
      );
    }
    chunks.addAll(_pack(skillUnits));

    // Experience — a role and its own bullets never separate.
    final experienceUnits = <_Unit>[];
    for (final e in vault.experiences) {
      if (!draft.experienceIds.contains(e.id)) continue;
      final role = effective(e.role, draft.roleOverrides[e.id]);
      final bullets = bulletsFor(draft.bulletIds[e.id] ?? const []);
      if (role == null && bullets.isEmpty) continue;
      experienceUnits.add(
        _Unit({
          'roles': {e.id: ?role},
          'bullets': bullets,
        }),
      );
    }
    chunks.addAll(_pack(experienceUnits));

    // Projects — same shape, one entity over.
    final projectUnits = <_Unit>[];
    for (final p in vault.projects) {
      if (!draft.projectIds.contains(p.id)) continue;
      final title = effective(p.title, draft.projectTitleOverrides[p.id]);
      final bullets = bulletsFor(draft.projectBulletIds[p.id] ?? const []);
      if (title == null && bullets.isEmpty) continue;
      projectUnits.add(
        _Unit({
          'projectTitles': {p.id: ?title},
          'bullets': bullets,
        }),
      );
    }
    chunks.addAll(_pack(projectUnits));

    // Education — qualification, grade, details and bullets per entry.
    final educationUnits = <_Unit>[];
    for (final edu in vault.education) {
      if (!draft.educationIds.contains(edu.id)) continue;
      final qualification = effective(
        edu.qualification,
        draft.educationQualificationOverrides[edu.id],
      );
      final grade = effective(edu.grade, draft.educationGradeOverrides[edu.id]);
      final details = effective(
        edu.details,
        draft.educationDetailsOverrides[edu.id],
      );
      final bullets = bulletsFor(
        draft.educationBulletSelection(edu.id, [
          for (final b in edu.bullets) b.id,
        ]),
      );
      if (qualification == null &&
          grade == null &&
          details == null &&
          bullets.isEmpty) {
        continue;
      }
      educationUnits.add(
        _Unit({
          'qualifications': {edu.id: ?qualification},
          'grades': {edu.id: ?grade},
          'educationDetails': {edu.id: ?details},
          'bullets': bullets,
        }),
      );
    }
    chunks.addAll(_pack(educationUnits));

    // Publications — only the bullets. A paper's title and citation are
    // editable by hand (see `CvDraft`'s override-layer doc) but never
    // machine-translated: the person rewriting their own citation knows
    // what they are doing, where a translated one is a reference nobody
    // can look up, produced by a pass the user never reads line by line.
    final publicationUnits = <_Unit>[];
    for (final p in vault.publications) {
      if (!draft.publicationIds.contains(p.id)) continue;
      final bullets = bulletsFor(draft.publicationBulletIds[p.id] ?? const []);
      if (bullets.isEmpty) continue;
      publicationUnits.add(_Unit({'bullets': bullets}));
    }
    chunks.addAll(_pack(publicationUnits));

    // Hobbies — each is one short string, so they pack freely.
    final hobbyUnits = <_Unit>[];
    for (final h in vault.hobbies) {
      if (!draft.hobbyIds.contains(h.id)) continue;
      final text = effective(h.text, draft.hobbyOverrides[h.id]);
      if (text == null) continue;
      hobbyUnits.add(
        _Unit({
          'hobbies': {h.id: text},
        }),
      );
    }
    chunks.addAll(_pack(hobbyUnits));

    // Languages — the name only. A CEFR band is a code with a fixed
    // meaning, and handing "C1" to a translator invites it back as
    // something that is no longer the scale.
    final languageUnits = <_Unit>[];
    for (final l in vault.languages) {
      if (!draft.languageIds.contains(l.id)) continue;
      final text = effective(l.name, draft.languageOverrides[l.id]);
      if (text == null) continue;
      languageUnits.add(
        _Unit({
          'languages': {l.id: text},
        }),
      );
    }
    chunks.addAll(_pack(languageUnits));

    final references = effective(
      vault.referencesNote,
      draft.referencesOverride,
    );
    if (references != null) {
      chunks.add(CvTranslationPayload._({'referencesNote': references}, 1));
    }

    // Printed prose like the headline and the summary, so it translates
    // with them rather than staying in the language it was typed in.
    final workAuthorization = effective(
      vault.basics.workAuthorization,
      draft.workAuthorizationOverride,
    );
    if (workAuthorization != null) {
      chunks.add(
        CvTranslationPayload._({'workAuthorization': workAuthorization}, 1),
      );
    }

    return chunks;
  }

  /// Packs [units] into as few requests as [_maxFieldsPerChunk] allows,
  /// never splitting a unit across two of them.
  static List<CvTranslationPayload> _pack(List<_Unit> units) {
    final chunks = <CvTranslationPayload>[];
    var current = <_Unit>[];
    var count = 0;

    void flush() {
      if (current.isEmpty) return;
      final merged = <String, Map<String, String>>{};
      for (final unit in current) {
        unit.groups.forEach((group, entries) {
          if (entries.isEmpty) return;
          (merged[group] ??= <String, String>{}).addAll(entries);
        });
      }
      chunks.add(
        CvTranslationPayload._(Map<String, dynamic>.from(merged), count),
      );
      current = <_Unit>[];
      count = 0;
    }

    for (final unit in units) {
      // A single unit over the cap still ships whole: splitting an entry
      // is the one thing this is here to avoid.
      if (current.isNotEmpty && count + unit.fieldCount > _maxFieldsPerChunk) {
        flush();
      }
      current.add(unit);
      count += unit.fieldCount;
    }
    flush();
    return chunks;
  }
}

/// One entry and every string belonging to it — the indivisible unit of a
/// request, so a role and its own bullets are always translated with each
/// other in view.
class _Unit {
  _Unit(this.groups);

  final Map<String, Map<String, String>> groups;

  int get fieldCount =>
      groups.values.fold(0, (total, entries) => total + entries.length);
}
