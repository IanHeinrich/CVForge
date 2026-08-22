import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';
import 'package:cv_forge/features/studio/widgets/vault_item_selector_list.dart';

/// The [CvSectionType.publications] editor.
class PublicationsSectionEditor extends StatelessWidget {
  const PublicationsSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VaultItemSelectorList(
      title: 'Publications',
      unselectedCount: viewModel.unselectedPublications.length,
      onAddAll: viewModel.addAllPublications,
      items: [
        for (final publication in viewModel.publications)
          SelectorItem(
            id: publication.id,
            title: publication.title.isEmpty
                ? 'Untitled publication'
                : publication.title,
            subtitle: publication.citation,
            selected: viewModel.isPublicationIncluded(publication.id),
            onToggle: () => viewModel.togglePublication(publication),
            onAddAllBullets: () =>
                viewModel.addAllPublicationBullets(publication),
            bullets: [
              for (final bullet in publication.bullets)
                SelectorItem(
                  id: bullet.id,
                  title: bulletTitle(
                    bullet.label,
                    viewModel.bulletText(bullet),
                  ),
                  selected: viewModel.isPublicationBulletIncluded(
                    publication.id,
                    bullet.id,
                  ),
                  onToggle: () =>
                      viewModel.togglePublicationBullet(publication, bullet),
                  tailorable: TailorableField(
                    hasOverride: viewModel.hasBulletOverride(bullet.id),
                    effectiveText: viewModel.bulletText(bullet),
                    fieldLabel: bullet.label,
                    onChanged: (value) =>
                        viewModel.setBulletOverride(bullet, value),
                    onRevert: () => viewModel.revertBulletOverride(bullet.id),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
