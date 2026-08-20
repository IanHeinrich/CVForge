import 'package:cv_forge/templates/design/cv_design_tokens.dart';

const _ink = 0xFF000000;
const _mutedInk = 0xFF555555;

/// Sans-serif, single-column, real-bullet-glyph styling modelled on the
/// r/EngineeringResumes community template — deliberately plain: no small
/// caps anywhere, one rule per section (not flanking rules either side).
///
/// Every non-muted [CvTypeToken] below sets [CvTypeToken.colorArgb]
/// explicitly to [_ink] rather than leaving it null — the printed ink
/// should never silently depend on `package:pdf`'s own default text
/// color rather than this template's own choice.
const CvDesignTokens atsMinimalTokens = CvDesignTokens(
  marginTop: 40,
  marginRight: 40,
  marginBottom: 40,
  marginLeft: 40,
  sectionGap: 10,
  sectionRuleGap: 4,
  itemGap: 6,
  bulletGap: 2,
  // The reference template keeps bullets flush with the job
  // title/project name above them, not indented under it.
  bulletIndent: 0,
  ruleThickness: 0.75,
  ruleColorArgb: 0xFF333333,
  inkArgb: _ink,
  mutedInkArgb: _mutedInk,
  name: CvTypeToken(sizePt: 24, weight: CvWeight.bold, colorArgb: _ink),
  // Ink, not muted — the reference r/EngineeringResumes template uses one
  // text color throughout; grey reads as lower-priority to some ATS
  // parsers and adds nothing here.
  contact: CvTypeToken(sizePt: 10, colorArgb: _ink),
  // Larger than body text but not bold — the size alone is enough to read
  // as a heading.
  sectionHeading: CvTypeToken(sizePt: 12, colorArgb: _ink),
  role: CvTypeToken(sizePt: 10.5, weight: CvWeight.bold, colorArgb: _ink),
  company: CvTypeToken(sizePt: 10.5, colorArgb: _ink),
  meta: CvTypeToken(sizePt: 10, colorArgb: _ink),
  body: CvTypeToken(sizePt: 10, lineSpacingPt: 2, colorArgb: _ink),
  bulletLabel: CvTypeToken(sizePt: 10, weight: CvWeight.bold, colorArgb: _ink),
  bullet: CvTypeToken(sizePt: 10, lineSpacingPt: 2, colorArgb: _ink),
  // Kept as a separate token (not the same size as the bullet body) so a
  // future size/weight tweak to just the marker is a one-line change.
  bulletGlyph: CvTypeToken(sizePt: 20, colorArgb: _ink),
);
