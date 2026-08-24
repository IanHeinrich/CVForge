import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// Shown only when the Vault is genuinely empty (see [CvVaultEmptiness]).
/// "Load example CV" uses the exact same fixture the golden tests are
/// built on — so this button and a deterministic test fixture are the
/// same mechanism, not two things that can drift apart.
class VaultEmptyState extends StatelessWidget {
  const VaultEmptyState({
    super.key,
    required this.onStartFromScratch,
    required this.onLoadExample,
  });

  final VoidCallback onStartFromScratch;
  final VoidCallback onLoadExample;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: RemixIcons.safe_line,
      title: context.l10n.vaultEmptyTitle,
      message: context.l10n.vaultEmptyBody,
      actions: [
        OutlinedButton(
          onPressed: onLoadExample,
          child: Text(context.l10n.vaultEmptyLoadExample),
        ),
        FilledButton(
          onPressed: onStartFromScratch,
          child: Text(context.l10n.vaultEmptyStartScratch),
        ),
      ],
    );
  }
}
