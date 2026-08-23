import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

part 'copilot_result.freezed.dart';

/// A Copilot tailoring pass's response, parsed and validated against
/// [CvVault] rather than trusted as-is.
///
/// [buildCopilotResponseSchema]'s `enum` constraints make a hallucinated id
/// structurally impossible on a provider that honours them — but that
/// guarantee doesn't hold for every provider (Gemini has no
/// `additionalProperties`-style key-closure mechanism at all; see
/// `GeminiProvider._walkSchema`'s doc comment). [fromLlmResponse] therefore
/// validates every id against
/// [vault]'s own ids unconditionally — belt-and-braces on a provider that
/// enforces the schema, the *only* enforcement on one that doesn't. An
/// unknown id, a wrong type, or a bullet attached to the wrong
/// experience/project/publication is dropped silently, the same "dangling
/// ids are normal, not an error" rule [CvDraft] already applies everywhere
/// else — never a crash, never a thrown exception.
@freezed
abstract class CopilotResult with _$CopilotResult {
  const factory CopilotResult({
    String? headline,
    String? summary,
    required List<String> experienceIds,

    /// experienceId -> selected bullet ids, scoped to that experience's
    /// own bullets only — see [fromLlmResponse]'s per-entry validation.
    required Map<String, List<String>> bulletIds,
    required List<String> projectIds,
    required Map<String, List<String>> projectBulletIds,
    required List<String> publicationIds,
    required Map<String, List<String>> publicationBulletIds,

    /// bulletId -> rewritten text, flattened across experiences and
    /// projects — legal because bullet ids are globally unique (the same
    /// reasoning as `CvDraft.bulletOverrides`), and it's exactly the shape
    /// `DraftService.applyCopilotResult` needs to hand `CvDraft` directly.
    required Map<String, String> bulletOverrides,
    required List<String> skillIds,
    required List<String> educationIds,
    required List<String> hobbyIds,
    required Set<CvSectionType> hiddenSections,
    required String rationale,
    required List<String> keywordGaps,
  }) = _CopilotResult;

  factory CopilotResult.fromLlmResponse(
    Map<String, dynamic> json,
    CvVault vault,
  ) {
    final skillIds = {
      for (final c in vault.skillCategories)
        for (final s in c.skills) s.id,
    };
    final educationIds = {for (final e in vault.education) e.id};
    final hobbyIds = {for (final h in vault.hobbies) h.id};
    final sectionNames = {for (final s in CvSectionType.values) s.name};

    final resultBulletIds = <String, List<String>>{};
    final resultProjectBulletIds = <String, List<String>>{};
    final resultPublicationBulletIds = <String, List<String>>{};
    final bulletOverrides = <String, String>{};

    final experiencesRaw = json['experiences'];
    if (experiencesRaw is Map) {
      for (final e in vault.experiences) {
        final entry = experiencesRaw[e.id];
        if (entry is! Map) continue;
        _applyEntry(
          entry,
          entryId: e.id,
          validBulletIds: {for (final b in e.bullets) b.id},
          bulletIdsOut: resultBulletIds,
          bulletOverridesOut: bulletOverrides,
        );
      }
    }

    final projectsRaw = json['projects'];
    if (projectsRaw is Map) {
      for (final p in vault.projects) {
        final entry = projectsRaw[p.id];
        if (entry is! Map) continue;
        _applyEntry(
          entry,
          entryId: p.id,
          validBulletIds: {for (final b in p.bullets) b.id},
          bulletIdsOut: resultProjectBulletIds,
          bulletOverridesOut: bulletOverrides,
        );
      }
    }

    final publicationsRaw = json['publications'];
    if (publicationsRaw is Map) {
      for (final p in vault.publications) {
        final entry = publicationsRaw[p.id];
        if (entry is! Map) continue;
        _applyEntry(
          entry,
          entryId: p.id,
          validBulletIds: {for (final b in p.bullets) b.id},
          bulletIdsOut: resultPublicationBulletIds,
          bulletOverridesOut: bulletOverrides,
        );
      }
    }

    return CopilotResult(
      headline: _asString(json['headline']),
      summary: _asString(json['summary']),
      experienceIds: [
        for (final e in vault.experiences)
          if (resultBulletIds.containsKey(e.id)) e.id,
      ],
      bulletIds: resultBulletIds,
      projectIds: [
        for (final p in vault.projects)
          if (resultProjectBulletIds.containsKey(p.id)) p.id,
      ],
      projectBulletIds: resultProjectBulletIds,
      publicationIds: [
        for (final p in vault.publications)
          if (resultPublicationBulletIds.containsKey(p.id)) p.id,
      ],
      publicationBulletIds: resultPublicationBulletIds,
      bulletOverrides: bulletOverrides,
      skillIds: _filteredIds(json['skillIds'], skillIds),
      educationIds: _filteredIds(json['educationIds'], educationIds),
      hobbyIds: _filteredIds(json['hobbyIds'], hobbyIds),
      hiddenSections: {
        for (final name in _filteredIds(json['hiddenSections'], sectionNames))
          CvSectionType.values.byName(name),
      },
      rationale: _asString(json['rationale']) ?? '',
      keywordGaps: [
        for (final gap in _asList(json['keywordGaps']))
          if (gap is String) gap,
      ],
    );
  }
}

/// Shared by the `experiences` and `projects` branches of
/// [CopilotResult.fromLlmResponse]: reads [entry]'s `bulletIds`/`rewrites`,
/// keeping only ids that are actually in [validBulletIds] — the
/// per-experience/per-project scoping that stops a rewrite meant for one
/// entry's bullet from being applied to another's.
void _applyEntry(
  Map<dynamic, dynamic> entry, {
  required String entryId,
  required Set<String> validBulletIds,
  required Map<String, List<String>> bulletIdsOut,
  required Map<String, String> bulletOverridesOut,
}) {
  bulletIdsOut[entryId] = [
    for (final id in _asList(entry['bulletIds']))
      if (id is String && validBulletIds.contains(id)) id,
  ];

  for (final rewrite in _asList(entry['rewrites'])) {
    if (rewrite is! Map) continue;
    final id = _asString(rewrite['id']);
    final text = _asString(rewrite['text']);
    if (id != null && text != null && validBulletIds.contains(id)) {
      bulletOverridesOut[id] = text;
    }
  }
}

List<String> _filteredIds(dynamic raw, Set<String> validIds) => [
  for (final id in _asList(raw))
    if (id is String && validIds.contains(id)) id,
];

/// Every raw JSON field this file reads a list out of goes through this
/// rather than a blind `as List?` cast — a provider that violated the
/// schema (or a test exercising that case) hands a wrong-typed value here,
/// and this is what turns that into "treated as empty" instead of a
/// `CastError` crash. See this file's class doc comment: the same
/// never-crash guarantee the id validation gives dangling ids applies to
/// wrong-typed values too.
List<dynamic> _asList(dynamic value) => value is List ? value : const [];

String? _asString(dynamic value) => value is String ? value : null;
