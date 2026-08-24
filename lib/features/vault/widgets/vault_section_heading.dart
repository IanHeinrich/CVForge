import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// The "SECTION NAME  [+]" row above each list of summary cards.
///
/// The add action is an icon-only button (tooltip carries the full
/// label) rather than a labelled button — the card list column can be
/// narrow (mobile, or the desktop split with the editor panel open), and
/// a text-labelled button here reliably overflowed at those widths.
class VaultSectionHeading extends StatelessWidget {
  const VaultSectionHeading({
    super.key,
    required this.title,
    this.onAdd,
    this.addLabel,
  });

  final String title;
  final VoidCallback? onAdd;

  /// Null means the standard "Add" label — a localized string is not a
  /// compile-time constant, so it cannot be a constructor default.
  final String? addLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.appSpacing.paddingTight),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.appTypography.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onAdd != null)
            IconButton(
              onPressed: onAdd,
              icon: const Icon(
                RemixIcons.add_circle_line,
                color: kcPrimaryColor,
              ),
              tooltip: addLabel ?? context.l10n.commonAdd,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
