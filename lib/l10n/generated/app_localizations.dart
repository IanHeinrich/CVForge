import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// ATS check, body text shown while processing.
  ///
  /// In en, this message translates to:
  /// **'Reading the PDF and checking for ATS parsing issues.'**
  String get analyzerAnalyzingBody;

  /// ATS check, shown while the uploaded PDF is being processed.
  ///
  /// In en, this message translates to:
  /// **'Analyzing…'**
  String get analyzerAnalyzingTitle;

  /// ATS check error message when the PDF parsing library itself failed to download.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the PDF engine — check your connection and try again.'**
  String get analyzerErrorEngineLoad;

  /// ATS check error message for an unclassified failure while analyzing.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t analyze that file — try again.'**
  String get analyzerErrorGeneric;

  /// ATS check error message when the PDF is an interactive form (AcroForm) rather than a normal document.
  ///
  /// In en, this message translates to:
  /// **'This is an interactive PDF form, which works differently from a typical resume and can\'t be analyzed the same way.'**
  String get analyzerErrorInteractiveForm;

  /// ATS check error message when the chosen file could not be opened as a PDF.
  ///
  /// In en, this message translates to:
  /// **'That file doesn\'t look like a valid PDF, or it\'s password-protected.'**
  String get analyzerErrorInvalidPdf;

  /// ATS check, heading shown when processing the uploaded PDF failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t analyze that file'**
  String get analyzerErrorTitle;

  /// ATS check finding card, shown when a finding's evidence spans more than one page.
  ///
  /// In en, this message translates to:
  /// **'{count} locations across {pages} pages'**
  String analyzerFindingLocationsAcrossPages(int count, int pages);

  /// ATS check finding card, shown when a finding has several pieces of evidence all on the same page.
  ///
  /// In en, this message translates to:
  /// **'{count} locations on page {page}'**
  String analyzerFindingLocationsOnPage(int count, int page);

  /// ATS check finding card, position indicator while stepping through a finding's evidence one location at a time — e.g. '2 of 5'. {index} is 1-based.
  ///
  /// In en, this message translates to:
  /// **'{index} of {total}'**
  String analyzerFindingStepOf(int index, int total);

  /// ATS check Machine Ingestion tab, body of the empty state.
  ///
  /// In en, this message translates to:
  /// **'This PDF didn\'t yield any extractable text runs.'**
  String get analyzerMachineEmptyBody;

  /// ATS check Machine Ingestion tab, shown when the PDF yielded no text runs.
  ///
  /// In en, this message translates to:
  /// **'No text extracted'**
  String get analyzerMachineEmptyTitle;

  /// Page marker shown above each page's text in the Machine Ingestion tab, and on a finding that belongs to one page. {page} is 1-based.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String analyzerPageLabel(int page);

  /// ATS check results screen, button that clears the current result and returns to the upload prompt.
  ///
  /// In en, this message translates to:
  /// **'Analyze another file'**
  String get analyzerResultsAnalyzeAnother;

  /// ATS check results screen, one-line summary of what was pulled out of the PDF. A 'text run' is one contiguous piece of text the extractor found.
  ///
  /// In en, this message translates to:
  /// **'{pages, plural, =1{1 page} other{{pages} pages}}, {runs, plural, =1{1 text run} other{{runs} text runs}} extracted.'**
  String analyzerResultsExtractionSummary(int pages, int runs);

  /// ATS check results screen, heading above the analysis output.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get analyzerResultsTitle;

  /// ATS check results screen, second tab. Shows the raw text in the order a machine would read it.
  ///
  /// In en, this message translates to:
  /// **'Machine Ingestion'**
  String get analyzerTabMachineIngestion;

  /// ATS check results screen, first tab. Shows the PDF page with boxes drawn over each extracted text run, so the user sees what a parser sees.
  ///
  /// In en, this message translates to:
  /// **'X-Ray'**
  String get analyzerTabXray;

  /// ATS check, explanatory text on the upload screen. The branch follows the region's document noun; the list after the dash is shared.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{Upload a PDF CV to check for formatting that applicant tracking software commonly misreads} resume{Upload a PDF résumé to check for formatting that applicant tracking software commonly misreads} other{Upload a PDF document to check for formatting that applicant tracking software commonly misreads}} — missing text layers, multi-column layouts, garbled characters, and more. Nothing leaves your browser.'**
  String analyzerUploadBody(String noun);

  /// ATS check, button that opens the file picker to choose a PDF.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get analyzerUploadCta;

  /// ATS check, main heading on the upload screen. The branch follows the user's default REGION's document noun, not their language.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{Check your CV for ATS issues} resume{Check your résumé for ATS issues} other{Check your document for ATS issues}}'**
  String analyzerUploadTitle(String noun);

  /// ATS check findings rail, group heading for findings that apply to the whole document rather than one page.
  ///
  /// In en, this message translates to:
  /// **'Document-level'**
  String get analyzerXrayDocumentLevel;

  /// ATS check X-Ray tab, body of the pre-analysis empty state.
  ///
  /// In en, this message translates to:
  /// **'Analyze a PDF to see its X-Ray.'**
  String get analyzerXrayEmptyBody;

  /// ATS check X-Ray tab, shown before any file has been analyzed.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet'**
  String get analyzerXrayEmptyTitle;

  /// ATS check X-Ray, tab/heading over the list of detected problems.
  ///
  /// In en, this message translates to:
  /// **'Findings'**
  String get analyzerXrayFindings;

  /// ATS check findings rail, body of the no-issues state.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this PDF matched a known ATS parsing problem.'**
  String get analyzerXrayNoIssuesBody;

  /// ATS check findings rail, shown when the PDF matched none of the known parsing problems.
  ///
  /// In en, this message translates to:
  /// **'No issues found'**
  String get analyzerXrayNoIssuesTitle;

  /// ATS check X-Ray tab, body of the empty-page state.
  ///
  /// In en, this message translates to:
  /// **'No extractable text runs to draw boxes on.'**
  String get analyzerXrayPageEmptyBody;

  /// ATS check X-Ray tab, shown when the selected page has no extractable text to draw boxes over.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show on this page'**
  String get analyzerXrayPageEmptyTitle;

  /// ATS check X-Ray, the page navigator's position indicator. Both numbers are 1-based.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String analyzerXrayPageOf(int page, int total);

  /// ATS check X-Ray, tab/heading over the rendered PDF page view.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get analyzerXrayPageTab;

  /// ATS check X-Ray, toggle that numbers the text boxes in the order a machine would read them.
  ///
  /// In en, this message translates to:
  /// **'Reading order'**
  String get analyzerXrayReadingOrder;

  /// Main navigation rail, third destination. Checks a finished PDF for problems an Applicant Tracking System would hit. 'ATS' is a widely-used industry abbreviation — keep it if recognised in the target market, otherwise expand it.
  ///
  /// In en, this message translates to:
  /// **'ATS Check'**
  String get appNavAnalyzer;

  /// Main navigation rail, second destination — the list of CVs the user has built. The branch follows the user's default REGION's document noun, not their language: someone targeting the US market sees 'Résumés' even in a non-English UI. Translate each branch into the target language's word for that kind of document.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{CVs} resume{Résumés} other{Documents}}'**
  String appNavDrafts(String noun);

  /// Main navigation rail, pinned bottom destination.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appNavSettings;

  /// Main navigation rail, first destination. This app's name for the user's stored career history — a single place everything is kept and drawn from. Treat as a product term and keep it consistent everywhere it appears.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get appNavVault;

  /// ATS check finding body for a suspected multi-column layout. {left} and {right} are verbatim excerpts from the user's own PDF and must not be translated; {merged} shows the two run together to demonstrate the failure.
  ///
  /// In en, this message translates to:
  /// **'\"{left}\" and \"{right}\" sit on the same line with a wide gap between them. A text extractor that reads by position rather than by the document\'s own structure may merge these into one run, e.g. \"{merged}\".'**
  String atsFindingColumnCrushBody(String left, String right, String merged);

  /// ATS check finding title: two text runs sit on one line with a wide gap, which a position-sorting parser may merge incorrectly.
  ///
  /// In en, this message translates to:
  /// **'Possible multi-column layout'**
  String get atsFindingColumnCrushTitle;

  /// ATS check finding body for characters that vanished during extraction.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Found 1 short run where more space was used than the extracted characters account for} other{Found {count} short runs where more space was used than the extracted characters account for}} — a sign a symbol (often a bullet) silently failed to extract at all.'**
  String atsFindingDroppedCharsBody(int count);

  /// ATS check finding title: a run used more horizontal space than its characters account for, so a glyph likely failed to extract.
  ///
  /// In en, this message translates to:
  /// **'Possible dropped characters'**
  String get atsFindingDroppedCharsTitle;

  /// ATS check finding body for undecodable characters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Found 1 character that failed to decode to readable text} other{Found {count} characters that failed to decode to readable text}} — the font used likely has a missing or broken character map. An ATS will see this text as garbage.'**
  String atsFindingGarbledBody(int count);

  /// ATS check finding title: characters that failed to decode to readable text.
  ///
  /// In en, this message translates to:
  /// **'Unreadable characters found'**
  String get atsFindingGarbledTitle;

  /// ATS check finding body for icon-font glyphs. 'Wingdings' is a font name and stays untranslated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Found 1 character from a private-use code range} other{Found {count} characters from a private-use code range}} embedded within words — a common sign of an icon or symbol font (e.g. Wingdings) rather than real text, which most ATS parsers will render as blanks or gibberish.'**
  String atsFindingIconFontBody(int count);

  /// ATS check finding title: private-use-area codepoints inside words, typically an icon font used as if it were text.
  ///
  /// In en, this message translates to:
  /// **'Possible icon/symbol font glyphs in text'**
  String get atsFindingIconFontTitle;

  /// ATS check finding body for a missing canonical section heading. The first sentence varies by section; the explanation after it is shared.
  ///
  /// In en, this message translates to:
  /// **'{section, select, experience{Couldn\'t find a heading for Experience anywhere in the document.} education{Couldn\'t find a heading for Education anywhere in the document.} skills{Couldn\'t find a heading for Skills anywhere in the document.} other{Couldn\'t find a heading for {section} anywhere in the document.}} Some ATS software structures a resume by matching canonical section headings, and may file this content as unstructured text if the heading is missing or phrased unusually.'**
  String atsFindingMissingHeadingBody(String section);

  /// ATS check finding title for a canonical CV section whose heading could not be found. The branch names a section of a CV. Note the app searches the PDF for ENGLISH heading keywords because the CVs it produces are English, so this reports on an English document even in a translated UI.
  ///
  /// In en, this message translates to:
  /// **'{section, select, experience{No Experience section detected} education{No Education section detected} skills{No Skills section detected} other{No {section} section detected}}'**
  String atsFindingMissingHeadingTitle(String section);

  /// ATS check finding body for a missing email address.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find an email address in the extracted text or in any clickable link. Most ATS software requires a readable email address to file an application.'**
  String get atsFindingNoEmailBody;

  /// ATS check finding title: no email address in the extracted text or in any clickable link.
  ///
  /// In en, this message translates to:
  /// **'No email address found'**
  String get atsFindingNoEmailTitle;

  /// ATS check finding body for a non-embedded font. Only ever shown below one of the garbled-text findings, which is what 'found above' refers to.
  ///
  /// In en, this message translates to:
  /// **'This PDF relies on at least one font that is not embedded in the file. Combined with the unreadable text found above, this is a likely contributing cause.'**
  String get atsFindingNonEmbeddedFontBody;

  /// ATS check finding title: the PDF depends on a font that is not embedded in the file.
  ///
  /// In en, this message translates to:
  /// **'Non-embedded font in use'**
  String get atsFindingNonEmbeddedFontTitle;

  /// ATS check finding body for a missing phone number.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find a phone number in the extracted text or in any clickable link.'**
  String get atsFindingNoPhoneBody;

  /// ATS check finding title: no phone number in the extracted text or in any clickable link.
  ///
  /// In en, this message translates to:
  /// **'No phone number found'**
  String get atsFindingNoPhoneTitle;

  /// ATS check finding body for a PDF with no text layer. 'ATS' = Applicant Tracking System, the software employers use to parse CVs.
  ///
  /// In en, this message translates to:
  /// **'This PDF has no text layer at all — likely a scanned image. Most ATS software will read this as a completely blank resume.'**
  String get atsFindingNoTextLayerBody;

  /// ATS check finding title, most severe case: the uploaded PDF contains no machine-readable text at all.
  ///
  /// In en, this message translates to:
  /// **'No extractable text found'**
  String get atsFindingNoTextLayerTitle;

  /// ATS check finding body for a single page with no extractable text.
  ///
  /// In en, this message translates to:
  /// **'Page {page} contributed no text at all, while other pages did — an ATS will likely skip this page entirely.'**
  String atsFindingPageNoTextBody(int page);

  /// ATS check finding title for one page that yielded no text while other pages did. {page} is 1-based for display.
  ///
  /// In en, this message translates to:
  /// **'Page {page} has no extractable text'**
  String atsFindingPageNoTextTitle(int page);

  /// Body of the storage-unavailable error card, explaining the cause and the way out.
  ///
  /// In en, this message translates to:
  /// **'Local storage is unavailable in this browser or browsing mode. CVForge keeps everything on your device, so it needs access to it to work. Try a normal (non-private) browsing window, or a different browser.'**
  String get chromeStorageUnavailableBody;

  /// Full-page error card heading, shown when the browser's local storage cannot be read — typically private browsing or Firefox strict privacy mode.
  ///
  /// In en, this message translates to:
  /// **'CVForge couldn\'t load your data'**
  String get chromeStorageUnavailableTitle;

  /// Small action on a Vault section heading that appends a new, empty entry to that section.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// Chip-group action that selects every currently unselected chip. Shown only when at least one is unselected.
  ///
  /// In en, this message translates to:
  /// **'Add all ({count})'**
  String commonAddAll(int count);

  /// Badge beside a feature's heading marking it as early/unstable. Shared by every beta feature (AI tailoring, translation) - one statement about the app's confidence, so it lives in the common namespace rather than per-feature.
  ///
  /// In en, this message translates to:
  /// **'BETA'**
  String get commonBeta;

  /// Default label for the dismiss button on every dialog. Closes without applying changes.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Confirm button on the dialog that wipes the whole Vault.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// Tooltip on the button that empties a search field.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get commonClearSearch;

  /// Tooltip on the button that closes an open Vault editor panel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Confirm button on the dialog that makes a new CV.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// Default tooltip on the small delete icon button used throughout the Vault and Studio editors.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Button that stops Google Drive syncing, and the confirm button on its dialog.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get commonDisconnect;

  /// Button that closes an inline editor and keeps what was typed.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Tooltip on the button that reopens a long CV text field in a roomier dialog, and the fallback dialog title when the field has no label of its own. Studio's editor pane is narrow beside the live preview, so long prose is otherwise written through a slot.
  ///
  /// In en, this message translates to:
  /// **'Edit in a larger box'**
  String get commonExpandEditor;

  /// Tooltip on the bold button above a focused CV text field. The button wraps the selected words in the emphasis markers the document prints as bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get commonFormatBold;

  /// Tooltip on the italic button above a focused CV text field. The button wraps the selected words in the emphasis markers the document prints as italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get commonFormatItalic;

  /// Shown under a long CV text field as it nears the length that still fits on a page. Silent until close to the limit, so it reads as a warning rather than as a permanent counter. Counts printed characters, so emphasis markers do not count against it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 character left} other{{count} characters left}}'**
  String commonLengthBudgetLeft(int count);

  /// Shown under a CV text field whose text has passed the length that fits on a page. States the consequence rather than a number, because the number is not what the writer needs to act on.
  ///
  /// In en, this message translates to:
  /// **'Too long to fit on one page'**
  String get commonLengthBudgetOver;

  /// Shown above an open Studio editor when the field has been tailored, giving the wording the Vault still holds so the writer can see what this CV is diverging from. The prefix names the Vault, which is the app's own term for the master record.
  ///
  /// In en, this message translates to:
  /// **'Vault: {text}'**
  String commonVaultOriginal(String text);

  /// Tooltip on a button that opens an overflow menu of extra actions.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get commonMore;

  /// Relative timestamp for 2-29 days ago, used mid-sentence. Past 29 days the app switches to an absolute date instead.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String commonRelativeDaysAgo(int count);

  /// Relative timestamp for 1-23 hours ago, used mid-sentence. Past 24 hours the app switches to yesterday / N days ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String commonRelativeHoursAgo(int count);

  /// Absolute fallback for a timestamp older than about a month, used mid-sentence — e.g. 'Last backup: on 23/08/2026'. The day/month/year order is pinned deliberately and should follow the locale's own convention.
  ///
  /// In en, this message translates to:
  /// **'on {date}'**
  String commonRelativeOnDate(DateTime date);

  /// Relative timestamp for anything less than an hour old, used mid-sentence after a label like 'Updated'. Deliberately terse — it renders into caption-width slots and a spelled-out form ellipsised on the narrowest of them.
  ///
  /// In en, this message translates to:
  /// **'< 1 hour ago'**
  String get commonRelativeUnderAnHour;

  /// Relative timestamp for the previous day, used mid-sentence. Lowercase on purpose.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get commonRelativeYesterday;

  /// Confirm button on the dialog that deletes a stored API key.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// Chip-group action that deselects every currently selected chip. Shown only when at least one is selected.
  ///
  /// In en, this message translates to:
  /// **'Remove all ({count})'**
  String commonRemoveAll(int count);

  /// Confirm button on the dialog that replaces all local data with an imported backup.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get commonReplace;

  /// Generic confirm-button label on a dialog whose action resets something to a saved state. Shared, so it must stay generic — the dialog's own title says what is being reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// Button on the inline error banner shown when saving to local storage failed. Retries the failed write.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Button that starts the AI tailoring run.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get commonRun;

  /// Button label while the AI tailoring run is in progress.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get commonRunning;

  /// Confirm button on dialogs that persist an edit.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Neutral placeholder shown in a dropdown before the user has chosen anything.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// Button on the full-page card shown when local storage could not be read at all. Retries loading.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// Name of the language a CV can be written in, as Dansk writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Dansk'**
  String get documentLanguageDaName;

  /// Name of the language a CV can be written in, as Deutsch (Österreich) writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Deutsch (Österreich)'**
  String get documentLanguageDeAtName;

  /// Name of the language a CV can be written in, as Deutsch writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get documentLanguageDeName;

  /// Name of the language a CV can be written in, as English (Australia) writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'English (Australia)'**
  String get documentLanguageEnAuName;

  /// Name of the language a CV can be written in, as English (United Kingdom) writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'English (United Kingdom)'**
  String get documentLanguageEnGbName;

  /// Name of the language a CV can be written in, as English (United States) writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'English (United States)'**
  String get documentLanguageEnUsName;

  /// Name of the language a CV can be written in, as Español (Latinoamérica) writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Español (Latinoamérica)'**
  String get documentLanguageEs419Name;

  /// Name of the language a CV can be written in, as Español (España) writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Español (España)'**
  String get documentLanguageEsName;

  /// Name of the language a CV can be written in, as Suomi writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Suomi'**
  String get documentLanguageFiName;

  /// Name of the language a CV can be written in, as Français (Canada) writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Français (Canada)'**
  String get documentLanguageFrCaName;

  /// Name of the language a CV can be written in, as Français writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get documentLanguageFrName;

  /// Name of the language a CV can be written in, as Italiano writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get documentLanguageItName;

  /// Name of the language a CV can be written in, as Norsk bokmål writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Norsk bokmål'**
  String get documentLanguageNbName;

  /// Name of the language a CV can be written in, as Nederlands writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Nederlands'**
  String get documentLanguageNlName;

  /// Name of the language a CV can be written in, as Português (Brasil) writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Português (Brasil)'**
  String get documentLanguagePtBrName;

  /// Name of the language a CV can be written in, as Português (Portugal) writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Português (Portugal)'**
  String get documentLanguagePtPtName;

  /// Name of the language a CV can be written in, as Svenska writes it. An autonym: NEVER translate this — it is what makes the picker usable by someone who cannot read the app's current language. Shown in the document-language picker and on the Vault's CV defaults card.
  ///
  /// In en, this message translates to:
  /// **'Svenska'**
  String get documentLanguageSvName;

  /// The name given to a duplicated CV, based on the original's name.
  ///
  /// In en, this message translates to:
  /// **'{name} (copy)'**
  String draftCopySuffix(String name);

  /// The name a newly created CV gets before the user renames it.
  ///
  /// In en, this message translates to:
  /// **'My CV'**
  String get draftDefaultName;

  /// Stands in for the user's email address when it could not be read from Google. Appears mid-sentence, e.g. 'Connected as your Google account', so keep it lowercase.
  ///
  /// In en, this message translates to:
  /// **'your Google account'**
  String get driveSyncAccountFallback;

  /// Google Drive sync status message: the file stored on Drive could not be parsed, so nothing on this device was changed.
  ///
  /// In en, this message translates to:
  /// **'Drive\'s copy looked corrupted. Left this device as is.'**
  String get driveSyncErrorCorrupted;

  /// Google Drive sync status message: the app's own file was deleted from the user's Drive.
  ///
  /// In en, this message translates to:
  /// **'Your CVForge file on Drive is gone. Syncing again will recreate it.'**
  String get driveSyncErrorFileGone;

  /// Google Drive sync status message: the upload failed but local data is safe.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach Google Drive. Saved on this device.'**
  String get driveSyncErrorNetwork;

  /// Google Drive sync status message: the Drive file was written by a newer app version this build cannot safely read.
  ///
  /// In en, this message translates to:
  /// **'Another device is running a newer version of CVForge. Update this device to sync again.'**
  String get driveSyncErrorNewerVersion;

  /// Google Drive sync status message: an unclassified sync failure; local data is safe.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong syncing to Drive. Saved on this device.'**
  String get driveSyncErrorUnknown;

  /// Tooltip on the sync status icon just after incoming changes from another browser were merged into this one.
  ///
  /// In en, this message translates to:
  /// **'Merged changes from your other device'**
  String get driveSyncMerged;

  /// Tooltip on the sync status icon when the Google authorisation has expired or been revoked and syncing has stopped.
  ///
  /// In en, this message translates to:
  /// **'Reconnect Google Drive in Settings to keep syncing'**
  String get driveSyncNeedsReauth;

  /// Tooltip on the sync status icon when changes are queued but the debounced upload has not started yet.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync to Google Drive…'**
  String get driveSyncPending;

  /// Tooltip on the sync status icon in the app chrome, when everything is saved and the last sync time is not known.
  ///
  /// In en, this message translates to:
  /// **'Synced to Google Drive'**
  String get driveSyncSynced;

  /// Tooltip on the sync status icon when the last sync time is known. {relative} is an already-formatted phrase like 'today', 'yesterday', '12 days ago' or 'on 23/08/2026', so it arrives lowercase and mid-sentence.
  ///
  /// In en, this message translates to:
  /// **'Synced to Google Drive · {relative}'**
  String driveSyncSyncedAt(String relative);

  /// Tooltip on the sync status icon while an upload is in flight.
  ///
  /// In en, this message translates to:
  /// **'Syncing to Google Drive…'**
  String get driveSyncSyncing;

  /// This locale's own name, in this locale (an autonym). Shown in the Settings language picker. NEVER translate this into another language — it is what lets someone who landed in a language they cannot read find their way back.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeDisplayName;

  /// Paper size option. Includes the physical dimensions because 'A4' versus 'Letter' only means something to someone who already knows the difference.
  ///
  /// In en, this message translates to:
  /// **'A4 (210 × 297 mm)'**
  String get pageFormatA4;

  /// Paper size option, the North American standard. Includes the physical dimensions for the same reason as A4.
  ///
  /// In en, this message translates to:
  /// **'US Letter (8.5 × 11 in)'**
  String get pageFormatLetter;

  /// Region detail: CV header carries a location as well as name and contact.
  ///
  /// In en, this message translates to:
  /// **'Name, contact, city'**
  String get personalDetailsMinimal;

  /// Region detail: what a CV header carries in this market. The three options describe increasing amounts of personal information.
  ///
  /// In en, this message translates to:
  /// **'Name and contact only'**
  String get personalDetailsOmit;

  /// Region detail: CV header conventionally carries date of birth and nationality in this market.
  ///
  /// In en, this message translates to:
  /// **'Name, contact, date of birth, nationality'**
  String get personalDetailsTraditional;

  /// Region detail: photograph not expected, and a liability under equality law in this market.
  ///
  /// In en, this message translates to:
  /// **'No — strongly discouraged'**
  String get photoStanceDiscouraged;

  /// Region detail: a professional photograph is conventional in this market.
  ///
  /// In en, this message translates to:
  /// **'Usually expected'**
  String get photoStanceExpected;

  /// Region detail: a photograph is neither expected nor discouraged in this market.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get photoStanceOptional;

  /// Region detail: whether a CV should carry a photograph. This is the strongest 'no' on a four-point scale; the four options are meant to read against each other.
  ///
  /// In en, this message translates to:
  /// **'No — an automatic rejection'**
  String get photoStanceProhibited;

  /// Region picker: one of the ANZ market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Two to three pages is normal and expected. A one-page resume reads as thin here.'**
  String get regionAnzConvention1;

  /// Region picker: one of the ANZ market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'No photograph, date of birth, or marital status.'**
  String get regionAnzConvention2;

  /// Region picker: one of the ANZ market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'State your work rights in the header — \"Australian citizen\", \"NZ permanent resident\", \"482 visa\". Recruiters filter on this first.'**
  String get regionAnzConvention3;

  /// Region picker: one of the ANZ market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Include a dedicated \"Referees\" section with two named referees, or state that details are available on request.'**
  String get regionAnzConvention4;

  /// Region picker: one of the ANZ market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'If writing in English, use Australian spelling: organised, centre, analyse. Be consistent — some sectors accept -ize, but mixing the two is what gets noticed.'**
  String get regionAnzConvention5;

  /// Region picker: one of the ANZ market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Give more context per role than a US résumé would: company scope, reporting lines, team size, budget.'**
  String get regionAnzConvention6;

  /// Region picker: which countries the ANZ grouping covers. Use each country's own name in the target language.
  ///
  /// In en, this message translates to:
  /// **'Australia, New Zealand'**
  String get regionAnzCoverage;

  /// Region picker: the name of the ANZ market grouping.
  ///
  /// In en, this message translates to:
  /// **'Australia & New Zealand'**
  String get regionAnzDisplayName;

  /// Region picker: how long a CV should run in the ANZ market.
  ///
  /// In en, this message translates to:
  /// **'Two to three pages mid-career; three to five for executive roles.'**
  String get regionAnzLengthNote;

  /// Region picker: how achievements should be framed in the ANZ market.
  ///
  /// In en, this message translates to:
  /// **'Context-rich and concrete. Explain what the organisation does, the size of your remit, then the outcome — Australasian readers expect more surrounding detail than a US résumé gives.'**
  String get regionAnzToneNote;

  /// Region picker: one of the DACH market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Around two thirds of German-speaking employers still expect a professional headshot, top right. Upload one in the Vault and choose a template that includes one; the rest leave it off.'**
  String get regionDachConvention1;

  /// Region picker: one of the DACH market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Date and place of birth, nationality, and sometimes marital status are traditional in the personal-details block, and CVForge has no field for any of them. Younger and international employers increasingly omit them: omitting is safe, including is conventional.'**
  String get regionDachConvention2;

  /// Region picker: one of the DACH market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'The chronology must be gap-free and month-precise. An unexplained gap reads as concealment; label it plainly (\"Parental leave\", \"Further education\").'**
  String get regionDachConvention3;

  /// Region picker: one of the DACH market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Education stays prominent throughout your career, with the institution named and grades given.'**
  String get regionDachConvention4;

  /// Region picker: one of the DACH market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Certificates (Zeugnisse) are attached as a separate document; the Lebenslauf references them rather than reproducing them.'**
  String get regionDachConvention5;

  /// Region picker: one of the DACH market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'If writing in English, use British spelling.'**
  String get regionDachConvention6;

  /// Region picker: which countries the DACH grouping covers. Use each country's own name in the target language.
  ///
  /// In en, this message translates to:
  /// **'Germany, Austria, Switzerland'**
  String get regionDachCoverage;

  /// Region picker: the name of the DACH market grouping.
  ///
  /// In en, this message translates to:
  /// **'DACH'**
  String get regionDachDisplayName;

  /// Region picker: how long a CV should run in the DACH market.
  ///
  /// In en, this message translates to:
  /// **'Two to three pages, tabular and complete.'**
  String get regionDachLengthNote;

  /// Region picker: how achievements should be framed in the DACH market.
  ///
  /// In en, this message translates to:
  /// **'Formal, factual, complete. Understatement over salesmanship, verifiable facts over adjectives.'**
  String get regionDachToneNote;

  /// Region picker: one of the EUROPE market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'One to two pages. France in particular expects a single page for anything under about fifteen years\' experience.'**
  String get regionEuropeConvention1;

  /// Region picker: one of the EUROPE market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'A photograph is common in France, Spain, Italy, and Portugal, and unusual elsewhere. For an international or multinational application, leave it off.'**
  String get regionEuropeConvention2;

  /// Region picker: one of the EUROPE market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Keep personal data minimal for a multinational. A domestic French or Southern European employer may still expect date of birth and nationality.'**
  String get regionEuropeConvention3;

  /// Region picker: one of the EUROPE market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'List language proficiencies with CEFR levels (A1–C2). European recruiters read these precisely.'**
  String get regionEuropeConvention4;

  /// Region picker: one of the EUROPE market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Southern European employers tolerate longer CVs — four or five pages is seen — but a tighter document still reads better.'**
  String get regionEuropeConvention5;

  /// Region picker: one of the EUROPE market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'If writing in English, use British spelling. A local-language version is worth producing for a domestic application.'**
  String get regionEuropeConvention6;

  /// Region picker: which countries the EUROPE grouping covers. Use each country's own name in the target language.
  ///
  /// In en, this message translates to:
  /// **'France, Benelux, Southern Europe, and multinationals'**
  String get regionEuropeCoverage;

  /// Region picker: the name of the EUROPE market grouping.
  ///
  /// In en, this message translates to:
  /// **'Europe — international'**
  String get regionEuropeDisplayName;

  /// Region picker: how long a CV should run in the EUROPE market.
  ///
  /// In en, this message translates to:
  /// **'One to two pages. France prefers one; Southern Europe tolerates more.'**
  String get regionEuropeLengthNote;

  /// Region picker: how achievements should be framed in the EUROPE market.
  ///
  /// In en, this message translates to:
  /// **'Professional and measured. Concrete results, without the hard-sell register of a US résumé.'**
  String get regionEuropeToneNote;

  /// Region picker: one of the LATAMA4 market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'A4 is standard across Brazil, Argentina, Uruguay, and Peru. For Mexico, Colombia, Chile, or Central America, pick \"Mexico, Colombia & Chile\" instead — those markets use US Letter.'**
  String get regionLatamA4Convention1;

  /// Region picker: one of the LATAMA4 market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'The document is a \"Currículo\" in Brazil and a \"Curriculum Vitae\" across the Southern Cone.'**
  String get regionLatamA4Convention2;

  /// Region picker: one of the LATAMA4 market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'A photograph, date of birth, marital status, and national ID number (CPF, DNI/CUIL) are common at domestic firms, and deliberately excluded by multinationals and their local subsidiaries. Match the employer, not the country. CVForge renders a photograph when the template supports one; it has no field for the rest.'**
  String get regionLatamA4Convention3;

  /// Region picker: one of the LATAMA4 market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Two to three pages is normal.'**
  String get regionLatamA4Convention4;

  /// Region picker: one of the LATAMA4 market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Certified language proficiency is a primary screening filter, especially in Brazil: state TOEFL, IELTS, DELE, or CELPE-Bras scores with the date taken.'**
  String get regionLatamA4Convention5;

  /// Region picker: one of the LATAMA4 market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Name the institution for every qualification; university reputation is read closely.'**
  String get regionLatamA4Convention6;

  /// Region picker: one of the LATAMA4 market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'If writing in English, US spelling is the regional norm.'**
  String get regionLatamA4Convention7;

  /// Region picker: which countries the LATAMA4 grouping covers. Use each country's own name in the target language.
  ///
  /// In en, this message translates to:
  /// **'Brazil, Argentina, Uruguay, Peru'**
  String get regionLatamA4Coverage;

  /// Region picker: the name of the LATAMA4 market grouping.
  ///
  /// In en, this message translates to:
  /// **'Brazil & Southern Cone'**
  String get regionLatamA4DisplayName;

  /// Region picker: how long a CV should run in the LATAMA4 market.
  ///
  /// In en, this message translates to:
  /// **'Two to three pages.'**
  String get regionLatamA4LengthNote;

  /// Region picker: how achievements should be framed in the LATAMA4 market.
  ///
  /// In en, this message translates to:
  /// **'Formal and credential-forward. Qualifications, institutions, and certifications carry real weight — state them fully.'**
  String get regionLatamA4ToneNote;

  /// Region picker: one of the LATAMLETTER market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'US Letter is standard across Mexico, Colombia, Chile, and Central America. For Brazil, Argentina, Uruguay, or Peru, pick \"Brazil & Southern Cone\" instead — those markets use A4.'**
  String get regionLatamLetterConvention1;

  /// Region picker: one of the LATAMLETTER market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'The document is a \"Hoja de Vida\" in Colombia and the Andean countries, and a \"Currículum Vitae\" in Mexico and Central America.'**
  String get regionLatamLetterConvention2;

  /// Region picker: one of the LATAMLETTER market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'A photograph, date of birth, marital status, and national ID number (CURP/RFC, Cédula) are common at domestic firms, and deliberately excluded by multinationals and their local subsidiaries. Match the employer, not the country. CVForge renders a photograph when the template supports one; it has no field for the rest.'**
  String get regionLatamLetterConvention3;

  /// Region picker: one of the LATAMLETTER market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Two to three pages is normal.'**
  String get regionLatamLetterConvention4;

  /// Region picker: one of the LATAMLETTER market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Certified language proficiency carries real weight: state TOEFL, IELTS, or DELE scores with the date taken.'**
  String get regionLatamLetterConvention5;

  /// Region picker: one of the LATAMLETTER market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Name the institution for every qualification; university reputation is read closely.'**
  String get regionLatamLetterConvention6;

  /// Region picker: one of the LATAMLETTER market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'If writing in English, US spelling is the regional norm.'**
  String get regionLatamLetterConvention7;

  /// Region picker: which countries the LATAMLETTER grouping covers. Use each country's own name in the target language.
  ///
  /// In en, this message translates to:
  /// **'Mexico, Colombia, Chile, Central America'**
  String get regionLatamLetterCoverage;

  /// Region picker: the name of the LATAMLETTER market grouping.
  ///
  /// In en, this message translates to:
  /// **'Mexico, Colombia & Chile'**
  String get regionLatamLetterDisplayName;

  /// Region picker: how long a CV should run in the LATAMLETTER market.
  ///
  /// In en, this message translates to:
  /// **'Two to three pages.'**
  String get regionLatamLetterLengthNote;

  /// Region picker: how achievements should be framed in the LATAMLETTER market.
  ///
  /// In en, this message translates to:
  /// **'Formal and credential-forward. Qualifications, institutions, and certifications carry real weight — state them fully.'**
  String get regionLatamLetterToneNote;

  /// Region picker: one of the NORDICS market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'One to two pages. A long CV reads as poor editing.'**
  String get regionNordicsConvention1;

  /// Region picker: one of the NORDICS market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'A photograph is neither expected nor unwelcome. Include one only if it is genuinely professional.'**
  String get regionNordicsConvention2;

  /// Region picker: one of the NORDICS market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Keep personal data minimal: name, contact, city. No date of birth, marital status, or national ID number.'**
  String get regionNordicsConvention3;

  /// Region picker: one of the NORDICS market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Frame achievements around the team and the outcome rather than personal heroics.'**
  String get regionNordicsConvention4;

  /// Region picker: one of the NORDICS market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'State Scandinavian language proficiency explicitly with a level (\"Swedish — B2\"). It moves the needle.'**
  String get regionNordicsConvention5;

  /// Region picker: one of the NORDICS market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'English CVs are widely accepted; if you write in English, use British spelling.'**
  String get regionNordicsConvention6;

  /// Region picker: which countries the NORDICS grouping covers. Use each country's own name in the target language.
  ///
  /// In en, this message translates to:
  /// **'Sweden, Norway, Denmark, Finland'**
  String get regionNordicsCoverage;

  /// Region picker: the name of the NORDICS market grouping.
  ///
  /// In en, this message translates to:
  /// **'Nordics'**
  String get regionNordicsDisplayName;

  /// Region picker: how long a CV should run in the NORDICS market.
  ///
  /// In en, this message translates to:
  /// **'One to two pages. Concision is read as a virtue here.'**
  String get regionNordicsLengthNote;

  /// Region picker: how achievements should be framed in the NORDICS market.
  ///
  /// In en, this message translates to:
  /// **'Factual and team-framed. Say what the team achieved and what your part in it was; \"I single-handedly\" reads badly across the Nordics.'**
  String get regionNordicsToneNote;

  /// Region picker: one of the UK market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Two pages is the norm. One page for a recent graduate; three only for academic or very senior roles.'**
  String get regionUkConvention1;

  /// Region picker: one of the UK market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'No photograph, date of birth, marital status, or nationality. UK equality law makes them a liability for the employer as much as for you.'**
  String get regionUkConvention2;

  /// Region picker: one of the UK market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'If writing in English, use British spelling throughout: organised, programme, centre, analyse.'**
  String get regionUkConvention3;

  /// Region picker: one of the UK market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'\"References available on request\" at the foot is still expected. Do not list referees\' contact details.'**
  String get regionUkConvention4;

  /// Region picker: one of the UK market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Open with a short personal statement or profile.'**
  String get regionUkConvention5;

  /// Region picker: one of the UK market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Ireland follows the same conventions. State your work authorisation if you are not an EU or UK citizen.'**
  String get regionUkConvention6;

  /// Region picker: which countries the UK grouping covers. Use each country's own name in the target language.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom, Ireland'**
  String get regionUkCoverage;

  /// Region picker: the name of the UK market grouping.
  ///
  /// In en, this message translates to:
  /// **'UK & Ireland'**
  String get regionUkDisplayName;

  /// Region picker: how long a CV should run in the UK market.
  ///
  /// In en, this message translates to:
  /// **'Two pages is the standard. One page is fine for a recent graduate.'**
  String get regionUkLengthNote;

  /// Region picker: how achievements should be framed in the UK market.
  ///
  /// In en, this message translates to:
  /// **'Understated and factual. State achievements plainly with the evidence behind them; overt self-promotion reads as boastful.'**
  String get regionUkToneNote;

  /// Region picker: one of the US market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'One page until roughly ten years of experience, two beyond that. Three pages means an academic CV, which is a different document.'**
  String get regionUsConvention1;

  /// Region picker: one of the US market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Never include a photograph, date of birth, marital status, or gender. US employers routinely discard résumés carrying them to avoid discrimination claims.'**
  String get regionUsConvention2;

  /// Region picker: one of the US market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Single column. No tables, text boxes, headers, or footers — US applicant tracking systems are the strictest anywhere and mis-parse everything else.'**
  String get regionUsConvention3;

  /// Region picker: one of the US market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'If writing in English, use US spelling: organized, program, center, analyze.'**
  String get regionUsConvention4;

  /// Region picker: one of the US market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Quantify everything you can. An unquantified bullet reads as a job description rather than an achievement.'**
  String get regionUsConvention5;

  /// Region picker: one of the US market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Do not add a references line; it is assumed.'**
  String get regionUsConvention6;

  /// Region picker: one of the US market's CV conventions, rendered as a bullet and read on its own. A complete sentence.
  ///
  /// In en, this message translates to:
  /// **'Canada follows the same conventions. Quebec roles may expect a French-language version alongside.'**
  String get regionUsConvention7;

  /// Region picker: which countries the US grouping covers. Use each country's own name in the target language.
  ///
  /// In en, this message translates to:
  /// **'United States, Canada'**
  String get regionUsCoverage;

  /// Region picker: the name of the US market grouping.
  ///
  /// In en, this message translates to:
  /// **'US & Canada'**
  String get regionUsDisplayName;

  /// Region picker: how long a CV should run in the US market.
  ///
  /// In en, this message translates to:
  /// **'One page under about ten years\' experience; two pages beyond that.'**
  String get regionUsLengthNote;

  /// Region picker: how achievements should be framed in the US market.
  ///
  /// In en, this message translates to:
  /// **'Quantified and outcome-led. Lead each bullet with the result and a number — revenue, percentage, headcount, time saved.'**
  String get regionUsToneNote;

  /// Studio's section-visibility picker: qualifications.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get sectionLabelEducation;

  /// Studio's section-visibility picker: jobs and roles.
  ///
  /// In en, this message translates to:
  /// **'Work history'**
  String get sectionLabelExperience;

  /// Studio's section-visibility picker: personal interests.
  ///
  /// In en, this message translates to:
  /// **'Hobbies and interests'**
  String get sectionLabelHobbies;

  /// Studio's section-visibility picker: languages the person speaks.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get sectionLabelLanguages;

  /// Studio's section-visibility picker: the projects section.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get sectionLabelProjects;

  /// Studio's section-visibility picker: published work.
  ///
  /// In en, this message translates to:
  /// **'Publications'**
  String get sectionLabelPublications;

  /// Studio's section-visibility picker: the references note.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get sectionLabelReferences;

  /// Studio's section-visibility picker: the skills section.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get sectionLabelSkills;

  /// Studio's section-visibility picker: the CV's opening paragraph. This is the PICKER's label — deliberately separate from the heading printed on the PDF, which follows the document's own language, not the app's.
  ///
  /// In en, this message translates to:
  /// **'Professional summary'**
  String get sectionLabelSummary;

  /// Settings, AI card body. 'Bring your own API key' (BYOK) means the user supplies their own paid account rather than the app providing one.
  ///
  /// In en, this message translates to:
  /// **'Bring your own API key to enable AI-assisted tailoring. Your key never leaves this device except to call the provider\'s API directly. There is no CVForge server.'**
  String get settingsAiBody;

  /// Settings, shown when this user has configured the AI Assistant elsewhere but this browser has no key. Explains that the key deliberately did not sync.
  ///
  /// In en, this message translates to:
  /// **'You set the AI Assistant up on another device. Your CVs synced, but your key stayed there on purpose — paste your {provider} key below to use the assistant here too.'**
  String settingsAiConfiguredElsewhere(String provider);

  /// Settings, confirmation shown after a successful AI connection test.
  ///
  /// In en, this message translates to:
  /// **'Connected.'**
  String get settingsAiConnected;

  /// Settings, AI connection test error: the request was malformed, which is the app's fault rather than the user's.
  ///
  /// In en, this message translates to:
  /// **'{provider} rejected the request. That\'s a bug in CVForge, not your key.'**
  String settingsAiErrorInvalidRequest(String provider);

  /// Settings, AI connection test error: the provider's reply could not be parsed.
  ///
  /// In en, this message translates to:
  /// **'Got an unexpected response. Try again.'**
  String get settingsAiErrorMalformedResponse;

  /// Settings, AI connection test error: the request never reached the provider.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach {provider}. Check your connection.'**
  String settingsAiErrorNetwork(String provider);

  /// Settings, AI connection test error: the field was empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an API key first.'**
  String get settingsAiErrorNoKey;

  /// Settings, AI connection test error: the provider's service is overloaded.
  ///
  /// In en, this message translates to:
  /// **'{provider}\'s API is temporarily unavailable. Try again shortly.'**
  String settingsAiErrorOverloaded(String provider);

  /// Settings, AI connection test error: too many requests to the provider.
  ///
  /// In en, this message translates to:
  /// **'Your API account is rate limited. Try again in a moment.'**
  String get settingsAiErrorRateLimited;

  /// Settings, AI connection test error: the model declined to answer the check.
  ///
  /// In en, this message translates to:
  /// **'The connection check was refused.'**
  String get settingsAiErrorRefusal;

  /// Settings, AI connection test error: the provider did not respond in time.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Try again.'**
  String get settingsAiErrorTimeout;

  /// Settings, AI connection test error: the provider rejected the key as invalid.
  ///
  /// In en, this message translates to:
  /// **'That key was rejected. Check it and try again.'**
  String get settingsAiErrorUnauthorized;

  /// Settings, safety advice item about using a separate key per application.
  ///
  /// In en, this message translates to:
  /// **'Use a key created only for CVForge, so you can revoke it without breaking anything else.'**
  String get settingsAiHelpDedicatedKey;

  /// Settings, safety advice item. 'auto top-up' / 'auto-reload' are the provider's own terms for automatically buying more credit.
  ///
  /// In en, this message translates to:
  /// **'Turn OFF auto top-up / auto-reload. Left on, a runaway or leaked key can recharge itself indefinitely.'**
  String get settingsAiHelpNoAutoTopUp;

  /// Settings, link that opens the provider's billing page in a new tab.
  ///
  /// In en, this message translates to:
  /// **'Open billing & spend limits'**
  String get settingsAiHelpOpenBilling;

  /// Settings, link that opens the provider's own API key page in a new tab.
  ///
  /// In en, this message translates to:
  /// **'Open {provider} key settings'**
  String settingsAiHelpOpenKeySettings(String provider);

  /// Settings, heading of the safety advice list in the API key help panel.
  ///
  /// In en, this message translates to:
  /// **'Protect yourself from surprise bills'**
  String get settingsAiHelpProtectTitle;

  /// Settings, safety advice item about limiting monthly spending.
  ///
  /// In en, this message translates to:
  /// **'Set a hard monthly spend cap, as low as you are willing to pay.'**
  String get settingsAiHelpSpendCap;

  /// Settings, the numeral prefixing each step in the API key help list — e.g. '1.'. Use whatever numbering punctuation is conventional for the locale.
  ///
  /// In en, this message translates to:
  /// **'{number}.'**
  String settingsAiHelpStepNumber(int number);

  /// Settings, heading of the expandable help panel explaining how to obtain an API key.
  ///
  /// In en, this message translates to:
  /// **'How do I get a {provider} API key?'**
  String settingsAiHelpTitle(String provider);

  /// Settings, button that cancels replacing an existing API key.
  ///
  /// In en, this message translates to:
  /// **'Keep my current key'**
  String get settingsAiKeepCurrentKey;

  /// Settings, placeholder text inside the empty API key field.
  ///
  /// In en, this message translates to:
  /// **'Paste your API key'**
  String get settingsAiKeyFieldHint;

  /// Settings, label on the API key text field, naming the selected provider.
  ///
  /// In en, this message translates to:
  /// **'{provider} API key'**
  String settingsAiKeyFieldLabel(String provider);

  /// Settings, status line when no key is stored for the selected provider.
  ///
  /// In en, this message translates to:
  /// **'No {provider} key yet. The AI Assistant is off.'**
  String settingsAiKeyNone(String provider);

  /// Settings, status line when a key is stored persistently.
  ///
  /// In en, this message translates to:
  /// **'Your {provider} key is saved on this device.'**
  String settingsAiKeySaved(String provider);

  /// Settings, helper text under the API key field, explaining the key is not stored until verified.
  ///
  /// In en, this message translates to:
  /// **'Your key is saved only if the connection test succeeds.'**
  String get settingsAiKeySavedOnSuccess;

  /// Settings, status line when a key was entered but not persisted.
  ///
  /// In en, this message translates to:
  /// **'Your {provider} key is set for this session only. It will be gone when you reload the page.'**
  String settingsAiKeySession(String provider);

  /// Settings, label on the dropdown choosing which AI model to use.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get settingsAiModelLabel;

  /// Settings, note under the model dropdown clarifying that the AI provider bills the user directly.
  ///
  /// In en, this message translates to:
  /// **'{provider}\'s own rate, not billed by CVForge: {price}'**
  String settingsAiPriceLabel(String provider, String price);

  /// Settings, the model's price per million tokens, split into input and output rates. Prices are in US dollars because the AI providers bill in USD — keep the dollar sign whatever the locale.
  ///
  /// In en, this message translates to:
  /// **'{input} in / {output} out per M tokens'**
  String settingsAiPriceRate(double input, double output);

  /// Settings, label on the dropdown choosing which AI company to use.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get settingsAiProviderLabel;

  /// Settings, button that deletes the stored API key.
  ///
  /// In en, this message translates to:
  /// **'Remove key'**
  String get settingsAiRemoveKey;

  /// Settings, body of the API key removal dialog, explaining the action is not undoable.
  ///
  /// In en, this message translates to:
  /// **'{provider} won\'t show you this key again, so you\'d need to create a new one in their console to use the AI Assistant on this device. Your CVs and Vault are not affected.'**
  String settingsAiRemoveKeyConfirmBody(String provider);

  /// Settings, title of the dialog confirming API key deletion.
  ///
  /// In en, this message translates to:
  /// **'Remove your {provider} key?'**
  String settingsAiRemoveKeyConfirmTitle(String provider);

  /// Settings, button that reveals the field to enter a new API key over the existing one.
  ///
  /// In en, this message translates to:
  /// **'Replace key'**
  String get settingsAiReplaceKey;

  /// Settings, security warning shown near the API key field.
  ///
  /// In en, this message translates to:
  /// **'Your key is saved on this device, unencrypted in this browser\'s storage — the same as your Vault and CVs. Anyone with access to this device can read it.'**
  String get settingsAiStorageWarning;

  /// Settings, button that verifies a newly entered API key and stores it if it works.
  ///
  /// In en, this message translates to:
  /// **'Test and save'**
  String get settingsAiTestAndSave;

  /// Settings, button that verifies the already-saved API key still works.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get settingsAiTestConnection;

  /// Settings, AI card heading. An optional feature that tailors a CV to a job description using the user's own API key.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get settingsAiTitle;

  /// Settings, appearance card body. Stresses that the theme is chrome-only and never affects the exported PDF.
  ///
  /// In en, this message translates to:
  /// **'Applies to CVForge\'s own interface. Your CV always renders on white paper, whichever theme you pick.'**
  String get settingsAppearanceBody;

  /// Settings, appearance card heading — light/dark theme choice.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// Settings, backup card body explaining export and import.
  ///
  /// In en, this message translates to:
  /// **'Export your whole Vault and every CV as one JSON file, or restore from a previous export. Restoring replaces everything currently on this device. Your current data downloads as a backup first.'**
  String get settingsBackupBody;

  /// Settings, button that downloads all data as a JSON file.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsBackupExport;

  /// Settings, button that opens a file picker to restore from a backup file.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get settingsBackupImport;

  /// Settings, backup status line when nothing has changed since the last export.
  ///
  /// In en, this message translates to:
  /// **'Last backed up {relative}'**
  String settingsBackupLast(String relative);

  /// Settings, backup status line when data has changed since the last export. {relative} is an already-formatted lowercase phrase like 'yesterday' or '12 days ago'.
  ///
  /// In en, this message translates to:
  /// **'Last backed up {relative}, and you have changes since then'**
  String settingsBackupLastWithChanges(String relative);

  /// Settings, backup status line when no export has ever been made on this device.
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get settingsBackupNever;

  /// Settings, backup card heading.
  ///
  /// In en, this message translates to:
  /// **'Manual backup'**
  String get settingsBackupTitle;

  /// Settings, button that deletes every entry in the user's Vault.
  ///
  /// In en, this message translates to:
  /// **'Clear Vault'**
  String get settingsClearVault;

  /// Settings, body of the clear-Vault confirmation dialog. The list names the kinds of entry a Vault holds.
  ///
  /// In en, this message translates to:
  /// **'This removes every experience, project, skill, education entry, hobby, and publication. This can\'t be undone.'**
  String get settingsClearVaultConfirmBody;

  /// Settings, title of the dialog confirming deletion of all Vault content.
  ///
  /// In en, this message translates to:
  /// **'Clear your entire Vault?'**
  String get settingsClearVaultConfirmTitle;

  /// Settings, heading above destructive actions. A common convention for a visually separated section of irreversible operations.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get settingsDangerZone;

  /// Settings, Drive card body explaining what connecting does.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to keep your Vault and every CV synced to your own Google Drive. Sign in again on another browser and they\'ll all be there. CVForge never sees or stores your Google credentials, only a single hidden file this app creates for itself.'**
  String get settingsDriveBody;

  /// Settings, button that starts the Google sign-in flow.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Drive'**
  String get settingsDriveConnect;

  /// Settings, shows which Google account is currently linked.
  ///
  /// In en, this message translates to:
  /// **'Connected as {email}'**
  String settingsDriveConnectedAs(String email);

  /// Settings, Drive status while the Google sign-in flow is in progress.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get settingsDriveConnecting;

  /// Settings, body of the Drive disconnect dialog. Stresses that no data is deleted, since users commonly read 'disconnect' as 'delete'.
  ///
  /// In en, this message translates to:
  /// **'Your Vault and CVs stay exactly as they are on this device. This only stops syncing them to Drive. You can reconnect any time.'**
  String get settingsDriveDisconnectConfirmBody;

  /// Settings, title of the dialog confirming Drive disconnection.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Google Drive?'**
  String get settingsDriveDisconnectConfirmTitle;

  /// Settings, Drive error: the user closed the Google popup, or a popup blocker stopped it.
  ///
  /// In en, this message translates to:
  /// **'Connection cancelled.'**
  String get settingsDriveErrorCancelled;

  /// Settings, Drive error: this build has no Google client id compiled in.
  ///
  /// In en, this message translates to:
  /// **'Google Drive sync is not set up.'**
  String get settingsDriveErrorNotConfigured;

  /// Settings, Drive error: Google's sign-in script failed to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach Google. Check your connection and try again.'**
  String get settingsDriveErrorScriptLoad;

  /// Settings, Drive error: an unclassified sign-in failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect to Google Drive. Try again.'**
  String get settingsDriveErrorUnknown;

  /// Settings, Drive status naming when the last successful sync happened.
  ///
  /// In en, this message translates to:
  /// **'Last synced {relative}'**
  String settingsDriveLastSynced(String relative);

  /// Settings, Drive status just after incoming changes were merged in.
  ///
  /// In en, this message translates to:
  /// **'Merged changes from your other device'**
  String get settingsDriveMerged;

  /// Settings, Drive status when connected but no sync has completed yet.
  ///
  /// In en, this message translates to:
  /// **'Not yet synced'**
  String get settingsDriveNotYetSynced;

  /// Settings, button that re-runs the Google sign-in flow after authorisation expired.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get settingsDriveReconnect;

  /// Settings, shown when the Google authorisation expired and syncing has stopped.
  ///
  /// In en, this message translates to:
  /// **'Connected as {email}. Reconnect to keep syncing.'**
  String settingsDriveReconnectPrompt(String email);

  /// Settings, Drive status while an upload is in flight.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get settingsDriveSyncing;

  /// Settings, button that forces an immediate sync instead of waiting for the debounce.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get settingsDriveSyncNow;

  /// Settings, Drive card heading. A product name — keep as-is.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get settingsDriveTitle;

  /// Settings, Drive status when changes are queued but the upload has not started.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync…'**
  String get settingsDriveWaiting;

  /// Settings, body of the import confirmation dialog. The branch follows the user's default REGION's document noun, not their language. {current} is how many documents exist now; {incoming} is how many the file contains.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{This will replace your Vault and all {current} CVs with {incoming} CVs from this file.} resume{This will replace your Vault and all {current} résumés with {incoming} résumés from this file.} other{This will replace your Vault and all {current} documents with {incoming} documents from this file.}} Your current data downloads as a backup first.'**
  String settingsImportConfirmBody(String noun, int current, int incoming);

  /// Settings, title of the dialog confirming a backup import, which overwrites everything.
  ///
  /// In en, this message translates to:
  /// **'Replace your data?'**
  String get settingsImportConfirmTitle;

  /// Settings, error shown when the import file could not be read from disk.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that file. Try again.'**
  String get settingsImportErrorIo;

  /// Settings, error shown when the chosen import file could not be parsed as a backup.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t a valid CVForge backup.'**
  String get settingsImportErrorMalformed;

  /// Settings, error shown when the backup file's schema is newer than this build understands.
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of CVForge.'**
  String get settingsImportErrorNewerVersion;

  /// Settings, language card body. Says what this setting does NOT control — the document's own language, which lives on the Vault — because the two are the app's most confusable pair.
  ///
  /// In en, this message translates to:
  /// **'The language CVForge\'s own buttons and labels are shown in. The language your CV is written in is separate, and lives in the Vault.'**
  String get settingsLanguageCardBody;

  /// Settings, language card, section heading. Sits above a one-line body paragraph.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageCardTitle;

  /// Settings, language picker, the first option. Selecting it clears the stored preference so the app follows the browser locale.
  ///
  /// In en, this message translates to:
  /// **'Use my browser\'s language'**
  String get settingsLanguageFollowSystem;

  /// Settings, footer link to the privacy policy page.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsLinkPrivacy;

  /// Settings, footer link to the terms of service page.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsLinkTerms;

  /// Stands in for a skill category's name while it is still blank. Shown wherever the name is displayed (a chip-group heading, a menu item); the editor field itself still shows the real empty value.
  ///
  /// In en, this message translates to:
  /// **'Unnamed category'**
  String get skillCategoryUnnamed;

  /// Region detail: which spelling convention the CV should use.
  ///
  /// In en, this message translates to:
  /// **'Australian English'**
  String get spellingEnAu;

  /// Region detail: which spelling convention the CV should use.
  ///
  /// In en, this message translates to:
  /// **'British English'**
  String get spellingEnGb;

  /// Region detail: which spelling convention the CV should use.
  ///
  /// In en, this message translates to:
  /// **'US English'**
  String get spellingEnUs;

  /// Studio AI card body when an API key is configured.
  ///
  /// In en, this message translates to:
  /// **'Paste the job ad here to select and rewrite this CV for it.'**
  String get studioAiCardBody;

  /// Studio AI card body when no API key is configured yet.
  ///
  /// In en, this message translates to:
  /// **'Bring your own API key in Settings, then paste a job ad here to select and rewrite this CV for it.'**
  String get studioAiCardBodyNoKey;

  /// Studio AI card heading, and the button that opens the run dialog.
  ///
  /// In en, this message translates to:
  /// **'Tailor with AI'**
  String get studioAiCardTitle;

  /// Tooltip on the button that empties the job description field.
  ///
  /// In en, this message translates to:
  /// **'Clear job description'**
  String get studioAiClearJobDescription;

  /// Confirm screen of both AI dialogs (tailoring and translation) — roughly what this run will cost. In US cents because both providers price and bill in USD, so it matches the invoice; do not convert to a local currency, the app has no way to keep a rate current. Approximate by nature: token counts are inferred from character counts.
  ///
  /// In en, this message translates to:
  /// **'{cents, plural, =0{Under 1¢ at current rates.} one{About 1¢ at current rates.} other{About {cents}¢ at current rates.}}'**
  String studioAiCostEstimate(int cents);

  /// AI dialog, note naming the language the assistant will write the tailored bullets in. Sits beside the region note. Names it explicitly because translating someone's career history is a larger surprise than a page size if they had not noticed the setting.
  ///
  /// In en, this message translates to:
  /// **'Written in {language} — the assistant translates your bullets if your Vault is in another language.'**
  String studioAiDialogLanguageNote(String language);

  /// AI dialog, privacy note listing exactly what is and is not transmitted. The exclusions matter; keep them explicit.
  ///
  /// In en, this message translates to:
  /// **'This sends the job description below and your CV content — not your name, email, phone, or links — to {provider}, using your own API key. There is no CVForge server in between. This can take up to a few minutes — the model reasons through your whole Vault before responding.'**
  String studioAiDialogPrivacy(String provider);

  /// AI dialog, note naming which regional CV conventions the AI will follow. Deliberately no longer mentions spelling: the line directly below names the document's language, and spelling only applies within English — see _languageBlock, which drops the spelling instruction entirely for a non-English document.
  ///
  /// In en, this message translates to:
  /// **'Tailored for {region} — the assistant follows that market\'s length and tone conventions.'**
  String studioAiDialogRegionNote(String region);

  /// Title of the dialog that rewrites a CV against a job description using AI.
  ///
  /// In en, this message translates to:
  /// **'Tailor with AI'**
  String get studioAiDialogTitle;

  /// Button that reopens the job description for editing.
  ///
  /// In en, this message translates to:
  /// **'Edit job description'**
  String get studioAiEditJobDescription;

  /// AI run error: an unclassified failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong — try again.'**
  String get studioAiErrorGeneric;

  /// AI run error: a malformed request, which is the app's fault rather than the user's.
  ///
  /// In en, this message translates to:
  /// **'{provider} rejected the request. That\'s a bug in CVForge, not your input.'**
  String studioAiErrorInvalidRequest(String provider);

  /// AI run error: the provider's reply could not be parsed.
  ///
  /// In en, this message translates to:
  /// **'Got an unexpected response — try again.'**
  String get studioAiErrorMalformedResponse;

  /// AI run error: the request never reached the provider.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach {provider} — check your connection.'**
  String studioAiErrorNetwork(String provider);

  /// AI run error: no API key is configured.
  ///
  /// In en, this message translates to:
  /// **'Add an AI Assistant API key in Settings first.'**
  String get studioAiErrorNoKey;

  /// AI run error: the provider's service is overloaded.
  ///
  /// In en, this message translates to:
  /// **'{provider}\'s API is temporarily unavailable — try again shortly.'**
  String studioAiErrorOverloaded(String provider);

  /// AI run error: too many requests.
  ///
  /// In en, this message translates to:
  /// **'Your API account is rate limited — try again in a moment.'**
  String get studioAiErrorRateLimited;

  /// AI run error: the model refused to produce a result.
  ///
  /// In en, this message translates to:
  /// **'The model declined to answer — try rephrasing the job description.'**
  String get studioAiErrorRefusal;

  /// AI run error: the provider did not respond in time.
  ///
  /// In en, this message translates to:
  /// **'The request timed out — try again.'**
  String get studioAiErrorTimeout;

  /// AI run error: the provider rejected the key.
  ///
  /// In en, this message translates to:
  /// **'Your API key was rejected — check it in Settings.'**
  String get studioAiErrorUnauthorized;

  /// AI dialog, heading shown when the run failed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get studioAiFailedTitle;

  /// AI dialog, one bullet in the 'Not covered by your Vault' list. The leading middle dot is the bullet mark.
  ///
  /// In en, this message translates to:
  /// **'• {gap}'**
  String studioAiGapItem(String gap);

  /// Studio AI card, placeholder in the job description text area.
  ///
  /// In en, this message translates to:
  /// **'Paste the job ad you\'re tailoring this CV for.'**
  String get studioAiJobAdHint;

  /// AI dialog, heading above job-ad requirements the user's Vault has no evidence for.
  ///
  /// In en, this message translates to:
  /// **'Not covered by your Vault'**
  String get studioAiKeywordGaps;

  /// AI dialog, heading above the model's explanation of the choices it made.
  ///
  /// In en, this message translates to:
  /// **'Rationale'**
  String get studioAiRationale;

  /// AI dialog, body shown while the run is in progress, warning against closing it.
  ///
  /// In en, this message translates to:
  /// **'This can take up to a few minutes. Please keep this dialog open.'**
  String get studioAiRunningBody;

  /// AI dialog, heading shown while the run is in progress.
  ///
  /// In en, this message translates to:
  /// **'Tailoring your CV'**
  String get studioAiRunningTitle;

  /// Studio AI card button that navigates to Settings to configure an API key.
  ///
  /// In en, this message translates to:
  /// **'Set up in Settings'**
  String get studioAiSetUpInSettings;

  /// Studio button that reverts everything the AI run rewrote.
  ///
  /// In en, this message translates to:
  /// **'Undo AI changes'**
  String get studioAiUndo;

  /// Studio warning shown on AI-rewritten content, reminding the user to verify accuracy of their own CV.
  ///
  /// In en, this message translates to:
  /// **'AI-written. Check every rewritten bullet against what you actually did.'**
  String get studioAiWarning;

  /// Studio tooltip on the link returning to the CV list.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{Back to your CVs} resume{Back to your résumés} other{Back to your documents}}'**
  String studioBackToDrafts(String noun);

  /// Studio narrow-layout button returning from one section's editor to the section list.
  ///
  /// In en, this message translates to:
  /// **'Back to sections'**
  String get studioBackToSections;

  /// Hint inside an open Studio editor for a field the Vault also has wording for. Clearing the box removes the per-CV override rather than blanking the field, so the Vault's text reappears — said up front, because watching it come back unexplained reads as the edit having failed.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the Vault\'s wording'**
  String get studioBlankRestoresVault;

  /// Studio, how many of an entry's bullets are included in this CV.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total} bullets'**
  String studioBulletsSelected(int selected, int total);

  /// Studio, how many of an entry's bullets are included, and how many of those have been reworded for this CV.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total} bullets · {tailored} tailored'**
  String studioBulletsSelectedTailored(int selected, int total, int tailored);

  /// Confirmation dialog body for deleting a CV.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get studioDeleteDraftBody;

  /// Confirmation dialog title for deleting a CV, naming it.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String studioDeleteDraftTitle(String name);

  /// CV card menu item that makes a copy of the CV.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get studioDraftDuplicate;

  /// CV card menu item that opens the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename / edit notes'**
  String get studioDraftRename;

  /// CV list first-run empty state body.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{Create a CV to start tailoring your Vault for a specific application.} resume{Create a résumé to start tailoring your Vault for a specific application.} other{Create a document to start tailoring your Vault for a specific application.}}'**
  String studioDraftsEmptyBody(String noun);

  /// CV list first-run empty state heading.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{No CVs yet} resume{No résumés yet} other{No documents yet}}'**
  String studioDraftsEmptyTitle(String noun);

  /// CV list empty state when the search matches nothing.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{No CVs match your search.} resume{No résumés match your search.} other{No documents match your search.}}'**
  String studioDraftsNoMatches(String noun);

  /// CV list banner shown when a write to local storage failed.
  ///
  /// In en, this message translates to:
  /// **'Your last change couldn\'t be saved.'**
  String get studioDraftsPersistError;

  /// Placeholder in the CV list search field.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{Search CVs…} resume{Search résumés…} other{Search documents…}}'**
  String studioDraftsSearch(String noun);

  /// Marker on a CV card showing it has a job description saved against it, so the AI Assistant has something to tailor to.
  ///
  /// In en, this message translates to:
  /// **'Tailored to a job ad'**
  String get studioDraftTailoredMarker;

  /// Shown on a CV card when the CV has no name yet.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{Untitled CV} resume{Untitled Résumé} other{Untitled Document}}'**
  String studioDraftUntitled(String noun);

  /// CV card line showing when the CV was last edited. {relative} is an already-formatted lowercase phrase like "< 1 hour ago" or "3 days ago", read as the tail of this sentence.
  ///
  /// In en, this message translates to:
  /// **'Updated {relative}'**
  String studioDraftUpdated(String relative);

  /// Tooltip on a CV card's "Updated" line, giving the exact timestamp the relative phrase approximates. Order and separators should follow the locale's own convention.
  ///
  /// In en, this message translates to:
  /// **'{timestamp}'**
  String studioDraftUpdatedExact(DateTime timestamp);

  /// Studio tooltip on the button opening the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{Edit CV details} resume{Edit résumé details} other{Edit document details}}'**
  String studioEditDetailsTooltip(String noun);

  /// Title of the dialog for editing an existing CV's name and notes.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{Edit CV details} resume{Edit résumé details} other{Edit document details}}'**
  String studioEditDraftDetailsTitle(String noun);

  /// Edit-CV dialog, form field label for the CV's name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get studioEditDraftName;

  /// Edit-CV dialog, helper text under the name field.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{Give this CV a name} resume{Give this résumé a name} other{Give this document a name}}'**
  String studioEditDraftNameHelper(String noun);

  /// Edit-CV dialog, name placeholder. A company and role, which is how people usually name a tailored CV.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Acme — Backend Engineer\"'**
  String get studioEditDraftNameHint;

  /// Edit-CV dialog, form field label for free-text notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get studioEditDraftNotes;

  /// Edit-CV dialog, helper text under the notes field.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{What this CV is for, or anything to remember} resume{What this résumé is for, or anything to remember} other{What this document is for, or anything to remember}}'**
  String studioEditDraftNotesHelper(String noun);

  /// Title of the dialog for renaming a CV and editing its notes. The branch follows the user's REGION's document noun, not their language.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{CV details} resume{Résumé details} other{Document details}}'**
  String studioEditDraftTitle(String noun);

  /// Studio export error: the font files could not be fetched.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the fonts needed to export — check your connection and try again.'**
  String get studioExportErrorFonts;

  /// Studio export error: an unclassified failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the PDF — try again.'**
  String get studioExportErrorGeneric;

  /// Studio export error: building the PDF document failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate the PDF — try again, and if it keeps failing, check your CV for unusual characters or formatting.'**
  String get studioExportErrorRender;

  /// Studio export error: the browser refused the download.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the file — check your browser\'s download settings and try again.'**
  String get studioExportErrorSave;

  /// Studio button label while the PDF is being generated.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get studioExporting;

  /// Studio button that generates and downloads the CV as a PDF.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get studioExportPdf;

  /// Studio, Publications editor — label on the locked row showing an entry's bibliographic citation.
  ///
  /// In en, this message translates to:
  /// **'Citation'**
  String get studioFieldCitation;

  /// Studio, Experience editor — label on the row for the organisation a position was at.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get studioFieldCompany;

  /// Studio, Experience editor — label on the locked row showing a position's start and end dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get studioFieldDates;

  /// Studio, Education editor — label on the collapsed row for an entry's free-text details, distinguishing it from the qualification and grade rows beside it.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get studioFieldDetails;

  /// Studio — tooltip on the control that drops a Vault-sourced field from this CV without changing it. Shown while the field is still printing.
  ///
  /// In en, this message translates to:
  /// **'Don’t print this on this CV'**
  String get studioFieldDoNotPrint;

  /// Studio, Education editor — label on the collapsed row for an entry's grade or classification.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get studioFieldGrade;

  /// Studio, Education editor — label on the row for the school or university an entry was at.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get studioFieldInstitution;

  /// Studio — label on the locked row showing a project's or publication's URL.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get studioFieldLink;

  /// Studio — label on the row for where a position or education entry was, shared by both editors.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get studioFieldLocation;

  /// Studio — the inverse of studioFieldDoNotPrint, shown while the field is being left off.
  ///
  /// In en, this message translates to:
  /// **'Print this on this CV'**
  String get studioFieldPrintAgain;

  /// Studio, Projects editor — label on the collapsed row for a project's title.
  ///
  /// In en, this message translates to:
  /// **'Project title'**
  String get studioFieldProjectTitle;

  /// Studio, Publications editor — label on the row for a paper's own title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get studioFieldPublicationTitle;

  /// Studio, Education editor — label on the collapsed row for an entry's qualification or degree name.
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get studioFieldQualification;

  /// Studio, Experience editor — label on the collapsed row for a position's job title.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get studioFieldRole;

  /// Studio, Skills editor — label on the collapsed row for one skill's name.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get studioFieldSkill;

  /// Studio, Skills editor — label on the collapsed row for a skill category's name.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get studioFieldSkillCategory;

  /// Studio, Education editor — label on the locked row showing an entry's year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get studioFieldYear;

  /// Studio, Summary editor — checkbox controlling whether the headline line under the name prints on this CV at all. Separate from editing its text.
  ///
  /// In en, this message translates to:
  /// **'Include headline'**
  String get studioHeadlineInclude;

  /// Studio warning when the CV runs longer than the chosen market's convention. {note} is the region's own length guidance sentence, already complete.
  ///
  /// In en, this message translates to:
  /// **'Longer than {region} typically expects. {note} Try trimming content, or a denser template.'**
  String studioLengthWarning(String region, String note);

  /// Studio, Experience editor — shown on the lock beside a position's dates, explaining why they cannot be changed for one CV.
  ///
  /// In en, this message translates to:
  /// **'Dates stay as your Vault records them — they are what an employment check verifies, and they set the order this section prints in.'**
  String get studioLockedDates;

  /// Studio — shown on the lock beside any field that prints from the Vault and has no per-CV override, where there is no reason more specific than where the value comes from.
  ///
  /// In en, this message translates to:
  /// **'Printed from your Vault. Edit it there to change it on every CV.'**
  String get studioLockedFromVault;

  /// Title of the dialog for creating a CV, and the button that opens it.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, cv{New CV} resume{New résumé} other{New document}}'**
  String studioNewDraftTitle(String noun);

  /// Studio, Publications editor — placeholder on the citation row when the Vault entry has none.
  ///
  /// In en, this message translates to:
  /// **'No citation in your Vault yet.'**
  String get studioNoCitation;

  /// Studio empty state when an education entry has no detail text to draw from.
  ///
  /// In en, this message translates to:
  /// **'No details in your Vault yet.'**
  String get studioNoEducationDetails;

  /// Studio, Education editor — placeholder on the grade row when the Vault entry has no grade recorded.
  ///
  /// In en, this message translates to:
  /// **'No grade in your Vault yet.'**
  String get studioNoGrade;

  /// Studio empty state when the Vault has no headline to draw from.
  ///
  /// In en, this message translates to:
  /// **'No headline in your Vault yet.'**
  String get studioNoHeadline;

  /// Studio — placeholder on the location row when the Vault entry has none. Shared by the Experience and Education editors.
  ///
  /// In en, this message translates to:
  /// **'No location in your Vault yet.'**
  String get studioNoLocation;

  /// Studio empty state when the Vault has no references note to draw from.
  ///
  /// In en, this message translates to:
  /// **'No references note in your Vault yet.'**
  String get studioNoReferences;

  /// Studio editor pane placeholder body.
  ///
  /// In en, this message translates to:
  /// **'Choose a section on the left to edit its content.'**
  String get studioNoSectionSelectedBody;

  /// Studio editor pane placeholder when no section is chosen.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected'**
  String get studioNoSectionSelectedTitle;

  /// Studio empty state when the Vault has no professional summary to draw from.
  ///
  /// In en, this message translates to:
  /// **'No summary in your Vault yet.'**
  String get studioNoSummary;

  /// Studio, how many pages the exported CV currently runs to.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String studioPageCount(int count);

  /// Studio warning when a photo-printing template is paired with a market that rejects photographs. Each branch is a complete sentence rather than a stance label dropped into a frame, so it stays grammatical in any language.
  ///
  /// In en, this message translates to:
  /// **'{stance, select, prohibited{This template prints a photo, and {region} expects none — an automatic rejection. Switch template, or change region.} discouraged{This template prints a photo, and {region} expects none — strongly discouraged. Switch template, or change region.} other{This template prints a photo, and {region} expects none. Switch template, or change region.}}'**
  String studioPhotoRegionWarning(String stance, String region);

  /// Studio preview pane button that includes every Vault item in this CV.
  ///
  /// In en, this message translates to:
  /// **'Add all'**
  String get studioPreviewAddAll;

  /// Studio preview pane empty state body.
  ///
  /// In en, this message translates to:
  /// **'Add something to your Vault, then come back to build a CV.'**
  String get studioPreviewEmptyBody;

  /// Studio preview pane empty state when the Vault itself is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to preview yet'**
  String get studioPreviewEmptyTitle;

  /// Studio preview pane error body, pointing at a workaround.
  ///
  /// In en, this message translates to:
  /// **'The Export PDF button above uses the same PDF generation and may still work — try it, or reload the page.'**
  String get studioPreviewErrorBody;

  /// Internal description of the failing operation, appended to a diagnostic message. Names what the app was doing when preview rendering failed.
  ///
  /// In en, this message translates to:
  /// **'rasterizing the Studio preview'**
  String get studioPreviewErrorContext;

  /// Studio preview pane error heading.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t render the preview'**
  String get studioPreviewErrorTitle;

  /// Studio preview pane button navigating to the Vault.
  ///
  /// In en, this message translates to:
  /// **'Go to Vault'**
  String get studioPreviewGoToVault;

  /// Studio preview pane empty state body, counting available Vault entries.
  ///
  /// In en, this message translates to:
  /// **'Your Vault has {count} items, but none are included in this CV.'**
  String studioPreviewNothingSelectedBody(int count);

  /// Studio preview pane empty state when the Vault has content but none is included in this CV.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected yet'**
  String get studioPreviewNothingSelectedTitle;

  /// Region detail row prefix, putting the label before its value on one line.
  ///
  /// In en, this message translates to:
  /// **'{label}: '**
  String studioRegionDetailRow(String label);

  /// Region detail row label, introducing the market's own word for a CV.
  ///
  /// In en, this message translates to:
  /// **'Known locally as'**
  String get studioRegionLocalName;

  /// Region detail row label — the paper size CVs are exported at for this market.
  ///
  /// In en, this message translates to:
  /// **'Page size'**
  String get studioRegionPageSize;

  /// Region detail row label — which personal information a CV header carries in this market.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get studioRegionPersonalDetails;

  /// Region detail row label — whether a photograph is expected on a CV in this market.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get studioRegionPhoto;

  /// Region picker intro, per-CV context. Names what region does NOT do, because market and language are the app's most confusable pair: someone targeting DACH does not necessarily write in German. The old wording said it 'never changes what your Vault stores', which stopped being precise once the Vault started holding the default region itself.
  ///
  /// In en, this message translates to:
  /// **'Conventions differ by market. This sets the page size, the expected length, and the guidance below. It does not set the language your CV is written in, and it never rewrites your career content.'**
  String get studioRegionPickerBody;

  /// Region picker body when setting the default from Settings.
  ///
  /// In en, this message translates to:
  /// **'Sets the region every new CV starts with. Changing it never touches a CV you have already created — switch those individually from Studio.'**
  String get studioRegionPickerDefaultBody;

  /// Title of the region picker when opened from Settings to set the default for new CVs.
  ///
  /// In en, this message translates to:
  /// **'Default region'**
  String get studioRegionPickerDefaultTitle;

  /// Region picker confirm button when setting the default for new CVs.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get studioRegionPickerSetDefault;

  /// Title of the region picker when opened for one specific CV.
  ///
  /// In en, this message translates to:
  /// **'Choose a region'**
  String get studioRegionPickerTitle;

  /// Region picker confirm button when choosing for one CV.
  ///
  /// In en, this message translates to:
  /// **'Use this region'**
  String get studioRegionPickerUse;

  /// Region detail pane, label for the English spelling variant this market reads as native. Says 'English' deliberately: RegionSpelling has only en-GB/en-US/en-AU cases, so the row means nothing for a CV written in another language, and an unqualified 'Spelling' beside a German document reads as a contradiction.
  ///
  /// In en, this message translates to:
  /// **'English spelling'**
  String get studioRegionSpelling;

  /// Region detail row label — how many pages a CV usually runs to in this market.
  ///
  /// In en, this message translates to:
  /// **'Typical length'**
  String get studioRegionTypicalLength;

  /// Studio, section nav — button discarding every per-draft text edit so each line reads as the Vault has it. Sits beside the control that resets section layout; this one resets text, that one resets which sections show.
  ///
  /// In en, this message translates to:
  /// **'Reset wording to Vault'**
  String get studioResetWording;

  /// Studio, confirmation before resetting wording. Spells out the breadth because it cannot be undone: an override records no provenance, so the three kinds of edit cannot be told apart or restored separately.
  ///
  /// In en, this message translates to:
  /// **'Every line goes back to how your Vault words it, discarding your edits, any AI rewrites and any translation on this CV. Which entries are included is not affected.'**
  String get studioResetWordingConfirm;

  /// Studio section editor label for the professional title line.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get studioSectionHeadline;

  /// Studio banner shown when saving the section order or selection failed.
  ///
  /// In en, this message translates to:
  /// **'Your last selection change couldn\'t be saved.'**
  String get studioSectionNavPersistError;

  /// Studio, section nav — button restoring the section order and visibility saved as the Vault's CV defaults. Deliberately parallel to studioResetWording ('Reset wording to Vault'): both reset this CV to the Vault, and the middle word is what says which axis. Keep the two phrased alike in every locale, or the pair stops reading as a pair.
  ///
  /// In en, this message translates to:
  /// **'Reset sections to Vault'**
  String get studioSectionsResetDefault;

  /// Studio, confirmation before resetting section order and visibility. The closing sentence draws the line against the wording reset sitting next to it, since the two are easily confused.
  ///
  /// In en, this message translates to:
  /// **'The sections on this CV go back to the order and visibility saved in your Vault, discarding how you have arranged this one. What each line says is not affected.'**
  String get studioSectionsResetDefaultConfirm;

  /// Studio heading above the reorderable list of CV sections.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get studioSectionsTitle;

  /// Studio section editor heading for the CV's opening paragraph.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get studioSectionSummary;

  /// Studio, how many included bullets evidence this skill.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Linked to 1 bullet in this CV} other{Linked to {count} bullets in this CV}}'**
  String studioSkillLinkedBullets(int count);

  /// Studio skill selector — hover text on a skill chip, counting the bullets in THIS CV that are linked to it. Not the Vault-wide count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Linked to 1 bullet in this CV} other{Linked to {count} bullets in this CV}}'**
  String studioSkillsEvidenceCount(int count);

  /// Studio skill selector search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Filter skills…'**
  String get studioSkillsFilter;

  /// Studio tooltip when no skill is linked to any bullet, so the evidenced-skills action is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Link skills to bullets in the Vault to use this'**
  String get studioSkillsNoLinks;

  /// Studio tooltip when the evidenced-skills bulk action would do nothing.
  ///
  /// In en, this message translates to:
  /// **'No new evidenced skills to add — every skill linked to an included bullet is already selected'**
  String get studioSkillsNoNewEvidenced;

  /// Studio skill selector, the control that turns each selected skill into an editable row. Off state.
  ///
  /// In en, this message translates to:
  /// **'Rename for this CV'**
  String get studioSkillsRename;

  /// Studio skill selector, the same control as studioSkillsRename in its on state.
  ///
  /// In en, this message translates to:
  /// **'Done renaming'**
  String get studioSkillsRenameDone;

  /// Studio skill selector, how many skills are included out of those available.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String studioSkillsSelectedCount(int selected, int total);

  /// Studio button that selects every skill supported by an included bullet.
  ///
  /// In en, this message translates to:
  /// **'Select {count} evidenced skills'**
  String studioSkillsSelectEvidenced(int count);

  /// Studio tooltip explaining the bulk-select action for skills that have supporting evidence.
  ///
  /// In en, this message translates to:
  /// **'Selects every skill linked to a bullet already included in this CV'**
  String get studioSkillsSelectEvidencedTooltip;

  /// Studio skill selector heading.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get studioSkillsTitle;

  /// Tooltip on the button that opens the CV list's sort menu.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get studioSortLabel;

  /// CV list sort option: alphabetical by name. Use the target language's own alphabet range convention (e.g. 'A–Z').
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get studioSortNameAtoZ;

  /// CV list sort option: most recently edited first.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get studioSortRecentlyUpdated;

  /// Studio narrow-layout tab showing the section editors.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get studioTabConfigure;

  /// Studio narrow-layout tab showing the rendered CV.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get studioTabPreview;

  /// Studio button that opens an inline editor for this CV's copy of the text.
  ///
  /// In en, this message translates to:
  /// **'Edit text'**
  String get studioTailoringEditText;

  /// Studio tooltip on text still showing the Vault's original wording.
  ///
  /// In en, this message translates to:
  /// **'From your Vault — not yet tailored'**
  String get studioTailoringFromVault;

  /// Studio note clarifying that an edit here does not change the Vault.
  ///
  /// In en, this message translates to:
  /// **'Only affects this CV.'**
  String get studioTailoringOnlyThisCv;

  /// Studio, the line above the section editor pane saying which layer the whole pane edits. Replaces a per-editor note, so it must read correctly with nothing open.
  ///
  /// In en, this message translates to:
  /// **'Edits here change this CV only. Your Vault keeps its own wording.'**
  String get studioTailoringPaneNote;

  /// Studio tooltip on text that has been edited for this CV only; the action restores the Vault's original wording.
  ///
  /// In en, this message translates to:
  /// **'Revert to Vault — tailored for this CV'**
  String get studioTailoringReverted;

  /// Marker in the template picker on the template the CV currently uses, distinguishing it from the one being considered.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get studioTemplateCurrent;

  /// Title of the dialog for picking the CV's visual template.
  ///
  /// In en, this message translates to:
  /// **'Choose a template'**
  String get studioTemplatePickerTitle;

  /// Template picker confirm button.
  ///
  /// In en, this message translates to:
  /// **'Use this template'**
  String get studioTemplatePickerUse;

  /// Studio, Translate card body when an API key is configured.
  ///
  /// In en, this message translates to:
  /// **'Rewrite everything this CV prints into its document language, leaving your Vault in the language you wrote it.'**
  String get studioTranslateCardBody;

  /// Studio, Translate card body when no AI provider key is set up yet.
  ///
  /// In en, this message translates to:
  /// **'Translating a CV uses the same AI provider as tailoring. Add a key in Settings to turn it on.'**
  String get studioTranslateCardBodyNoKey;

  /// Studio, Translate card status when the draft's document language has changed since it was translated, so the translation no longer matches.
  ///
  /// In en, this message translates to:
  /// **'Translated into {translated}, but this CV is now set to {current}.'**
  String studioTranslateCardStale(String translated, String current);

  /// Studio, Translate card line naming the language a run would translate into, taken from the draft's own document language.
  ///
  /// In en, this message translates to:
  /// **'This CV\'s language is {language}.'**
  String studioTranslateCardTarget(String language);

  /// Studio, Translate card heading and the button that starts a run.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get studioTranslateCardTitle;

  /// Studio, Translate card status once a translation has been applied.
  ///
  /// In en, this message translates to:
  /// **'Translated into {language}.'**
  String studioTranslateCardTranslated(String language);

  /// Studio, Translate confirm dialog — states the target language and what will and won't be rewritten. Named first because rewriting a career history into another language is a large, surprising change.
  ///
  /// In en, this message translates to:
  /// **'Every line this CV prints will be rewritten into {language} — job titles, bullet points, skills and section content. Employers, schools and publication titles are left exactly as they are.'**
  String studioTranslateDialogLanguageNote(String language);

  /// Studio, Translate confirm dialog — extra warning shown only when a translation already exists.
  ///
  /// In en, this message translates to:
  /// **'This CV already has a translation. Running again replaces it.'**
  String get studioTranslateDialogReplaceNote;

  /// Studio, Translate run dialog title.
  ///
  /// In en, this message translates to:
  /// **'Translate this CV'**
  String get studioTranslateDialogTitle;

  /// Studio, Translate error for an unclassified failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t translate this CV — try again.'**
  String get studioTranslateErrorGeneric;

  /// Studio, Translate error for LlmFailure.invalidRequest.
  ///
  /// In en, this message translates to:
  /// **'{provider} rejected the request. This CV may be too long to translate in one pass.'**
  String studioTranslateErrorInvalidRequest(String provider);

  /// Studio, Translate error for LlmFailure.malformedResponse.
  ///
  /// In en, this message translates to:
  /// **'The translation came back in a form CVForge couldn\'t read — try again.'**
  String get studioTranslateErrorMalformedResponse;

  /// Studio, Translate error for LlmFailure.network.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach {provider} — check your connection and try again.'**
  String studioTranslateErrorNetwork(String provider);

  /// Studio, Translate error for LlmFailure.noKey.
  ///
  /// In en, this message translates to:
  /// **'No API key set up yet — add one in Settings.'**
  String get studioTranslateErrorNoKey;

  /// Studio, Translate error for LlmFailure.overloaded.
  ///
  /// In en, this message translates to:
  /// **'{provider} is busy right now — try again in a moment.'**
  String studioTranslateErrorOverloaded(String provider);

  /// Studio, Translate error for LlmFailure.rateLimited.
  ///
  /// In en, this message translates to:
  /// **'You\'ve hit your provider\'s rate limit — wait a moment and try again.'**
  String get studioTranslateErrorRateLimited;

  /// Studio, Translate error for LlmFailure.refusal.
  ///
  /// In en, this message translates to:
  /// **'The provider declined to translate this CV.'**
  String get studioTranslateErrorRefusal;

  /// Studio, Translate error for LlmFailure.timeout.
  ///
  /// In en, this message translates to:
  /// **'The translation took too long and timed out — try again.'**
  String get studioTranslateErrorTimeout;

  /// Studio, Translate error for LlmFailure.unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your API key was rejected — check it in Settings.'**
  String get studioTranslateErrorUnauthorized;

  /// Studio, Translate dialog heading on the error screen.
  ///
  /// In en, this message translates to:
  /// **'Translation failed'**
  String get studioTranslateFailedTitle;

  /// Studio, Translate card button restoring the CV to how it read before it was translated. Destructive: it also discards anything edited by hand since.
  ///
  /// In en, this message translates to:
  /// **'Remove translation'**
  String get studioTranslateRemove;

  /// Studio, confirmation before removing a translation — an override records no provenance, so a hand edit made after translating cannot be told apart from the translation and is restored with it.
  ///
  /// In en, this message translates to:
  /// **'This restores every line to how it read before translating, including anything you\'ve edited since. Remove it?'**
  String get studioTranslateRemoveConfirm;

  /// Studio, Translate dialog result screen — how many of the CV's lines came back translated. Shown as a fraction rather than a bare count so a partial pass is visible: lines can be left alone because they were already in the target language, are names that should not be translated, or came back unusable and were discarded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Translated 1 of {total} lines.} other{Translated {count} of {total} lines.}}'**
  String studioTranslateResultBody(int count, int total);

  /// Studio, Translate card button when a translation already exists.
  ///
  /// In en, this message translates to:
  /// **'Translate again'**
  String get studioTranslateRunAgain;

  /// Studio, Translate dialog body while the request is in flight.
  ///
  /// In en, this message translates to:
  /// **'Translating every line this CV prints. This can take a few minutes.'**
  String get studioTranslateRunningBody;

  /// Studio, Translate dialog — how far through the run it is. A CV is translated as one request per section, so this moves several times during a pass rather than sitting still for minutes.
  ///
  /// In en, this message translates to:
  /// **'Section {completed} of {total}.'**
  String studioTranslateRunningProgress(int completed, int total);

  /// Studio, Translate dialog heading while the request is in flight.
  ///
  /// In en, this message translates to:
  /// **'Translating your CV'**
  String get studioTranslateRunningTitle;

  /// Studio, Translate card note on run order. The two passes share one override layer, so tailoring after translating puts English back on the page.
  ///
  /// In en, this message translates to:
  /// **'Tailor before translating — a tailoring pass rewrites in English and would undo this.'**
  String get studioTranslateTailorFirst;

  /// Studio, Translate card standing warning once a translation is applied. Permanent rather than dismissible, matching studioAiWarning.
  ///
  /// In en, this message translates to:
  /// **'Machine-translated. Have a fluent speaker read it before you send it.'**
  String get studioTranslateWarning;

  /// Studio, X-Ray preview mode, shown under the spinner while the first pass renders, extracts and analyses the CV.
  ///
  /// In en, this message translates to:
  /// **'Reading your CV the way an ATS would…'**
  String get studioXrayAnalyzing;

  /// Studio document bar, tooltip on the ATS X-Ray toggle. Says what the overlay shows rather than restating the label.
  ///
  /// In en, this message translates to:
  /// **'Show what an ATS pulls out of this page'**
  String get studioXrayBoxesTooltip;

  /// Studio, X-Ray summary chip counting critical findings. A standalone label in a row of chips, never joined into a sentence.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 critical} other{{count} critical}}'**
  String studioXrayCriticalCount(int count);

  /// Studio, X-Ray error state, button that turns the overlay off and returns to the ordinary rendered preview.
  ///
  /// In en, this message translates to:
  /// **'Back to preview'**
  String get studioXrayErrorBackToPreview;

  /// Studio, X-Ray error state body. Must reassure that only the overlay failed, since the ordinary preview and export use a different, still-working path.
  ///
  /// In en, this message translates to:
  /// **'The CV rendered, but couldn\'t be read back for checking. Turn X-Ray off to keep working — your preview and export are unaffected.'**
  String get studioXrayErrorBody;

  /// Studio, X-Ray, FlutterError report context string. Diagnostic only — never shown to the user.
  ///
  /// In en, this message translates to:
  /// **'while building the Studio ATS X-Ray'**
  String get studioXrayErrorContext;

  /// Studio, X-Ray error state title, shown when rendering or extraction failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t run the ATS check'**
  String get studioXrayErrorTitle;

  /// Studio, heading above the ATS findings list that replaces the section editor while the X-Ray is on.
  ///
  /// In en, this message translates to:
  /// **'What an ATS would struggle with'**
  String get studioXrayFindingsTitle;

  /// Studio document bar, the text segment of the ATS overlay control, which also acts as its on/off switch. An acronym the market uses untranslated in most locales — check before translating it.
  ///
  /// In en, this message translates to:
  /// **'ATS'**
  String get studioXrayGroupLabel;

  /// Studio document bar, tooltip on the ATS label segment while an overlay is showing. Clicking it returns to the ordinary preview.
  ///
  /// In en, this message translates to:
  /// **'Hide the ATS overlay'**
  String get studioXrayHide;

  /// Studio, X-Ray summary chip counting informational findings. A standalone label in a row of chips, never joined into a sentence.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note} other{{count} notes}}'**
  String studioXrayInfoCount(int count);

  /// Studio, X-Ray summary bar when the analysis produced no findings. Deliberately narrow — it claims no known problem was found, not that the CV is good.
  ///
  /// In en, this message translates to:
  /// **'Nothing here trips a known ATS parsing problem.'**
  String get studioXrayNoIssues;

  /// Studio, title of the ATS findings empty state. Pairs with studioXrayNoIssues, which carries the narrower claim underneath it.
  ///
  /// In en, this message translates to:
  /// **'Nothing to fix here'**
  String get studioXrayNoIssuesTitle;

  /// Studio document bar, tooltip on the reading-order toggle. Says what the overlay shows rather than restating the label.
  ///
  /// In en, this message translates to:
  /// **'Show the order an ATS reads this page in'**
  String get studioXrayReadingOrderTooltip;

  /// Studio document bar, tooltip on the ATS label segment while the ordinary preview is showing. Clicking it turns the overlay on.
  ///
  /// In en, this message translates to:
  /// **'Show what an ATS sees'**
  String get studioXrayShow;

  /// Studio, X-Ray summary chip counting warning findings. A standalone label in a row of chips, never joined into a sentence.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 warning} other{{count} warnings}}'**
  String studioXrayWarningCount(int count);

  /// Template description in the picker, for the traditional layout.
  ///
  /// In en, this message translates to:
  /// **'Centred headings and a justified summary, with whitespace in place of section rules.'**
  String get templateDescriptionClassicCentered;

  /// Template description in the picker, for the compact layout.
  ///
  /// In en, this message translates to:
  /// **'A plain single column, tightly set — the most content per page.'**
  String get templateDescriptionCompact;

  /// Template description in the picker, for the photo layout. The market warning is load-bearing — a registry test asserts a photo-tagged template states it, so it must survive translation.
  ///
  /// In en, this message translates to:
  /// **'A tinted header band around your Vault photo. Expected in DACH, common in southern Europe; in the US and UK a photo invites rejection.'**
  String get templateDescriptionPhotoHeader;

  /// Template name shown in the template picker: a conservative centred layout.
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get templateNameClassicCentered;

  /// Template name shown in the template picker: a dense single-column layout.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get templateNameCompact;

  /// Template name shown in the template picker: the layout that prints the Vault photograph.
  ///
  /// In en, this message translates to:
  /// **'Modern with photo'**
  String get templateNamePhotoHeader;

  /// Template tag: suited to academic CVs, which run longer and list publications.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get templateTagAcademic;

  /// Template tag: this layout parses cleanly in applicant tracking software. 'ATS' is a widely-used industry abbreviation.
  ///
  /// In en, this message translates to:
  /// **'ATS-safe'**
  String get templateTagAtsSafe;

  /// Template tag: fits more content per page.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get templateTagCompact;

  /// Template tag: a contemporary layout.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get templateTagModern;

  /// Template tag: this layout prints the profile photograph from the Vault.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get templateTagPhoto;

  /// Template tag: a conservative, conventional layout.
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get templateTagTraditional;

  /// Template tag: the layout splits the page into two columns.
  ///
  /// In en, this message translates to:
  /// **'Two-column'**
  String get templateTagTwoColumn;

  /// Theme option: always use the dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// Theme option: always use the light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Theme option: follow the operating system's light/dark setting.
  ///
  /// In en, this message translates to:
  /// **'Match device'**
  String get themeModeSystem;

  /// Tooltip on the theme cycle button, naming the current theme and the one a click moves to. Both values are already-translated theme option names.
  ///
  /// In en, this message translates to:
  /// **'Theme: {current} — switch to {next}'**
  String themeToggleTooltip(String current, String next);

  /// Vault action shown when no personal details have been entered yet.
  ///
  /// In en, this message translates to:
  /// **'Add your basics'**
  String get vaultAddBasics;

  /// Vault button that adds a new education entry.
  ///
  /// In en, this message translates to:
  /// **'Add education'**
  String get vaultAddEducation;

  /// Vault button that adds a new job entry.
  ///
  /// In en, this message translates to:
  /// **'Add experience'**
  String get vaultAddExperience;

  /// Vault list card title for the hobbies section before any hobby exists, shown where the hobby names otherwise appear.
  ///
  /// In en, this message translates to:
  /// **'Add your hobbies'**
  String get vaultAddHobbies;

  /// Vault list card title for the languages section before any language exists, shown where the language names otherwise appear.
  ///
  /// In en, this message translates to:
  /// **'Add your languages'**
  String get vaultAddLanguages;

  /// Vault button that adds a new project entry.
  ///
  /// In en, this message translates to:
  /// **'Add project'**
  String get vaultAddProject;

  /// Vault button that adds a new publication entry.
  ///
  /// In en, this message translates to:
  /// **'Add publication'**
  String get vaultAddPublication;

  /// Vault list card title for the skills section before any category exists, shown where the category names otherwise appear.
  ///
  /// In en, this message translates to:
  /// **'Add your skills'**
  String get vaultAddSkills;

  /// Tooltip on the button removing one link row.
  ///
  /// In en, this message translates to:
  /// **'Delete link'**
  String get vaultBasicsDeleteLink;

  /// Vault basics form field label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get vaultBasicsEmail;

  /// Vault basics form field label.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get vaultBasicsFullName;

  /// Heading over the email, phone and location fields in the Vault's About you panel. Groups the lookup values, as against the writing below them.
  ///
  /// In en, this message translates to:
  /// **'How to reach you'**
  String get vaultBasicsGroupContact;

  /// Heading over the photo, name and headline fields at the top of the Vault's About you panel.
  ///
  /// In en, this message translates to:
  /// **'Who you are'**
  String get vaultBasicsGroupIdentity;

  /// Heading over the summary and work-authorisation fields in the Vault's About you panel. These are prose the reader judges, unlike the lookup values above.
  ///
  /// In en, this message translates to:
  /// **'What you say'**
  String get vaultBasicsGroupWriting;

  /// Vault basics form field label. A short professional title line shown under the name on a CV.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get vaultBasicsHeadline;

  /// Vault basics headline field placeholder. Replace the example with one natural in the target language.
  ///
  /// In en, this message translates to:
  /// **'e.g. Senior Software Engineer'**
  String get vaultBasicsHeadlineHint;

  /// Vault basics form field label for a link's display name.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get vaultBasicsLinkLabel;

  /// Vault basics link-label placeholder. LinkedIn is a product name; keep it.
  ///
  /// In en, this message translates to:
  /// **'e.g. LinkedIn'**
  String get vaultBasicsLinkLabelHint;

  /// Vault basics sub-heading above the list of profile links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get vaultBasicsLinks;

  /// Vault basics form field label for a link's web address.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get vaultBasicsLinkUrl;

  /// Vault basics form field label — the city or region the candidate is based in.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get vaultBasicsLocation;

  /// Vault basics form field label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get vaultBasicsPhone;

  /// Vault basics form field label. On a CV, a note about who can vouch for the candidate.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get vaultBasicsReferences;

  /// Vault basics references placeholder. 'Available on request' is the conventional English phrase — use the equivalent convention in the target market.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Available on request.\"'**
  String get vaultBasicsReferencesHint;

  /// Vault basics form field label. A short paragraph opening the CV.
  ///
  /// In en, this message translates to:
  /// **'Professional summary'**
  String get vaultBasicsSummary;

  /// Vault section heading for personal and contact details.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get vaultBasicsTitle;

  /// Field label in the Vault basics editor. The value is printed verbatim in the CV header with no label beside it, so the field holds the whole line.
  ///
  /// In en, this message translates to:
  /// **'Work authorisation (optional)'**
  String get vaultBasicsWorkAuthorization;

  /// Hint for the work-authorisation field. A whole sentence rather than a status word, because nothing labels it on the printed CV.
  ///
  /// In en, this message translates to:
  /// **'e.g. Right to work in the UK — no sponsorship required'**
  String get vaultBasicsWorkAuthorizationHint;

  /// Vault button that creates a new skill from the typed search text.
  ///
  /// In en, this message translates to:
  /// **'Add skill'**
  String get vaultBulletAddSkill;

  /// Vault form label for which category a newly added skill goes into.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get vaultBulletCategory;

  /// Tooltip on the button removing one bullet point.
  ///
  /// In en, this message translates to:
  /// **'Delete bullet'**
  String get vaultBulletDelete;

  /// Vault, summary of how many skills are tied to this bullet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Linked to 1 skill} other{Linked to {count} skills}}'**
  String vaultBulletLinkedSkills(int count);

  /// Vault action opening the picker that ties skills to this bullet.
  ///
  /// In en, this message translates to:
  /// **'Link to skills'**
  String get vaultBulletLinkToSkills;

  /// Vault dropdown option that creates a new skill category instead of picking an existing one.
  ///
  /// In en, this message translates to:
  /// **'New category…'**
  String get vaultBulletNewCategory;

  /// Vault form field label for naming a newly created skill category.
  ///
  /// In en, this message translates to:
  /// **'New category name'**
  String get vaultBulletNewCategoryName;

  /// Vault empty state in the skill-link picker when the search matches nothing.
  ///
  /// In en, this message translates to:
  /// **'No skills match your search.'**
  String get vaultBulletNoSkillMatches;

  /// Vault empty state in the skill-link picker when the Vault holds no skills at all.
  ///
  /// In en, this message translates to:
  /// **'No skills in your Vault yet.'**
  String get vaultBulletNoSkillsYet;

  /// Vault placeholder in the skill-link search field.
  ///
  /// In en, this message translates to:
  /// **'Search or add a skill…'**
  String get vaultBulletSearchSkills;

  /// Vault empty state for an entry with no bullet points.
  ///
  /// In en, this message translates to:
  /// **'No bullets yet.'**
  String get vaultBulletsEmpty;

  /// Vault, shown in the skill picker when the typed text matches no existing skill, offering to create it.
  ///
  /// In en, this message translates to:
  /// **'\"{query}\" isn\'t in your Vault yet'**
  String vaultBulletSkillNotInVault(String query);

  /// Vault sub-heading above the achievement lines belonging to a role or project.
  ///
  /// In en, this message translates to:
  /// **'Bullets'**
  String get vaultBulletsTitle;

  /// Vault bullet form field label for the bullet's own wording.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get vaultBulletText;

  /// Fallback title for the delete-confirmation dialog when a caller supplies none. Callers normally pass something specific.
  ///
  /// In en, this message translates to:
  /// **'Delete this?'**
  String get vaultConfirmDeleteFallbackTitle;

  /// Crop dialog body. 35 × 45 mm is the standard European CV photo size — keep the measurement.
  ///
  /// In en, this message translates to:
  /// **'Drag the frame to choose what appears. The shape is fixed to the 35 × 45 mm size European CVs expect.'**
  String get vaultCropPhotoBody;

  /// Crop dialog, button that accepts the current crop.
  ///
  /// In en, this message translates to:
  /// **'Use this photo'**
  String get vaultCropPhotoConfirm;

  /// Crop dialog, button label while the cropped photograph is being encoded and stored.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get vaultCropPhotoSaving;

  /// Title of the dialog for cropping a profile photograph to the required aspect ratio.
  ///
  /// In en, this message translates to:
  /// **'Position your photo'**
  String get vaultCropPhotoTitle;

  /// Button on the region row of the Vault's document-defaults panel, opening the region picker.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get vaultCvDefaultsChange;

  /// Vault CV defaults panel, label on the checkbox deciding whether a new CV starts with its headline shown. Pinned above the section list; the headline prints in the name block, not as a section.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get vaultCvDefaultsHeadline;

  /// Help text under the document-language row of the Vault's CV defaults panel. Names both of the other two axes explicitly — this is the one place all three meet, and the divide has to be stated rather than inferred.
  ///
  /// In en, this message translates to:
  /// **'The language your CV is written in — separate from the market above, and from the language CVForge itself is shown in, which you set in Settings.'**
  String get vaultCvDefaultsLanguageHelp;

  /// Label on the document-language row of the Vault's document-defaults panel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get vaultCvDefaultsLanguageLabel;

  /// Body text in the Vault's document-defaults editor panel. The second clause is the point: users routinely expect a 'default' to apply retroactively.
  ///
  /// In en, this message translates to:
  /// **'What every new CV starts out as. Changing these never rewrites a CV you have already made — switch those individually from Studio.'**
  String get vaultCvDefaultsPanelBody;

  /// Title of the Vault editor panel for the document defaults. Same copy as the section heading that opens it.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, resume{Résumé defaults} other{CV defaults}}'**
  String vaultCvDefaultsPanelTitle(String noun);

  /// Help text under the region row of the Vault's CV defaults panel. Lists only what a reader can actually observe changing. It deliberately does not mention dates: region owns the date's *shape* (RegionDateStyle) and the language owns its words, but every preset resolves to the same shape, so naming it promised a difference that does not exist.
  ///
  /// In en, this message translates to:
  /// **'Sets the page size, the expected length, and the advice the AI Assistant follows. Not the language — that is the row below.'**
  String get vaultCvDefaultsRegionHelp;

  /// Label on the region row of the Vault's document-defaults panel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get vaultCvDefaultsRegionLabel;

  /// Help text under the default section list in the Vault's CV defaults panel. Deliberately does not repeat that existing CVs are untouched — the panel's intro says that once, for all five rows.
  ///
  /// In en, this message translates to:
  /// **'Which sections a new CV includes, and the order they print in. Drag to reorder.'**
  String get vaultCvDefaultsSectionsHelp;

  /// Label for the default section-order list in the Vault's CV defaults panel.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get vaultCvDefaultsSectionsLabel;

  /// Help text under the default-template row of the Vault's CV defaults panel. Names the photo specifically: whether one is printed is a property of the template and of nothing else, and the region picker sends people here expecting a photo to be a setting.
  ///
  /// In en, this message translates to:
  /// **'The design a new CV starts with — its layout, its type, and whether a photo is printed.'**
  String get vaultCvDefaultsTemplateHelp;

  /// Label for the default-template row of the Vault's CV defaults panel.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get vaultCvDefaultsTemplateLabel;

  /// Confirmation dialog body for deleting a skill category.
  ///
  /// In en, this message translates to:
  /// **'This removes it and all of its skills.'**
  String get vaultDeleteCategoryBody;

  /// Confirmation dialog title for deleting a skill category from the Vault.
  ///
  /// In en, this message translates to:
  /// **'Delete this category?'**
  String get vaultDeleteCategoryTitle;

  /// Confirmation dialog title for deleting one job/role from the Vault.
  ///
  /// In en, this message translates to:
  /// **'Delete this experience?'**
  String get vaultDeleteExperienceTitle;

  /// Confirmation dialog title for deleting one project from the Vault.
  ///
  /// In en, this message translates to:
  /// **'Delete this project?'**
  String get vaultDeleteProjectTitle;

  /// Confirmation dialog title for deleting one publication from the Vault.
  ///
  /// In en, this message translates to:
  /// **'Delete this publication?'**
  String get vaultDeletePublicationTitle;

  /// Confirmation dialog title for deleting one education entry from the Vault.
  ///
  /// In en, this message translates to:
  /// **'Delete this qualification?'**
  String get vaultDeleteQualificationTitle;

  /// Confirmation dialog body for deleting an entry that owns nothing else.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get vaultDeleteUndoneBody;

  /// Confirmation dialog body used when deleting an entry that owns bullet points. 'Bullets' are the achievement lines under a role or project.
  ///
  /// In en, this message translates to:
  /// **'This removes it and all of its bullets. This can\'t be undone.'**
  String get vaultDeleteWithBulletsBody;

  /// Vault education form field label for any extra notes.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get vaultEducationDetails;

  /// Vault education form field label — the classification or result achieved.
  ///
  /// In en, this message translates to:
  /// **'Grade (optional)'**
  String get vaultEducationGrade;

  /// Vault education grade placeholder. 'First Class Honours' is a UK grading term — substitute the target market's own convention.
  ///
  /// In en, this message translates to:
  /// **'e.g. First Class Honours'**
  String get vaultEducationGradeHint;

  /// Vault education form field label — the university, college or school.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get vaultEducationInstitution;

  /// Vault education form field label.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get vaultEducationLocation;

  /// Vault placeholder title for an education entry with no name yet.
  ///
  /// In en, this message translates to:
  /// **'New qualification'**
  String get vaultEducationNew;

  /// Vault education form field label — the degree or certificate earned.
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get vaultEducationQualification;

  /// Vault education placeholder. Replace with a qualification name natural in the target market.
  ///
  /// In en, this message translates to:
  /// **'e.g. BSc Computer Science'**
  String get vaultEducationQualificationHint;

  /// Vault education form field label — the year the qualification was completed.
  ///
  /// In en, this message translates to:
  /// **'Year (optional)'**
  String get vaultEducationYear;

  /// Vault first-run empty state body, explaining the Vault holds everything while a CV is a selected subset.
  ///
  /// In en, this message translates to:
  /// **'Add your work history, skills, and education here — this is your master record, separate from any CV you export.'**
  String get vaultEmptyBody;

  /// Vault first-run button that fills the Vault with sample content so the app can be explored.
  ///
  /// In en, this message translates to:
  /// **'Load example CV'**
  String get vaultEmptyLoadExample;

  /// Vault first-run button that begins with an empty Vault.
  ///
  /// In en, this message translates to:
  /// **'Start from scratch'**
  String get vaultEmptyStartScratch;

  /// Vault first-run empty state heading.
  ///
  /// In en, this message translates to:
  /// **'Your Vault is empty'**
  String get vaultEmptyTitle;

  /// Vault experience form field label — the employer's name.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get vaultExperienceCompany;

  /// Vault experience checkbox that marks the role as ongoing and hides the end date fields.
  ///
  /// In en, this message translates to:
  /// **'I currently work here'**
  String get vaultExperienceCurrent;

  /// Label on the end-date picker in the Vault's experience editor. Only shown when the role is not the current one.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get vaultExperienceEnd;

  /// Vault experience form field label.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get vaultExperienceLocation;

  /// Vault placeholder title for a job entry with no role name yet.
  ///
  /// In en, this message translates to:
  /// **'New experience'**
  String get vaultExperienceNew;

  /// Vault experience field that ties this role to an earlier one at the same employer, so the CV shows them as one company with several positions.
  ///
  /// In en, this message translates to:
  /// **'Promotion — group with'**
  String get vaultExperiencePromotionGroup;

  /// Vault experience form field label — the job title held.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get vaultExperienceRole;

  /// Label on the start-date picker in the Vault's experience editor.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get vaultExperienceStart;

  /// Vault summary card line counting hobbies. English has an irregular plural here (hobby/hobbies); other languages may need different plural categories.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hobby} other{{count} hobbies}}'**
  String vaultHobbiesCount(int count);

  /// Vault empty state inside the hobbies editor.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet.'**
  String get vaultHobbiesEmptyShort;

  /// Vault sub-heading above the list of individual hobbies.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get vaultHobbiesItems;

  /// Vault list card line under the hobbies section while a search is active, counting the hobbies that matched. Other languages may need different plural categories.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 matching hobby} other{{count} matching hobbies}}'**
  String vaultHobbiesMatchCount(int count);

  /// Vault section heading for personal interests.
  ///
  /// In en, this message translates to:
  /// **'Hobbies and interests'**
  String get vaultHobbiesTitle;

  /// One-shot notice shown when the user lands on a URL that matches no route and is redirected to the Vault.
  ///
  /// In en, this message translates to:
  /// **'That page doesn\'t exist — here\'s your Vault.'**
  String get vaultInvalidUrlNotice;

  /// Field label for the CEFR proficiency picker in the Vault languages editor.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get vaultLanguageLevel;

  /// Proficiency picker option that grades a language not at all; the CV then prints the language on its own.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get vaultLanguageLevelUnset;

  /// Field label for a language name in the Vault languages editor.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get vaultLanguageName;

  /// Hint for the language-name field. The name is printed on the CV verbatim, so it is written in the document language, not the UI one.
  ///
  /// In en, this message translates to:
  /// **'e.g. German'**
  String get vaultLanguageNameHint;

  /// Vault summary card line counting languages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 language} other{{count} languages}}'**
  String vaultLanguagesCount(int count);

  /// Tooltip on the delete button beside a language in the Vault languages editor.
  ///
  /// In en, this message translates to:
  /// **'Delete language'**
  String get vaultLanguagesDeleteLanguage;

  /// Empty state inside the Vault languages editor.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet.'**
  String get vaultLanguagesEmptyShort;

  /// Heading above the list of entries inside the Vault languages editor.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get vaultLanguagesItems;

  /// Vault list card line under the languages section while a search is active, counting the languages that matched.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 matching language} other{{count} matching languages}}'**
  String vaultLanguagesMatchCount(int count);

  /// Title of the Vault's languages editor panel, and of Studio's languages section editor.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get vaultLanguagesTitle;

  /// Month abbreviation shown in the Vault's year/month picker for April. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get vaultMonthApr;

  /// Month abbreviation shown in the Vault's year/month picker for August. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get vaultMonthAug;

  /// Month abbreviation shown in the Vault's year/month picker for December. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get vaultMonthDec;

  /// Month abbreviation shown in the Vault's year/month picker for February. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get vaultMonthFeb;

  /// Month abbreviation shown in the Vault's year/month picker for January. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get vaultMonthJan;

  /// Month abbreviation shown in the Vault's year/month picker for July. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get vaultMonthJul;

  /// Month abbreviation shown in the Vault's year/month picker for June. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get vaultMonthJun;

  /// Month abbreviation shown in the Vault's year/month picker for March. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get vaultMonthMar;

  /// Month abbreviation shown in the Vault's year/month picker for May. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get vaultMonthMay;

  /// Month abbreviation shown in the Vault's year/month picker for November. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get vaultMonthNov;

  /// Month abbreviation shown in the Vault's year/month picker for October. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get vaultMonthOct;

  /// Month abbreviation shown in the Vault's year/month picker for September. This is app chrome, so it follows the app's language — it is NOT what the CV prints, which follows the document's own language (see DocumentStrings). Keep it short enough for a grid cell.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get vaultMonthSep;

  /// Vault empty state for the education section.
  ///
  /// In en, this message translates to:
  /// **'No education yet.'**
  String get vaultNoEducation;

  /// Vault empty state for the work history section.
  ///
  /// In en, this message translates to:
  /// **'No experience yet.'**
  String get vaultNoExperience;

  /// Vault empty state for the projects section.
  ///
  /// In en, this message translates to:
  /// **'No projects yet.'**
  String get vaultNoProjects;

  /// Vault empty state for the publications section.
  ///
  /// In en, this message translates to:
  /// **'No publications yet.'**
  String get vaultNoPublications;

  /// Vault empty state when the whole-Vault search matches nothing.
  ///
  /// In en, this message translates to:
  /// **'No matches for your search.'**
  String get vaultNoSearchMatches;

  /// Vault banner shown when a write to local storage failed.
  ///
  /// In en, this message translates to:
  /// **'Your last change couldn\'t be saved.'**
  String get vaultPersistError;

  /// Vault basics, button that opens the file picker to choose a profile photograph.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get vaultPhotoAdd;

  /// Vault error when a decoded image failed to resize or re-encode for storage.
  ///
  /// In en, this message translates to:
  /// **'That photo couldn\'t be prepared. Try a different image.'**
  String get vaultPhotoErrorPrepareFailed;

  /// Vault error when the chosen file could not be decoded as an image. JPEG and PNG are format names.
  ///
  /// In en, this message translates to:
  /// **'That file couldn\'t be read as an image. Try a JPEG or PNG.'**
  String get vaultPhotoErrorUnreadable;

  /// Vault basics, help text under the photo field once a photo has been added.
  ///
  /// In en, this message translates to:
  /// **'Used by templates that include a photo. Others ignore it.'**
  String get vaultPhotoHelpInUse;

  /// Vault basics, help text under the photo field when no photo is set. 'DACH' is the German-speaking market grouping used elsewhere in the app.
  ///
  /// In en, this message translates to:
  /// **'Optional. Only used by templates that include a photo — expected in DACH, best left off for the US and UK.'**
  String get vaultPhotoHelpOptional;

  /// Vault basics, shown while the stored photo is being decoded for display.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get vaultPhotoLoading;

  /// Vault basics, button that deletes the stored profile photograph.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get vaultPhotoRemove;

  /// Vault basics, button that swaps the existing profile photograph for a new one.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get vaultPhotoReplace;

  /// Vault basics, heading for the optional profile photograph.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get vaultPhotoTitle;

  /// Proficiency picker option in the Vault languages editor. The CEFR code is never translated; the gloss after it is.
  ///
  /// In en, this message translates to:
  /// **'A1 — Beginner'**
  String get vaultProficiencyA1;

  /// Proficiency picker option in the Vault languages editor. The CEFR code is never translated; the gloss after it is.
  ///
  /// In en, this message translates to:
  /// **'A2 — Elementary'**
  String get vaultProficiencyA2;

  /// Proficiency picker option in the Vault languages editor. The CEFR code is never translated; the gloss after it is.
  ///
  /// In en, this message translates to:
  /// **'B1 — Intermediate'**
  String get vaultProficiencyB1;

  /// Proficiency picker option in the Vault languages editor. The CEFR code is never translated; the gloss after it is.
  ///
  /// In en, this message translates to:
  /// **'B2 — Upper intermediate'**
  String get vaultProficiencyB2;

  /// Proficiency picker option in the Vault languages editor. The CEFR code is never translated; the gloss after it is.
  ///
  /// In en, this message translates to:
  /// **'C1 — Advanced'**
  String get vaultProficiencyC1;

  /// Proficiency picker option in the Vault languages editor. The CEFR code is never translated; the gloss after it is.
  ///
  /// In en, this message translates to:
  /// **'C2 — Mastery'**
  String get vaultProficiencyC2;

  /// Proficiency picker option in the Vault languages editor. CEFR has no native band; this is the one level that prints as a word rather than a code.
  ///
  /// In en, this message translates to:
  /// **'Native speaker'**
  String get vaultProficiencyNative;

  /// Vault project form field label for a URL showing the project.
  ///
  /// In en, this message translates to:
  /// **'Link (optional)'**
  String get vaultProjectLink;

  /// Vault project link placeholder. A URL example — keep the shape.
  ///
  /// In en, this message translates to:
  /// **'e.g. github.com/you/project'**
  String get vaultProjectLinkHint;

  /// Vault placeholder title for a project entry with no title yet.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get vaultProjectNew;

  /// Vault project form field label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get vaultProjectTitle;

  /// Vault publication form field label for the full academic citation.
  ///
  /// In en, this message translates to:
  /// **'Citation (optional)'**
  String get vaultPublicationCitation;

  /// Vault publication citation placeholder. Keep the citation shape; the target market's own citation style may differ.
  ///
  /// In en, this message translates to:
  /// **'e.g. Trujillo, L. (2021). Journal Name, 11(2), 194–206.'**
  String get vaultPublicationCitationHint;

  /// Vault publication form field label for a URL or DOI.
  ///
  /// In en, this message translates to:
  /// **'Link (optional)'**
  String get vaultPublicationLink;

  /// Vault publication link placeholder. 'doi.org' is a real domain — keep it.
  ///
  /// In en, this message translates to:
  /// **'e.g. doi.org/10.1234/example'**
  String get vaultPublicationLinkHint;

  /// Vault placeholder title for a publication entry with no title yet.
  ///
  /// In en, this message translates to:
  /// **'New publication'**
  String get vaultPublicationNew;

  /// Vault publication form field label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get vaultPublicationTitle;

  /// Vault publication title placeholder — an example paper title. Replace with one natural in the target language.
  ///
  /// In en, this message translates to:
  /// **'e.g. Community resistance in Doña Juana'**
  String get vaultPublicationTitleHint;

  /// Vault, one line naming an education entry by qualification and institution.
  ///
  /// In en, this message translates to:
  /// **'{qualification} · {institution}'**
  String vaultQualificationAtInstitution(
    String qualification,
    String institution,
  );

  /// Vault, one line naming a job by role and employer, used in the bullet picker so a bullet can be told apart from a similar one elsewhere.
  ///
  /// In en, this message translates to:
  /// **'{role} · {company}'**
  String vaultRoleAtCompany(String role, String company);

  /// Placeholder in the search field above the Vault's entry list.
  ///
  /// In en, this message translates to:
  /// **'Search your Vault…'**
  String get vaultSearch;

  /// Heading above the Vault's career-content cards (personal details, experience, skills and so on), separating them from the document defaults above.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get vaultSectionAboutYou;

  /// Heading above the Vault's document-defaults card, separating it from the career content below. Follows the default region's document noun. Branch on the noun, not on the language.
  ///
  /// In en, this message translates to:
  /// **'{noun, select, resume{Résumé defaults} other{CV defaults}}'**
  String vaultSectionCvDefaults(String noun);

  /// Vault list section heading for qualifications.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get vaultSectionEducation;

  /// Vault list section heading for jobs and roles. Note this is the Vault's own picker label, deliberately independent of the heading printed on the CV.
  ///
  /// In en, this message translates to:
  /// **'Work history'**
  String get vaultSectionExperience;

  /// Heading above the hobbies card in the Vault's main list.
  ///
  /// In en, this message translates to:
  /// **'Hobbies and interests'**
  String get vaultSectionHobbies;

  /// Heading above the languages card in the Vault's main list.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get vaultSectionLanguages;

  /// Vault list section heading for projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get vaultSectionProjects;

  /// Vault list section heading for published work.
  ///
  /// In en, this message translates to:
  /// **'Publications'**
  String get vaultSectionPublications;

  /// Heading above the skills card in the Vault's main list.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get vaultSectionSkills;

  /// Vault, summary of how many bullet points this skill is tied to.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Linked to 1 bullet} other{Linked to {count} bullets}}'**
  String vaultSkillLinkedBullets(int count);

  /// Vault action opening the picker that ties this skill to bullet points.
  ///
  /// In en, this message translates to:
  /// **'Link to bullets'**
  String get vaultSkillLinkToBullets;

  /// Vault empty state in the bullet-link picker when the search matches nothing.
  ///
  /// In en, this message translates to:
  /// **'No bullets match your search.'**
  String get vaultSkillNoBulletMatches;

  /// Vault button that creates a new, empty skill category.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get vaultSkillsAddCategory;

  /// Vault button that adds a new, empty skill to a category.
  ///
  /// In en, this message translates to:
  /// **'Add skill'**
  String get vaultSkillsAddSkill;

  /// Vault sub-heading above the skill category list.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get vaultSkillsCategories;

  /// Vault form field label for a skill category's name.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get vaultSkillsCategoryName;

  /// Vault skill category name placeholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Languages & Frameworks'**
  String get vaultSkillsCategoryNameHint;

  /// Tooltip on the button removing a whole skill category.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get vaultSkillsDeleteCategory;

  /// Tooltip on the button removing one skill.
  ///
  /// In en, this message translates to:
  /// **'Delete skill'**
  String get vaultSkillsDeleteSkill;

  /// Vault placeholder in the bullet-link search field.
  ///
  /// In en, this message translates to:
  /// **'Search bullets…'**
  String get vaultSkillSearchBullets;

  /// Vault list card line under the skills section while a search is active, counting the skills that matched. Other languages may need different plural categories.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 matching skill} other{{count} matching skills}}'**
  String vaultSkillsMatchCount(int count);

  /// Vault empty state when no skill categories exist.
  ///
  /// In en, this message translates to:
  /// **'No skill categories yet.'**
  String get vaultSkillsNoCategories;

  /// Vault empty state when the skills search matches nothing.
  ///
  /// In en, this message translates to:
  /// **'No skills match your search.'**
  String get vaultSkillsNoMatches;

  /// Vault placeholder in the skills search field.
  ///
  /// In en, this message translates to:
  /// **'Search skills…'**
  String get vaultSkillsSearch;

  /// Vault form field label for one skill's name.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get vaultSkillsSkillLabel;

  /// Vault summary card line counting skill categories and skills.
  ///
  /// In en, this message translates to:
  /// **'{categories} categories, {skills} skills'**
  String vaultSkillsSummary(int categories, int skills);

  /// Vault section heading for the user's skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get vaultSkillsTitle;

  /// Placeholder shown wherever a project is referenced but has no title yet.
  ///
  /// In en, this message translates to:
  /// **'Untitled project'**
  String get vaultUntitledProject;

  /// Placeholder shown wherever a publication is referenced but has no title yet.
  ///
  /// In en, this message translates to:
  /// **'Untitled publication'**
  String get vaultUntitledPublication;

  /// Placeholder shown wherever an education entry is referenced but has no qualification name yet.
  ///
  /// In en, this message translates to:
  /// **'Untitled qualification'**
  String get vaultUntitledQualification;

  /// Placeholder shown wherever a job entry is referenced but has no role name filled in yet.
  ///
  /// In en, this message translates to:
  /// **'Untitled role'**
  String get vaultUntitledRole;

  /// Button in the Vault's year/month picker that removes the chosen date. Only shown where the date is optional — an experience start date never is.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get vaultYearMonthClear;

  /// Placeholder in the Vault's year/month field before a date has been chosen.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get vaultYearMonthEmpty;

  /// Tooltip on the forward arrow in the Vault's year/month picker.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get vaultYearMonthNextYear;

  /// Tooltip on the forward arrow while the Vault's picker is showing its grid of years.
  ///
  /// In en, this message translates to:
  /// **'Later years'**
  String get vaultYearMonthNextYears;

  /// Tooltip on the year label in the Vault's year/month picker, which switches the grid from months to years.
  ///
  /// In en, this message translates to:
  /// **'Choose a year'**
  String get vaultYearMonthPickYear;

  /// Tooltip on the back arrow in the Vault's year/month picker.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get vaultYearMonthPreviousYear;

  /// Tooltip on the back arrow while the Vault's picker is showing its grid of years.
  ///
  /// In en, this message translates to:
  /// **'Earlier years'**
  String get vaultYearMonthPreviousYears;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
