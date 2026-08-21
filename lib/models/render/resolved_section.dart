import 'package:freezed_annotation/freezed_annotation.dart';

part 'resolved_section.freezed.dart';

/// A single resolved, print-ready CV section. Union over [CvSectionType] so
/// a new template is just a `switch` over the cases already defined here —
/// adding template #2/#3 never requires touching this file.
@freezed
sealed class ResolvedSection with _$ResolvedSection {
  const factory ResolvedSection.summary({
    required String title,
    required String text,
  }) = ResolvedSummarySection;

  const factory ResolvedSection.experience({
    required String title,
    required List<ResolvedCompanyGroup> groups,
  }) = ResolvedExperienceSection;

  const factory ResolvedSection.projects({
    required String title,
    required List<ResolvedProject> items,
  }) = ResolvedProjectsSection;

  const factory ResolvedSection.skills({
    required String title,
    required List<ResolvedSkillGroup> groups,
  }) = ResolvedSkillsSection;

  const factory ResolvedSection.education({
    required String title,
    required List<ResolvedQualification> items,
  }) = ResolvedEducationSection;

  const factory ResolvedSection.hobbies({
    required String title,
    required List<String> items,
  }) = ResolvedHobbiesSection;

  const factory ResolvedSection.references({
    required String title,
    required String text,
  }) = ResolvedReferencesSection;

  const factory ResolvedSection.publications({
    required String title,
    required List<ResolvedPublication> items,
  }) = ResolvedPublicationsSection;
}

/// One company heading. Holds one [ResolvedPosition] for a normal entry,
/// or several for a promotion — grouped ([Experience.companyGroupId]) and
/// ungrouped entries render through the same shape, so a template has one
/// code path rather than a special case for promotions.
@freezed
abstract class ResolvedCompanyGroup with _$ResolvedCompanyGroup {
  const factory ResolvedCompanyGroup({
    required String company,
    required String location,
    @Default(<ResolvedPosition>[]) List<ResolvedPosition> positions,
  }) = _ResolvedCompanyGroup;
}

@freezed
abstract class ResolvedPosition with _$ResolvedPosition {
  const factory ResolvedPosition({
    required String role,

    /// Pre-formatted, e.g. "01/2025 - current". Formatting happens in the
    /// composer, not here and not in a template.
    required String dateRange,
    @Default(<ResolvedBullet>[]) List<ResolvedBullet> bullets,
  }) = _ResolvedPosition;
}

@freezed
abstract class ResolvedBullet with _$ResolvedBullet {
  const factory ResolvedBullet({String? label, required String text}) =
      _ResolvedBullet;
}

@freezed
abstract class ResolvedProject with _$ResolvedProject {
  const factory ResolvedProject({
    required String title,
    String? link,
    @Default(<ResolvedBullet>[]) List<ResolvedBullet> bullets,
  }) = _ResolvedProject;
}

@freezed
abstract class ResolvedSkillGroup with _$ResolvedSkillGroup {
  const factory ResolvedSkillGroup({
    required String category,
    @Default(<String>[]) List<String> skills,
  }) = _ResolvedSkillGroup;
}

@freezed
abstract class ResolvedPublication with _$ResolvedPublication {
  const factory ResolvedPublication({
    required String title,
    String? citation,
    String? link,
  }) = _ResolvedPublication;
}

@freezed
abstract class ResolvedQualification with _$ResolvedQualification {
  const factory ResolvedQualification({
    required String qualification,
    required String institution,
    String? location,

    /// Pre-formatted (e.g. "2021"), not a raw int — same reasoning as
    /// [ResolvedPosition.dateRange].
    String? yearLabel,
    String? grade,
    String? details,
  }) = _ResolvedQualification;
}
