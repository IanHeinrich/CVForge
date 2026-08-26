/// Shared `pw`-only bullet-list rendering, factored out of `compact`'s
/// renderer so a second template doesn't have to re-derive the bullet
/// glyph's ink-center scaling math independently — divergence there would
/// be a silent, hard-to-notice pixel drift between templates rather than a
/// deliberate style choice. Every [CvDesignTokens]-driven template can
/// reuse this for its bullet lists; a template that wants a genuinely
/// different bullet treatment (a different marker shape, no scaling) is
/// free to render its own instead.
library;

import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/resolved_section.dart';
import 'cv_design_tokens.dart';
import 'cv_design_tokens_pdf.dart';
import 'cv_font_set.dart';
import 'cv_markup_pdf.dart';

const _bulletGlyphGap = 6.0;

/// See [buildBulletGlyph]'s doc comment for the derivation — anchors the
/// glyph's scale on its own ink center rather than `Transform.scale`'s
/// default box-center, so `bulletGlyph.sizePt` can be tuned freely without
/// dragging the glyph off its natural position.
const _bulletGlyphAlignmentY = 0.04416;

/// The bullet glyph, laid out at [CvDesignTokens.bullet]'s font size (so
/// its box never grows or shrinks the row it sits in) and then visually
/// scaled to [CvDesignTokens.bulletGlyph]'s size via `Transform.scale`,
/// which paints larger/smaller without touching the layout box.
pw.Widget buildBulletGlyph(CvDesignTokens tokens, CvFontSet fonts) {
  final scale = tokens.bulletGlyph.sizePt / tokens.bullet.sizePt;
  final layoutStyle = tokens.bulletGlyph
      .toPdfStyle(fonts)
      .copyWith(fontSize: tokens.bullet.sizePt);
  return pw.Transform.scale(
    scale: scale,
    alignment: const pw.Alignment(0, _bulletGlyphAlignmentY),
    // Roboto has no glyph for a filled circle (●) — it renders as a tofu
    // box. '•' is covered.
    child: pw.Text('•', style: layoutStyle),
  );
}

/// One bullet's row — glyph, optional bold label, text. Pre-indented by
/// [CvDesignTokens.bulletIndent] and pre-gapped below by
/// [CvDesignTokens.bulletGap] on itself (not on a wrapping container), so
/// a list of these composes correctly as separate top-level `pw.MultiPage`
/// widgets, which `assembleSectionWidgets` requires for genuine
/// cross-page splitting between bullets — see that function's doc
/// comment for why a nested `pw.Column` of many bullets can't safely span
/// pages on its own.
///
/// A Row with a start-aligned cross axis, not an inline TextSpan —
/// mixed-size spans in one RichText share a baseline, so once
/// bulletGlyph's size diverges from bullet's, the glyph reads as floating
/// above/below the text rather than centered on it. `start`, not
/// `center`: for a bullet that wraps to multiple lines, the glyph should
/// sit against the FIRST line, not centered against the whole
/// multi-line block.
///
/// [preventOrphansAndSplits] false swaps that Row for [_spanningBulletRow]
/// — see there for why one bullet cannot both hang its own indent and
/// break across a page.
pw.Widget buildBulletRow(
  ResolvedBullet bullet,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  bool preventOrphansAndSplits = true,
}) {
  if (!preventOrphansAndSplits) {
    return _spanningBulletRow(bullet, tokens, fonts);
  }
  return pw.Padding(
    padding: pw.EdgeInsets.only(
      left: tokens.bulletIndent,
      bottom: tokens.bulletGap,
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        buildBulletGlyph(tokens, fonts),
        pw.SizedBox(width: _bulletGlyphGap),
        pw.Expanded(child: markupText(bullet.text, tokens.bullet, fonts)),
      ],
    ),
  );
}

/// The same bullet as one `pw.RichText`, for the retry that runs after a
/// bullet turned out to be taller than a whole page.
///
/// A `pw.Row` is not a `SpanningWidget`, and no amount of making its
/// children spannable changes that — `pw.MultiPage` asks the top-level
/// widget itself, so a bullet laid out as glyph-beside-text simply cannot
/// break across a page and throws instead. Folding the glyph into the
/// text as a leading span is what makes the bullet a single spannable
/// widget.
///
/// The trade is the hanging indent: continuation lines return to the left
/// margin rather than aligning under the first line's text. That is the
/// deliberate cost of `PdfExportService.render`'s unguarded retry, which
/// exists to get an oversized field onto the page at all — the alternative
/// on this path is no document. The glyph is drawn at the body size rather
/// than [CvDesignTokens.bulletGlyph]'s, because a single RichText shares
/// one baseline across its spans (the reason [buildBulletRow] uses a Row
/// in the first place).
pw.Widget _spanningBulletRow(
  ResolvedBullet bullet,
  CvDesignTokens tokens,
  CvFontSet fonts,
) => pw.Padding(
  padding: pw.EdgeInsets.only(
    left: tokens.bulletIndent,
    bottom: tokens.bulletGap,
  ),
  child: pw.RichText(
    overflow: pw.TextOverflow.span,
    text: pw.TextSpan(
      children: [
        literalSpan('\u2022  ', tokens.bullet, fonts),
        ...markupSpans(bullet.text, tokens.bullet, fonts),
      ],
    ),
  ),
);
