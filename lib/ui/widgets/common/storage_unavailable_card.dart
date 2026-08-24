import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
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
    return AppEmptyState(
      icon: RemixIcons.error_warning_line,
      title: context.l10n.chromeStorageUnavailableTitle,
      message: context.l10n.chromeStorageUnavailableBody,
      actions: [
        FilledButton(
          onPressed: onRetry,
          child: Text(context.l10n.commonTryAgain),
        ),
      ],
    );
  }
}
