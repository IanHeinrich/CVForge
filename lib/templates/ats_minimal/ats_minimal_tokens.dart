import '../design/cv_design_tokens.dart';

const _ink = 0xFF000000;
const _mutedInk = 0xFF555555;

/// Sans-serif, single-column, real-bullet-glyph styling modelled on the
/// r/EngineeringResumes community template — deliberately plain: no small
/// caps anywhere, one rule per section (not flanking rules either side).
///
/// Every non-muted [CvTypeToken] below sets [CvTypeToken.colorArgb]
/// explicitly to [_ink] rather than leaving it null — a null color falls
/// back to the ambient `DefaultTextStyle` in the Flutter screen renderer,
/// which picks up the app chrome's theme color (not this template's ink)
/// since the CV page is rendered inside that theme, not a page of its own.
const CvDesignTokens atsMinimalTokens = CvDesignTokens(
  marginTop: 40,
  marginRight: 40,
  marginBottom: 40,
  marginLeft: 40,
  sectionGap: 14,
  sectionRuleGap: 6,
  itemGap: 8,
  bulletGap: 3,
  bulletIndent: 14,
  ruleThickness: 0.75,
  ruleColorArgb: 0xFF333333,
  inkArgb: _ink,
  mutedInkArgb: _mutedInk,
  skillColumnCount: 1,
  skillColumnGap: 0,
  name: CvTypeToken(sizePt: 24, weight: CvWeight.bold, colorArgb: _ink),
  contact: CvTypeToken(sizePt: 10, colorArgb: _mutedInk),
  sectionHeading: CvTypeToken(
    sizePt: 12,
    weight: CvWeight.bold,
    colorArgb: _ink,
  ),
  role: CvTypeToken(sizePt: 10.5, weight: CvWeight.bold, colorArgb: _ink),
  company: CvTypeToken(sizePt: 10.5, colorArgb: _ink),
  meta: CvTypeToken(sizePt: 10, colorArgb: _mutedInk),
  body: CvTypeToken(sizePt: 10, lineSpacingPt: 2, colorArgb: _ink),
  bulletLabel: CvTypeToken(sizePt: 10, weight: CvWeight.bold, colorArgb: _ink),
  bullet: CvTypeToken(sizePt: 10, lineSpacingPt: 2, colorArgb: _ink),
);
