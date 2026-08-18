/// The shared layout vocabulary consumed by both render trees.
///
/// Pure Dart, imports nothing — this file must never depend on `flutter`
/// or `pdf`. Two thin adapters (`cv_design_tokens_flutter.dart` and
/// `cv_design_tokens_pdf.dart`) each import exactly one of those and map
/// these tokens to that framework's style types. All dimensions are in
/// PDF points, and colours are `int` ARGB — the PDF is the source of
/// truth; the screen preview adapts to it, not the other way round.
library;

enum CvWeight { regular, bold }

/// A single named typographic style — think "the 'role' text style" — not
/// a raw Flutter/pdf TextStyle, so both renderers can derive their own
/// concrete style object from the same numbers.
class CvTypeToken {
  const CvTypeToken({
    required this.sizePt,
    this.weight = CvWeight.regular,
    this.italic = false,
    this.smallCaps = false,

    /// EXTRA points added between lines — not a multiplier. pw.TextStyle's
    /// `lineSpacing` is extra points; Flutter's TextStyle.height is a
    /// multiplier of the whole line box. Storing the pt-based value here
    /// (the PDF's native unit) and having the Flutter adapter compute
    /// `height: (sizePt + lineSpacingPt) / sizePt` is what keeps the two
    /// renderers within a line or two of each other over a full page.
    this.lineSpacingPt = 0,
    this.letterSpacingPt = 0,
    this.colorArgb,
  });

  final double sizePt;
  final CvWeight weight;
  final bool italic;
  final bool smallCaps;
  final double lineSpacingPt;
  final double letterSpacingPt;
  final int? colorArgb;
}

class CvDesignTokens {
  const CvDesignTokens({
    required this.marginTop,
    required this.marginRight,
    required this.marginBottom,
    required this.marginLeft,
    required this.sectionGap,
    required this.sectionRuleGap,
    required this.itemGap,
    required this.bulletGap,
    required this.bulletIndent,
    required this.ruleThickness,
    required this.ruleColorArgb,
    required this.inkArgb,
    required this.mutedInkArgb,
    required this.skillColumnCount,
    required this.skillColumnGap,
    required this.name,
    required this.contact,
    required this.sectionHeading,
    required this.role,
    required this.company,
    required this.meta,
    required this.body,
    required this.bulletLabel,
    required this.bullet,
  });

  // Page margins, PDF points.
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final double marginLeft;

  // Vertical rhythm, PDF points.
  final double sectionGap;
  final double sectionRuleGap;
  final double itemGap;
  final double bulletGap;
  final double bulletIndent;

  // Rules (the horizontal lines flanking section headings, and under the
  // name).
  final double ruleThickness;
  final int ruleColorArgb;

  final int inkArgb;
  final int mutedInkArgb;

  final int skillColumnCount;
  final double skillColumnGap;

  final CvTypeToken name;
  final CvTypeToken contact;
  final CvTypeToken sectionHeading;
  final CvTypeToken role;
  final CvTypeToken company;
  final CvTypeToken meta;
  final CvTypeToken body;
  final CvTypeToken bulletLabel;
  final CvTypeToken bullet;
}
