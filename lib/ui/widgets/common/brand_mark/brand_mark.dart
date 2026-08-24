import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The CVForge mark — the page-into-anvil logo — for use inside the app.
///
/// Deliberately not an `Icon`: this is a brand graphic, not part of the
/// icon set, so it sizes on its own scale rather than
/// `AppIconSize` (whose `xLarge` is the 48px empty-state *icon* size — too
/// small for a brand moment, and the wrong concept to grow for one).
///
/// The mark ships in two optical sizes and this widget picks between them,
/// which is the whole point of there being two: below
/// [_smallMarkThreshold] the detail mark's hammer, base scallop and
/// lower-left pocket close into a blob, so the simplified mark is used
/// instead. Call sites should not reach for the asset paths directly —
/// that is how the two marks end up used at the wrong sizes.
///
/// Decorative by default. Every current call site sits next to text that
/// already carries the meaning, so the mark is hidden from screen readers
/// unless [semanticsLabel] is given.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = defaultSize,
    this.color,
    this.semanticsLabel,
  });

  /// Big enough to read as a brand moment rather than a large icon, and to
  /// keep the hammer and the page rules legible. Both call sites take this
  /// default; it is a named constant rather than a token because `BrandMark`
  /// is the only thing that has any business sizing the mark.
  static const double defaultSize = 88;

  /// Below this the detail mark turns to mush — see the comment in
  /// `assets/brand/cvforge-mark-small.svg`, which records what was checked
  /// at 16/20/24/32 and why each piece came off.
  static const double _smallMarkThreshold = 32;

  final double size;

  /// Defaults to the ambient [IconTheme] colour, so the mark tints with
  /// whatever surface it is dropped on rather than pinning itself to brand
  /// purple. Pass a colour to override.
  final Color? color;

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? _fallbackColor;
    return SvgPicture.asset(
      size < _smallMarkThreshold
          ? 'assets/brand/cvforge-mark-small.svg'
          : 'assets/brand/cvforge-mark.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: semanticsLabel == null,
    );
  }
}

/// Only reachable if a `BrandMark` is built outside any `IconTheme`, which
/// `MaterialApp` always provides — a defined value beats a null-assertion
/// crash in that case.
const _fallbackColor = Color(0xFFFFFFFF);
