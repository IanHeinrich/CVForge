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

/// UI-facing label for Studio's section-visibility toggles. Deliberately
/// separate from the titles `CvComposer` bakes into a `ResolvedSection` —
/// today they read the same, but "what a picker calls this section" and
/// "what's printed on the page" are different concerns that happen to
/// agree, not one written in terms of the other.
extension CvSectionTypeLabel on CvSectionType {
  String get displayLabel => switch (this) {
    CvSectionType.summary => 'Professional summary',
    CvSectionType.skills => 'Skills',
    CvSectionType.experience => 'Work history',
    CvSectionType.projects => 'Projects',
    CvSectionType.education => 'Education',
    CvSectionType.hobbies => 'Hobbies and interests',
    CvSectionType.references => 'References',
    CvSectionType.publications => 'Publications',
  };
}
