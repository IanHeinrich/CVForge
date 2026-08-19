import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default(<CvSectionType>{}) Set<CvSectionType> hiddenSections,

    /// Set by a future tailoring feature; honoured by the composer today
    /// (falls back to the Vault's own summary when null) so that feature
    /// never needs to mutate the master Vault to rewrite a summary.
    String? tailoredSummary,

    /// bulletId -> rewritten text. Same rationale as [tailoredSummary]:
    /// lets a future tailoring feature rewrite a bullet for one draft
    /// without touching the Vault, preserving the master/draft separation
    /// that is this product's entire premise.
    @Default(<String, String>{}) Map<String, String> bulletOverrides,
    required DateTime updatedAt,
  }) = _CvDraft;

  factory CvDraft.fromJson(Map<String, dynamic> json) =>
      _$CvDraftFromJson(json);

  factory CvDraft.empty({
    String id = 'current',
    String name = 'My CV',
    String templateId = 'classic_serif',
  }) => CvDraft(
    schemaVersion: 1,
    id: id,
    name: name,
    templateId: templateId,
    updatedAt: DateTime.now(),
  );
}
