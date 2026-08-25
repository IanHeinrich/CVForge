import 'package:cv_forge/templates/design/cv_design_tokens.dart';

/// Slate, replacing the reference layout's green. The band is a backdrop
/// for a name, so it stays quiet; [_accent] carries the structure.
const _bandFill = 0xFFE7ECF0;
const _accent = 0xFF74849A;

const _ink = 0xFF1F2933;
const _mutedInk = 0xFF5A6672;

/// Every non-type measurement in this template, taken off the reference
/// layout at A4 and stated in that layout's own units.
///
/// Points, not millimetres: the reference is a PDF and every number below
/// was measured out of its content stream, so restating them in mm would
/// only add rounding between the source and this file. The two that are
/// genuinely physical carry their mm equivalent in a comment.
///
/// Kept template-local rather than added to [CvDesignTokens]: this is the
/// only template with a band, a photo, or page marks, and a dozen nullable
/// fields that two of three templates ignore would make the shared
/// vocabulary worse to read. Promote it if a second one ever appears.
class PhotoHeaderStyle {
  const PhotoHeaderStyle({
    required this.bandFillArgb,
    required this.accentArgb,
    required this.bandHeightPt,
    required this.bandHeightNoPhotoPt,
    required this.photoDiameterPt,
    required this.photoRingPt,
    required this.photoRingArgb,
    required this.photoInsetPt,
    required this.contactLabelWidthPt,
    required this.contactLineHeightPt,
    required this.nameToContactPt,
    required this.afterRuleGapPt,
    required this.continuationTopPt,
    required this.markTopWidthPt,
    required this.markTopHeightPt,
    required this.markTopYPt,
    required this.markBottomWidthPt,
    required this.markBottomHeightPt,
    required this.markBottomRightPt,
  });

  /// The band behind the name, contact block and photograph. Bleeds to the
  /// left, top and right page edges — see `PhotoHeaderTemplate.buildDocument`.
  final int bandFillArgb;

  /// Carries the structure: the hairline under every section heading, the
  /// bullet glyphs, and the two page marks. One colour for all three
  /// because they are one gesture, and three near-identical slates would
  /// read as a mistake.
  final int accentArgb;

  /// Measured from the top of the *page*, not from the top margin, since
  /// the band bleeds past it. 167.3pt is ~59mm.
  final double bandHeightPt;

  /// The band still appears when the Vault holds no photo yet — the band
  /// is the whole look of this template, and dropping it would make an
  /// un-uploaded photo silently change which template you appear to have
  /// chosen. It shrinks to the contact block instead.
  final double bandHeightNoPhotoPt;

  /// 121.4pt is ~43mm.
  final double photoDiameterPt;
  final double photoRingPt;

  /// [accentArgb], tying the circle to the edge marks and the section
  /// hairlines. The reference uses white, which it needs against a
  /// saturated green band; on a pale slate band white disappears and the
  /// photograph is left with no edge at all.
  final int photoRingArgb;

  /// How far the circle sits inside the content box's right edge. The
  /// reference tucks it in rather than aligning it flush.
  final double photoInsetPt;

  /// The label column in the stacked contact block ("Email:",
  /// "LinkedIn:"). The reference puts labels at x=61.6 and values at
  /// x=132.3.
  ///
  /// Measured on a rendered sample, the widest gap this produces between
  /// any label and its value is 45.5pt — the *shortest* label in the
  /// widest box — against the 60pt that
  /// `AtsAnalyzerService._checkColumnCrush` flags. Widening this box eats
  /// that margin, so raise it only against a re-measured sample
  /// (`tool/render_photo_samples.dart`).
  ///
  /// The entry-title-plus-date row is the other shared-baseline construct
  /// here and does cross that threshold; see `PhotoHeaderPdfRenderer`'s
  /// class doc for why that one is left alone.
  final double contactLabelWidthPt;

  /// Baseline to baseline in the contact block; 15pt in the reference.
  final double contactLineHeightPt;

  /// Name baseline to first contact baseline; 35.4pt in the reference.
  final double nameToContactPt;

  /// Hairline to the section's first line.
  ///
  /// A *box* gap, not the baseline-to-baseline figure the reference is
  /// measured in: a `pw.Text`'s box starts one ascent above its baseline.
  /// The reference starts its body 19.0pt under the rule; subtracting a
  /// 12pt Roboto line's 11.1pt ascent leaves this.
  ///
  /// The gap on the other side of the rule needs no field of its own —
  /// `CvDesignTokens.sectionRuleGap` already carries it, and the reference
  /// puts the rule 5.9pt under the heading baseline, which that token's
  /// 2.5pt box gap reproduces.
  final double afterRuleGapPt;

  /// Added above pages two and up, so they keep a normal top margin. The
  /// page margin itself is pulled tight to seat the name high inside the
  /// band — see [photoHeaderTokens]' doc comment.
  final double continuationTopPt;

  /// The small accent bar bleeding off the left edge, level with the top
  /// of the photograph.
  final double markTopWidthPt;
  final double markTopHeightPt;
  final double markTopYPt;

  /// The matching mark at the foot of every page, bleeding off the bottom.
  final double markBottomWidthPt;
  final double markBottomHeightPt;
  final double markBottomRightPt;
}

/// The reference layout's own numbers. Changing one changes how closely
/// this template tracks it, so each is annotated with what it came from
/// rather than left as a bare constant.
const photoHeaderStyle = PhotoHeaderStyle(
  bandFillArgb: _bandFill,
  accentArgb: _accent,
  bandHeightPt: 167.3,
  // Without a photo the band only has to seat the name and contact rows.
  bandHeightNoPhotoPt: 140,
  photoDiameterPt: 121.4,
  photoRingPt: 1.2,
  photoRingArgb: _accent,
  photoInsetPt: 8,
  contactLabelWidthPt: 75.3,
  contactLineHeightPt: 15,
  nameToContactPt: 35.4,
  afterRuleGapPt: 7.9,
  continuationTopPt: 27,
  markTopWidthPt: 13.6,
  markTopHeightPt: 28.4,
  markTopYPt: 31.6,
  markBottomWidthPt: 10.4,
  markBottomHeightPt: 17.6,
  markBottomRightPt: 53.1,
);

/// The reference layout's type scale, which is a notably open one — 12pt
/// body on a 16.3pt line, against Compact's 10pt on 12. That is the point
/// of this template: it is the visually distinct option, not the dense
/// one. `StudioViewModel.pageCountWarning` is what catches a CV that runs
/// long as a result.
///
/// [marginTop] is deliberately much smaller than the other three. The
/// reference seats its name baseline at 56pt — above where a 57pt top
/// margin would start the content box — so the margin is pulled up to meet
/// it, and pages two and up get [PhotoHeaderStyle.continuationTopPt] back
/// through `pw.MultiPage.header`.
///
/// Spelled out in full rather than derived from `compactTokens`, matching
/// how `classicCenteredTokens` is declared — [CvDesignTokens] is a const
/// lookup table with no `copyWith`, and a partial override would hide
/// which values this template actually prints.
const CvDesignTokens photoHeaderTokens = CvDesignTokens(
  marginTop: 30,
  marginRight: 57,
  marginBottom: 57,
  marginLeft: 57,
  // The reference runs a consistent 35.8pt from a section's last baseline
  // to the next heading's. Subtracting a 12pt line's descent (2.9) and a
  // 16pt heading's ascent (14.8) leaves this as the box gap between them.
  sectionGap: 18.1,
  sectionRuleGap: 2.5,
  // The reference runs entries continuously, one line pitch apart. Opened
  // up a little here: at this type scale a job, project or publication
  // butting straight against the next reads as one block, and the extra
  // air is what makes each entry legible as its own thing.
  itemGap: 9,
  // Between the bullets inside one entry, and between a heading and its
  // first bullet. Stays tight: the reference runs bullets at a flat line
  // pitch, and [itemGap] is what separates one entry from the next.
  bulletGap: 0,
  // Glyph 18pt in from the margin; wrapped bullet text at 36pt.
  bulletIndent: 18,
  ruleThickness: 0.6,
  ruleColorArgb: _accent,
  inkArgb: _ink,
  mutedInkArgb: _mutedInk,
  // Tracked, approximating the reference's wide display face — Roboto is
  // considerably narrower, so without this the name reads as smaller than
  // 28pt even though it is set at 28pt.
  name: CvTypeToken(
    sizePt: 28,
    weight: CvWeight.bold,
    letterSpacingPt: 0.6,
    colorArgb: _ink,
  ),
  contact: CvTypeToken(sizePt: 11, colorArgb: _ink),
  // Bold and tracked over a hairline: the single biggest thing that makes
  // the page read as designed rather than typed.
  sectionHeading: CvTypeToken(
    sizePt: 16,
    weight: CvWeight.bold,
    letterSpacingPt: 0.5,
    colorArgb: _ink,
  ),
  // The reference sets entry titles at plain 12pt, undifferentiated from
  // the body. Bold here instead: `CvComposer` hands the renderer role,
  // company and location as separate fields, and printing all three at one
  // weight throws away a distinction the rest of the app makes.
  role: CvTypeToken(sizePt: 12, weight: CvWeight.bold, colorArgb: _ink),
  company: CvTypeToken(sizePt: 12, colorArgb: _ink),
  meta: CvTypeToken(sizePt: 12, colorArgb: _mutedInk),
  body: CvTypeToken(sizePt: 12, lineSpacingPt: 2.3, colorArgb: _ink),
  inlineLabel: CvTypeToken(sizePt: 12, weight: CvWeight.bold, colorArgb: _ink),
  bullet: CvTypeToken(sizePt: 12, lineSpacingPt: 2.3, colorArgb: _ink),
  bulletGlyph: CvTypeToken(sizePt: 24, colorArgb: _accent),
);
