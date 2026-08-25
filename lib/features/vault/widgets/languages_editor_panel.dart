import 'package:cv_forge/models/vault/language_item.dart';
import 'package:cv_forge/models/vault/language_proficiency.dart';
import 'package:cv_forge/ui/common/l10n/language_proficiency_labels.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'package:cv_forge/ui/widgets/common/app_delete_icon_button/app_delete_icon_button.dart';
import 'package:cv_forge/ui/widgets/common/app_inline_empty_message/app_inline_empty_message.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

/// The languages a person speaks, each with an optional CEFR level.
///
/// Two controls per row rather than the hobbies panel's one, which is why
/// each row wraps: at the narrow end of the editor panel a name field and
/// a level picker do not fit side by side, and squeezing them makes the
/// name unreadable in the field it is being typed into.
class LanguagesEditorPanel extends StatelessWidget {
  const LanguagesEditorPanel({
    super.key,
    required this.languages,
    required this.onClose,
    required this.onAdd,
    required this.onChanged,
    required this.onDelete,
  });

  final List<LanguageItem> languages;
  final VoidCallback onClose;
  final VoidCallback onAdd;
  final ValueChanged<LanguageItem> onChanged;
  final ValueChanged<String> onDelete;

  /// Below this the name field and the level picker stack instead of
  /// sitting side by side.
  static const _sideBySideMinWidth = 380.0;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: context.l10n.vaultLanguagesTitle,
      onClose: onClose,
      children: [
        VaultSectionHeading(
          title: context.l10n.vaultLanguagesItems,
          onAdd: onAdd,
        ),
        if (languages.isEmpty)
          AppInlineEmptyMessage(context.l10n.vaultLanguagesEmptyShort),
        for (final language in languages)
          Padding(
            padding: EdgeInsets.only(bottom: context.appSpacing.paddingTight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final name = _nameField(context, language);
                      final level = _levelField(context, language);
                      if (constraints.maxWidth < _sideBySideMinWidth) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            name,
                            SizedBox(height: context.appSpacing.gapTiny),
                            level,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: name),
                          SizedBox(width: context.appSpacing.gapSmall),
                          Expanded(child: level),
                        ],
                      );
                    },
                  ),
                ),
                AppDeleteIconButton(
                  tooltip: context.l10n.vaultLanguagesDeleteLanguage,
                  onPressed: () => onDelete(language.id),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _nameField(BuildContext context, LanguageItem language) =>
      AppTextField(
        label: context.l10n.vaultLanguageName,
        hint: context.l10n.vaultLanguageNameHint,
        initialValue: language.name,
        markup: true,
        onChanged: (v) => onChanged(language.copyWith(name: v)),
      );

  Widget _levelField(BuildContext context, LanguageItem language) =>
      DropdownButtonFormField<LanguageProficiency?>(
        initialValue: language.proficiency,
        isExpanded: true,
        decoration: InputDecoration(
          isDense: true,
          labelText: context.l10n.vaultLanguageLevel,
        ),
        items: [
          // Ungraded is a real answer, not an absence — someone listing a
          // language without claiming a band prints just the language.
          DropdownMenuItem(child: Text(context.l10n.vaultLanguageLevelUnset)),
          for (final level in LanguageProficiency.values)
            DropdownMenuItem(
              value: level,
              child: Text(level.displayLabel(context.l10n)),
            ),
        ],
        // A fresh instance rather than copyWith: freezed cannot tell
        // "set this back to null" from "leave it alone", and clearing a
        // level back to unspecified has to be possible.
        onChanged: (level) => onChanged(
          LanguageItem(
            id: language.id,
            name: language.name,
            proficiency: level,
          ),
        ),
      );
}
