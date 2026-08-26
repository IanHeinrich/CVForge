import 'package:cv_forge/models/draft/cv_draft.dart';

/// One of [CvDraft]'s id-keyed text-override maps. Plays the same role for
/// them that `BulletOwner` plays for the bullet-selection maps: one enum
/// and one switch, rather than a near-identical setter per field.
///
/// The four scalar overrides (headline, summary, references note, work
/// authorization) are not here — they are single `String?` fields with no
/// id to key by.
enum TextOverrideField {
  bullet,
  role,
  projectTitle,
  skillLabel,
  skillCategoryName,
  hobby,
  language,
  educationQualification,
  educationGrade,
  educationDetails,
  publicationTitle,
  publicationCitation,
  experienceLocation,
  educationLocation,
}

extension TextOverrideFieldAccess on TextOverrideField {
  Map<String, String> of(CvDraft draft) => switch (this) {
    TextOverrideField.bullet => draft.bulletOverrides,
    TextOverrideField.role => draft.roleOverrides,
    TextOverrideField.projectTitle => draft.projectTitleOverrides,
    TextOverrideField.skillLabel => draft.skillLabelOverrides,
    TextOverrideField.skillCategoryName => draft.skillCategoryNameOverrides,
    TextOverrideField.hobby => draft.hobbyOverrides,
    TextOverrideField.language => draft.languageOverrides,
    TextOverrideField.educationQualification =>
      draft.educationQualificationOverrides,
    TextOverrideField.educationGrade => draft.educationGradeOverrides,
    TextOverrideField.educationDetails => draft.educationDetailsOverrides,
    TextOverrideField.publicationTitle => draft.publicationTitleOverrides,
    TextOverrideField.publicationCitation => draft.publicationCitationOverrides,
    TextOverrideField.experienceLocation => draft.experienceLocationOverrides,
    TextOverrideField.educationLocation => draft.educationLocationOverrides,
  };

  CvDraft applyTo(CvDraft draft, Map<String, String> overrides) =>
      switch (this) {
        TextOverrideField.bullet => draft.copyWith(bulletOverrides: overrides),
        TextOverrideField.role => draft.copyWith(roleOverrides: overrides),
        TextOverrideField.projectTitle => draft.copyWith(
          projectTitleOverrides: overrides,
        ),
        TextOverrideField.skillLabel => draft.copyWith(
          skillLabelOverrides: overrides,
        ),
        TextOverrideField.skillCategoryName => draft.copyWith(
          skillCategoryNameOverrides: overrides,
        ),
        TextOverrideField.hobby => draft.copyWith(hobbyOverrides: overrides),
        TextOverrideField.language => draft.copyWith(
          languageOverrides: overrides,
        ),
        TextOverrideField.educationQualification => draft.copyWith(
          educationQualificationOverrides: overrides,
        ),
        TextOverrideField.educationGrade => draft.copyWith(
          educationGradeOverrides: overrides,
        ),
        TextOverrideField.educationDetails => draft.copyWith(
          educationDetailsOverrides: overrides,
        ),
        TextOverrideField.publicationTitle => draft.copyWith(
          publicationTitleOverrides: overrides,
        ),
        TextOverrideField.publicationCitation => draft.copyWith(
          publicationCitationOverrides: overrides,
        ),
        TextOverrideField.experienceLocation => draft.copyWith(
          experienceLocationOverrides: overrides,
        ),
        TextOverrideField.educationLocation => draft.copyWith(
          educationLocationOverrides: overrides,
        ),
      };
}

/// The whole-draft operations over [TextOverrideField], derived from
/// `values` rather than hand-enumerated.
///
/// Both of these used to be a written-out list of every override map, in
/// two different files — so adding a map meant remembering to touch both,
/// and forgetting left the new field out of "Reset wording" while still
/// letting the user create one. Deriving them is what makes that omission
/// impossible rather than merely unlikely; it is the reason this enum
/// exists at all.
extension CvDraftTextOverrides on CvDraft {
  /// Whether this draft says anything the Vault doesn't, in any id-keyed
  /// field. The four scalar overrides (headline, summary, references note,
  /// work authorization) are not [TextOverrideField]s and are checked
  /// separately by callers — see that enum's doc comment.
  bool get hasAnyTextOverride =>
      TextOverrideField.values.any((field) => field.of(this).isNotEmpty);

  /// This draft with every id-keyed override map emptied.
  CvDraft withoutTextOverrides() => TextOverrideField.values.fold(
    this,
    (draft, field) => field.applyTo(draft, const {}),
  );
}
