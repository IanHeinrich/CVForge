import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kdPaddingPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.design_services_outlined,
              size: 48,
              color: kcLightGrey,
            ),
            verticalSpaceMedium,
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kcWhite,
              ),
            ),
            verticalSpaceSmall,
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kcLightGrey),
            ),
            verticalSpaceMedium,
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
