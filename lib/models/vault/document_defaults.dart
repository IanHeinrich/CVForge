import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/region/region_profile.dart';

part 'document_defaults.freezed.dart';
part 'document_defaults.g.dart';

/// What every new CV starts out as — the shape of the document, kept
/// alongside the career content it is built from.
///
/// These live on [CvVault] rather than in `AppSettings` because of the one
/// question that sorts the two: **does this change the CV?** Region picks
/// the page size and date convention, language picks every word the app
/// itself prints, and the section fields decide what appears and in what
/// order. The AI provider and the app's own UI language do not, and stay in
/// settings.
///
/// ## These are defaults, not the values that render
///
/// Every field here is copied onto a [CvDraft] and read from there
/// afterwards. A draft is one application to one employer, so it has to be
/// able to differ: the whole reason the document language is per-draft is
/// that someone applying to a firm in Munich and a firm in London from one
/// Vault needs two languages, not one.
///
/// So changing anything here never rewrites a CV that already exists — with
/// one deliberate exception, [sectionOrder] and [hiddenSections], which
/// Studio's "reset sections" action re-reads and applies to the open draft
/// on demand. That is a user asking for it rather than a background
/// re-resolve, but it does mean these two are not purely seed-time the way
/// [region], [language] and [templateId] are.
///
/// ## Every field here is authored in one place
///
/// All five are edited from the Vault's "CV defaults" panel and nowhere
/// else. [sectionOrder] and [hiddenSections] used to be authored from
/// Studio instead, by a "Save as my default" button that promoted the open
/// draft's arrangement — which meant the defaults had an editor in one
/// feature and every other default had its editor in another. Studio keeps
/// the *reset* action, because discarding one draft's customisation is a
/// fact about that draft, not about the defaults.
@freezed
abstract class DocumentDefaults with _$DocumentDefaults {
  const factory DocumentDefaults({
    @Default(RegionProfile.uk) RegionProfile region,

    /// The language a new CV is written in.
    ///
    /// Defaults to [DocumentLanguage.enGb] to agree with [region]'s own
    /// default. The two are independent axes and neither is inferred from
    /// the other — see `RegionProfile`'s "Region is not a locale" note —
    /// but their *defaults* may as well describe the same person.
    @Default(DocumentLanguage.enGb) DocumentLanguage language,

    /// `CvTemplate.id` for the template a new CV starts on. Null means the
    /// user has never chosen one, in which case a new draft inherits the
    /// template of whichever draft is open — the sticky behaviour that was
    /// the only behaviour before this field existed.
    ///
    /// Deliberately the raw id and not a `CvTemplate`: this is a model, and
    /// `lib/templates/` imports `pdf`. An id that no longer resolves is
    /// safe — `TemplateRegistryService.byId` falls back rather than
    /// throwing — so a default surviving a template's removal degrades to
    /// the fallback instead of breaking every new draft.
    String? templateId,

    /// The section order (see `CvDraft.sectionOrder`) to seed a new draft
    /// with. Null means no default has ever been set, and a new draft falls
    /// back to its chosen template's own `CvTemplate.sectionOrder`.
    ///
    /// Kept as two fields with [hiddenSections] rather than one combined
    /// value, mirroring `CvDraft.sectionOrder` / `CvDraft.hiddenSections`
    /// being separate there too.
    List<CvSectionType>? sectionOrder,

    /// Which sections a new draft starts with hidden. See [sectionOrder].
    Set<CvSectionType>? hiddenSections,
  }) = _DocumentDefaults;

  factory DocumentDefaults.fromJson(Map<String, dynamic> json) =>
      _$DocumentDefaultsFromJson(json);
}
