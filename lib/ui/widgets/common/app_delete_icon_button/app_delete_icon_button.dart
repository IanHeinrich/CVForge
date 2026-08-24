import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// The delete-bin icon button repeated across every Vault editor row
/// (basics links, bullets, hobbies, skills) and `AppSummaryCard`'s own
/// delete action — one widget instead of five copies of the same icon,
/// color and tooltip.
class AppDeleteIconButton extends StatelessWidget {
  const AppDeleteIconButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Delete',
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        RemixIcons.delete_bin_line,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
