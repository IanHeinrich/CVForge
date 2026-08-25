import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/llm/cv_translation_payload.dart';
import 'package:cv_forge/models/llm/llm_field_length_guard.dart';

part 'cv_translation_result.freezed.dart';

/// One translation pass's answer, validated against the request that
/// produced it.
///
/// Validated against the [CvTranslationPayload] rather than against the
/// Vault and draft directly, which is both simpler and stricter: the
/// payload already decided which ids this CV prints, so a field can only
/// come back if it went out, and there is exactly one place that rule
/// lives. It also puts each field's *source* text in reach, which is what
/// lets [acceptTranslatedField] judge an answer against its own input
/// rather than only against the page.
///
/// Nothing in here throws. A malformed value, an unknown id, or a field we
/// never asked about is dropped silently — a translation that comes back
/// 90% complete should apply the 90% rather than fail the pass — and
/// [translatedCount] against [requestedCount] is what tells the user how
/// much actually landed.
@freezed
abstract class CvTranslationResult with _$CvTranslationResult {
  const factory CvTranslationResult({
    String? headline,
    String? summary,
    String? referencesNote,
    String? workAuthorization,
    required Map<String, String> roles,
    required Map<String, String> projectTitles,
    required Map<String, String> skillCategoryNames,
    required Map<String, String> skillLabels,
    required Map<String, String> educationQualifications,
    required Map<String, String> educationGrades,
    required Map<String, String> educationDetails,
    required Map<String, String> hobbies,
    required Map<String, String> languages,
    required Map<String, String> bullets,

    /// How many strings the request asked about, so a caller can report
    /// "translated 3 of 61" rather than an unqualified "translated 3".
    @Default(0) int requestedCount,

    /// How many came back saying something different from what was sent.
    ///
    /// Not the size of the maps, which is now every field the request
    /// asked about: the schema requires an answer for each one, and a term
    /// that should keep its name is answered by returning it unchanged.
    /// Counting those as translations would report "61 of 61" on a pass
    /// that changed forty things.
    @Default(0) int translatedCount,
  }) = _CvTranslationResult;

  const CvTranslationResult._();

  /// Every chunk's answer as one result.
  ///
  /// The pass is all-or-nothing, so this only ever runs once every request
  /// has succeeded — there is no partial state to reconcile, just maps to
  /// combine. Chunks never share an id (each field is asked about exactly
  /// once), so the merge cannot be lossy.
  static CvTranslationResult merge(Iterable<CvTranslationResult> parts) {
    Map<String, String> join(
      Map<String, String> Function(CvTranslationResult) pick,
    ) => {for (final part in parts) ...pick(part)};

    return CvTranslationResult(
      headline: parts
          .map((p) => p.headline)
          .firstWhere((v) => v != null, orElse: () => null),
      summary: parts
          .map((p) => p.summary)
          .firstWhere((v) => v != null, orElse: () => null),
      referencesNote: parts
          .map((p) => p.referencesNote)
          .firstWhere((v) => v != null, orElse: () => null),
      roles: join((p) => p.roles),
      projectTitles: join((p) => p.projectTitles),
      skillCategoryNames: join((p) => p.skillCategoryNames),
      skillLabels: join((p) => p.skillLabels),
      educationQualifications: join((p) => p.educationQualifications),
      educationGrades: join((p) => p.educationGrades),
      educationDetails: join((p) => p.educationDetails),
      hobbies: join((p) => p.hobbies),
      languages: join((p) => p.languages),
      bullets: join((p) => p.bullets),
      requestedCount: parts.fold(0, (t, p) => t + p.requestedCount),
      translatedCount: parts.fold(0, (t, p) => t + p.translatedCount),
    );
  }

  factory CvTranslationResult.fromLlmResponse(
    Map<String, dynamic> json,
    CvTranslationPayload payload,
  ) {
    final request = payload.toJson();
    var changed = 0;

    /// Keeps [value], and counts it as a translation only if it says
    /// something other than what was sent — every key comes back now, so
    /// the map size is no longer a count of work done.
    String? keep(String source, String? value) {
      if (value == null) return null;
      if (value != source) changed++;
      return value;
    }

    /// One of the three scalar fields, accepted only if it was asked about.
    String? scalar(String key) {
      final source = request[key];
      if (source is! String) return null;
      return keep(source, acceptTranslatedField(source, json[key]));
    }

    /// One id-keyed group, keeping only ids this request actually sent.
    Map<String, String> group(String key) {
      final source = request[key];
      final raw = json[key];
      if (source is! Map || raw is! Map) return const {};
      final result = <String, String>{};
      raw.forEach((id, value) {
        if (id is! String) return;
        final sourceText = source[id];
        if (sourceText is! String) return;
        final accepted = keep(
          sourceText,
          acceptTranslatedField(sourceText, value),
        );
        if (accepted != null) result[id] = accepted;
      });
      return result;
    }

    return CvTranslationResult(
      headline: scalar('headline'),
      summary: scalar('summary'),
      referencesNote: scalar('referencesNote'),
      workAuthorization: scalar('workAuthorization'),
      roles: group('roles'),
      projectTitles: group('projectTitles'),
      skillCategoryNames: group('skillCategories'),
      skillLabels: group('skills'),
      educationQualifications: group('qualifications'),
      educationGrades: group('grades'),
      educationDetails: group('educationDetails'),
      hobbies: group('hobbies'),
      languages: group('languages'),
      bullets: group('bullets'),
      requestedCount: payload.fieldCount,
      translatedCount: changed,
    );
  }
}
