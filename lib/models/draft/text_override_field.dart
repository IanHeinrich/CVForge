import 'package:cv_forge/models/draft/cv_draft.dart';

/// One of [CvDraft]'s id-keyed text-override maps. Plays the same role for
/// them that `BulletOwner` plays for the bullet-selection maps: one enum
/// and one switch, rather than a near-identical setter per field.
///
/// The three scalar overrides (headline, summary, references note) are not
/// here — they are single `String?` fields with no id to key by.
enum TextOverrideField {
  bullet,
  role,
  projectTitle,
  skillLabel,
  skillCategoryName,
  hobby,
  educationQualification,
  educationGrade,
  educationDetails,
}

extension TextOverrideFieldAccess on TextOverrideField {
  Map<String, String> of(CvDraft draft) => switch (this) {
    TextOverrideField.bullet => draft.bulletOverrides,
    TextOverrideField.role => draft.roleOverrides,
    TextOverrideField.projectTitle => draft.projectTitleOverrides,
    TextOverrideField.skillLabel => draft.skillLabelOverrides,
    TextOverrideField.skillCategoryName => draft.skillCategoryNameOverrides,
    TextOverrideField.hobby => draft.hobbyOverrides,
    TextOverrideField.educationQualification =>
      draft.educationQualificationOverrides,
    TextOverrideField.educationGrade => draft.educationGradeOverrides,
    TextOverrideField.educationDetails => draft.educationDetailsOverrides,
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
        TextOverrideField.educationQualification => draft.copyWith(
          educationQualificationOverrides: overrides,
        ),
        TextOverrideField.educationGrade => draft.copyWith(
          educationGradeOverrides: overrides,
        ),
        TextOverrideField.educationDetails => draft.copyWith(
          educationDetailsOverrides: overrides,
        ),
      };
}
