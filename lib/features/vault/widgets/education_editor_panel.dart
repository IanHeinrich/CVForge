import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'vault_editor_panel_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

class EducationEditorPanel extends StatelessWidget {
  const EducationEditorPanel({
    super.key,
    required this.education,
    required this.onClose,
    required this.onChanged,
  });

  final Education education;
  final VoidCallback onClose;
  final ValueChanged<Education> onChanged;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: education.qualification.isEmpty
          ? 'New qualification'
          : education.qualification,
      onClose: onClose,
      children: [
        AppTextField(
          label: 'Qualification',
          hint: 'e.g. BSc Computer Science',
          initialValue: education.qualification,
          onChanged: (v) => onChanged(education.copyWith(qualification: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Institution',
          initialValue: education.institution,
          onChanged: (v) => onChanged(education.copyWith(institution: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Location (optional)',
          initialValue: education.location ?? '',
          onChanged: (v) =>
              onChanged(education.copyWith(location: v.isEmpty ? null : v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Year (optional)',
          initialValue: education.year?.toString() ?? '',
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final year = int.tryParse(v);
            onChanged(education.copyWith(year: v.isEmpty ? null : year));
          },
        ),
        const VGap.small(),
        AppTextField(
          label: 'Grade (optional)',
          hint: 'e.g. First Class Honours',
          initialValue: education.grade ?? '',
          onChanged: (v) =>
              onChanged(education.copyWith(grade: v.isEmpty ? null : v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Details (optional)',
          initialValue: education.details ?? '',
          maxLines: 3,
          onChanged: (v) =>
              onChanged(education.copyWith(details: v.isEmpty ? null : v)),
        ),
      ],
    );
  }
}
