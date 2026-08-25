import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/region/region_profile.dart';

import 'cv_section_type.dart';
import 'draft_omittable_field.dart';

part 'cv_draft.freezed.dart';
part 'cv_draft.g.dart';

/// A curated, tailored presentation of the Vault — "The Studio" draft.
///
/// References into the Vault are by id, and selection is **opt-in**: an
/// empty or missing list means nothing from that collection is included.
/// An id list is also an ordering. The corollary is that a newly-added
/// Vault entry does NOT appear in an existing draft, so Studio has to
/// surface "N items in your Vault aren't in this draft".
///
/// Dangling ids are normal, not an error — [CvComposer] drops them. No
/// referential integrity is enforced anywhere, so deleting a Vault entry
/// never requires touching every draft that references it.
///
/// ## The override layer
///
/// The `*Override(s)` fields are the single answer to "what does this
/// draft say that the Vault doesn't". The user typing in Studio, an AI
/// tailoring pass and a translation pass all write into them and are
/// indistinguishable afterwards — one layer means one revert idiom, one
/// composer lookup per field, one place to add a new overridable field.
///
/// Absent, and to stay absent: `fullName`, `email`, `phone`,
/// `ProfileLink.label`, `Experience.company`, `Education.institution`,
/// and `Publication.link`. A reader who cannot look a claim up cannot
/// verify the document, and a link that goes somewhere other than the
/// real page is the sharpest version of that.
///
/// **Overridable is not the same as translatable.** It was, until
/// publication titles and citations became editable: a person rewriting
/// their own paper's citation knows what they are doing, where a machine
/// translating it produces a reference nobody can find, in a pass the
/// user never reviews line by line. So `CvTranslationPayload` chooses
/// what it sends, and those two are deliberately not in it — see its own
/// publications branch.
@freezed
abstract class CvDraft with _$CvDraft {
  const factory CvDraft({
    required int schemaVersion,
    required String id,
    required String name,
    required String templateId,
    @Default(RegionProfile.uk) RegionProfile region,

    /// The language this CV is written in — the value that renders, where
    /// `DocumentDefaults.language` only seeded it.
    ///
    /// Per-draft because a draft is one application to one employer:
    /// Munich and London from one career history need two languages at
    /// once. Snapshot at creation and never re-resolved, like [region].
    /// Independent of the UI locale — see [DocumentLanguage].
    @Default(DocumentLanguage.enGb) DocumentLanguage documentLanguage,

    /// Free-text for the user's own tracking — never rendered.
    @Default('') String notes,
    @Default(<String>[]) List<String> experienceIds,

    /// experienceId -> ordered bulletIds included. A missing key means no
    /// bullets are shown; the service layer populates this when an
    /// experience is added, and nothing is inferred here.
    @Default(<String, List<String>>{}) Map<String, List<String>> bulletIds,
    @Default(<String>[]) List<String> projectIds,

    /// Same shape and rationale as [bulletIds], one level over for
    /// [Project] bullets instead of [Experience] bullets.
    @Default(<String, List<String>>{})
    Map<String, List<String>> projectBulletIds,
    @Default(<String>[]) List<String> skillIds,
    @Default(<String>[]) List<String> educationIds,
    @Default(<String>[]) List<String> hobbyIds,
    @Default(<String>[]) List<String> languageIds,
    @Default(<String>[]) List<String> publicationIds,

    /// Same shape and rationale as [bulletIds]/[projectBulletIds], one
    /// entity type over for [Publication] bullets.
    @Default(<String, List<String>>{})
    Map<String, List<String>> publicationBulletIds,

    /// publicationId -> rewritten `Publication.title`.
    @Default(<String, String>{}) Map<String, String> publicationTitleOverrides,

    /// publicationId -> rewritten `Publication.citation`.
    @Default(<String, String>{})
    Map<String, String> publicationCitationOverrides,

    /// educationId -> ordered bulletIds included, with one deliberate
    /// difference from the three maps above: **a missing key means every
    /// bullet**, not none.
    ///
    /// Education bullets printed wholesale before this map existed, so a
    /// draft saved back then has no key for any entry — and "no key" has
    /// to keep meaning "all of them", or upgrading would silently strip
    /// education bullets out of every CV already made. An explicit empty
    /// list still means none, so the user can genuinely clear an entry's
    /// bullets; only *absence* is the permissive case.
    ///
    /// Read it through [educationBulletSelection], never directly. This
    /// is the one place in this class where absent and empty differ, and
    /// that rule lives in exactly one method.
    @Default(<String, List<String>>{})
    Map<String, List<String>> educationBulletIds,

    /// Which entries drop which printed field entirely — see
    /// [DraftOmittableField] for what belongs in here and what doesn't.
    /// An absent key means nothing is dropped, so this is additive: a
    /// draft saved before it existed prints exactly what it always did.
    ///
    /// Keyed by the enum rather than by its `.name`, matching
    /// [hiddenSections], and carrying the same known exposure: a draft
    /// written by a future version that adds a case cannot be decoded by
    /// this one. That is the existing posture for stored enums here, not
    /// a new risk introduced by this field.
    @Default(<DraftOmittableField, List<String>>{})
    Map<DraftOmittableField, List<String>> omittedFields,
    @Default(<CvSectionType>{}) Set<CvSectionType> hiddenSections,

    /// This draft's own print order, reorderable in Studio. Distinct from
    /// `CvTemplate.sectionOrder`, which only seeds a brand-new draft —
    /// switching template afterwards never touches this. Read
    /// [effectiveSectionOrder], never this field, wherever order is
    /// consumed.
    @Default(<CvSectionType>[
      CvSectionType.summary,
      CvSectionType.skills,
      CvSectionType.languages,
      CvSectionType.experience,
      CvSectionType.projects,
      CvSectionType.education,
      CvSectionType.hobbies,
      CvSectionType.references,
      CvSectionType.publications,
    ])
    List<CvSectionType> sectionOrder,

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

    /// Drops the headline from this draft entirely, independently of
    /// [headlineOverride] — which is preserved while hidden, so toggling
    /// back restores the edit rather than losing it.
    ///
    /// A bool rather than a ninth [CvSectionType]: [hiddenSections] drives
    /// the reorderable section list and `CvComposer`'s section walk, but
    /// the headline sits in the header block, has no heading of its own
    /// and cannot be reordered. In that enum it would show up in Studio's
    /// section nav as a draggable row that renders nothing.
    @Default(false) bool hideHeadline,

    /// Same null-means-inherit rationale as [tailoredSummary], one field
    /// over, for `CvVault.referencesNote`.
    String? referencesOverride,

    /// educationId -> rewritten `Education.details` text. Same
    /// null-means-inherit rationale as [bulletOverrides], one entity type
    /// over.
    @Default(<String, String>{}) Map<String, String> educationDetailsOverrides,

    /// experienceId -> rewritten `Experience.role`.
    @Default(<String, String>{}) Map<String, String> roleOverrides,

    /// projectId -> rewritten `Project.title`.
    @Default(<String, String>{}) Map<String, String> projectTitleOverrides,

    /// experienceId -> rewritten `Experience.location`, and below it the
    /// same for `Education.location`.
    ///
    /// A place name is not one fact with one spelling: München and Munich
    /// are the same office written for two readers, and which one belongs
    /// on the page is a property of the CV, not of the career history.
    /// That is the whole reason these are overridable while the employer
    /// and institution beside them are not.
    ///
    /// **A grouped experience takes its printed location from the most
    /// recent role that has an override**, falling back to the most
    /// recent role's Vault value — see `CvComposer._buildExperience`. A
    /// group prints one location for several roles, so an override on any
    /// member has to be able to reach it; picking the newest keeps it
    /// deterministic when more than one is set.
    @Default(<String, String>{})
    Map<String, String> experienceLocationOverrides,

    /// educationId -> rewritten `Education.location`. See
    /// [experienceLocationOverrides].
    @Default(<String, String>{}) Map<String, String> educationLocationOverrides,

    /// skillId -> rewritten `Skill.label`.
    @Default(<String, String>{}) Map<String, String> skillLabelOverrides,

    /// skillCategoryId -> rewritten `SkillCategory.name`.
    @Default(<String, String>{}) Map<String, String> skillCategoryNameOverrides,

    /// hobbyId -> rewritten `HobbyItem.text`.
    @Default(<String, String>{}) Map<String, String> hobbyOverrides,

    /// languageId -> rewritten `LanguageItem.name`. The proficiency has
    /// no override: a CEFR band is a code, not wording, and reads the
    /// same in every language.
    @Default(<String, String>{}) Map<String, String> languageOverrides,

    /// educationId -> rewritten `Education.qualification`.
    @Default(<String, String>{})
    Map<String, String> educationQualificationOverrides,

    /// educationId -> rewritten `Education.grade`.
    @Default(<String, String>{}) Map<String, String> educationGradeOverrides,

    /// The language this draft was last translated into, or null if it
    /// never has been.
    ///
    /// Pure provenance — a translation is stored as ordinary overrides
    /// and is indistinguishable from a hand edit, so this changes nothing
    /// about rendering. It exists so Studio can offer "remove translation"
    /// and can say when one has gone stale.
    DocumentLanguage? translatedTo,

    /// The job ad this draft is tailored for. Persisted rather than a
    /// modal's transient text, so an AI pass can be re-run against the
    /// same ad. Distinct from [notes], which is never sent anywhere.
    String? targetJobDescription,
    required DateTime updatedAt,
  }) = _CvDraft;

  factory CvDraft.fromJson(Map<String, dynamic> json) =>
      _$CvDraftFromJson(json);

  /// [id] and [templateId] are required, not defaulted: no default is ever
  /// correct to manufacture for a caller. A default id risks colliding with
  /// a real one, and a default template id can only guess at what is
  /// registered — which `TemplateRegistryService.byId`'s graceful fallback
  /// would then hide. Pass `TemplateRegistryService.defaultTemplate.id`.
  factory CvDraft.empty({
    required String id,
    required String templateId,

    /// Null means the standard "My CV" default, which is localized and so
    /// cannot be a constructor default — `DraftService` supplies it.
    String? name,

    /// Defaulted rather than required: `DraftService._emptyDraft` is
    /// reached from the synchronous `draft` getter, which cannot await the
    /// Vault these normally come from.
    RegionProfile region = RegionProfile.uk,
    DocumentLanguage documentLanguage = DocumentLanguage.enGb,
  }) => CvDraft(
    schemaVersion: 1,
    id: id,
    name: name ?? '',
    templateId: templateId,
    region: region,
    documentLanguage: documentLanguage,
    updatedAt: DateTime.now(),
  );
}

extension CvDraftEducationBullets on CvDraft {
  /// Which of [allBulletIds] print for education entry [educationId] —
  /// the one place [educationBulletIds]'s absent-means-all rule is
  /// applied, so no caller re-derives it.
  List<String> educationBulletSelection(
    String educationId,
    List<String> allBulletIds,
  ) => educationBulletIds[educationId] ?? allBulletIds;
}

extension CvDraftSectionOrder on CvDraft {
  /// [sectionOrder] with any missing [CvSectionType] appended in
  /// enum-declaration order, so a section type shipped after this draft was
  /// saved isn't silently dropped forever. Always read this, never
  /// [sectionOrder], wherever order is consumed.
  List<CvSectionType> get effectiveSectionOrder =>
      completeSectionOrder(sectionOrder);
}
