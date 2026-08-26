import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/studio_field_override_card.dart';

/// The work-authorization editor — the optional line under the contact
/// details, e.g. "Right to work in the UK, no sponsorship required".
///
/// Structurally the headline's twin (see [HeadlineEditor]), and its own
/// editor for the same reason: it prints in the header rather than as a
/// section, so it has no position in the reorderable list, and whether it
/// appears is independent of everything around it. It is not a
/// [CvSectionType] — see [StudioViewModel.openHeaderField].
///
/// Being tailorable per draft is the point rather than a bonus. The line
/// is worth printing on a cross-border application and worth dropping on
/// a domestic one, and the Vault holds one sentence for both.
class WorkAuthorizationEditor extends StatelessWidget {
  const WorkAuthorizationEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudioFieldOverrideCard(
          key: const ValueKey('studio_work_authorization_editor'),
          label: context.l10n.studioSectionWorkAuthorization,
          vaultValue: viewModel.vaultWorkAuthorization,
          hasOverride: viewModel.hasWorkAuthorizationOverride,
          effectiveValue: viewModel.workAuthorizationText,
          onChanged: viewModel.setWorkAuthorizationOverride,
          onRevert: viewModel.revertWorkAuthorizationToVault,
          emptyVaultMessage: context.l10n.studioNoWorkAuthorization,
        ),
      ],
    );
  }
}
