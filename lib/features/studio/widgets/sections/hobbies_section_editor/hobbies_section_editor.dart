import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/vault_item_selector_list.dart';

/// The [CvSectionType.hobbies] editor.
class HobbiesSectionEditor extends StatelessWidget {
  const HobbiesSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VaultItemSelectorList(
      title: context.l10n.vaultHobbiesTitle,
      unselectedCount: viewModel.unselectedHobbies.length,
      selectedCount: viewModel.selectedHobbies.length,
      onAddAll: viewModel.addAllHobbies,
      onRemoveAll: viewModel.removeAllHobbies,
      items: [
        for (final hobby in viewModel.hobbies)
          SelectorItem(
            id: hobby.id,
            title: hobby.text,
            selected: viewModel.isHobbyIncluded(hobby.id),
            onToggle: () => viewModel.toggleHobby(hobby),
          ),
      ],
    );
  }
}
