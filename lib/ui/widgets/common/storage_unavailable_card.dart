import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// Shown wherever a load from local storage genuinely failed — e.g.
/// Firefox strict-privacy mode or private browsing, where IndexedDB is
/// unavailable. Explains the problem in plain English and offers a retry
/// rather than a dead end or a raw exception. Shared by `StartupView` (the
/// initial boot) and `VaultView`/`StudioView` (a deep-link or refresh that
/// bypasses `StartupView` and loads on its own account) so the message and
/// the recovery path stay identical regardless of where the failure
/// actually surfaces.
class StorageUnavailableCard extends StatelessWidget {
  const StorageUnavailableCard({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            RemixIcons.error_warning_line,
            color: kcLightGrey,
            size: 40,
          ),
          verticalSpaceMedium,
          const Text(
            "CVForge couldn't load your data",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kcWhite,
            ),
          ),
          verticalSpaceSmall,
          const Text(
            'Local storage is unavailable in this browser or browsing '
            'mode. CVForge keeps everything on your device, so it needs '
            'access to it to work. Try a normal (non-private) browsing '
            'window, or a different browser.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kcLightGrey),
          ),
          verticalSpaceMedium,
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
