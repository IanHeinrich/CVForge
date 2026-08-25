import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

/// A chosen value with the button that changes it — the shape both the
/// region and the template rows in `DocumentDefaultsEditorPanel` take.
///
/// One widget rather than the two inline copies it replaces, so the mark,
/// the value and the button cannot drift apart between the two settings
/// that are meant to read as peers. [leading] is whatever identifies the
/// value at a glance: a `RegionFlagStack` for a region, a plain icon for a
/// template.
class DocumentDefaultsValueRow extends StatelessWidget {
  const DocumentDefaultsValueRow({
    super.key,
    required this.leading,
    required this.value,
    required this.onChange,
  });

  final Widget leading;
  final String value;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        const HGap.small(),
        Expanded(
          child: Text(
            value,
            style: context.appTypography.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const HGap.small(),
        OutlinedButton(
          onPressed: onChange,
          child: Text(context.l10n.vaultCvDefaultsChange),
        ),
      ],
    );
  }
}
