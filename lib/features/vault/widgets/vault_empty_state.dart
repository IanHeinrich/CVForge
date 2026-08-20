import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
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
      title: 'Your Vault is empty',
      message:
          'Add your work history, skills, and education here — this is '
          'your master record, separate from any CV you export.',
      actions: [
        OutlinedButton(
          onPressed: onLoadExample,
          child: const Text('Load example CV'),
        ),
        FilledButton(
          onPressed: onStartFromScratch,
          child: const Text('Start from scratch'),
        ),
      ],
    );
  }
}
