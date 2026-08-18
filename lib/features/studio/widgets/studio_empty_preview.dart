import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

/// The "nothing to preview yet" placeholder shown until the Studio has
/// real content to render. [compact] tightens icon/text sizing and wraps
/// in horizontal padding for the mobile breakpoint; desktop and tablet
/// use the default sizing.
class StudioEmptyPreview extends StatelessWidget {
  const StudioEmptyPreview({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.design_services_outlined,
          size: compact ? 40 : 48,
          color: kcLightGrey,
        ),
        verticalSpaceMedium,
        Text(
          'Nothing to preview yet',
          textAlign: compact ? TextAlign.center : null,
          style: TextStyle(
            fontSize: compact ? 20 : 22,
            fontWeight: FontWeight.w700,
            color: kcWhite,
          ),
        ),
        verticalSpaceSmall,
        Text(
          'Add something to your Vault, then come back to build a CV.',
          textAlign: compact ? TextAlign.center : null,
          style: const TextStyle(color: kcLightGrey),
        ),
      ],
    );

    return Center(
      child: compact
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: kdPaddingPage),
              child: content,
            )
          : content,
    );
  }
}
