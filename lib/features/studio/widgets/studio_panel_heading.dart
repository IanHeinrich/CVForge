import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// The small bold section-title style shared by every group in
/// [StudioConfigPanel] — Sections, the summary editor, and each
/// [VaultItemSelectorList] — so the panel reads as one visual system
/// rather than each block picking its own heading weight. Same
/// [AppTypography.titleSmall] role as [VaultSectionHeading] — a heading above one
/// group of cards/items reads the same size regardless of which feature
/// it's in.
class StudioPanelHeading extends StatelessWidget {
  const StudioPanelHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: context.appTypography.titleSmall);
  }
}
