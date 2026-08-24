import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/region/region_profile.dart';

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
///
/// ## The override layer
///
/// The `*Override(s)` fields below are the single answer to "what does
/// this draft say that the Vault doesn't". Three things write into them —
/// the user typing in Studio, an AI tailoring pass, and a translation pass
/// — and none of them is distinguishable from the others afterwards. That
/// is deliberate: one layer means one revert idiom, one composer lookup
/// per field, and one place a newly-overridable field has to be added.
///
/// The set of fields that are overridable is therefore also the set a
/// translation may rewrite, and that boundary is a product decision rather
/// than an oversight. Deliberately absent, and to stay absent: `fullName`,
/// `email`, `phone`, every `location`, `ProfileLink.label`,
/// `Experience.company`, `Education.institution`, and `Publication`'s
/// `title`/`citation`/`link`. Employers, institutions and published paper
/// titles are citable proper nouns — a reader who cannot look them up
/// cannot verify the document, and verifiability is the one property a CV
/// cannot trade away.
@freezed
abstract class CvDraft with _$CvDraft {
  const factory CvDraft({
    required int schemaVersion,
    required String id,
    required String name,
    required String templateId,
    @Default(RegionProfile.uk) RegionProfile region,

    /// The language this CV is written in — the value that actually
    /// renders, as opposed to `DocumentDefaults.language`, which only
    /// seeded it.
    ///
    /// Per-draft rather than per-Vault because a draft is one application
    /// to one employer: applying to a firm in Munich and a firm in London
    /// from the same career history needs two languages at once. Snapshot
    /// at creation, never re-resolved, exactly like [region].
    ///
    /// Independent of the app's own UI locale, which never reaches the
    /// document — see [DocumentLanguage].
    @Default(DocumentLanguage.enGb) DocumentLanguage documentLanguage,

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

    /// Same shape and rationale as [bulletIds]/[projectBulletIds], one
    /// entity type over for [Publication] bullets.
    @Default(<String, List<String>>{})
    Map<String, List<String>> publicationBulletIds,
    @Default(<CvSectionType>{}) Set<CvSectionType> hiddenSections,

    /// This draft's own print order — reorderable per-draft in Studio
    /// (drag handles in the "Sections" list). Distinct from
    /// `CvTemplate.sectionOrder`, which is only a seed suggestion
    /// consulted once, when a brand-new draft is constructed (see
    /// `DraftService.createDraft`) — switching a draft's template
    /// afterwards never touches this field. Read [effectiveSectionOrder],
    /// not this field directly, anywhere the order is consumed.
    @Default(<CvSectionType>[
      CvSectionType.summary,
      CvSectionType.skills,
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

    /// skillId -> rewritten `Skill.label`.
    @Default(<String, String>{}) Map<String, String> skillLabelOverrides,

    /// skillCategoryId -> rewritten `SkillCategory.name`.
    @Default(<String, String>{}) Map<String, String> skillCategoryNameOverrides,

    /// hobbyId -> rewritten `HobbyItem.text`.
    @Default(<String, String>{}) Map<String, String> hobbyOverrides,

    /// educationId -> rewritten `Education.qualification`.
    @Default(<String, String>{})
    Map<String, String> educationQualificationOverrides,

    /// educationId -> rewritten `Education.grade`.
    @Default(<String, String>{}) Map<String, String> educationGradeOverrides,

    /// The language this draft was last translated into, or null if it
    /// never has been.
    ///
    /// Pure provenance — it changes nothing about how the draft renders,
    /// since a translation is stored as ordinary overrides above and is
    /// indistinguishable from a hand edit once written. It exists so
    /// Studio can offer "remove translation", and can tell the user their
    /// translation is stale once [documentLanguage] moves away from it.
    DocumentLanguage? translatedTo,

    /// The job ad this draft is being tailored for — a persisted field, not
    /// a modal's transient text, so an AI Assistant pass can be re-run and
    /// refined against the same ad. Null means no ad has been entered yet;
    /// distinct from [notes], which is the user's own application tracking
    /// and is never rendered or sent anywhere.
    String? targetJobDescription,
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

    /// Null means the caller wants the standard "My CV" default, which is
    /// a localized string and therefore cannot be a constructor default —
    /// `DraftService` supplies it.
    String? name,

    /// Defaulted rather than required because `DraftService._emptyDraft`
    /// is reached from the *synchronous* `draft` getter, which can never
    /// await the Vault these normally come from.
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

extension CvDraftSectionOrder on CvDraft {
  /// [sectionOrder] with any [CvSectionType] case missing from it appended
  /// at the end, in enum-declaration order — guards against a future new
  /// section type shipping after this draft was last saved, so it isn't
  /// silently dropped from the printed CV forever. Always read this,
  /// never [sectionOrder] directly, anywhere order is consumed for
  /// rendering or for the picker UI.
  List<CvSectionType> get effectiveSectionOrder =>
      completeSectionOrder(sectionOrder);
}
