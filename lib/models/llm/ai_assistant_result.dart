import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/llm/llm_field_length_guard.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

part 'ai_assistant_result.freezed.dart';

/// An AI Assistant tailoring pass's response, parsed and validated against
/// [CvVault] rather than trusted as-is.
///
/// [buildAiAssistantResponseSchema]'s `enum` constraints make a hallucinated id
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
///
/// The three fields that reach the page — headline, summary and each
/// bullet rewrite — additionally go through [acceptRewrittenField], so a
/// single runaway value cannot produce a CV that will not render. This
/// pass is not chunked the way translation is, and shouldn't be: tailoring
/// decides what to *cut*, which it can only do seeing the whole CV at
/// once. Guarding the output is what buys the same safety without taking
/// away the context the pass exists to use.
@freezed
abstract class AiAssistantResult with _$AiAssistantResult {
  const factory AiAssistantResult({
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
    /// `DraftService.applyAiAssistantResult` needs to hand `CvDraft` directly.
    required Map<String, String> bulletOverrides,

    required List<String> skillIds,
    required List<String> educationIds,

    /// educationId -> selected bullet ids, same shape and per-entry
    /// scoping as [bulletIds]. Empty for a pass that returned no
    /// `education` object at all, which `CvDraft.educationBulletSelection`
    /// then reads as "every bullet" — the behaviour before the model was
    /// asked about them.
    required Map<String, List<String>> educationBulletIds,
    required List<String> hobbyIds,
    required List<String> languageIds,
    required Set<CvSectionType> hiddenSections,
    required String rationale,
    required List<String> keywordGaps,
  }) = _AiAssistantResult;

  factory AiAssistantResult.fromLlmResponse(
    Map<String, dynamic> json,
    CvVault vault,
  ) {
    final skillIds = {
      for (final c in vault.skillCategories)
        for (final s in c.skills) s.id,
    };
    final hobbyIds = {for (final h in vault.hobbies) h.id};
    final languageIds = {for (final l in vault.languages) l.id};
    final sectionNames = {for (final s in CvSectionType.values) s.name};

    final resultBulletIds = <String, List<String>>{};
    final resultProjectBulletIds = <String, List<String>>{};
    final resultPublicationBulletIds = <String, List<String>>{};
    final resultEducationBulletIds = <String, List<String>>{};
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

    final educationRaw = json['education'];
    if (educationRaw is Map) {
      for (final e in vault.education) {
        final entry = educationRaw[e.id];
        if (entry is! Map) continue;
        _applyEntry(
          entry,
          entryId: e.id,
          validBulletIds: {for (final b in e.bullets) b.id},
          bulletIdsOut: resultEducationBulletIds,
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

    return AiAssistantResult(
      headline: acceptRewrittenField(json['headline']),
      summary: acceptRewrittenField(json['summary']),
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
      educationIds: [
        for (final e in vault.education)
          if (resultEducationBulletIds.containsKey(e.id)) e.id,
      ],
      educationBulletIds: resultEducationBulletIds,
      hobbyIds: _filteredIds(json['hobbyIds'], hobbyIds),
      languageIds: _filteredIds(json['languageIds'], languageIds),
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

/// Shared by all four entity branches of
/// [AiAssistantResult.fromLlmResponse]: reads [entry]'s `bulletIds`/`rewrites`,
/// keeping only ids that are actually in [validBulletIds] — the
/// per-entry scoping that stops a rewrite meant for one entry's bullet
/// from being applied to another's.
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
    final text = acceptRewrittenField(rewrite['text']);
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
