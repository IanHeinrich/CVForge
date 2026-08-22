import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// A collapsed entity summary card — tapping it opens an editor, a preview,
/// or drills into whatever [onTap] represents. Shared by every Vault
/// section (basics, one per experience, one per education entry, skills,
/// hobbies) and by the Drafts list, so they all read as one system.
class AppSummaryCard extends StatelessWidget {
  const AppSummaryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.notes,
    required this.onTap,
    this.selected = false,
    this.onDelete,
    this.leading,
    this.actions,
  });

  final String title;
  final String? subtitle;

  /// An optional third line, rendered italic beneath [subtitle] when
  /// non-empty — free-text user notes rather than a computed summary.
  final String? notes;
  final VoidCallback onTap;
  final bool selected;
  final VoidCallback? onDelete;
  final Widget? leading;

  /// Trailing controls shown instead of the single delete icon that
  /// [onDelete] renders — for a card with more than one action (edit,
  /// duplicate, delete). Ignored if set alongside [onDelete].
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: context.appSpacing.paddingTight),
      color: selected
          ? Theme.of(context).colorScheme.surfaceContainerHigh
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.appRadius.medium),
        onTap: onTap,
        child: Container(
          // A left accent edge reads as "selected" without turning the
          // whole card purple, now that a real surface ramp sits under it.
          decoration: selected
              ? const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: kcPrimaryColor, width: 2),
                  ),
                )
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: context.appSpacing.paddingDefault,
            vertical: 14,
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const HGap.small()],
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
                      const VGap.tiny(),
                      Text(
                        subtitle!,
                        style: context.appTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (notes != null && notes!.isNotEmpty) ...[
                      const VGap.tiny(),
                      Text(
                        notes!,
                        style: context.appTypography.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null)
                ...actions!
              else if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    RemixIcons.delete_bin_line,
                    color: kcLightGrey,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
