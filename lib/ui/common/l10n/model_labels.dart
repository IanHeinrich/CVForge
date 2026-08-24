import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/templates/cv_template.dart';

/// Display labels for the enums and value types that live under
/// `lib/models/` and `lib/templates/`.
///
/// They live *here*, not beside their types, because a localized label needs
/// [AppLocalizations] — which imports Flutter — and `lib/models/` must never
/// import Flutter (see CLAUDE.md). The enum stays framework-free; only the
/// words move.
///
/// That split also makes an existing intent structural rather than merely
/// documented: `CvSectionType`'s picker label and the section title
/// `CvComposer` prints on the page were always "different concerns that
/// happen to agree". Now one lives in `lib/ui/` and the other in
/// `lib/models/render/`, so they cannot quietly become one.
///
/// Each is a method taking the localizations rather than a getter, so the
/// same call works from a View (`context.l10n`) and from a ViewModel or
/// Service (`localizationService.strings`).
extension CvSectionTypeLabel on CvSectionType {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    CvSectionType.summary => l10n.sectionLabelSummary,
    CvSectionType.skills => l10n.sectionLabelSkills,
    CvSectionType.experience => l10n.sectionLabelExperience,
    CvSectionType.projects => l10n.sectionLabelProjects,
    CvSectionType.education => l10n.sectionLabelEducation,
    CvSectionType.hobbies => l10n.sectionLabelHobbies,
    CvSectionType.references => l10n.sectionLabelReferences,
    CvSectionType.publications => l10n.sectionLabelPublications,
  };
}

extension SkillCategoryDisplay on SkillCategory {
  /// A category is legitimately unnamed while it's being filled in — new
  /// ones start blank so they prune like any other unfilled entry (see
  /// `CvVaultPruning.withoutBlankEntries`). Anywhere the name is *shown* —
  /// a chip-group heading, a menu item — needs something to render; the
  /// editor field itself still binds to the raw `name`.
  String displayName(AppLocalizations l10n) =>
      name.trim().isEmpty ? l10n.skillCategoryUnnamed : name;
}

extension TemplateTagLabel on TemplateTag {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    TemplateTag.atsSafe => l10n.templateTagAtsSafe,
    TemplateTag.academic => l10n.templateTagAcademic,
    TemplateTag.twoColumn => l10n.templateTagTwoColumn,
    TemplateTag.compact => l10n.templateTagCompact,
    TemplateTag.traditional => l10n.templateTagTraditional,
    TemplateTag.modern => l10n.templateTagModern,
  };
}

extension PdfPageFormatTokenLabel on PdfPageFormatToken {
  /// Includes the physical dimensions, since "A4" versus "Letter" only
  /// means something to a reader who already knows the difference — the
  /// region picker exists partly to explain it.
  String displayLabel(AppLocalizations l10n) => switch (this) {
    PdfPageFormatToken.a4 => l10n.pageFormatA4,
    PdfPageFormatToken.letter => l10n.pageFormatLetter,
  };
}

extension RegionDateStyleLabel on RegionDateStyle {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    RegionDateStyle.monYyyy => l10n.dateStyleMonYyyy,
  };
}

/// The `displayLabel` halves of the region stances. Their `promptLabel`
/// counterparts deliberately stay behind in `region_profile.dart`, English
/// and Flutter-free: they instruct the AI model, not the reader, and
/// translating a prompt changes model behaviour. That file already
/// documented the two as "genuinely different registers"; this is that
/// split made physical.
extension RegionPhotoStanceLabel on RegionPhotoStance {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    RegionPhotoStance.prohibited => l10n.photoStanceProhibited,
    RegionPhotoStance.discouraged => l10n.photoStanceDiscouraged,
    RegionPhotoStance.optional => l10n.photoStanceOptional,
    RegionPhotoStance.expected => l10n.photoStanceExpected,
  };
}

extension RegionPersonalDetailsStanceLabel on RegionPersonalDetailsStance {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    RegionPersonalDetailsStance.omit => l10n.personalDetailsOmit,
    RegionPersonalDetailsStance.minimal => l10n.personalDetailsMinimal,
    RegionPersonalDetailsStance.traditional => l10n.personalDetailsTraditional,
  };
}

extension RegionSpellingLabel on RegionSpelling {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    RegionSpelling.enGb => l10n.spellingEnGb,
    RegionSpelling.enUs => l10n.spellingEnUs,
    RegionSpelling.enAu => l10n.spellingEnAu,
  };
}
