/// The language a produced CV is written in — the only one of the app's
/// three language axes that reaches the document.
///
/// Conflating any two of them is a bug:
///
/// - **The UI locale** (`LocalizationService`, `CvPreferences.localeTag`) —
///   what the app's own buttons and labels are drawn in. It must never
///   reach the document; someone applying across borders routinely reads a
///   Spanish interface while preparing an English CV.
/// - **[DocumentLanguage]** — what the CV itself is written in.
/// - **`RegionProfile`** — which market the CV targets. See its own
///   "Region is not a locale" note.
///
/// **These are locales, not languages**, because the rendered strings
/// differ at that granularity: Austrian German writes *Jän.*, Brazilian
/// Portuguese *acadêmica*, British English *Sept*. Region cannot supply
/// it — `RegionProfile.dach` groups Germany, Austria and Switzerland into
/// one market, so it cannot tell Vienna from Berlin.
///
/// A variant exists **only where at least one string actually differs**;
/// `documentStringsHaveNoRedundantVariants` enforces that.
///
/// The enum *names* are the persistence contract — stored by `.name` on
/// `CvDraft` and `DocumentDefaults` — and must never be renamed. Every
/// string in [DocumentStrings] is free to change between app versions.
enum DocumentLanguage {
  enGb,
  enUs,
  enAu,
  de,
  deAt,
  fr,
  frCa,
  nl,
  it,
  es,
  es419,
  ptPt,
  ptBr,
  sv,
  nb,
  da,
  fi,
}

/// Everything a CV prints that the app supplies rather than the user.
///
/// A hand-written `const` class rather than `@freezed`, against CLAUDE.md's
/// default and for the same reason [RegionPreset] makes that call: a
/// compile-time lookup table, never constructed, serialized, or copied.
///
/// **Not** an `.arb` file, and that is load-bearing. `AppLocalizations`
/// imports Flutter, so a table in `lib/models/` structurally cannot reach
/// the UI locale — the import graph enforces the invariant instead of a
/// reviewer. (`flutter gen-l10n` also reads `l10n.yaml` over its own command
/// line, so a second output class isn't reachable anyway.)
class DocumentStrings {
  const DocumentStrings({
    required this.cldrTag,
    required this.promptName,
    required this.summary,
    required this.experience,
    required this.projects,
    required this.skills,
    required this.education,
    required this.hobbies,
    required this.references,
    required this.publications,
    required this.present,
    required this.months,
  });

  /// The CLDR locale [months] was transcribed from.
  ///
  /// Checked in rather than read from `package:intl` at render time:
  /// `intl: any` is pinned by the SDK, so CLDR data shifting under an
  /// upgrade would silently change the bytes of every exported PDF.
  /// `document_strings_test.dart` compares the two and fails on divergence,
  /// turning that into a failure a human adjudicates.
  final String cldrTag;

  /// What to call this language when telling the model to write in it —
  /// "Brazilian Portuguese", "Austrian German". English, and separate from
  /// the autonym the picker shows, because prompt text is English by policy
  /// (see CLAUDE.md's list of what is not localized).
  final String promptName;

  final String summary;
  final String experience;
  final String projects;
  final String skills;
  final String education;
  final String hobbies;
  final String references;
  final String publications;

  /// The end of an ongoing role, as in "Mar 2020 - Present". Capitalized
  /// in every language: ATS parsers regex for this marker to decide a role
  /// is current, against whatever language the document is in.
  final String present;

  /// The twelve month abbreviations, January first. Only ever indexed by a
  /// `YearMonth.month`, which its own assertion constrains to 1-12.
  final List<String> months;
}

/// The separator between the two ends of a date range, as in
/// "Mar 2020 - Jun 2023". Not per-language: a spaced hyphen reads correctly
/// in every language shipped here, and switching to the en dash some
/// European conventions prefer would rewrite every existing CV's date line
/// for no change in meaning.
const String documentDateRangeSeparator = ' - ';
