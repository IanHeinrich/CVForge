import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:flutter/material.dart';

import 'vault_section_heading.dart';
import 'vault_summary_card.dart';

class ProjectListSection extends StatelessWidget {
  const ProjectListSection({
    super.key,
    required this.projects,
    required this.openId,
    required this.onOpen,
    required this.onAdd,
    required this.onDelete,
  });

  final List<Project> projects;
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
          title: 'Projects',
          onAdd: onAdd,
          addLabel: 'Add project',
        ),
        if (projects.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: kdPaddingTight),
            child: Text(
              'No projects yet.',
              style: TextStyle(color: kcLightGrey),
            ),
          ),
        for (final project in projects)
          VaultSummaryCard(
            title: project.title.isEmpty ? 'Untitled project' : project.title,
            subtitle: project.link,
            selected: project.id == openId,
            onTap: () => onOpen(project.id),
            onDelete: () => onDelete(project.id),
            leading: const Icon(
              Icons.rocket_launch_outlined,
              color: kcLightGrey,
            ),
          ),
      ],
    );
  }
}
