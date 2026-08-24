/// Semantic CV sections. Declaration order is only the fallback print
/// order — the canonical order for an existing CV is
/// `CvDraft.effectiveSectionOrder`, user-reorderable per-draft in Studio.
/// Templates still just render whatever ordered list of resolved sections
/// they're handed, so this enum and `CvComposer` are the only places that
/// needed to change to support that.
enum CvSectionType {
  summary,
  skills,
  experience,
  projects,
  education,
  hobbies,
  references,
  publications,
}

/// The picker label for a section moved to
/// `lib/ui/common/l10n/model_labels.dart` — it needs `AppLocalizations`,
/// and this library must stay free of Flutter imports. What `CvComposer`
/// prints on the page is a separate concern that stays English.
