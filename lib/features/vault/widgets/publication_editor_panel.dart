import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'bullet_list_editor.dart';
import 'vault_editor_panel_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

class PublicationEditorPanel extends StatelessWidget {
  const PublicationEditorPanel({
    super.key,
    required this.publication,
    required this.skillCategories,
    required this.onUpdateSkill,
    required this.onAddSkill,
    required this.onAddCategory,
    required this.onClose,
    required this.onChanged,
    required this.bulletCallbacks,
  });

  final Publication publication;
  final List<SkillCategory> skillCategories;
  final void Function(String categoryId, Skill skill) onUpdateSkill;
  final Future<Skill> Function(String categoryId, String label) onAddSkill;
  final Future<SkillCategory> Function(String name) onAddCategory;
  final VoidCallback onClose;
  final ValueChanged<Publication> onChanged;
  final BulletEditorCallbacks bulletCallbacks;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: publication.title.isEmpty
          ? context.l10n.vaultPublicationNew
          : publication.title,
      onClose: onClose,
      children: [
        AppTextField(
          label: context.l10n.vaultPublicationTitle,
          hint: context.l10n.vaultPublicationTitleHint,
          initialValue: publication.title,
          markup: true,
          maxLines: 3,
          onChanged: (v) => onChanged(publication.copyWith(title: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultPublicationCitation,
          hint: context.l10n.vaultPublicationCitationHint,
          initialValue: publication.citation ?? '',
          markup: true,
          maxLines: 3,
          onChanged: (v) =>
              onChanged(publication.copyWith(citation: v.orNullIfEmpty)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultPublicationLink,
          hint: context.l10n.vaultPublicationLinkHint,
          initialValue: publication.link ?? '',
          onChanged: (v) =>
              onChanged(publication.copyWith(link: v.orNullIfEmpty)),
        ),
        const VGap.medium(),
        BulletListEditor(
          bullets: publication.bullets,
          skillCategories: skillCategories,
          onUpdateSkill: onUpdateSkill,
          onAddSkill: onAddSkill,
          onAddCategory: onAddCategory,
          callbacks: bulletCallbacks,
        ),
      ],
    );
  }
}
