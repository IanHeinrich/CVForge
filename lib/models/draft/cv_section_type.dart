/// Semantic CV sections. Declaration order IS the canonical print order —
/// templates render whatever ordered list of resolved sections they're
/// handed, so a future user-reorderable-sections feature only has to touch
/// the draft model and composer, never every template.
enum CvSectionType {
  summary,
  skills,
  experience,
  projects,
  education,
  hobbies,
  references,
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
  };
}
