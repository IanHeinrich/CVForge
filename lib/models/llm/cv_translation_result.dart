import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

part 'cv_translation_result.freezed.dart';

/// One translation pass's answer, validated against the Vault and draft it
/// was asked about.
///
/// Every id is re-checked here rather than trusted from the response, for
/// the reason [AiAssistantResult] documents: Anthropic can close an
/// object's key set through the schema, Gemini cannot (see
/// `GeminiProvider._walkSchema`), so app-side validation is belt-and-braces
/// on one provider and the only enforcement on the other.
///
/// Nothing in here throws. A malformed value, an unknown id, or a key for
/// something this draft does not include is dropped silently — a
/// translation that comes back 90% complete should apply the 90%, not fail
/// the pass. [translatedCount] is what tells the user how much landed.
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
  }) = _CvTranslationResult;

  const CvTranslationResult._();

  /// How many strings the model actually returned a translation for.
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
    CvVault vault,
    CvDraft draft,
  ) {
    /// The subset of [json]`[key]` whose ids are in [allowed] and whose
    /// values are non-blank strings.
    Map<String, String> scoped(String key, Set<String> allowed) {
      final raw = json[key];
      if (raw is! Map) return const {};
      final result = <String, String>{};
      raw.forEach((id, value) {
        if (id is! String || !allowed.contains(id)) return;
        final text = _asString(value);
        if (text != null) result[id] = text;
      });
      return result;
    }

    final includedExperiences = draft.experienceIds.toSet();
    final includedProjects = draft.projectIds.toSet();
    final includedEducation = draft.educationIds.toSet();
    final includedHobbies = draft.hobbyIds.toSet();
    final includedSkills = draft.skillIds.toSet();

    final skillIds = <String>{};
    final categoryIds = <String>{};
    for (final category in vault.skillCategories) {
      var used = false;
      for (final skill in category.skills) {
        if (!includedSkills.contains(skill.id)) continue;
        used = true;
        skillIds.add(skill.id);
      }
      if (used) categoryIds.add(category.id);
    }

    // Every bullet the draft actually prints, flat — bullet ids are
    // globally unique, so the owning entity never has to be consulted.
    final bulletIds = <String>{
      for (final expId in includedExperiences) ...?draft.bulletIds[expId],
      for (final projId in includedProjects) ...?draft.projectBulletIds[projId],
      for (final pubId in draft.publicationIds)
        ...?draft.publicationBulletIds[pubId],
      for (final edu in vault.education)
        if (includedEducation.contains(edu.id))
          for (final bullet in edu.bullets) bullet.id,
    };

    return CvTranslationResult(
      headline: draft.hideHeadline ? null : _asString(json['headline']),
      summary: _asString(json['summary']),
      referencesNote: _asString(json['referencesNote']),
      roles: scoped('roles', includedExperiences),
      projectTitles: scoped('projectTitles', includedProjects),
      skillCategoryNames: scoped('skillCategories', categoryIds),
      skillLabels: scoped('skills', skillIds),
      educationQualifications: scoped('qualifications', includedEducation),
      educationGrades: scoped('grades', includedEducation),
      educationDetails: scoped('educationDetails', includedEducation),
      hobbies: scoped('hobbies', includedHobbies),
      bullets: scoped('bullets', bulletIds),
    );
  }
}

/// A non-blank string, or null for anything else — a wrong type from the
/// model reads as "not answered" rather than crashing the pass.
String? _asString(Object? value) {
  if (value is! String) return null;
  return value.trim().isEmpty ? null : value;
}
