import 'dart:math' as math;

import 'ats_text_node.dart';

/// An axis-aligned bounding box in pixel space — the X-Ray overlay's unit
/// of "one drawable rectangle". A plain record, not a `@freezed` class:
/// this is a per-render calculation result, not persisted app state, and
/// this package must never import `flutter` (no `dart:ui` `Rect`) — see
/// [AtsTextMatrix]'s doc comment.
typedef AtsPixelRect = ({double left, double top, double right, double bottom});

/// The smallest [AtsPixelRect] enclosing every rect in [rects] — the X-Ray
/// overlay's camera-framing primitive (frame a finding's evidence) and its
/// `span`-shape hull (frame the gap between a `columnCrush` pair). Throws
/// on an empty iterable — callers already know whether they have evidence
/// to frame before reaching for this.
AtsPixelRect atsUnionRect(Iterable<AtsPixelRect> rects) {
  return rects.reduce(
    (a, b) => (
      left: math.min(a.left, b.left),
      top: math.min(a.top, b.top),
      right: math.max(a.right, b.right),
      bottom: math.max(a.bottom, b.bottom),
    ),
  );
}

/// Composes `item`'s own text-rendering matrix with the page's [viewport]
/// transform — "apply the item's own transform, then the viewport
/// transform" (`result = item ∘ viewport`), the standard PDF
/// matrix-composition formula (what `pdf.js`'s own `Util.transform`
/// computes). This is the part of the coordinate reconciliation most
/// likely to have a sign or order error, hence the dedicated unit test
/// rather than trusting it inline in painter code.
AtsTextMatrix composeAtsTextMatrix(AtsTextMatrix item, AtsTextMatrix viewport) {
  return AtsTextMatrix(
    a: item.a * viewport.a + item.b * viewport.c,
    b: item.a * viewport.b + item.b * viewport.d,
    c: item.c * viewport.a + item.d * viewport.c,
    d: item.c * viewport.b + item.d * viewport.d,
    e: item.e * viewport.a + item.f * viewport.c + viewport.e,
    f: item.e * viewport.b + item.f * viewport.d + viewport.f,
  );
}

/// Typical PDF font-metric defaults (fraction of em, ascent positive /
/// descent negative) for a font that doesn't report its own — `pdf.js`
/// doesn't always populate `AtsFontInfo.ascent`/`.descent` (some
/// standard/substituted fonts), and these keep [atsInkBoxRect] usable
/// rather than requiring them.
const _fallbackAscentEm = 0.75;
const _fallbackDescentEm = -0.25;

/// The pixel-space ink box for [node] once rasterized under [viewport] —
/// [AtsTextNode.width] is an *advance* box, not an *ink* box, so without
/// ascent/descent every box would sit with its vertical center on the
/// baseline rather than around the glyph ink.
///
/// Deliberately computes the four corners in the run's own (possibly
/// rotated) frame — using [AtsTextMatrix.rotationRadians]/[AtsTextMatrix.
/// fontSize] as the local "along baseline"/"up" axes — and only then
/// projects each corner through [viewport], rather than assuming which
/// projected corner ends up top-left. This is what makes the result
/// correct for a rotated run (a sidebar label) without a separate code
/// path, and side-steps needing to hand-guess whichever sign convention
/// [viewport]'s y-flip uses: the bounding box of four correctly-projected
/// points is right regardless.
///
/// [ascent]/[descent] should come from the node's `AtsFontInfo` (`pdf.js`
/// reports them as fractions of em); `null` falls back to typical
/// defaults.
AtsPixelRect atsInkBoxRect({
  required AtsTextNode node,
  required AtsTextMatrix viewport,
  double? ascent,
  double? descent,
}) {
  final transform = node.transform;
  final rotation = transform.rotationRadians;
  final fontSize = transform.fontSize;

  // Unit vectors of the run's own frame, in page space: "along the
  // baseline" and "up" (perpendicular, matching the font's own upright
  // orientation before any rotation).
  final unitXx = math.cos(rotation);
  final unitXy = math.sin(rotation);
  final unitYx = -math.sin(rotation);
  final unitYy = math.cos(rotation);

  final ascentPx = (ascent ?? _fallbackAscentEm) * fontSize;
  final descentPx = (descent ?? _fallbackDescentEm) * fontSize;

  final baseX = transform.e;
  final baseY = transform.f;
  final endX = baseX + node.width * unitXx;
  final endY = baseY + node.width * unitXy;

  final cornersPageSpace = [
    (baseX + ascentPx * unitYx, baseY + ascentPx * unitYy),
    (endX + ascentPx * unitYx, endY + ascentPx * unitYy),
    (baseX + descentPx * unitYx, baseY + descentPx * unitYy),
    (endX + descentPx * unitYx, endY + descentPx * unitYy),
  ];

  final projected = cornersPageSpace.map(
    (p) => (
      p.$1 * viewport.a + p.$2 * viewport.c + viewport.e,
      p.$1 * viewport.b + p.$2 * viewport.d + viewport.f,
    ),
  );
  final xs = projected.map((p) => p.$1);
  final ys = projected.map((p) => p.$2);

  return (
    left: xs.reduce(math.min),
    top: ys.reduce(math.min),
    right: xs.reduce(math.max),
    bottom: ys.reduce(math.max),
  );
}
