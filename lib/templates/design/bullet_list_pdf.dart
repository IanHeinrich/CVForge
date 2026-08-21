/// Shared `pw`-only bullet-list rendering, factored out of `ats_minimal`'s
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

pw.Widget buildBulletList(
  List<ResolvedBullet> bullets,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  if (bullets.isEmpty) return pw.SizedBox.shrink();
  return pw.Padding(
    padding: pw.EdgeInsets.only(
      top: tokens.bulletGap,
      left: tokens.bulletIndent,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final bullet in bullets)
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: tokens.bulletGap),
            // A Row with a start-aligned cross axis, not an inline
            // TextSpan — mixed-size spans in one RichText share a
            // baseline, so once bulletGlyph's size diverges from bullet's,
            // the glyph reads as floating above/below the text rather than
            // centered on it. `start`, not `center`: for a bullet that
            // wraps to multiple lines, the glyph should sit against the
            // FIRST line, not centered against the whole multi-line block.
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildBulletGlyph(tokens, fonts),
                pw.SizedBox(width: _bulletGlyphGap),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        if (bullet.label != null)
                          pw.TextSpan(
                            text: '${bullet.label}: ',
                            style: tokens.bulletLabel.toPdfStyle(fonts),
                          ),
                        pw.TextSpan(
                          text: bullet.text,
                          style: tokens.bullet.toPdfStyle(fonts),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
