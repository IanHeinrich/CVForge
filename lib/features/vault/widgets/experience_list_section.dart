import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

import 'vault_section_heading.dart';
import 'vault_summary_card.dart';

class ExperienceListSection extends StatelessWidget {
  const ExperienceListSection({
    super.key,
    required this.experiences,
    required this.openId,
    required this.onOpen,
    required this.onAdd,
    required this.onDelete,
  });

  final List<Experience> experiences;
  final String? openId;
  final ValueChanged<String> onOpen;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VaultSectionHeading(
          title: 'Work history',
          onAdd: onAdd,
          addLabel: 'Add experience',
        ),
        if (experiences.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'No experience yet.',
              style: TextStyle(color: kcLightGrey),
            ),
          ),
        for (final experience in experiences)
          VaultSummaryCard(
            title: experience.role.isEmpty ? 'Untitled role' : experience.role,
            subtitle: experience.company,
            selected: experience.id == openId,
            onTap: () => onOpen(experience.id),
            onDelete: () => onDelete(experience.id),
            leading: const Icon(Icons.work_outline, color: kcLightGrey),
          ),
      ],
    );
  }
}
