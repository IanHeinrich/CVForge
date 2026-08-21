/// The shared layout vocabulary consumed by every template's renderer.
///
/// Pure Dart, imports nothing — this file must never depend on `flutter`
/// or `pdf`. `cv_design_tokens_pdf.dart` is the one adapter that imports
/// `pdf` and maps these tokens to `pw` style types. All dimensions are in
/// PDF points, and colours are `int` ARGB — the PDF is the source of
/// truth; Studio's live preview rasterizes that same PDF rather than
/// maintaining a second render tree.
library;

enum CvWeight { regular, bold }

/// A single named typographic style — think "the 'role' text style" — not
/// a raw `pw.TextStyle`, so a template's tokens stay framework-agnostic
/// even though `pdf` is the only renderer that ever consumes them.
class CvTypeToken {
  const CvTypeToken({
    required this.sizePt,
    this.weight = CvWeight.regular,
    this.italic = false,

    /// EXTRA points added between lines — not a multiplier. Matches
    /// `pw.TextStyle.lineSpacing`'s own unit (see
    /// `CvTypeTokenPdf.toPdfStyle`), so no conversion happens between this
    /// token and the style it produces.
    this.lineSpacingPt = 0,
    this.letterSpacingPt = 0,
    this.colorArgb,
  });

  final double sizePt;
  final CvWeight weight;
  final bool italic;
  final double lineSpacingPt;
  final double letterSpacingPt;
  final int? colorArgb;

  CvTypeToken copyWith({
    double? sizePt,
    CvWeight? weight,
    bool? italic,
    double? lineSpacingPt,
    double? letterSpacingPt,
    int? colorArgb,
  }) => CvTypeToken(
    sizePt: sizePt ?? this.sizePt,
    weight: weight ?? this.weight,
    italic: italic ?? this.italic,
    lineSpacingPt: lineSpacingPt ?? this.lineSpacingPt,
    letterSpacingPt: letterSpacingPt ?? this.letterSpacingPt,
    colorArgb: colorArgb ?? this.colorArgb,
  );
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
    required this.name,
    required this.contact,
    required this.sectionHeading,
    required this.role,
    required this.company,
    required this.meta,
    required this.body,
    required this.bulletLabel,
    required this.bullet,
    required this.bulletGlyph,
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

  final CvTypeToken name;
  final CvTypeToken contact;
  final CvTypeToken sectionHeading;
  final CvTypeToken role;
  final CvTypeToken company;
  final CvTypeToken meta;
  final CvTypeToken body;
  final CvTypeToken bulletLabel;
  final CvTypeToken bullet;

  /// The bullet glyph itself (e.g. "•"), styled separately from [bullet]'s
  /// body text — sizing/weighting the marker independently of the text
  /// that follows it is a common per-template tweak, and splitting it out
  /// here is what makes that a one-line token change instead of a
  /// renderer-level `copyWith`.
  final CvTypeToken bulletGlyph;
}
