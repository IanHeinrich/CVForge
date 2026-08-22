import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'bullet_list_editor.dart';
import 'vault_editor_panel_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

class PublicationEditorPanel extends StatelessWidget {
  const PublicationEditorPanel({
    super.key,
    required this.publication,
    required this.skillCategories,
    required this.onClose,
    required this.onChanged,
    required this.bulletCallbacks,
  });

  final Publication publication;
  final List<SkillCategory> skillCategories;
  final VoidCallback onClose;
  final ValueChanged<Publication> onChanged;
  final BulletEditorCallbacks bulletCallbacks;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: publication.title.isEmpty ? 'New publication' : publication.title,
      onClose: onClose,
      children: [
        AppTextField(
          label: 'Title',
          hint: 'e.g. Community resistance in Doña Juana',
          initialValue: publication.title,
          maxLines: 3,
          onChanged: (v) => onChanged(publication.copyWith(title: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Citation (optional)',
          hint: 'e.g. Trujillo, L. (2021). Journal Name, 11(2), 194–206.',
          initialValue: publication.citation ?? '',
          maxLines: 3,
          onChanged: (v) =>
              onChanged(publication.copyWith(citation: v.orNullIfEmpty)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Link (optional)',
          hint: 'e.g. doi.org/10.1234/example',
          initialValue: publication.link ?? '',
          onChanged: (v) =>
              onChanged(publication.copyWith(link: v.orNullIfEmpty)),
        ),
        const VGap.medium(),
        BulletListEditor(
          bullets: publication.bullets,
          skillCategories: skillCategories,
          callbacks: bulletCallbacks,
        ),
      ],
    );
  }
}
