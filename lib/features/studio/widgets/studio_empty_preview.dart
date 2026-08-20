import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// The "nothing to preview yet" placeholder — shown both when the Vault
/// itself is empty and when it has data but none of it is included in
/// this draft (see `StudioPreviewState`). [title]/[message]/[actionLabel]
/// differ between those two cases so the copy can point at the actual
/// problem instead of a generic "add something to your Vault" that's
/// wrong half the time.
class StudioEmptyPreview extends StatelessWidget {
  const StudioEmptyPreview({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: RemixIcons.quill_pen_line,
      title: title,
      message: message,
      actions: [FilledButton(onPressed: onAction, child: Text(actionLabel))],
    );
  }
}
