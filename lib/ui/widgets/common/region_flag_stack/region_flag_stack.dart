import 'package:flutter/material.dart';

/// A region's flags as a single mark of constant size, so a preset covering
/// four countries reads honestly without taking four times the width.
///
/// `RegionPreset.flags` is a list rather than one emoji because most regions
/// span several countries — but the mark still has to fit a slot built for
/// one glyph. Rendering the list as a plain string would be four glyphs
/// wide and overflow it, so this lays them out in a [size]-square box
/// instead: one flag fills it, two sit side by side, three or four go in a
/// 2x2 grid. Beyond four it truncates, since a fifth would be illegible at
/// any size this is used at.
///
/// Only used where there is room to render every flag — the region picker
/// and Settings, both at `appIconSize.large`. `StudioDocumentBar` shows a
/// globe instead: its 16px slot would reduce four flags to mush, and
/// showing only the first would mark "UK & Ireland" with the UK flag
/// alone.
///
/// The glyphs are laid out at a nominal size and scaled to fit by
/// [FittedBox], rather than at a computed fraction of [size]. A flag emoji
/// is a regional-indicator *pair*, whose advance width is wider than its
/// font size — so any fraction picked by hand overflows on some platform's
/// emoji font. Letting the layout measure itself makes the fit a property
/// of the box rather than of a guess about font metrics.
///
/// Deliberately not overlapped: flag emoji are colour glyphs with no
/// outline, and overlapping them reads as a smudge at these sizes.
class RegionFlagStack extends StatelessWidget {
  const RegionFlagStack({super.key, required this.flags, required this.size});

  final List<String> flags;

  /// The width and height of the whole mark, whatever [flags] holds — pass
  /// the same value a single-flag `Text` would have used as its `fontSize`.
  final double size;

  /// Arbitrary — only the *ratios* between glyphs matter, since [FittedBox]
  /// rescales the result. Large enough that layout rounding doesn't show.
  static const _nominalGlyphSize = 100.0;

  @override
  Widget build(BuildContext context) {
    final shown = flags.take(4).toList();
    if (shown.isEmpty) return SizedBox.square(dimension: size);

    return SizedBox.square(
      dimension: size,
      child: FittedBox(fit: BoxFit.contain, child: _layoutFor(shown)),
    );
  }

  Widget _layoutFor(List<String> shown) {
    if (shown.length == 1) return _glyph(shown.first);
    if (shown.length == 2) return _row(shown);

    // Three flags leave the last cell empty rather than stretching the
    // third across the bottom row — a ragged grid reads as three of four,
    // which is what it is.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_row(shown.take(2)), _row(shown.skip(2))],
    );
  }

  Widget _row(Iterable<String> flags) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [for (final flag in flags) _glyph(flag)],
  );

  /// `height: 1` so a row of glyphs measures its own box rather than the
  /// font's default line spacing, which would leave a 2x2 grid with a band
  /// of dead space through the middle.
  Widget _glyph(String flag) => Text(
    flag,
    style: const TextStyle(fontSize: _nominalGlyphSize, height: 1),
  );
}
