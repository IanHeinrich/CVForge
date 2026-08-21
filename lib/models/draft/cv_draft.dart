import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/render/region_profile.dart';

import 'cv_section_type.dart';

part 'cv_draft.freezed.dart';
part 'cv_draft.g.dart';

/// A curated, tailored presentation of the Vault — "The Studio" draft.
///
/// References into the Vault are by id, and selection is **opt-in**: an
/// empty/missing list means "nothing from this collection is included",
/// not "everything is". An id list is also an ordering, so draft-level
/// reordering is free later — but the corollary is that a newly-added
/// Vault entry does NOT automatically appear in an existing draft; the
/// Studio UI must surface "N items in your Vault aren't in this draft".
///
/// Dangling ids (referencing a Vault entry that's since been deleted) are
/// normal, not an error — [CvComposer] silently drops them. There is no
/// referential integrity enforced anywhere, by design: deleting a Vault
/// entry must never require touching every draft that might reference it.
@freezed
abstract class CvDraft with _$CvDraft {
  const factory CvDraft({
    required int schemaVersion,
    required String id,
    required String name,
    required String templateId,
    @Default(RegionProfile.uk) RegionProfile region,

    /// Free-text, for the user's own tracking ("tailored for the Acme
    /// Backend role, applied 2026-08-19") — never rendered into the CV
    /// itself.
    @Default('') String notes,
    @Default(<String>[]) List<String> experienceIds,

    /// experienceId -> ordered bulletIds included for that experience.
    /// A missing key means no bullets are shown for that experience — this
    /// map is populated by the service layer when an experience is added
    /// to a draft, not inferred here.
    @Default(<String, List<String>>{}) Map<String, List<String>> bulletIds,
    @Default(<String>[]) List<String> projectIds,

    /// Same shape and rationale as [bulletIds], one level over for
    /// [Project] bullets instead of [Experience] bullets.
    @Default(<String, List<String>>{})
    Map<String, List<String>> projectBulletIds,
    @Default(<String>[]) List<String> skillIds,
    @Default(<String>[]) List<String> educationIds,
    @Default(<String>[]) List<String> hobbyIds,
    @Default(<String>[]) List<String> publicationIds,
    @Default(<CvSectionType>{}) Set<CvSectionType> hiddenSections,

    /// A draft-only rewrite of the Vault's professional summary — null
    /// means "inherit the Vault's", never "omit" (the Summary section
    /// checkbox is what omits it). `CvComposer` prefers this over the
    /// Vault's own summary, so tailoring a draft never mutates the master
    /// Vault, preserving the master/draft separation that is this
    /// product's entire premise.
    String? tailoredSummary,

    /// bulletId -> rewritten text. Same null-means-inherit rationale as
    /// [tailoredSummary], one level down — lets a bullet be rewritten for
    /// one draft without touching the Vault. Bullet ids are globally
    /// unique (see `Skill.linkedBulletIds`'s doc comment), so this map
    /// doesn't need to be scoped per experience/project.
    @Default(<String, String>{}) Map<String, String> bulletOverrides,

    /// Same null-means-inherit rationale as [tailoredSummary], one field
    /// over, for `ContactBasics.headline`.
    String? headlineOverride,

    /// Same null-means-inherit rationale as [tailoredSummary], one field
    /// over, for `CvVault.referencesNote`.
    String? referencesOverride,

    /// educationId -> rewritten `Education.details` text. Same
    /// null-means-inherit rationale as [bulletOverrides], one entity type
    /// over — only `details` is prose; qualification/institution/grade/
    /// year stay Vault-sourced, never overridable here.
    @Default(<String, String>{}) Map<String, String> educationDetailsOverrides,
    required DateTime updatedAt,
  }) = _CvDraft;

  factory CvDraft.fromJson(Map<String, dynamic> json) =>
      _$CvDraftFromJson(json);

  /// [id] and [templateId] are required, not defaulted — both are identity
  /// fields with no value that's ever correct to manufacture on a caller's
  /// behalf. A default id risks colliding with a real one (the legacy
  /// single-draft storage key was exactly this kind of literal); a default
  /// template id can only ever be a guess at what's actually registered,
  /// and `TemplateRegistryService.byId`'s graceful unknown-id fallback
  /// means a wrong guess here fails silently rather than loudly. Callers
  /// should pass `TemplateRegistryService.defaultTemplate.id`.
  factory CvDraft.empty({
    required String id,
    required String templateId,
    String name = 'My CV',
    RegionProfile region = RegionProfile.uk,
  }) => CvDraft(
    schemaVersion: 1,
    id: id,
    name: name,
    templateId: templateId,
    region: region,
    updatedAt: DateTime.now(),
  );
}
