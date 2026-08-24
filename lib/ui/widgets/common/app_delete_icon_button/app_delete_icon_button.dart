import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// The delete-bin icon button repeated across every Vault editor row
/// (basics links, bullets, hobbies, skills) and `AppSummaryCard`'s own
/// delete action — one widget instead of five copies of the same icon,
/// color and tooltip.
class AppDeleteIconButton extends StatelessWidget {
  const AppDeleteIconButton({super.key, required this.onPressed, this.tooltip});

  final VoidCallback onPressed;

  /// Null means the standard "Delete" label. Resolved in [build] rather
  /// than defaulted here, because a localized string is not a compile-time
  /// constant and this widget has a `const` constructor.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        RemixIcons.delete_bin_line,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: onPressed,
      tooltip: tooltip ?? context.l10n.commonDelete,
    );
  }
}
