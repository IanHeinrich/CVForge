import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

/// The small bold section-title style shared by every group in
/// [StudioConfigPanel] — Sections, the summary editor, and each
/// [VaultItemSelectorList] — so the panel reads as one visual system
/// rather than each block picking its own heading weight.
class StudioPanelHeading extends StatelessWidget {
  const StudioPanelHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: kcWhite,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
