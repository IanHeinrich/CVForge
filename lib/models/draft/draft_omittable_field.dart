import 'package:cv_forge/models/draft/cv_draft.dart';

/// A printed field a draft can drop without rewriting it — the third
/// answer, alongside `TextOverrideField`'s "this CV says something
/// different" and a plain Vault-sourced field's "this CV says what the
/// Vault says".
///
/// Every case here is a field where a per-CV *rewrite* would be a
/// factual divergence but leaving it off is an ordinary editorial choice:
///
/// - A link must go to the real page or not appear at all. Rewriting one
///   is how a reader ends up somewhere that isn't the work; omitting one
///   is what you do when the demo has rotted or the CV has no room.
/// - A graduation year is a date, and dates stay as the Vault records
///   them (see `CvDraft.experienceLocationOverrides` for the sibling
///   case). But dropping one is standard age-discrimination advice in
///   several of the markets this app targets, so "not printed" has to be
///   reachable even though "a different year" never is.
///
/// A field that is freely rewritable does not belong here: blanking its
/// override is how it gets omitted, with no second mechanism.
enum DraftOmittableField { projectLink, publicationLink, educationYear }

extension DraftOmittableFieldAccess on DraftOmittableField {
  /// Whether [entityId] drops this field on [draft]. Absent means printed,
  /// which is what makes the whole map additive: a draft saved before any
  /// of this existed has none, and prints everything exactly as it did.
  bool isOmittedFor(CvDraft draft, String entityId) =>
      draft.omittedFields[this]?.contains(entityId) ?? false;

  /// [draft] with [entityId] added to or removed from this field's list.
  ///
  /// Prunes a list that empties rather than storing `[]`, so the stored
  /// JSON of a draft that omitted something and then put it back is
  /// identical to one that never touched it.
  CvDraft applyTo(CvDraft draft, String entityId, {required bool omitted}) {
    final ids = [...?draft.omittedFields[this]];
    if (omitted) {
      if (ids.contains(entityId)) return draft;
      ids.add(entityId);
    } else if (!ids.remove(entityId)) {
      return draft;
    }

    final next = {...draft.omittedFields};
    if (ids.isEmpty) {
      next.remove(this);
    } else {
      next[this] = ids;
    }
    return draft.copyWith(omittedFields: next);
  }
}
