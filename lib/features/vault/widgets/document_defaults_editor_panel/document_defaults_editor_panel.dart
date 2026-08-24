import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/ui/common/l10n/document_language_labels.dart';
import 'package:cv_forge/ui/common/l10n/region_labels.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:flutter/material.dart';

import '../vault_editor_panel_scaffold.dart';

/// Edits what every new CV starts out as — the Vault's one configuration
/// surface, sitting in the same right-hand panel every career-content card
/// opens into.
///
/// Region opens the shared gallery rather than a control of its own, the
/// same way Studio's per-CV region button does: choosing a market carries
/// a page of consequences worth explaining, and one surface with two entry
/// points cannot drift on how it explains them. Language is a plain
/// dropdown, because choosing one carries none.
class DocumentDefaultsEditorPanel extends StatelessWidget {
  const DocumentDefaultsEditorPanel({
    super.key,
    required this.defaults,
    required this.documentNoun,
    required this.onClose,
    required this.onChangeRegion,
    required this.onLanguageChanged,
  });

  final DocumentDefaults defaults;

  /// `cv` or `resume` — an ICU `select` branch id, not a display word.
  final String documentNoun;

  final VoidCallback onClose;
  final VoidCallback onChangeRegion;
  final ValueChanged<DocumentLanguage> onLanguageChanged;

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

        _FieldLabel(
          label: context.l10n.vaultCvDefaultsRegionLabel,
          help: context.l10n.vaultCvDefaultsRegionHelp,
        ),
        const VGap.tiny(),
        Row(
          children: [
            RegionFlagStack(
              flags: region.preset.flags,
              size: context.appIconSize.large,
            ),
            HGap.small(),
            Expanded(
              child: Text(
                region.displayName(context.l10n),
                style: context.appTypography.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            HGap.small(),
            OutlinedButton(
              onPressed: onChangeRegion,
              child: Text(context.l10n.vaultCvDefaultsChange),
            ),
          ],
        ),
        const VGap.medium(),

        _FieldLabel(
          label: context.l10n.vaultCvDefaultsLanguageLabel,
          help: context.l10n.vaultCvDefaultsLanguageHelp,
        ),
        const VGap.tiny(),
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
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.help});

  final String label;
  final String help;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.appTypography.titleSmall),
        Text(
          help,
          style: context.appTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
