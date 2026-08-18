import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

/// A collapsed entity summary — tapping it opens the right-hand editor
/// panel. Shared by every Vault section (basics, one per experience, one
/// per education entry, skills, hobbies) so they all read as one system.
class VaultSummaryCard extends StatelessWidget {
  const VaultSummaryCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.selected = false,
    this.onDelete,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool selected;
  final VoidCallback? onDelete;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: kdPaddingTight),
      color: selected ? kcPrimaryColorDark : kcDarkGreyColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: selected
            ? const BorderSide(color: kcPrimaryColor)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kdPaddingDefault,
            vertical: 14,
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, horizontalSpaceSmall],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: kcWhite,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      verticalSpaceTiny,
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: kcLightGrey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: kcLightGrey),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              const Icon(Icons.chevron_right, color: kcLightGrey),
            ],
          ),
        ),
      ),
    );
  }
}
