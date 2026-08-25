import 'package:cv_forge/ui/common/l10n/language_proficiency_labels.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';
import 'package:cv_forge/features/studio/widgets/vault_item_selector_list.dart';

/// The [CvSectionType.languages] editor.
///
/// Only the language's name is tailorable. Its level is a CEFR band —
/// a code with a fixed meaning, not wording — so there is nothing here a
/// per-CV rewrite could honestly change; the Vault is where a level is
/// corrected. See `LanguageProficiency`.
class LanguagesSectionEditor extends StatelessWidget {
  const LanguagesSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VaultItemSelectorList(
      title: context.l10n.vaultLanguagesTitle,
      unselectedCount: viewModel.unselectedLanguages.length,
      selectedCount: viewModel.selectedLanguages.length,
      onAddAll: viewModel.addAllLanguages,
      onRemoveAll: viewModel.removeAllLanguages,
      items: [
        for (final language in viewModel.languages)
          SelectorItem(
            id: language.id,
            title: viewModel.languageName(language),
            subtitle: language.proficiency?.displayLabel(context.l10n),
            selected: viewModel.isLanguageIncluded(language.id),
            onToggle: () => viewModel.toggleLanguage(language),
            titleField: TailorableField(
              hasOverride: viewModel.hasLanguageOverride(language.id),
              effectiveText: viewModel.languageName(language),
              vaultText: language.name,
              onChanged: (value) =>
                  viewModel.setLanguageOverride(language, value),
              onRevert: () => viewModel.revertLanguageOverride(language.id),
            ),
          ),
      ],
    );
  }
}
