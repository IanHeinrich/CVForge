/// A region's document conventions — what that market expects a CV to look
/// like, how long it should run, and what it is called there.
///
/// Two of [RegionPreset]'s fields reach the renderer ([RegionPreset.page],
/// [RegionPreset.dateStyle]); the rest are read by the app's own chrome, the
/// region picker's advice pane, and the AI Assistant's tailoring prompt.
/// Nothing here is ever printed inside the produced document.
///
/// [RegionProfile] is a plain enum and stays one: the per-region data lives
/// on [RegionPreset], so this only ever needs to be a stable identifier.
///
/// Declaration order is the region picker's display order: curated rather
/// than alphabetical, with the two original regions first.
enum RegionProfile { uk, us, anz, dach, nordics, europe, latamLetter, latamA4 }

/// A page-size token, not `package:pdf`'s `PdfPageFormat` directly — this
/// file (like the rest of `lib/models/`) must never import `pdf`. The
/// enum->`PdfPageFormat` mapping lives with the other pdf adapters, in
/// `lib/templates/design/cv_design_tokens_pdf.dart`.
enum PdfPageFormatToken { a4, letter }

/// `CvComposer._formatDateRange`'s seam — every region renders "Mon YYYY"
/// today. DACH's gap-free, month-precise chronology is a *content
/// completeness* convention (see that preset's `conventions`), not a
/// different date format, so it needs no value here. The switch lives on
/// this enum rather than on [RegionProfile] directly so a region that
/// genuinely differs needs one new case in the composer, not a change at
/// every call site.
enum RegionDateStyle { monYyyy }

/// What the app's own chrome calls the document.
///
/// Deliberately a closed two-value set rather than a per-region string. The
/// chrome's sentence frames are English, so a market's own term would read
/// as a bug in them — "No Lebensläufe yet", "Upload a PDF Lebenslauf" — and
/// because `AppChrome` and `AnalyzerViewModel` read the *global default*
/// region, that would leak well outside Studio. [RegionPreset.localName]
/// carries the local term for the two surfaces where it belongs.
///
/// All four forms are stated rather than derived. The `+ 's'` /
/// `substring(0, 1).toUpperCase()` derivation this replaced happened to be
/// correct for every noun then in the table, but that was a property of the
/// nouns, not of the code.
enum RegionDocumentNoun { cv, resume }

/// Whether this market expects a photograph on the document.
///
/// Advice, plus exactly one consequence: `StudioViewModel`'s
/// `photoRegionWarning` reads it to flag a photo-printing template aimed
/// at a market that rejects photographs. It never changes what is
/// rendered.
///
/// Whether a photo appears is a property of the chosen template (see
/// `TemplateTag.photo`), never of the region — a region that silently
/// added or removed one would change the document out from under the
/// user. Do not wire this into `CvComposer`, which passes
/// `ContactBasics.photo` through unconditionally and lets the template
/// decide.
enum RegionPhotoStance { prohibited, discouraged, optional, expected }

/// How much personal data (date of birth, nationality, marital status,
/// national ID) this market conventionally expects. Advice only — unlike
/// [RegionPhotoStance] the Vault has no field for any of it, so nothing
/// acts on this.
enum RegionPersonalDetailsStance { omit, minimal, traditional }

/// Which English spelling convention this market reads as native.
///
/// Surfaced as advice and fed to the AI Assistant's prompt. cv-forge never
/// bulk-rewrites stored Vault text on its own — but a bullet the assistant
/// chooses to rewrite will come back in the target region's spelling, since
/// that sits inside the rewrite envelope it already has. `TailorableField`'s
/// revert control is the escape hatch.
enum RegionSpelling { enGb, enUs, enAu }

/// One region's concrete document conventions.
///
/// Deliberately a hand-written `const` class rather than `@freezed`, against
/// CLAUDE.md's default. This is a compile-time lookup table, not a data
/// model: never constructed at runtime (only `const` entries in a `const`
/// map), never serialised (persistence keys on [RegionProfile]'s own name —
/// see `regionPresets`), and with no consumer for `copyWith`/`==`/
/// `hashCode`. Freezing it would add a generated file to regenerate on every
/// field addition and buy nothing. `AiAssistantVaultPayload` is the existing
/// precedent for this carve-out.
///
/// Every field here has at least one named reader. A field with no reader
/// does not belong on this class — that discipline predates this expansion
/// and survives it.
class RegionPreset {
  const RegionPreset({
    required this.displayName,
    required this.coverage,
    required this.flags,
    required this.page,
    required this.documentNoun,
    required this.localName,
    required this.dateStyle,
    required this.typicalMaxPages,
    required this.lengthNote,
    required this.photo,
    required this.personalDetails,
    required this.spelling,
    required this.toneNote,
    required this.conventions,
  });

  final String displayName;

  /// Which countries this preset actually covers, as a plain list —
  /// "Sweden, Norway, Denmark, Finland". Rendered directly under
  /// [displayName] in the picker and in Settings' summary row, and fed to
  /// the AI prompt so the model knows the target countries rather than
  /// inferring them from a label.
  final String coverage;

  /// The region's flags as emoji, representative country first, at most
  /// four. Rendered by `RegionFlagStack`, never concatenated into one
  /// string — four glyphs in a row overflow both the picker's leading mark
  /// and `StudioDocumentBar`'s icon slot.
  final List<String> flags;

  final PdfPageFormatToken page;

  /// What the app's own chrome calls this document. See
  /// [RegionDocumentNoun] for why this is a closed set and not the market's
  /// own term.
  final RegionDocumentNoun documentNoun;

  /// What the market itself calls the document — "Lebenslauf", "Hoja de
  /// Vida". Shown only in the region picker's detail pane and fed to the AI
  /// prompt; never used in app chrome. Equal to [documentNoun]'s English
  /// form wherever the two coincide.
  final String localName;

  final RegionDateStyle dateStyle;

  /// The page count past which `StudioViewModel.pageCountWarning` goes
  /// amber. The *typical* maximum, not a hard cap — nothing is blocked. A
  /// region whose executives run longer than its mid-career candidates is
  /// set to the mid-career number, since that is the common case the
  /// warning exists for; [lengthNote] carries the exception.
  final int typicalMaxPages;

  /// A sentence or two on expected length, shown in the picker, in the
  /// page-count warning's tooltip, and in the AI prompt.
  final String lengthNote;

  final RegionPhotoStance photo;
  final RegionPersonalDetailsStance personalDetails;
  final RegionSpelling spelling;

  /// How this market expects achievements to be framed — the US's
  /// quantified ROI, the Nordics' team-first register, Australasia's
  /// context-rich detail. Per-region prose rather than an enum: no two
  /// regions share one.
  final String toneNote;

  /// The region's conventions as standalone bullets, rendered as a list in
  /// the picker's detail pane and joined into the AI prompt's region block.
  /// Each entry is a complete sentence that reads correctly on its own —
  /// they appear in two very different surfaces and neither adds connecting
  /// prose.
  final List<String> conventions;
}

/// The instruction-register version of each stance, for the AI Assistant's
/// region block. Its short display counterpart now lives in
/// `lib/ui/common/l10n/model_labels.dart`: two consumers with genuinely
/// different registers, so one shared string would be wrong in both — and
/// now they are two files as well as two strings, because only one of them
/// is translated. These stay English; the model is instructed in English,
/// and translating a prompt changes its behaviour.
///
/// The stances describing something the Vault cannot hold carry their own
/// anti-fabrication guard inline — telling a model a date of birth is
/// expected, while handing it a Vault with no field for one, is otherwise
/// an invitation to invent it. The photo stances are phrased so they hold
/// whether or not a photo has been uploaded: the assistant produces text
/// and never touches `ContactBasics.photo`, so "CVForge handles it" is the
/// accurate instruction either way, and no `hasPhoto` flag has to be
/// threaded through `aiAssistantSystemPromptFor` to keep it true.
extension RegionPhotoStancePrompt on RegionPhotoStance {
  String get promptLabel => switch (this) {
    RegionPhotoStance.prohibited =>
      'Employers here discard documents carrying a photograph. Never '
          'suggest adding one.',
    RegionPhotoStance.discouraged =>
      'No photograph. Equality law here makes one a liability for the '
          'employer as well as the candidate. Do not suggest adding one.',
    RegionPhotoStance.optional =>
      'A photograph is optional here. CVForge renders it itself when the '
          'chosen template supports one — never add, describe, or imply '
          'one in the text you produce.',
    RegionPhotoStance.expected =>
      'A professional photograph is conventional here. CVForge renders it '
          'itself when the chosen template supports one — never add, '
          'describe, or imply one in the text you produce.',
  };
}

extension RegionPersonalDetailsStancePrompt on RegionPersonalDetailsStance {
  String get promptLabel => switch (this) {
    RegionPersonalDetailsStance.omit =>
      'Personal details are limited to name and contact information. Date '
          'of birth, nationality, and marital status are actively harmful '
          'here.',
    RegionPersonalDetailsStance.minimal =>
      'Keep personal details minimal: name, contact, city.',
    RegionPersonalDetailsStance.traditional =>
      'Date of birth, place of birth, and nationality are conventional in '
          'this market — but the Vault holds none of them. Never invent '
          'one; note the convention in keywordGaps if it matters.',
  };
}

extension RegionSpellingPrompt on RegionSpelling {
  String get promptLabel => switch (this) {
    RegionSpelling.enGb =>
      'British English (en-GB): organised, programme, centre, analyse, '
          'licence (noun).',
    RegionSpelling.enUs =>
      'US English (en-US): organized, program, center, analyze, license.',
    RegionSpelling.enAu =>
      'Australian English (en-AU): British spellings throughout — '
          'organised, centre, analyse — applied consistently.',
  };
}
