import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
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
        AppTextField(
          label: 'Full name',
          initialValue: basics.fullName,
          onChanged: (v) => onChanged(basics.copyWith(fullName: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Headline',
          hint: 'e.g. Senior Software Engineer',
          initialValue: basics.headline,
          onChanged: (v) => onChanged(basics.copyWith(headline: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Email',
          initialValue: basics.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => onChanged(basics.copyWith(email: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Phone',
          initialValue: basics.phone,
          keyboardType: TextInputType.phone,
          onChanged: (v) => onChanged(basics.copyWith(phone: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Location',
          initialValue: basics.location,
          onChanged: (v) => onChanged(basics.copyWith(location: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Professional summary',
          initialValue: basics.summary ?? '',
          maxLines: 4,
          onChanged: (v) =>
              onChanged(basics.copyWith(summary: v.isEmpty ? null : v)),
        ),
        const VGap.medium(),
        VaultSectionHeading(title: 'Links', onAdd: onAddLink),
        for (final link in basics.links)
          Padding(
            padding: EdgeInsets.only(bottom: context.appSpacing.paddingTight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Label',
                    hint: 'e.g. LinkedIn',
                    initialValue: link.label,
                    onChanged: (v) => onLinkChanged(link.copyWith(label: v)),
                  ),
                ),
                const HGap.small(),
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    label: 'URL',
                    initialValue: link.url,
                    onChanged: (v) => onLinkChanged(link.copyWith(url: v)),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    RemixIcons.delete_bin_line,
                    color: kcLightGrey,
                  ),
                  onPressed: () => onLinkDeleted(link.id),
                  tooltip: 'Delete link',
                ),
              ],
            ),
          ),
        const VGap.medium(),
        AppTextField(
          label: 'References',
          hint: 'e.g. "Available on request."',
          initialValue: referencesNote ?? '',
          onChanged: (v) => onReferencesChanged(v.isEmpty ? null : v),
        ),
      ],
    );
  }
}
