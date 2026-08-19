import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'vault_section_heading.dart';
import 'package:cv_forge/ui/widgets/common/app_summary_card.dart';

class EducationListSection extends StatelessWidget {
  const EducationListSection({
    super.key,
    required this.education,
    required this.openId,
    required this.onOpen,
    required this.onAdd,
    required this.onDelete,
  });

  final List<Education> education;
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
          title: 'Education',
          onAdd: onAdd,
          addLabel: 'Add education',
        ),
        if (education.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: kdPaddingTight),
            child: Text(
              'No education yet.',
              style: TextStyle(color: kcLightGrey),
            ),
          ),
        for (final entry in education)
          AppSummaryCard(
            title: entry.qualification.isEmpty
                ? 'Untitled qualification'
                : entry.qualification,
            subtitle: entry.institution,
            selected: entry.id == openId,
            onTap: () => onOpen(entry.id),
            onDelete: () => onDelete(entry.id),
            leading: const Icon(
              RemixIcons.graduation_cap_line,
              color: kcLightGrey,
            ),
          ),
      ],
    );
  }
}
