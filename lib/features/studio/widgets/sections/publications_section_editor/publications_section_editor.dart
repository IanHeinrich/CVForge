import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/sections/entity_bullet_section_editor.dart';
import 'package:cv_forge/models/draft/draft_omittable_field.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';

/// The [CvSectionType.publications] editor.
///
/// Title, citation and bullets are all editable per CV; only the link is
/// Vault-sourced, since a link that goes somewhere other than the real
/// page is the one thing a reader can't work around. Note that title and
/// citation are deliberately excluded from the translation pass even
/// though they're overridable here — see `CvDraft`'s override-layer doc.
class PublicationsSectionEditor extends StatelessWidget {
  const PublicationsSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) => EntityBulletSectionEditor(
    title: context.l10n.vaultSectionPublications,
    items: viewModel.publications,
    untitledLabel: context.l10n.vaultUntitledPublication,
    idOf: (p) => p.id,
    titleOf: viewModel.publicationTitleText,
    // The citation is a field row, not a subtitle — see the same call in
    // `ProjectsSectionEditor` for why an inert subtitle was the problem.
    subtitleOf: (p) => null,
    bulletsOf: (p) => p.bullets,
    unselectedCount: viewModel.unselectedPublications.length,
    selectedCount: viewModel.selectedPublications.length,
    onAddAll: viewModel.addAllPublications,
    onRemoveAll: viewModel.removeAllPublications,
    isIncluded: (p) => viewModel.isPublicationIncluded(p.id),
    onToggle: viewModel.togglePublication,
    onAddAllBullets: viewModel.addAllPublicationBullets,
    onRemoveAllBullets: viewModel.removeAllPublicationBullets,
    isBulletIncluded: (p, b) =>
        viewModel.isPublicationBulletIncluded(p.id, b.id),
    onToggleBullet: viewModel.togglePublicationBullet,
    bulletText: viewModel.bulletText,
    hasBulletOverride: viewModel.hasBulletOverride,
    onSetBulletOverride: viewModel.setBulletOverride,
    onRevertBulletOverride: viewModel.revertBulletOverride,
    titleFieldOf: (p) => TailorableField(
      hasOverride: viewModel.hasPublicationTitleOverride(p.id),
      effectiveText: viewModel.publicationTitleText(p),
      fieldLabel: context.l10n.studioFieldPublicationTitle,
      onChanged: (value) => viewModel.setPublicationTitleOverride(p, value),
      onRevert: () => viewModel.revertPublicationTitleOverride(p.id),
    ),
    fieldsOf: (p) => [
      TailorableField(
        hasOverride: viewModel.hasPublicationCitationOverride(p.id),
        effectiveText: viewModel.publicationCitationText(p),
        fieldLabel: context.l10n.studioFieldCitation,
        emptyMessage: context.l10n.studioNoCitation,
        onChanged: (value) =>
            viewModel.setPublicationCitationOverride(p, value),
        onRevert: () => viewModel.revertPublicationCitationOverride(p.id),
      ),
      VaultOnlyField(
        fieldLabel: context.l10n.studioFieldLink,
        value: p.link ?? '',
        reason: context.l10n.studioLockedFromVault,
        omitted: viewModel.isFieldOmitted(
          DraftOmittableField.publicationLink,
          p.id,
        ),
        onToggleOmitted: () => viewModel.toggleFieldOmitted(
          DraftOmittableField.publicationLink,
          p.id,
        ),
      ),
    ],
  );
}
