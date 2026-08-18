import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

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
    this.addLabel = 'Add',
  });

  final String title;
  final VoidCallback? onAdd;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: kcWhite,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onAdd != null)
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline, color: kcPrimaryColor),
              tooltip: addLabel,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
