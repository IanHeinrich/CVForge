import 'package:cv_forge/features/vault/widgets/document_defaults_row/document_defaults_row.dart';
import 'package:cv_forge/features/vault/widgets/document_defaults_section_list/document_defaults_section_list.dart';
import 'package:cv_forge/features/vault/widgets/document_defaults_value_row/document_defaults_value_row.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/ui/common/l10n/document_language_labels.dart';
import 'package:cv_forge/ui/common/l10n/region_labels.dart';
import 'package:cv_forge/ui/common/l10n/model_labels.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_settings_card/app_settings_card.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../vault_editor_panel_scaffold.dart';

/// Edits what every new CV starts out as — the Vault's one configuration
/// surface, sitting in the same right-hand panel every career-content card
/// opens into.
///
/// One [AppSettingsCard] per setting, which is the frame Settings uses for
/// its own cards: these are the app's two configuration surfaces, and a
/// reader arriving from one should recognise the other. Before that, the
/// four settings were a flat run of label/help/control blobs rendered three
/// different ways, and nothing said which control belonged to which help.
///
/// Region and template each open the shared gallery rather than a control
/// of their own, the same way Studio's per-CV buttons do: both choices
/// carry a page of consequences worth explaining or showing, and one
/// surface with two entry points cannot drift on how it presents them.
/// Language stays a plain dropdown, because choosing one carries neither —
/// the same call `LanguageSettingsCard` makes in Settings. The card frame
/// is what makes the three read as peers; the control does not have to.
class DocumentDefaultsEditorPanel extends StatelessWidget {
  const DocumentDefaultsEditorPanel({
    super.key,
    required this.defaults,
    required this.documentNoun,
    required this.templateId,
    required this.sectionOrder,
    required this.isSectionHidden,
    required this.onClose,
    required this.onChangeRegion,
    required this.onChangeTemplate,
    required this.onLanguageChanged,
    required this.onReorderSections,
    required this.onToggleSectionHidden,
    required this.includeHeadline,
    required this.onToggleHeadline,
    required this.includeWorkAuthorization,
    required this.onToggleWorkAuthorization,
  });

  final DocumentDefaults defaults;

  /// `cv` or `resume` — an ICU `select` branch id, not a display word.
  final String documentNoun;

  /// Resolved by the ViewModel, so this is always a template that exists —
  /// see `VaultViewModel.defaultTemplate`.
  final String templateId;

  final List<CvSectionType> sectionOrder;
  final bool Function(CvSectionType) isSectionHidden;

  final VoidCallback onClose;
  final VoidCallback onChangeRegion;
  final VoidCallback onChangeTemplate;
  final ValueChanged<DocumentLanguage> onLanguageChanged;
  final void Function(int oldIndex, int newIndex) onReorderSections;
  final ValueChanged<CvSectionType> onToggleSectionHidden;

  /// Whether a new CV starts with its headline shown.
  final bool includeHeadline;
  final VoidCallback onToggleHeadline;

  /// Whether a new CV starts with its work-authorisation line shown.
  final bool includeWorkAuthorization;
  final VoidCallback onToggleWorkAuthorization;

  @override
  Widget build(BuildContext context) {
    final region = defaults.region;

    return VaultEditorPanelScaffold(
      title: context.l10n.vaultCvDefaultsPanelTitle(documentNoun),
      onClose: onClose,
      children: [
        Text(
          context.l10n.vaultCvDefaultsPanelBody,
          style: context.appTypography.bodySmall,
        ),
        const VGap.medium(),

        AppSettingsCard(
          title: context.l10n.vaultCvDefaultsRegionLabel,
          body: context.l10n.vaultCvDefaultsRegionHelp,
          children: [
            const VGap.medium(),
            DocumentDefaultsValueRow(
              leading: RegionFlagStack(
                flags: region.preset.flags,
                size: context.appIconSize.large,
              ),
              value: region.displayName(context.l10n),
              onChange: onChangeRegion,
            ),
          ],
        ),
        const VGap.medium(),

        AppSettingsCard(
          title: context.l10n.vaultCvDefaultsLanguageLabel,
          body: context.l10n.vaultCvDefaultsLanguageHelp,
          children: [
            const VGap.medium(),
            DropdownButtonFormField<DocumentLanguage>(
              initialValue: defaults.language,
              isExpanded: true,
              items: [
                for (final language in DocumentLanguage.values)
                  DropdownMenuItem(
                    value: language,
                    child: Text(language.displayLabel(context.l10n)),
                  ),
              ],
              onChanged: (language) {
                if (language != null) onLanguageChanged(language);
              },
            ),
          ],
        ),
        const VGap.medium(),

        AppSettingsCard(
          title: context.l10n.vaultCvDefaultsTemplateLabel,
          body: context.l10n.vaultCvDefaultsTemplateHelp,
          children: [
            const VGap.medium(),
            DocumentDefaultsValueRow(
              leading: Icon(
                RemixIcons.layout_2_line,
                size: context.appIconSize.large,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              value: templateDisplayName(context.l10n, templateId),
              onChange: onChangeTemplate,
            ),
          ],
        ),
        const VGap.medium(),

        AppSettingsCard(
          title: context.l10n.vaultCvDefaultsSectionsLabel,
          body: context.l10n.vaultCvDefaultsSectionsHelp,
          children: [
            const VGap.medium(),
            // Pinned above the list and outside it, exactly as Studio's
            // own section nav pins these two rows: both print in the name
            // block, so neither has a position to drag to.
            DocumentDefaultsRow(
              label: context.l10n.vaultCvDefaultsHeadline,
              included: includeHeadline,
              onToggle: onToggleHeadline,
            ),
            DocumentDefaultsRow(
              label: context.l10n.vaultCvDefaultsWorkAuthorization,
              included: includeWorkAuthorization,
              onToggle: onToggleWorkAuthorization,
            ),
            DocumentDefaultsSectionList(
              sectionOrder: sectionOrder,
              isSectionHidden: isSectionHidden,
              onReorder: onReorderSections,
              onToggleHidden: onToggleSectionHidden,
            ),
          ],
        ),
      ],
    );
  }
}
