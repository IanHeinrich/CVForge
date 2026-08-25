import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'photo_editor_field/photo_editor_field.dart';
import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'package:cv_forge/ui/widgets/common/app_delete_icon_button/app_delete_icon_button.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

class BasicsEditorPanel extends StatelessWidget {
  const BasicsEditorPanel({
    super.key,
    required this.basics,
    required this.referencesNote,
    required this.onClose,
    required this.onChanged,
    required this.onReferencesChanged,
    required this.onAddLink,
    required this.onLinkChanged,
    required this.onLinkDeleted,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    this.photoBusy = false,
    this.photoError,
  });

  final ContactBasics basics;
  final String? referencesNote;
  final VoidCallback onClose;
  final ValueChanged<ContactBasics> onChanged;
  final ValueChanged<String?> onReferencesChanged;
  final VoidCallback onAddLink;
  final ValueChanged<ProfileLink> onLinkChanged;
  final ValueChanged<String> onLinkDeleted;

  /// The photo has its own pair of callbacks rather than going through
  /// [onChanged] because picking one is asynchronous and opens a dialog —
  /// see [PhotoEditorField].
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;
  final bool photoBusy;
  final String? photoError;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: context.l10n.vaultBasicsTitle,
      onClose: onClose,
      children: [
        PhotoEditorField(
          photo: basics.photo,
          onPick: onPickPhoto,
          onRemove: onRemovePhoto,
          busy: photoBusy,
          errorText: photoError,
        ),
        const VGap.medium(),
        AppTextField(
          label: context.l10n.vaultBasicsFullName,
          initialValue: basics.fullName,
          onChanged: (v) => onChanged(basics.copyWith(fullName: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultBasicsHeadline,
          hint: context.l10n.vaultBasicsHeadlineHint,
          initialValue: basics.headline,
          markup: true,
          onChanged: (v) => onChanged(basics.copyWith(headline: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultBasicsEmail,
          initialValue: basics.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => onChanged(basics.copyWith(email: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultBasicsPhone,
          initialValue: basics.phone,
          keyboardType: TextInputType.phone,
          onChanged: (v) => onChanged(basics.copyWith(phone: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultBasicsLocation,
          initialValue: basics.location,
          onChanged: (v) => onChanged(basics.copyWith(location: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultBasicsWorkAuthorization,
          hint: context.l10n.vaultBasicsWorkAuthorizationHint,
          initialValue: basics.workAuthorization ?? '',
          markup: true,
          onChanged: (v) => onChanged(
            basics.copyWith(workAuthorization: v.isEmpty ? null : v),
          ),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultBasicsSummary,
          initialValue: basics.summary ?? '',
          markup: true,
          maxLines: 4,
          onChanged: (v) =>
              onChanged(basics.copyWith(summary: v.orNullIfEmpty)),
        ),
        const VGap.medium(),
        VaultSectionHeading(
          title: context.l10n.vaultBasicsLinks,
          onAdd: onAddLink,
        ),
        for (final link in basics.links)
          Padding(
            padding: EdgeInsets.only(bottom: context.appSpacing.paddingTight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: context.l10n.vaultBasicsLinkLabel,
                    hint: context.l10n.vaultBasicsLinkLabelHint,
                    initialValue: link.label,
                    onChanged: (v) => onLinkChanged(link.copyWith(label: v)),
                  ),
                ),
                const HGap.small(),
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    label: context.l10n.vaultBasicsLinkUrl,
                    initialValue: link.url,
                    onChanged: (v) => onLinkChanged(link.copyWith(url: v)),
                  ),
                ),
                AppDeleteIconButton(
                  tooltip: context.l10n.vaultBasicsDeleteLink,
                  onPressed: () => onLinkDeleted(link.id),
                ),
              ],
            ),
          ),
        const VGap.medium(),
        AppTextField(
          label: context.l10n.vaultBasicsReferences,
          hint: context.l10n.vaultBasicsReferencesHint,
          initialValue: referencesNote ?? '',
          markup: true,
          onChanged: (v) => onReferencesChanged(v.orNullIfEmpty),
        ),
      ],
    );
  }
}
