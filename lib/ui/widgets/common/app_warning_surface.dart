import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';

/// The app's one amber advisory treatment: a faint warning-coloured fill
/// inside a stronger warning-coloured border.
///
/// Promoted here from `_PageCountBadge`, on that widget's own instruction
/// — it carried a note saying a third amber surface should stop copying
/// the recipe. There are now three (`_PageCountBadge`, `_SpendWarning`,
/// and Studio's photo/region advisory), which differ in shape but must not
/// differ in colour.
///
/// The alphas live here rather than in `tokens/` because they are a colour
/// treatment, not a scale value — `AppPalette.warning` is the token; how
/// far it is tinted to make a surface out of it is this widget's business.
///
/// What this deliberately does NOT own is layout: [child] is whatever the
/// caller needs, because an inline badge and a bulleted panel genuinely
/// have nothing to share below the decoration. [icon] is offered
/// separately for the same reason — every amber surface leads with it, but
/// not all of them lead with it in the same row as their text.
class AppWarningSurface extends StatelessWidget {
  const AppWarningSurface({
    super.key,
    required this.child,
    required this.radius,
    this.padding,
    this.height,
    this.width,
    this.alignment,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final AlignmentGeometry? alignment;

  static const _fillAlpha = 0.08;
  static const _borderAlpha = 0.4;

  /// The marker every amber surface leads with. A method rather than a
  /// const because both the size and the colour are read off the theme.
  static Widget icon(BuildContext context) => Icon(
    RemixIcons.error_warning_line,
    size: context.appIconSize.small,
    color: context.appPalette.warning,
  );

  @override
  Widget build(BuildContext context) {
    final warning = context.appPalette.warning;
    return Container(
      height: height,
      width: width,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: warning.withValues(alpha: _fillAlpha),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: warning.withValues(alpha: _borderAlpha)),
      ),
      child: child,
    );
  }
}
