import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// One row of the CV-defaults list — an "include by default" checkbox, a
/// label, and a drag handle when the row has somewhere to be dragged to.
///
/// Shared by [DocumentDefaultsSectionList] and by the pinned headline row
/// the panel puts above it, so the one row that cannot be reordered still
/// looks like the rest of the list rather than something bolted on.
/// [dragIndex] is null for that row, which is what drops the handle.
///
/// Same arrangement as `StudioSectionNav`'s `_NavRow`, which answers the
/// per-draft version of this question — see
/// [DocumentDefaultsSectionList]'s class doc for why the two lists are not
/// one widget.
class DocumentDefaultsRow extends StatelessWidget {
  const DocumentDefaultsRow({
    super.key,
    required this.label,
    required this.included,
    required this.onToggle,
    this.dragIndex,
  });

  final String label;
  final bool included;
  final VoidCallback onToggle;
  final int? dragIndex;

  @override
  Widget build(BuildContext context) {
    final index = dragIndex;
    return Row(
      children: [
        // Matches Studio's own section list: the compact density is what
        // lets the longest labels sit on one line.
        Checkbox(
          value: included,
          onChanged: (_) => onToggle(),
          activeColor: Theme.of(context).colorScheme.primary,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Text(
            label,
            style: context.appTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (index != null)
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsetsDirectional.all(context.appSpacing.gapTiny),
              child: Icon(
                RemixIcons.draggable,
                size: context.appIconSize.tiny,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
