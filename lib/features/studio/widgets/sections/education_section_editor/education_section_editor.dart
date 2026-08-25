import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/sections/entity_bullet_section_editor.dart';
import 'package:cv_forge/models/draft/draft_omittable_field.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';

/// The [CvSectionType.education] editor.
class EducationSectionEditor extends StatelessWidget {
  const EducationSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) => EntityBulletSectionEditor(
    title: context.l10n.vaultSectionEducation,
    items: viewModel.education,
    untitledLabel: context.l10n.vaultUntitledQualification,
    idOf: (e) => e.id,
    titleOf: viewModel.educationQualificationText,
    // The institution stays the subtitle for the same reason the employer
    // does in `ExperienceSectionEditor` — it's what tells two identical
    // qualifications apart in a collapsed list.
    subtitleOf: (e) => e.institution,
    bulletsOf: (e) => e.bullets,
    unselectedCount: viewModel.unselectedEducation.length,
    selectedCount: viewModel.selectedEducation.length,
    onAddAll: viewModel.addAllEducation,
    onRemoveAll: viewModel.removeAllEducation,
    isIncluded: (e) => viewModel.isEducationIncluded(e.id),
    onToggle: viewModel.toggleEducation,
    onAddAllBullets: viewModel.addAllEducationBullets,
    onRemoveAllBullets: viewModel.removeAllEducationBullets,
    isBulletIncluded: (e, b) => viewModel.isEducationBulletIncluded(e.id, b.id),
    onToggleBullet: viewModel.toggleEducationBullet,
    bulletText: viewModel.bulletText,
    hasBulletOverride: viewModel.hasBulletOverride,
    onSetBulletOverride: viewModel.setBulletOverride,
    onRevertBulletOverride: viewModel.revertBulletOverride,
    titleFieldOf: (e) => TailorableField(
      hasOverride: viewModel.hasEducationQualificationOverride(e.id),
      effectiveText: viewModel.educationQualificationText(e),
      fieldLabel: context.l10n.studioFieldQualification,
      onChanged: (value) =>
          viewModel.setEducationQualificationOverride(e, value),
      onRevert: () => viewModel.revertEducationQualificationOverride(e.id),
    ),
    fieldsOf: (e) => [
      TailorableField(
        hasOverride: viewModel.hasEducationLocationOverride(e.id),
        effectiveText: viewModel.educationLocationText(e),
        fieldLabel: context.l10n.studioFieldLocation,
        emptyMessage: context.l10n.studioNoLocation,
        onChanged: (value) => viewModel.setEducationLocationOverride(e, value),
        onRevert: () => viewModel.revertEducationLocationOverride(e.id),
      ),
      // Prints, and was not reachable from Studio at all. Shown even
      // locked, so it's clear what this entry puts on the page — an
      // absent row was indistinguishable from an unwired one.
      VaultOnlyField(
        fieldLabel: context.l10n.studioFieldYear,
        value: e.year?.toString() ?? '',
        reason: context.l10n.studioLockedFromVault,
        omitted: viewModel.isFieldOmitted(
          DraftOmittableField.educationYear,
          e.id,
        ),
        onToggleOmitted: () => viewModel.toggleFieldOmitted(
          DraftOmittableField.educationYear,
          e.id,
        ),
      ),
      TailorableField(
        hasOverride: viewModel.hasEducationGradeOverride(e.id),
        effectiveText: viewModel.educationGradeText(e),
        fieldLabel: context.l10n.studioFieldGrade,
        emptyMessage: context.l10n.studioNoGrade,
        onChanged: (value) => viewModel.setEducationGradeOverride(e, value),
        onRevert: () => viewModel.revertEducationGradeOverride(e.id),
      ),
      TailorableField(
        hasOverride: viewModel.hasEducationDetailsOverride(e.id),
        effectiveText: viewModel.educationDetailsText(e),
        fieldLabel: context.l10n.studioFieldDetails,
        emptyMessage: context.l10n.studioNoEducationDetails,
        onChanged: (value) => viewModel.setEducationDetailsOverride(e, value),
        onRevert: () => viewModel.revertEducationDetailsOverride(e.id),
      ),
    ],
  );
}
