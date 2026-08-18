import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'vault_text_field.dart';

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
  });

  final ContactBasics basics;
  final String? referencesNote;
  final VoidCallback onClose;
  final ValueChanged<ContactBasics> onChanged;
  final ValueChanged<String?> onReferencesChanged;
  final VoidCallback onAddLink;
  final ValueChanged<ProfileLink> onLinkChanged;
  final ValueChanged<String> onLinkDeleted;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: 'Basics',
      onClose: onClose,
      children: [
        VaultTextField(
          label: 'Full name',
          initialValue: basics.fullName,
          onChanged: (v) => onChanged(basics.copyWith(fullName: v)),
        ),
        verticalSpaceSmall,
        VaultTextField(
          label: 'Headline',
          hint: 'e.g. Senior Software Engineer',
          initialValue: basics.headline,
          onChanged: (v) => onChanged(basics.copyWith(headline: v)),
        ),
        verticalSpaceSmall,
        VaultTextField(
          label: 'Email',
          initialValue: basics.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => onChanged(basics.copyWith(email: v)),
        ),
        verticalSpaceSmall,
        VaultTextField(
          label: 'Phone',
          initialValue: basics.phone,
          keyboardType: TextInputType.phone,
          onChanged: (v) => onChanged(basics.copyWith(phone: v)),
        ),
        verticalSpaceSmall,
        VaultTextField(
          label: 'Location',
          initialValue: basics.location,
          onChanged: (v) => onChanged(basics.copyWith(location: v)),
        ),
        verticalSpaceSmall,
        VaultTextField(
          label: 'Professional summary',
          initialValue: basics.summary ?? '',
          maxLines: 4,
          onChanged: (v) =>
              onChanged(basics.copyWith(summary: v.isEmpty ? null : v)),
        ),
        verticalSpaceMedium,
        VaultSectionHeading(title: 'Links', onAdd: onAddLink),
        for (final link in basics.links)
          Padding(
            padding: const EdgeInsets.only(bottom: kdPaddingTight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: VaultTextField(
                    label: 'Label',
                    hint: 'e.g. LinkedIn',
                    initialValue: link.label,
                    onChanged: (v) => onLinkChanged(link.copyWith(label: v)),
                  ),
                ),
                horizontalSpaceSmall,
                Expanded(
                  flex: 2,
                  child: VaultTextField(
                    label: 'URL',
                    initialValue: link.url,
                    onChanged: (v) => onLinkChanged(link.copyWith(url: v)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: kcLightGrey),
                  onPressed: () => onLinkDeleted(link.id),
                  tooltip: 'Delete link',
                ),
              ],
            ),
          ),
        verticalSpaceMedium,
        VaultTextField(
          label: 'References',
          hint: 'e.g. "Available on request."',
          initialValue: referencesNote ?? '',
          onChanged: (v) => onReferencesChanged(v.isEmpty ? null : v),
        ),
      ],
    );
  }
}
