/// A region's document conventions — what that market expects a CV to look
/// like, how long it should run, and what it is called there.
///
/// Only [RegionPreset.page] and [RegionPreset.dateStyle] reach the renderer;
/// the rest feed the app's chrome, the picker's advice pane, and the AI
/// prompt. Nothing here is printed inside the document. The data lives on
/// [RegionPreset], so this enum is only ever a stable identifier.
///
/// ## Region is not a locale
///
/// A region is the *market a document targets*, independent of both language
/// axes:
///
/// - **The UI locale** (`CvPreferences.localeTag`) — someone applying across
///   borders routinely reads a German interface while preparing a UK
///   application, so neither may be inferred from the other.
/// - **The document's language** — a German-language CV can target Austria
///   or Switzerland. Region supplies page size, date convention and prompt
///   advice; never vocabulary.
///
/// Region is the coarsest of the three by design: [RegionProfile.dach] groups
/// Germany, Austria and Switzerland because they share market conventions, so
/// it cannot tell Vienna's *Jän.* from Berlin's *Jan.* — that is the document
/// language's job.
///
/// Declaration order is the picker's display order: curated, not
/// alphabetical.
enum RegionProfile { uk, us, anz, dach, nordics, europe, latamLetter, latamA4 }

/// A page-size token, not `package:pdf`'s `PdfPageFormat` directly — this
/// file (like the rest of `lib/models/`) must never import `pdf`. The
/// enum->`PdfPageFormat` mapping lives with the other pdf adapters, in
/// `lib/templates/design/cv_design_tokens_pdf.dart`.
enum PdfPageFormatToken { a4, letter }

/// `CvComposer._formatDateRange`'s seam — every region renders "Mon YYYY"
/// today. On its own enum rather than on [RegionProfile] so a region that
/// genuinely differs costs one new case in the composer, not a change at
/// every call site.
///
/// **Not** shown in the region picker: it decides the date's shape, never
/// its words, which come from `DocumentLanguage`. With one case the row
/// read identically under all eight regions while claiming the document
/// language's ground. Surface it if a second case ever appears.
enum RegionDateStyle { monYyyy }

/// What the app's own chrome calls the document.
///
/// A closed two-value set, not a per-region string: the chrome's sentence
/// frames are English, so a market's own term reads as a bug in them — "No
/// Lebensläufe yet" — and `AppChrome` reads the *global default* region, so
/// it would leak well outside Studio. [RegionPreset.localName] carries the
/// local term where it belongs.
///
/// All four forms are stated rather than derived: a `+ 's'` rule is a
/// property of the nouns currently in the table, not of the code.
enum RegionDocumentNoun { cv, resume }

/// Whether this market expects a photograph.
///
/// Advice plus exactly one consequence: `StudioViewModel
/// .photoRegionWarning` flags a photo-printing template aimed at a market
/// that rejects them. It never changes what is rendered.
///
/// Whether a photo appears is a property of the template (`TemplateTag
/// .photo`), never the region — do not wire this into `CvComposer`, which
/// passes `ContactBasics.photo` through and lets the template decide.
enum RegionPhotoStance { prohibited, discouraged, optional, expected }

/// How much personal data (date of birth, nationality, marital status,
/// national ID) this market conventionally expects. Advice only — unlike
/// [RegionPhotoStance] the Vault has no field for any of it, so nothing
/// acts on this.
enum RegionPersonalDetailsStance { omit, minimal, traditional }

/// Which English spelling convention this market reads as native. Advice,
/// and fed to the AI prompt — nothing bulk-rewrites stored Vault text, but
/// a bullet the assistant rewrites comes back in the region's spelling.
/// `TailorableField`'s revert control is the escape hatch.
enum RegionSpelling { enGb, enUs, enAu }

/// One region's concrete document conventions.
///
/// A hand-written `const` class rather than `@freezed`, against CLAUDE.md's
/// default: a compile-time lookup table, never constructed at runtime, never
/// serialised (persistence keys on [RegionProfile]'s name), and with no
/// consumer for `copyWith`/`==`. `AiAssistantVaultPayload` is the precedent.
///
/// Every field here has at least one named reader; one without does not
/// belong on this class.
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

  /// Which countries this preset covers — "Sweden, Norway, Denmark,
  /// Finland". Shown under [displayName] and fed to the AI prompt, so the
  /// model isn't inferring the countries from a label.
  final String coverage;

  /// The region's flags as emoji, representative country first, at most
  /// four. Rendered by `RegionFlagStack`, never concatenated — four glyphs
  /// in a row overflow the picker's leading mark and the document bar's
  /// icon slot.
  final List<String> flags;

  final PdfPageFormatToken page;

  /// What the app's own chrome calls this document. See
  /// [RegionDocumentNoun] for why this is a closed set and not the market's
  /// own term.
  final RegionDocumentNoun documentNoun;

  /// What the market itself calls the document — "Lebenslauf", "Hoja de
  /// Vida". The picker's detail pane and the AI prompt only, never chrome.
  final String localName;

  final RegionDateStyle dateStyle;

  /// The page count past which `StudioViewModel.pageCountWarning` goes
  /// amber. Typical, not a cap — nothing is blocked. Set to the mid-career
  /// number where a market's executives run longer; [lengthNote] carries
  /// the exception.
  final int typicalMaxPages;

  /// A sentence or two on expected length, shown in the picker, in the
  /// page-count warning's tooltip, and in the AI prompt.
  final String lengthNote;

  final RegionPhotoStance photo;
  final RegionPersonalDetailsStance personalDetails;
  final RegionSpelling spelling;

  /// How this market expects achievements to be framed. Per-region prose
  /// rather than an enum, because no two regions share one.
  final String toneNote;

  /// The region's conventions as standalone bullets — a list in the
  /// picker's detail pane, and joined into the AI prompt's region block.
  /// Each must be a complete sentence: neither surface adds connecting
  /// prose.
  final List<String> conventions;
}

/// The instruction-register version of each stance, for the AI prompt. The
/// short display counterpart lives in `lib/ui/common/l10n/model_labels
/// .dart` — two consumers with different registers, and only one of them
/// translated. These stay English; the model is instructed in English.
///
/// Stances describing something the Vault cannot hold carry an inline
/// anti-fabrication guard: telling a model a date of birth is expected,
/// while handing it a Vault with no field for one, invites invention. The
/// photo stances hold whether or not a photo was uploaded, so no `hasPhoto`
/// flag has to reach `aiAssistantSystemPromptFor`.
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
