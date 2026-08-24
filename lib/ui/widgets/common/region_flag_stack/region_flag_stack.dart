import 'package:flutter/material.dart';

/// A region's flags as a single mark of constant size, so a preset covering
/// four countries reads honestly without taking four times the width.
///
/// [RegionPreset.flags] is a list rather than one emoji because most regions
/// now span several countries — but the mark still has to fit slots built
/// for one glyph (`StudioDocumentBar`'s icon, the picker row's leading
/// mark). Rendering the list as a plain string would be four glyphs wide and
/// overflow both, so this lays them out in a [size]-square box instead:
/// one flag fills it, two sit side by side, three or four go in a 2x2 grid,
/// each scaled down to keep the footprint identical.
///
/// Deliberately not overlapped: flag emoji are colour glyphs with no
/// outline, and overlapping them reads as a smudge at these sizes.
class RegionFlagStack extends StatelessWidget {
  const RegionFlagStack({
    super.key,
    required this.flags,
    required this.size,
    this.maxFlags = 4,
  });

  final List<String> flags;

  /// The width and height of the whole mark, whatever [flags] holds — pass
  /// the same value a single-flag `Text` would have used as its `fontSize`.
  final double size;

  /// Caps how many flags are drawn. Truncates rather than shrinking further,
  /// since a fifth flag would be illegible at any of the sizes this is used
  /// at. `StudioDocumentBar` passes 1: a 2x2 grid inside a 16px slot is
  /// ~8px per glyph, and the button's label already names the region, so the
  /// mark there is decoration rather than information.
  final int maxFlags;

  /// Fractions of [size] at which a glyph stays legible while the row or
  /// grid it sits in still fits the square. Not spacing values, so they
  /// don't belong in `AppSpacing` — they're intrinsic to this layout.
  static const _pairScale = 0.62;
  static const _gridScale = 0.5;

  @override
  Widget build(BuildContext context) {
    final shown = flags.take(maxFlags).toList();
    if (shown.isEmpty) return SizedBox.square(dimension: size);

    return SizedBox.square(
      dimension: size,
      child: Center(child: _layoutFor(shown)),
    );
  }

  Widget _layoutFor(List<String> shown) {
    if (shown.length == 1) return _glyph(shown.first, size);

    if (shown.length == 2) {
      final glyphSize = size * _pairScale;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [for (final f in shown) _glyph(f, glyphSize)],
      );
    }

    // Three flags leave the last cell empty rather than stretching the
    // third across the bottom row — a ragged grid reads as three of four,
    // which is what it is.
    final glyphSize = size * _gridScale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [shown.take(2), shown.skip(2)])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final f in row) _glyph(f, glyphSize)],
          ),
      ],
    );
  }

  /// `height: 1` so a row of glyphs measures its own box rather than the
  /// font's default line spacing, which would push a 2x2 grid past [size].
  Widget _glyph(String flag, double fontSize) =>
      Text(flag, style: TextStyle(fontSize: fontSize, height: 1));
}
