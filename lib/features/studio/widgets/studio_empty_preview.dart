import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

/// The "nothing to preview yet" placeholder shown until the Studio has
/// real content to render.
class StudioEmptyPreview extends StatelessWidget {
  const StudioEmptyPreview({super.key});

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
            const Text(
              'Nothing to preview yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kcWhite,
              ),
            ),
            verticalSpaceSmall,
            const Text(
              'Add something to your Vault, then come back to build a CV.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kcLightGrey),
            ),
          ],
        ),
      ),
    );
  }
}
