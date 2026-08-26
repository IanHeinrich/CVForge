import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/region/region_profile.dart';

part 'document_defaults.freezed.dart';
part 'document_defaults.g.dart';

/// What every new CV starts out as, kept alongside the career content it
/// shapes. On [CvVault] rather than in `AppSettings` by the question that
/// sorts the two: **does this change the CV?**
///
/// **These are defaults, not the values that render.** Every field is
/// copied onto a [CvDraft] and read from there, so one Vault can serve
/// applications to Munich and to London at once. Changing anything here
/// never rewrites an existing CV — except [sectionOrder] and
/// [hiddenSections], which Studio's "reset sections" action re-reads on
/// demand, so those two are not purely seed-time.
///
/// All five are edited from the Vault's "CV defaults" panel and nowhere
/// else.
@freezed
abstract class DocumentDefaults with _$DocumentDefaults {
  const factory DocumentDefaults({
    @Default(RegionProfile.uk) RegionProfile region,

    /// The language a new CV is written in. Defaults to agree with
    /// [region]'s default, though the two are independent axes — see
    /// `RegionProfile`'s "Region is not a locale" note.
    @Default(DocumentLanguage.enGb) DocumentLanguage language,

    /// `CvTemplate.id` for the template a new CV starts on. Null means no
    /// choice has been made, and a new draft inherits the open draft's.
    ///
    /// The raw id and not a `CvTemplate`, because this is a model and
    /// `lib/templates/` imports `pdf`. An id that no longer resolves is
    /// safe: `TemplateRegistryService.byId` falls back rather than throws.
    String? templateId,

    /// The section order to seed a new draft with; null falls back to the
    /// chosen template's own `CvTemplate.sectionOrder`. Two fields with
    /// [hiddenSections], mirroring how `CvDraft` keeps them separate.
    List<CvSectionType>? sectionOrder,

    /// Which sections a new draft starts with hidden. See [sectionOrder].
    Set<CvSectionType>? hiddenSections,

    /// Whether a new draft starts with the headline dropped from the name
    /// block. Mirrors `CvDraft.hideHeadline`, which is the value that
    /// actually renders.
    ///
    /// Not nullable, unlike [sectionOrder]/[hiddenSections]: those two
    /// need "no choice made" to fall back to the template's own
    /// suggestion, where this has a real default of its own. `false` is
    /// also what stored JSON written before this field existed decodes
    /// to, which is the pre-existing behaviour — so no migration.
    @Default(false) bool hideHeadline,

    /// Whether a new draft starts with the work-authorization line
    /// dropped. Mirrors `CvDraft.hideWorkAuthorization` on the same terms
    /// [hideHeadline] mirrors its own draft field.
    ///
    /// The default that earns its keep: the line is relevant to a minority
    /// of applications, so someone who keeps a sentence in the Vault
    /// mostly wants it off and turned on deliberately.
    @Default(false) bool hideWorkAuthorization,
  }) = _DocumentDefaults;

  factory DocumentDefaults.fromJson(Map<String, dynamic> json) =>
      _$DocumentDefaultsFromJson(json);
}
