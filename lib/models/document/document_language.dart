/// The language a produced CV is written in — the app's third and last
/// language axis, and the only one that reaches the document.
///
/// The three are independent, and conflating any two of them is a bug:
///
/// - **The UI locale** (`LocalizationService`, `CvPreferences.localeTag`) —
///   which language the app's own buttons and labels are drawn in. It must
///   never reach the produced document; someone applying across borders
///   routinely reads a Spanish interface while preparing an English CV.
/// - **[DocumentLanguage]** — which language the CV itself is written in.
/// - **`RegionProfile`** — which market the CV targets. See its own
///   "Region is not a locale" note.
///
/// ## Why this is a locale, not a language
///
/// The entries below are locales because the rendered strings genuinely
/// differ at that granularity, and nothing coarser can express it: Austrian
/// German writes *Jän.* where German writes *Jan.*, Brazilian Portuguese
/// writes *acadêmica* where European Portuguese writes *académica*, and
/// British English writes *Sept* where American English writes *Sep*.
///
/// Region cannot supply this. `RegionProfile.dach` deliberately groups
/// Germany, Austria and Switzerland into one market, so it cannot tell
/// Vienna from Berlin — which is exactly why the two axes stay separate.
///
/// A variant exists **only where at least one string actually differs**.
/// `documentStringsHaveNoRedundantVariants` in the test suite enforces that:
/// two entries with identical tables mean one of them should be deleted and
/// its callers pointed at the other.
///
/// The enum *names* are the persistence contract — they are stored on
/// `CvDraft` and `DocumentDefaults` by `.name` — and must never be renamed.
/// Every string in [DocumentStrings] is free to change between app versions.
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
/// Deliberately a hand-written `const` class rather than `@freezed`, against
/// CLAUDE.md's default — the same call [RegionPreset] makes, for the same
/// reason. This is a compile-time lookup table: never constructed at
/// runtime, never serialized, never copied with a field changed.
///
/// Deliberately **not** an `.arb` file either, and that is load-bearing
/// rather than a convenience. `AppLocalizations` imports Flutter, so a table
/// living here in `lib/models/` structurally *cannot* reach for the UI
/// locale — the invariant this whole axis exists to protect is enforced by
/// the import graph instead of by a reviewer remembering it. (It is also
/// blocked outright: `flutter gen-l10n` reads `l10n.yaml` instead of its own
/// command line whenever that file exists, so a second output class is not
/// reachable without moving `l10n.yaml` out from under `flutter run`.)
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
  /// The abbreviations are checked in rather than read from `package:intl`
  /// at render time, because `pubspec.yaml` pins `intl: any` deliberately —
  /// `flutter_localizations` pins an exact `intl` per SDK, so any constraint
  /// of our own becomes a version-solve failure on the next SDK bump. That
  /// leaves CLDR data free to shift underneath us, which would silently
  /// change the bytes of every exported PDF and move golden baselines with
  /// no source change to explain them.
  ///
  /// So this records *where the data came from*, and
  /// `document_strings_test.dart` compares the table against `intl` and
  /// fails on divergence — turning an SDK bump into a test failure a human
  /// adjudicates, and giving the transcription a standing correctness check.
  final String cldrTag;

  /// What to call this language when telling the model to write in it —
  /// "Brazilian Portuguese", "Austrian German".
  ///
  /// English, and separate from the autonym the picker shows, because
  /// prompt text is English by policy: the model is instructed in English,
  /// and translating its instructions changes how it behaves. See
  /// CLAUDE.md's list of what is deliberately not localized.
  final String promptName;

  final String summary;
  final String experience;
  final String projects;
  final String skills;
  final String education;
  final String hobbies;
  final String references;
  final String publications;

  /// The end of an ongoing role, as in "Mar 2020 - Present".
  ///
  /// Capitalized in every language, matching the surrounding date. The
  /// convention is worth keeping deliberate rather than incidental: ATS
  /// parsers commonly regex for this marker to decide a role is current,
  /// and they are matching against whatever language the document is in.
  final String present;

  /// The twelve month abbreviations, January first.
  ///
  /// Only ever indexed by a `YearMonth.month` that its own assertion has
  /// already constrained to 1-12.
  final List<String> months;
}

/// The separator between the two ends of a date range, as in
/// "Mar 2020 - Jun 2023".
///
/// Deliberately not per-language. A spaced hyphen reads correctly in every
/// language shipped here, and the alternative — an en dash, which some
/// European typographic conventions prefer — would rewrite the date line of
/// every existing CV in exchange for no change in meaning.
const String documentDateRangeSeparator = ' - ';
