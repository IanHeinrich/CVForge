import 'package:flutter/material.dart';

import 'tokens/app_spacing.dart';

enum _GapSize {
  tiny,
  small,
  medium;

  double resolve(AppSpacing spacing) => switch (this) {
    _GapSize.tiny => spacing.gapTiny,
    _GapSize.small => spacing.gapSmall,
    _GapSize.medium => spacing.gapMedium,
  };
}

/// Vertical spacing between sibling widgets, sourced from [AppSpacing] at
/// build time — unlike a bare `SizedBox`, this can vary by theme instead
/// of being a const-baked-in number.
class VGap extends StatelessWidget {
  const VGap.tiny({super.key}) : _size = _GapSize.tiny;
  const VGap.small({super.key}) : _size = _GapSize.small;
  const VGap.medium({super.key}) : _size = _GapSize.medium;

  final _GapSize _size;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: _size.resolve(context.appSpacing));
}

/// Horizontal spacing between sibling widgets — see [VGap].
class HGap extends StatelessWidget {
  const HGap.tiny({super.key}) : _size = _GapSize.tiny;
  const HGap.small({super.key}) : _size = _GapSize.small;

  final _GapSize _size;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: _size.resolve(context.appSpacing));
}
