import 'package:cv_forge/templates/design/cv_design_tokens.dart';

const _ink = 0xFF000000;
const _mutedInk = 0xFF555555;

/// Sans-serif, single-column, centered-heading styling modelled on a
/// reference CV that favours whitespace over rules: no line under a
/// section title, a bold/italic two-row entry header (entity + date on
/// row one, role/qualification + location on row two) instead of
/// `compact`'s single combined row, and a fully justified summary
/// paragraph. [CvDesignTokens.ruleThickness]/[CvDesignTokens.ruleColorArgb]
/// are still populated (the class requires them) but this template's own
/// renderer never draws a rule with them.
///
/// [role] carries the BOLD top-row text (company/institution) and
/// [company] the ITALIC second-row text (role/qualification) — a reuse of
/// the shared [CvDesignTokens] vocabulary's existing fields rather than
/// new ones, since the two-row header only needs "a bold style" and "an
/// italic style", which those two tokens already are once
/// [CvTypeToken.italic] is set on [company].
const CvDesignTokens classicCenteredTokens = CvDesignTokens(
  marginTop: 40,
  marginRight: 40,
  marginBottom: 40,
  marginLeft: 40,
  sectionGap: 14,
  sectionRuleGap: 6,
  itemGap: 8,
  bulletGap: 3,
  bulletIndent: 4,
  ruleThickness: 0,
  ruleColorArgb: 0xFF333333,
  inkArgb: _ink,
  mutedInkArgb: _mutedInk,
  name: CvTypeToken(sizePt: 15, weight: CvWeight.bold, colorArgb: _ink),
  contact: CvTypeToken(sizePt: 10, colorArgb: _ink),
  // Centered by the renderer, not a token concern — size/weight alone are
  // enough to read as a heading, matching the reference's rule-less style.
  sectionHeading: CvTypeToken(
    sizePt: 11.5,
    weight: CvWeight.bold,
    colorArgb: _ink,
  ),
  role: CvTypeToken(sizePt: 10.5, weight: CvWeight.bold, colorArgb: _ink),
  company: CvTypeToken(sizePt: 10.5, italic: true, colorArgb: _ink),
  meta: CvTypeToken(sizePt: 10, colorArgb: _ink),
  body: CvTypeToken(sizePt: 10, lineSpacingPt: 2, colorArgb: _ink),
  inlineLabel: CvTypeToken(sizePt: 10, weight: CvWeight.bold, colorArgb: _ink),
  bullet: CvTypeToken(sizePt: 10, lineSpacingPt: 2, colorArgb: _ink),
  bulletGlyph: CvTypeToken(sizePt: 18, colorArgb: _ink),
);
