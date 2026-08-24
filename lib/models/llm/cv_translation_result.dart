import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/llm/cv_translation_payload.dart';

part 'cv_translation_result.freezed.dart';

/// One translation pass's answer, validated against the request that
/// produced it.
///
/// Validated against the [CvTranslationPayload] rather than against the
/// Vault and draft directly, which is both simpler and stricter: the
/// payload already decided which ids this CV prints, so a field can only
/// come back if it went out, and there is exactly one place that rule
/// lives. It also puts each field's *source* text in reach, which is what
/// makes the length guard below possible.
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
    required Map<String, String> roles,
    required Map<String, String> projectTitles,
    required Map<String, String> skillCategoryNames,
    required Map<String, String> skillLabels,
    required Map<String, String> educationQualifications,
    required Map<String, String> educationGrades,
    required Map<String, String> educationDetails,
    required Map<String, String> hobbies,
    required Map<String, String> bullets,

    /// How many strings the request asked about, so a caller can report
    /// "translated 3 of 61" rather than an unqualified "translated 3".
    @Default(0) int requestedCount,
  }) = _CvTranslationResult;

  const CvTranslationResult._();

  /// How many strings came back with a translation this result accepted.
  int get translatedCount =>
      (headline == null ? 0 : 1) +
      (summary == null ? 0 : 1) +
      (referencesNote == null ? 0 : 1) +
      roles.length +
      projectTitles.length +
      skillCategoryNames.length +
      skillLabels.length +
      educationQualifications.length +
      educationGrades.length +
      educationDetails.length +
      hobbies.length +
      bullets.length;

  factory CvTranslationResult.fromLlmResponse(
    Map<String, dynamic> json,
    CvTranslationPayload payload,
  ) {
    final request = payload.toJson();

    /// One of the three scalar fields, accepted only if it was asked about.
    String? scalar(String key) {
      final source = request[key];
      if (source is! String) return null;
      return _accept(source, json[key]);
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
        final accepted = _accept(sourceText, value);
        if (accepted != null) result[id] = accepted;
      });
      return result;
    }

    return CvTranslationResult(
      headline: scalar('headline'),
      summary: scalar('summary'),
      referencesNote: scalar('referencesNote'),
      roles: group('roles'),
      projectTitles: group('projectTitles'),
      skillCategoryNames: group('skillCategories'),
      skillLabels: group('skills'),
      educationQualifications: group('qualifications'),
      educationGrades: group('grades'),
      educationDetails: group('educationDetails'),
      hobbies: group('hobbies'),
      bullets: group('bullets'),
      requestedCount: payload.fieldCount,
    );
  }
}

/// [value] as a translation of [source], or null if it is not usable.
///
/// Rejects anything disproportionately longer than what it claims to
/// translate. This is not tidiness — it is the guard that stops a
/// misbehaving response from producing a CV that cannot be rendered at
/// all.
///
/// A model that ignores the per-id structure and returns the whole
/// document in one field (observed: an entire translated CV inside
/// `summary`) puts tens of thousands of points of text into a single
/// widget. `package:pdf` throws rather than paginating a single widget
/// taller than a page — see the oversized-bullet case in
/// `pdf_export_service_test.dart`, which is long-standing, deliberate
/// behaviour — so the whole preview and export die, and the user is left
/// with a CV they can edit but cannot see.
///
/// The bound is deliberately loose. It exists to catch a field that has
/// swallowed the document, not to police translation quality: German runs
/// appreciably longer than English, and a short label can legitimately
/// several-fold in length ("Skills" → "Compétences techniques"). Anything
/// inside it is accepted untouched.
String? _accept(String source, Object? value) {
  if (value is! String) return null;
  if (value.trim().isEmpty) return null;
  if (value.length > source.length * 3 + 40) return null;
  return value;
}
