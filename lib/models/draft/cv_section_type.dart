/// Semantic CV sections. Declaration order IS the canonical print order —
/// templates render whatever ordered list of resolved sections they're
/// handed, so a future user-reorderable-sections feature only has to touch
/// the draft model and composer, never every template.
enum CvSectionType {
  summary,
  experience,
  skills,
  education,
  hobbies,
  references,
}
