// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get analyzerAnalyzingBody =>
      'Reading the PDF and checking for ATS parsing issues.';

  @override
  String get analyzerAnalyzingTitle => 'Analyzing…';

  @override
  String get analyzerErrorEngineLoad =>
      'Couldn\'t load the PDF engine — check your connection and try again.';

  @override
  String get analyzerErrorGeneric => 'Couldn\'t analyze that file — try again.';

  @override
  String get analyzerErrorInteractiveForm =>
      'This is an interactive PDF form, which works differently from a typical resume and can\'t be analyzed the same way.';

  @override
  String get analyzerErrorInvalidPdf =>
      'That file doesn\'t look like a valid PDF, or it\'s password-protected.';

  @override
  String get analyzerErrorTitle => 'Couldn\'t analyze that file';

  @override
  String analyzerFindingLocationsAcrossPages(int count, int pages) {
    return '$count locations across $pages pages';
  }

  @override
  String analyzerFindingLocationsOnPage(int count, int page) {
    return '$count locations on page $page';
  }

  @override
  String analyzerFindingStepOf(int index, int total) {
    return '$index of $total';
  }

  @override
  String get analyzerMachineEmptyBody =>
      'This PDF didn\'t yield any extractable text runs.';

  @override
  String get analyzerMachineEmptyTitle => 'No text extracted';

  @override
  String analyzerPageLabel(int page) {
    return 'Page $page';
  }

  @override
  String get analyzerResultsAnalyzeAnother => 'Analyze another file';

  @override
  String analyzerResultsExtractionSummary(int pages, int runs) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages pages',
      one: '1 page',
    );
    String _temp1 = intl.Intl.pluralLogic(
      runs,
      locale: localeName,
      other: '$runs text runs',
      one: '1 text run',
    );
    return '$_temp0, $_temp1 extracted.';
  }

  @override
  String get analyzerResultsTitle => 'Results';

  @override
  String get analyzerTabMachineIngestion => 'Machine Ingestion';

  @override
  String get analyzerTabXray => 'X-Ray';

  @override
  String analyzerUploadBody(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv':
          'Upload a PDF CV to check for formatting that applicant tracking software commonly misreads',
      'resume':
          'Upload a PDF résumé to check for formatting that applicant tracking software commonly misreads',
      'other':
          'Upload a PDF document to check for formatting that applicant tracking software commonly misreads',
    });
    return '$_temp0 — missing text layers, multi-column layouts, garbled characters, and more. Nothing leaves your browser.';
  }

  @override
  String get analyzerUploadCta => 'Upload PDF';

  @override
  String analyzerUploadTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Check your CV for ATS issues',
      'resume': 'Check your résumé for ATS issues',
      'other': 'Check your document for ATS issues',
    });
    return '$_temp0';
  }

  @override
  String get analyzerXrayDocumentLevel => 'Document-level';

  @override
  String get analyzerXrayEmptyBody => 'Analyze a PDF to see its X-Ray.';

  @override
  String get analyzerXrayEmptyTitle => 'Nothing to show yet';

  @override
  String get analyzerXrayFindings => 'Findings';

  @override
  String get analyzerXrayNoIssuesBody =>
      'Nothing in this PDF matched a known ATS parsing problem.';

  @override
  String get analyzerXrayNoIssuesTitle => 'No issues found';

  @override
  String get analyzerXrayPageEmptyBody =>
      'No extractable text runs to draw boxes on.';

  @override
  String get analyzerXrayPageEmptyTitle => 'Nothing to show on this page';

  @override
  String analyzerXrayPageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get analyzerXrayPageTab => 'Page';

  @override
  String get analyzerXrayReadingOrder => 'Reading order';

  @override
  String get appNavAnalyzer => 'ATS Check';

  @override
  String appNavDrafts(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'CVs',
      'resume': 'Résumés',
      'other': 'Documents',
    });
    return '$_temp0';
  }

  @override
  String get appNavSettings => 'Settings';

  @override
  String get appNavVault => 'Vault';

  @override
  String atsFindingColumnCrushBody(String left, String right, String merged) {
    return '\"$left\" and \"$right\" sit on the same line with a wide gap between them. A text extractor that reads by position rather than by the document\'s own structure may merge these into one run, e.g. \"$merged\".';
  }

  @override
  String get atsFindingColumnCrushTitle => 'Possible multi-column layout';

  @override
  String atsFindingDroppedCharsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Found $count short runs where more space was used than the extracted characters account for',
      one:
          'Found 1 short run where more space was used than the extracted characters account for',
    );
    return '$_temp0 — a sign a symbol (often a bullet) silently failed to extract at all.';
  }

  @override
  String get atsFindingDroppedCharsTitle => 'Possible dropped characters';

  @override
  String atsFindingGarbledBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $count characters that failed to decode to readable text',
      one: 'Found 1 character that failed to decode to readable text',
    );
    return '$_temp0 — the font used likely has a missing or broken character map. An ATS will see this text as garbage.';
  }

  @override
  String get atsFindingGarbledTitle => 'Unreadable characters found';

  @override
  String atsFindingIconFontBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $count characters from a private-use code range',
      one: 'Found 1 character from a private-use code range',
    );
    return '$_temp0 embedded within words — a common sign of an icon or symbol font (e.g. Wingdings) rather than real text, which most ATS parsers will render as blanks or gibberish.';
  }

  @override
  String get atsFindingIconFontTitle =>
      'Possible icon/symbol font glyphs in text';

  @override
  String atsFindingMissingHeadingBody(String section) {
    String _temp0 = intl.Intl.selectLogic(section, {
      'experience':
          'Couldn\'t find a heading for Experience anywhere in the document.',
      'education':
          'Couldn\'t find a heading for Education anywhere in the document.',
      'skills': 'Couldn\'t find a heading for Skills anywhere in the document.',
      'other':
          'Couldn\'t find a heading for $section anywhere in the document.',
    });
    return '$_temp0 Some ATS software structures a resume by matching canonical section headings, and may file this content as unstructured text if the heading is missing or phrased unusually.';
  }

  @override
  String atsFindingMissingHeadingTitle(String section) {
    String _temp0 = intl.Intl.selectLogic(section, {
      'experience': 'No Experience section detected',
      'education': 'No Education section detected',
      'skills': 'No Skills section detected',
      'other': 'No $section section detected',
    });
    return '$_temp0';
  }

  @override
  String get atsFindingNoEmailBody =>
      'Couldn\'t find an email address in the extracted text or in any clickable link. Most ATS software requires a readable email address to file an application.';

  @override
  String get atsFindingNoEmailTitle => 'No email address found';

  @override
  String get atsFindingNonEmbeddedFontBody =>
      'This PDF relies on at least one font that is not embedded in the file. Combined with the unreadable text found above, this is a likely contributing cause.';

  @override
  String get atsFindingNonEmbeddedFontTitle => 'Non-embedded font in use';

  @override
  String get atsFindingNoPhoneBody =>
      'Couldn\'t find a phone number in the extracted text or in any clickable link.';

  @override
  String get atsFindingNoPhoneTitle => 'No phone number found';

  @override
  String get atsFindingNoTextLayerBody =>
      'This PDF has no text layer at all — likely a scanned image. Most ATS software will read this as a completely blank resume.';

  @override
  String get atsFindingNoTextLayerTitle => 'No extractable text found';

  @override
  String atsFindingPageNoTextBody(int page) {
    return 'Page $page contributed no text at all, while other pages did — an ATS will likely skip this page entirely.';
  }

  @override
  String atsFindingPageNoTextTitle(int page) {
    return 'Page $page has no extractable text';
  }

  @override
  String get chromeStorageUnavailableBody =>
      'Local storage is unavailable in this browser or browsing mode. CVForge keeps everything on your device, so it needs access to it to work. Try a normal (non-private) browsing window, or a different browser.';

  @override
  String get chromeStorageUnavailableTitle =>
      'CVForge couldn\'t load your data';

  @override
  String get commonAdd => 'Add';

  @override
  String commonAddAll(int count) {
    return 'Add all ($count)';
  }

  @override
  String get commonBeta => 'BETA';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonClearSearch => 'Clear search';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDisconnect => 'Disconnect';

  @override
  String get commonDone => 'Done';

  @override
  String get commonMore => 'More';

  @override
  String commonRelativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String commonRelativeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String commonRelativeOnDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'dd/MM/yyyy',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'on $dateString';
  }

  @override
  String get commonRelativeUnderAnHour => '< 1 hour ago';

  @override
  String get commonRelativeYesterday => 'yesterday';

  @override
  String get commonRemove => 'Remove';

  @override
  String commonRemoveAll(int count) {
    return 'Remove all ($count)';
  }

  @override
  String get commonReplace => 'Replace';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonRun => 'Run';

  @override
  String get commonRunning => 'Running…';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get documentLanguageDaName => 'Dansk';

  @override
  String get documentLanguageDeAtName => 'Deutsch (Österreich)';

  @override
  String get documentLanguageDeName => 'Deutsch';

  @override
  String get documentLanguageEnAuName => 'English (Australia)';

  @override
  String get documentLanguageEnGbName => 'English (United Kingdom)';

  @override
  String get documentLanguageEnUsName => 'English (United States)';

  @override
  String get documentLanguageEs419Name => 'Español (Latinoamérica)';

  @override
  String get documentLanguageEsName => 'Español (España)';

  @override
  String get documentLanguageFiName => 'Suomi';

  @override
  String get documentLanguageFrCaName => 'Français (Canada)';

  @override
  String get documentLanguageFrName => 'Français';

  @override
  String get documentLanguageItName => 'Italiano';

  @override
  String get documentLanguageNbName => 'Norsk bokmål';

  @override
  String get documentLanguageNlName => 'Nederlands';

  @override
  String get documentLanguagePtBrName => 'Português (Brasil)';

  @override
  String get documentLanguagePtPtName => 'Português (Portugal)';

  @override
  String get documentLanguageSvName => 'Svenska';

  @override
  String draftCopySuffix(String name) {
    return '$name (copy)';
  }

  @override
  String get draftDefaultName => 'My CV';

  @override
  String get driveSyncAccountFallback => 'your Google account';

  @override
  String get driveSyncErrorCorrupted =>
      'Drive\'s copy looked corrupted. Left this device as is.';

  @override
  String get driveSyncErrorFileGone =>
      'Your CVForge file on Drive is gone. Syncing again will recreate it.';

  @override
  String get driveSyncErrorNetwork =>
      'Couldn\'t reach Google Drive. Saved on this device.';

  @override
  String get driveSyncErrorNewerVersion =>
      'Another device is running a newer version of CVForge. Update this device to sync again.';

  @override
  String get driveSyncErrorUnknown =>
      'Something went wrong syncing to Drive. Saved on this device.';

  @override
  String get driveSyncMerged => 'Merged changes from your other device';

  @override
  String get driveSyncNeedsReauth =>
      'Reconnect Google Drive in Settings to keep syncing';

  @override
  String get driveSyncPending => 'Waiting to sync to Google Drive…';

  @override
  String get driveSyncSynced => 'Synced to Google Drive';

  @override
  String driveSyncSyncedAt(String relative) {
    return 'Synced to Google Drive · $relative';
  }

  @override
  String get driveSyncSyncing => 'Syncing to Google Drive…';

  @override
  String get localeDisplayName => 'English';

  @override
  String get pageFormatA4 => 'A4 (210 × 297 mm)';

  @override
  String get pageFormatLetter => 'US Letter (8.5 × 11 in)';

  @override
  String get personalDetailsMinimal => 'Name, contact, city';

  @override
  String get personalDetailsOmit => 'Name and contact only';

  @override
  String get personalDetailsTraditional =>
      'Name, contact, date of birth, nationality';

  @override
  String get photoStanceDiscouraged => 'No — strongly discouraged';

  @override
  String get photoStanceExpected => 'Usually expected';

  @override
  String get photoStanceOptional => 'Optional';

  @override
  String get photoStanceProhibited => 'No — an automatic rejection';

  @override
  String get regionAnzConvention1 =>
      'Two to three pages is normal and expected. A one-page resume reads as thin here.';

  @override
  String get regionAnzConvention2 =>
      'No photograph, date of birth, or marital status.';

  @override
  String get regionAnzConvention3 =>
      'State your work rights in the header — \"Australian citizen\", \"NZ permanent resident\", \"482 visa\". Recruiters filter on this first.';

  @override
  String get regionAnzConvention4 =>
      'Include a dedicated \"Referees\" section with two named referees, or state that details are available on request.';

  @override
  String get regionAnzConvention5 =>
      'If writing in English, use Australian spelling: organised, centre, analyse. Be consistent — some sectors accept -ize, but mixing the two is what gets noticed.';

  @override
  String get regionAnzConvention6 =>
      'Give more context per role than a US résumé would: company scope, reporting lines, team size, budget.';

  @override
  String get regionAnzCoverage => 'Australia, New Zealand';

  @override
  String get regionAnzDisplayName => 'Australia & New Zealand';

  @override
  String get regionAnzLengthNote =>
      'Two to three pages mid-career; three to five for executive roles.';

  @override
  String get regionAnzToneNote =>
      'Context-rich and concrete. Explain what the organisation does, the size of your remit, then the outcome — Australasian readers expect more surrounding detail than a US résumé gives.';

  @override
  String get regionDachConvention1 =>
      'Around two thirds of German-speaking employers still expect a professional headshot, top right. Upload one in the Vault and choose a template that includes one; the rest leave it off.';

  @override
  String get regionDachConvention2 =>
      'Date and place of birth, nationality, and sometimes marital status are traditional in the personal-details block, and CVForge has no field for any of them. Younger and international employers increasingly omit them: omitting is safe, including is conventional.';

  @override
  String get regionDachConvention3 =>
      'The chronology must be gap-free and month-precise. An unexplained gap reads as concealment; label it plainly (\"Parental leave\", \"Further education\").';

  @override
  String get regionDachConvention4 =>
      'Education stays prominent throughout your career, with the institution named and grades given.';

  @override
  String get regionDachConvention5 =>
      'Certificates (Zeugnisse) are attached as a separate document; the Lebenslauf references them rather than reproducing them.';

  @override
  String get regionDachConvention6 =>
      'If writing in English, use British spelling.';

  @override
  String get regionDachCoverage => 'Germany, Austria, Switzerland';

  @override
  String get regionDachDisplayName => 'DACH';

  @override
  String get regionDachLengthNote =>
      'Two to three pages, tabular and complete.';

  @override
  String get regionDachToneNote =>
      'Formal, factual, complete. Understatement over salesmanship, verifiable facts over adjectives.';

  @override
  String get regionEuropeConvention1 =>
      'One to two pages. France in particular expects a single page for anything under about fifteen years\' experience.';

  @override
  String get regionEuropeConvention2 =>
      'A photograph is common in France, Spain, Italy, and Portugal, and unusual elsewhere. For an international or multinational application, leave it off.';

  @override
  String get regionEuropeConvention3 =>
      'Keep personal data minimal for a multinational. A domestic French or Southern European employer may still expect date of birth and nationality.';

  @override
  String get regionEuropeConvention4 =>
      'List language proficiencies with CEFR levels (A1–C2). European recruiters read these precisely.';

  @override
  String get regionEuropeConvention5 =>
      'Southern European employers tolerate longer CVs — four or five pages is seen — but a tighter document still reads better.';

  @override
  String get regionEuropeConvention6 =>
      'If writing in English, use British spelling. A local-language version is worth producing for a domestic application.';

  @override
  String get regionEuropeCoverage =>
      'France, Benelux, Southern Europe, and multinationals';

  @override
  String get regionEuropeDisplayName => 'Europe — international';

  @override
  String get regionEuropeLengthNote =>
      'One to two pages. France prefers one; Southern Europe tolerates more.';

  @override
  String get regionEuropeToneNote =>
      'Professional and measured. Concrete results, without the hard-sell register of a US résumé.';

  @override
  String get regionLatamA4Convention1 =>
      'A4 is standard across Brazil, Argentina, Uruguay, and Peru. For Mexico, Colombia, Chile, or Central America, pick \"Mexico, Colombia & Chile\" instead — those markets use US Letter.';

  @override
  String get regionLatamA4Convention2 =>
      'The document is a \"Currículo\" in Brazil and a \"Curriculum Vitae\" across the Southern Cone.';

  @override
  String get regionLatamA4Convention3 =>
      'A photograph, date of birth, marital status, and national ID number (CPF, DNI/CUIL) are common at domestic firms, and deliberately excluded by multinationals and their local subsidiaries. Match the employer, not the country. CVForge renders a photograph when the template supports one; it has no field for the rest.';

  @override
  String get regionLatamA4Convention4 => 'Two to three pages is normal.';

  @override
  String get regionLatamA4Convention5 =>
      'Certified language proficiency is a primary screening filter, especially in Brazil: state TOEFL, IELTS, DELE, or CELPE-Bras scores with the date taken.';

  @override
  String get regionLatamA4Convention6 =>
      'Name the institution for every qualification; university reputation is read closely.';

  @override
  String get regionLatamA4Convention7 =>
      'If writing in English, US spelling is the regional norm.';

  @override
  String get regionLatamA4Coverage => 'Brazil, Argentina, Uruguay, Peru';

  @override
  String get regionLatamA4DisplayName => 'Brazil & Southern Cone';

  @override
  String get regionLatamA4LengthNote => 'Two to three pages.';

  @override
  String get regionLatamA4ToneNote =>
      'Formal and credential-forward. Qualifications, institutions, and certifications carry real weight — state them fully.';

  @override
  String get regionLatamLetterConvention1 =>
      'US Letter is standard across Mexico, Colombia, Chile, and Central America. For Brazil, Argentina, Uruguay, or Peru, pick \"Brazil & Southern Cone\" instead — those markets use A4.';

  @override
  String get regionLatamLetterConvention2 =>
      'The document is a \"Hoja de Vida\" in Colombia and the Andean countries, and a \"Currículum Vitae\" in Mexico and Central America.';

  @override
  String get regionLatamLetterConvention3 =>
      'A photograph, date of birth, marital status, and national ID number (CURP/RFC, Cédula) are common at domestic firms, and deliberately excluded by multinationals and their local subsidiaries. Match the employer, not the country. CVForge renders a photograph when the template supports one; it has no field for the rest.';

  @override
  String get regionLatamLetterConvention4 => 'Two to three pages is normal.';

  @override
  String get regionLatamLetterConvention5 =>
      'Certified language proficiency carries real weight: state TOEFL, IELTS, or DELE scores with the date taken.';

  @override
  String get regionLatamLetterConvention6 =>
      'Name the institution for every qualification; university reputation is read closely.';

  @override
  String get regionLatamLetterConvention7 =>
      'If writing in English, US spelling is the regional norm.';

  @override
  String get regionLatamLetterCoverage =>
      'Mexico, Colombia, Chile, Central America';

  @override
  String get regionLatamLetterDisplayName => 'Mexico, Colombia & Chile';

  @override
  String get regionLatamLetterLengthNote => 'Two to three pages.';

  @override
  String get regionLatamLetterToneNote =>
      'Formal and credential-forward. Qualifications, institutions, and certifications carry real weight — state them fully.';

  @override
  String get regionNordicsConvention1 =>
      'One to two pages. A long CV reads as poor editing.';

  @override
  String get regionNordicsConvention2 =>
      'A photograph is neither expected nor unwelcome. Include one only if it is genuinely professional.';

  @override
  String get regionNordicsConvention3 =>
      'Keep personal data minimal: name, contact, city. No date of birth, marital status, or national ID number.';

  @override
  String get regionNordicsConvention4 =>
      'Frame achievements around the team and the outcome rather than personal heroics.';

  @override
  String get regionNordicsConvention5 =>
      'State Scandinavian language proficiency explicitly with a level (\"Swedish — B2\"). It moves the needle.';

  @override
  String get regionNordicsConvention6 =>
      'English CVs are widely accepted; if you write in English, use British spelling.';

  @override
  String get regionNordicsCoverage => 'Sweden, Norway, Denmark, Finland';

  @override
  String get regionNordicsDisplayName => 'Nordics';

  @override
  String get regionNordicsLengthNote =>
      'One to two pages. Concision is read as a virtue here.';

  @override
  String get regionNordicsToneNote =>
      'Factual and team-framed. Say what the team achieved and what your part in it was; \"I single-handedly\" reads badly across the Nordics.';

  @override
  String get regionUkConvention1 =>
      'Two pages is the norm. One page for a recent graduate; three only for academic or very senior roles.';

  @override
  String get regionUkConvention2 =>
      'No photograph, date of birth, marital status, or nationality. UK equality law makes them a liability for the employer as much as for you.';

  @override
  String get regionUkConvention3 =>
      'If writing in English, use British spelling throughout: organised, programme, centre, analyse.';

  @override
  String get regionUkConvention4 =>
      '\"References available on request\" at the foot is still expected. Do not list referees\' contact details.';

  @override
  String get regionUkConvention5 =>
      'Open with a short personal statement or profile.';

  @override
  String get regionUkConvention6 =>
      'Ireland follows the same conventions. State your work authorisation if you are not an EU or UK citizen.';

  @override
  String get regionUkCoverage => 'United Kingdom, Ireland';

  @override
  String get regionUkDisplayName => 'UK & Ireland';

  @override
  String get regionUkLengthNote =>
      'Two pages is the standard. One page is fine for a recent graduate.';

  @override
  String get regionUkToneNote =>
      'Understated and factual. State achievements plainly with the evidence behind them; overt self-promotion reads as boastful.';

  @override
  String get regionUsConvention1 =>
      'One page until roughly ten years of experience, two beyond that. Three pages means an academic CV, which is a different document.';

  @override
  String get regionUsConvention2 =>
      'Never include a photograph, date of birth, marital status, or gender. US employers routinely discard résumés carrying them to avoid discrimination claims.';

  @override
  String get regionUsConvention3 =>
      'Single column. No tables, text boxes, headers, or footers — US applicant tracking systems are the strictest anywhere and mis-parse everything else.';

  @override
  String get regionUsConvention4 =>
      'If writing in English, use US spelling: organized, program, center, analyze.';

  @override
  String get regionUsConvention5 =>
      'Quantify everything you can. An unquantified bullet reads as a job description rather than an achievement.';

  @override
  String get regionUsConvention6 =>
      'Do not add a references line; it is assumed.';

  @override
  String get regionUsConvention7 =>
      'Canada follows the same conventions. Quebec roles may expect a French-language version alongside.';

  @override
  String get regionUsCoverage => 'United States, Canada';

  @override
  String get regionUsDisplayName => 'US & Canada';

  @override
  String get regionUsLengthNote =>
      'One page under about ten years\' experience; two pages beyond that.';

  @override
  String get regionUsToneNote =>
      'Quantified and outcome-led. Lead each bullet with the result and a number — revenue, percentage, headcount, time saved.';

  @override
  String get sectionLabelEducation => 'Education';

  @override
  String get sectionLabelExperience => 'Work history';

  @override
  String get sectionLabelHobbies => 'Hobbies and interests';

  @override
  String get sectionLabelProjects => 'Projects';

  @override
  String get sectionLabelPublications => 'Publications';

  @override
  String get sectionLabelReferences => 'References';

  @override
  String get sectionLabelSkills => 'Skills';

  @override
  String get sectionLabelSummary => 'Professional summary';

  @override
  String get settingsAiBody =>
      'Bring your own API key to enable AI-assisted tailoring. Your key never leaves this device except to call the provider\'s API directly. There is no CVForge server.';

  @override
  String settingsAiConfiguredElsewhere(String provider) {
    return 'You set the AI Assistant up on another device. Your CVs synced, but your key stayed there on purpose — paste your $provider key below to use the assistant here too.';
  }

  @override
  String get settingsAiConnected => 'Connected.';

  @override
  String settingsAiErrorInvalidRequest(String provider) {
    return '$provider rejected the request. That\'s a bug in CVForge, not your key.';
  }

  @override
  String get settingsAiErrorMalformedResponse =>
      'Got an unexpected response. Try again.';

  @override
  String settingsAiErrorNetwork(String provider) {
    return 'Couldn\'t reach $provider. Check your connection.';
  }

  @override
  String get settingsAiErrorNoKey => 'Enter an API key first.';

  @override
  String settingsAiErrorOverloaded(String provider) {
    return '$provider\'s API is temporarily unavailable. Try again shortly.';
  }

  @override
  String get settingsAiErrorRateLimited =>
      'Your API account is rate limited. Try again in a moment.';

  @override
  String get settingsAiErrorRefusal => 'The connection check was refused.';

  @override
  String get settingsAiErrorTimeout => 'The request timed out. Try again.';

  @override
  String get settingsAiErrorUnauthorized =>
      'That key was rejected. Check it and try again.';

  @override
  String get settingsAiHelpDedicatedKey =>
      'Use a key created only for CVForge, so you can revoke it without breaking anything else.';

  @override
  String get settingsAiHelpNoAutoTopUp =>
      'Turn OFF auto top-up / auto-reload. Left on, a runaway or leaked key can recharge itself indefinitely.';

  @override
  String get settingsAiHelpOpenBilling => 'Open billing & spend limits';

  @override
  String settingsAiHelpOpenKeySettings(String provider) {
    return 'Open $provider key settings';
  }

  @override
  String get settingsAiHelpProtectTitle =>
      'Protect yourself from surprise bills';

  @override
  String get settingsAiHelpSpendCap =>
      'Set a hard monthly spend cap, as low as you are willing to pay.';

  @override
  String settingsAiHelpStepNumber(int number) {
    return '$number.';
  }

  @override
  String settingsAiHelpTitle(String provider) {
    return 'How do I get a $provider API key?';
  }

  @override
  String get settingsAiKeepCurrentKey => 'Keep my current key';

  @override
  String get settingsAiKeyFieldHint => 'Paste your API key';

  @override
  String settingsAiKeyFieldLabel(String provider) {
    return '$provider API key';
  }

  @override
  String settingsAiKeyNone(String provider) {
    return 'No $provider key yet. The AI Assistant is off.';
  }

  @override
  String settingsAiKeySaved(String provider) {
    return 'Your $provider key is saved on this device.';
  }

  @override
  String get settingsAiKeySavedOnSuccess =>
      'Your key is saved only if the connection test succeeds.';

  @override
  String settingsAiKeySession(String provider) {
    return 'Your $provider key is set for this session only. It will be gone when you reload the page.';
  }

  @override
  String get settingsAiModelLabel => 'Model';

  @override
  String settingsAiPriceLabel(String provider, String price) {
    return '$provider\'s own rate, not billed by CVForge: $price';
  }

  @override
  String settingsAiPriceRate(double input, double output) {
    final intl.NumberFormat inputNumberFormat = intl.NumberFormat.currency(
      locale: localeName,
      symbol: '\$',
      decimalDigits: 2,
    );
    final String inputString = inputNumberFormat.format(input);
    final intl.NumberFormat outputNumberFormat = intl.NumberFormat.currency(
      locale: localeName,
      symbol: '\$',
      decimalDigits: 2,
    );
    final String outputString = outputNumberFormat.format(output);

    return '$inputString in / $outputString out per M tokens';
  }

  @override
  String get settingsAiProviderLabel => 'Provider';

  @override
  String get settingsAiRemoveKey => 'Remove key';

  @override
  String settingsAiRemoveKeyConfirmBody(String provider) {
    return '$provider won\'t show you this key again, so you\'d need to create a new one in their console to use the AI Assistant on this device. Your CVs and Vault are not affected.';
  }

  @override
  String settingsAiRemoveKeyConfirmTitle(String provider) {
    return 'Remove your $provider key?';
  }

  @override
  String get settingsAiReplaceKey => 'Replace key';

  @override
  String get settingsAiStorageWarning =>
      'Your key is saved on this device, unencrypted in this browser\'s storage — the same as your Vault and CVs. Anyone with access to this device can read it.';

  @override
  String get settingsAiTestAndSave => 'Test and save';

  @override
  String get settingsAiTestConnection => 'Test connection';

  @override
  String get settingsAiTitle => 'AI Assistant';

  @override
  String get settingsAppearanceBody =>
      'Applies to CVForge\'s own interface. Your CV always renders on white paper, whichever theme you pick.';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsBackupBody =>
      'Export your whole Vault and every CV as one JSON file, or restore from a previous export. Restoring replaces everything currently on this device. Your current data downloads as a backup first.';

  @override
  String get settingsBackupExport => 'Export backup';

  @override
  String get settingsBackupImport => 'Import backup';

  @override
  String settingsBackupLast(String relative) {
    return 'Last backed up $relative';
  }

  @override
  String settingsBackupLastWithChanges(String relative) {
    return 'Last backed up $relative, and you have changes since then';
  }

  @override
  String get settingsBackupNever => 'Never backed up';

  @override
  String get settingsBackupTitle => 'Manual backup';

  @override
  String get settingsClearVault => 'Clear Vault';

  @override
  String get settingsClearVaultConfirmBody =>
      'This removes every experience, project, skill, education entry, hobby, and publication. This can\'t be undone.';

  @override
  String get settingsClearVaultConfirmTitle => 'Clear your entire Vault?';

  @override
  String get settingsDangerZone => 'Danger zone';

  @override
  String get settingsDriveBody =>
      'Sign in with Google to keep your Vault and every CV synced to your own Google Drive. Sign in again on another browser and they\'ll all be there. CVForge never sees or stores your Google credentials, only a single hidden file this app creates for itself.';

  @override
  String get settingsDriveConnect => 'Connect Google Drive';

  @override
  String settingsDriveConnectedAs(String email) {
    return 'Connected as $email';
  }

  @override
  String get settingsDriveConnecting => 'Connecting…';

  @override
  String get settingsDriveDisconnectConfirmBody =>
      'Your Vault and CVs stay exactly as they are on this device. This only stops syncing them to Drive. You can reconnect any time.';

  @override
  String get settingsDriveDisconnectConfirmTitle => 'Disconnect Google Drive?';

  @override
  String get settingsDriveErrorCancelled => 'Connection cancelled.';

  @override
  String get settingsDriveErrorNotConfigured =>
      'Google Drive sync is not set up.';

  @override
  String get settingsDriveErrorScriptLoad =>
      'Couldn\'t reach Google. Check your connection and try again.';

  @override
  String get settingsDriveErrorUnknown =>
      'Couldn\'t connect to Google Drive. Try again.';

  @override
  String settingsDriveLastSynced(String relative) {
    return 'Last synced $relative';
  }

  @override
  String get settingsDriveMerged => 'Merged changes from your other device';

  @override
  String get settingsDriveNotYetSynced => 'Not yet synced';

  @override
  String get settingsDriveReconnect => 'Reconnect';

  @override
  String settingsDriveReconnectPrompt(String email) {
    return 'Connected as $email. Reconnect to keep syncing.';
  }

  @override
  String get settingsDriveSyncing => 'Syncing…';

  @override
  String get settingsDriveSyncNow => 'Sync now';

  @override
  String get settingsDriveTitle => 'Google Drive';

  @override
  String get settingsDriveWaiting => 'Waiting to sync…';

  @override
  String settingsImportConfirmBody(String noun, int current, int incoming) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv':
          'This will replace your Vault and all $current CVs with $incoming CVs from this file.',
      'resume':
          'This will replace your Vault and all $current résumés with $incoming résumés from this file.',
      'other':
          'This will replace your Vault and all $current documents with $incoming documents from this file.',
    });
    return '$_temp0 Your current data downloads as a backup first.';
  }

  @override
  String get settingsImportConfirmTitle => 'Replace your data?';

  @override
  String get settingsImportErrorIo => 'Couldn\'t read that file. Try again.';

  @override
  String get settingsImportErrorMalformed =>
      'That file isn\'t a valid CVForge backup.';

  @override
  String get settingsImportErrorNewerVersion =>
      'This backup was made by a newer version of CVForge.';

  @override
  String get settingsLanguageCardBody =>
      'The language CVForge\'s own buttons and labels are shown in. The language your CV is written in is separate, and lives in the Vault.';

  @override
  String get settingsLanguageCardTitle => 'Language';

  @override
  String get settingsLanguageFollowSystem => 'Use my browser\'s language';

  @override
  String get settingsLinkPrivacy => 'Privacy Policy';

  @override
  String get settingsLinkTerms => 'Terms of Service';

  @override
  String get skillCategoryUnnamed => 'Unnamed category';

  @override
  String get spellingEnAu => 'Australian English';

  @override
  String get spellingEnGb => 'British English';

  @override
  String get spellingEnUs => 'US English';

  @override
  String get studioAiCardBody =>
      'Paste the job ad here to select and rewrite this CV for it.';

  @override
  String get studioAiCardBodyNoKey =>
      'Bring your own API key in Settings, then paste a job ad here to select and rewrite this CV for it.';

  @override
  String get studioAiCardTitle => 'Tailor with AI';

  @override
  String get studioAiClearJobDescription => 'Clear job description';

  @override
  String studioAiCostEstimate(int cents) {
    String _temp0 = intl.Intl.pluralLogic(
      cents,
      locale: localeName,
      other: 'About $cents¢ at current rates.',
      one: 'About 1¢ at current rates.',
      zero: 'Under 1¢ at current rates.',
    );
    return '$_temp0';
  }

  @override
  String studioAiDialogLanguageNote(String language) {
    return 'Written in $language — the assistant translates your bullets if your Vault is in another language.';
  }

  @override
  String studioAiDialogPrivacy(String provider) {
    return 'This sends the job description below and your CV content — not your name, email, phone, or links — to $provider, using your own API key. There is no CVForge server in between. This can take up to a few minutes — the model reasons through your whole Vault before responding.';
  }

  @override
  String studioAiDialogRegionNote(String region) {
    return 'Tailored for $region — the assistant follows that market\'s length and tone conventions.';
  }

  @override
  String get studioAiDialogTitle => 'Tailor with AI';

  @override
  String get studioAiEditJobDescription => 'Edit job description';

  @override
  String get studioAiErrorGeneric => 'Something went wrong — try again.';

  @override
  String studioAiErrorInvalidRequest(String provider) {
    return '$provider rejected the request. That\'s a bug in CVForge, not your input.';
  }

  @override
  String get studioAiErrorMalformedResponse =>
      'Got an unexpected response — try again.';

  @override
  String studioAiErrorNetwork(String provider) {
    return 'Couldn\'t reach $provider — check your connection.';
  }

  @override
  String get studioAiErrorNoKey =>
      'Add an AI Assistant API key in Settings first.';

  @override
  String studioAiErrorOverloaded(String provider) {
    return '$provider\'s API is temporarily unavailable — try again shortly.';
  }

  @override
  String get studioAiErrorRateLimited =>
      'Your API account is rate limited — try again in a moment.';

  @override
  String get studioAiErrorRefusal =>
      'The model declined to answer — try rephrasing the job description.';

  @override
  String get studioAiErrorTimeout => 'The request timed out — try again.';

  @override
  String get studioAiErrorUnauthorized =>
      'Your API key was rejected — check it in Settings.';

  @override
  String get studioAiFailedTitle => 'Something went wrong.';

  @override
  String studioAiGapItem(String gap) {
    return '• $gap';
  }

  @override
  String get studioAiJobAdHint =>
      'Paste the job ad you\'re tailoring this CV for.';

  @override
  String get studioAiKeywordGaps => 'Not covered by your Vault';

  @override
  String get studioAiRationale => 'Rationale';

  @override
  String get studioAiRunningBody =>
      'This can take up to a few minutes. Please keep this dialog open.';

  @override
  String get studioAiRunningTitle => 'Tailoring your CV';

  @override
  String get studioAiSetUpInSettings => 'Set up in Settings';

  @override
  String get studioAiUndo => 'Undo AI changes';

  @override
  String get studioAiWarning =>
      'AI-written. Check every rewritten bullet against what you actually did.';

  @override
  String studioBackToDrafts(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Back to your CVs',
      'resume': 'Back to your résumés',
      'other': 'Back to your documents',
    });
    return '$_temp0';
  }

  @override
  String get studioBackToSections => 'Back to sections';

  @override
  String studioBulletsSelected(int selected, int total) {
    return '$selected/$total bullets';
  }

  @override
  String studioBulletsSelectedTailored(int selected, int total, int tailored) {
    return '$selected/$total bullets · $tailored tailored';
  }

  @override
  String get studioDeleteDraftBody => 'This can\'t be undone.';

  @override
  String studioDeleteDraftTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get studioDraftDuplicate => 'Duplicate';

  @override
  String get studioDraftRename => 'Rename / edit notes';

  @override
  String studioDraftsEmptyBody(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv':
          'Create a CV to start tailoring your Vault for a specific application.',
      'resume':
          'Create a résumé to start tailoring your Vault for a specific application.',
      'other':
          'Create a document to start tailoring your Vault for a specific application.',
    });
    return '$_temp0';
  }

  @override
  String studioDraftsEmptyTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'No CVs yet',
      'resume': 'No résumés yet',
      'other': 'No documents yet',
    });
    return '$_temp0';
  }

  @override
  String studioDraftsNoMatches(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'No CVs match your search.',
      'resume': 'No résumés match your search.',
      'other': 'No documents match your search.',
    });
    return '$_temp0';
  }

  @override
  String get studioDraftsPersistError => 'Your last change couldn\'t be saved.';

  @override
  String studioDraftsSearch(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Search CVs…',
      'resume': 'Search résumés…',
      'other': 'Search documents…',
    });
    return '$_temp0';
  }

  @override
  String get studioDraftTailoredMarker => 'Tailored to a job ad';

  @override
  String studioDraftUntitled(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Untitled CV',
      'resume': 'Untitled Résumé',
      'other': 'Untitled Document',
    });
    return '$_temp0';
  }

  @override
  String studioDraftUpdated(String relative) {
    return 'Updated $relative';
  }

  @override
  String studioDraftUpdatedExact(DateTime timestamp) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat(
      'dd/MM/yyyy HH:mm',
      localeName,
    );
    final String timestampString = timestampDateFormat.format(timestamp);

    return '$timestampString';
  }

  @override
  String studioEditDetailsTooltip(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Edit CV details',
      'resume': 'Edit résumé details',
      'other': 'Edit document details',
    });
    return '$_temp0';
  }

  @override
  String studioEditDraftDetailsTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Edit CV details',
      'resume': 'Edit résumé details',
      'other': 'Edit document details',
    });
    return '$_temp0';
  }

  @override
  String get studioEditDraftName => 'Name';

  @override
  String studioEditDraftNameHelper(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'Give this CV a name',
      'resume': 'Give this résumé a name',
      'other': 'Give this document a name',
    });
    return '$_temp0';
  }

  @override
  String get studioEditDraftNameHint => 'e.g. \"Acme — Backend Engineer\"';

  @override
  String get studioEditDraftNotes => 'Notes';

  @override
  String studioEditDraftNotesHelper(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'What this CV is for, or anything to remember',
      'resume': 'What this résumé is for, or anything to remember',
      'other': 'What this document is for, or anything to remember',
    });
    return '$_temp0';
  }

  @override
  String studioEditDraftTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'CV details',
      'resume': 'Résumé details',
      'other': 'Document details',
    });
    return '$_temp0';
  }

  @override
  String get studioExportErrorFonts =>
      'Couldn\'t load the fonts needed to export — check your connection and try again.';

  @override
  String get studioExportErrorGeneric =>
      'Couldn\'t export the PDF — try again.';

  @override
  String get studioExportErrorRender =>
      'Couldn\'t generate the PDF — try again, and if it keeps failing, check your CV for unusual characters or formatting.';

  @override
  String get studioExportErrorSave =>
      'Couldn\'t save the file — check your browser\'s download settings and try again.';

  @override
  String get studioExporting => 'Exporting…';

  @override
  String get studioExportPdf => 'Export PDF';

  @override
  String get studioFieldDetails => 'Details';

  @override
  String get studioFieldGrade => 'Grade';

  @override
  String get studioFieldProjectTitle => 'Project title';

  @override
  String get studioFieldQualification => 'Qualification';

  @override
  String get studioFieldRole => 'Role';

  @override
  String get studioFieldSkill => 'Skill';

  @override
  String get studioFieldSkillCategory => 'Category';

  @override
  String get studioHeadlineInclude => 'Include headline';

  @override
  String studioItemLabelledText(String label, String text) {
    return '$label: $text';
  }

  @override
  String studioLengthWarning(String region, String note) {
    return 'Longer than $region typically expects. $note Try trimming content, or a denser template.';
  }

  @override
  String studioNewDraftTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'cv': 'New CV',
      'resume': 'New résumé',
      'other': 'New document',
    });
    return '$_temp0';
  }

  @override
  String get studioNoEducationDetails => 'No details in your Vault yet.';

  @override
  String get studioNoGrade => 'No grade in your Vault yet.';

  @override
  String get studioNoHeadline => 'No headline in your Vault yet.';

  @override
  String get studioNoReferences => 'No references note in your Vault yet.';

  @override
  String get studioNoSectionSelectedBody =>
      'Choose a section on the left to edit its content.';

  @override
  String get studioNoSectionSelectedTitle => 'Nothing selected';

  @override
  String get studioNoSummary => 'No summary in your Vault yet.';

  @override
  String studioPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String studioPhotoRegionWarning(String stance, String region) {
    String _temp0 = intl.Intl.selectLogic(stance, {
      'prohibited':
          'This template prints a photo, and $region expects none — an automatic rejection. Switch template, or change region.',
      'discouraged':
          'This template prints a photo, and $region expects none — strongly discouraged. Switch template, or change region.',
      'other':
          'This template prints a photo, and $region expects none. Switch template, or change region.',
    });
    return '$_temp0';
  }

  @override
  String get studioPreviewAddAll => 'Add all';

  @override
  String get studioPreviewEmptyBody =>
      'Add something to your Vault, then come back to build a CV.';

  @override
  String get studioPreviewEmptyTitle => 'Nothing to preview yet';

  @override
  String get studioPreviewErrorBody =>
      'The Export PDF button above uses the same PDF generation and may still work — try it, or reload the page.';

  @override
  String get studioPreviewErrorContext => 'rasterizing the Studio preview';

  @override
  String get studioPreviewErrorTitle => 'Couldn\'t render the preview';

  @override
  String get studioPreviewGoToVault => 'Go to Vault';

  @override
  String studioPreviewNothingSelectedBody(int count) {
    return 'Your Vault has $count items, but none are included in this CV.';
  }

  @override
  String get studioPreviewNothingSelectedTitle => 'Nothing selected yet';

  @override
  String studioRegionDetailRow(String label) {
    return '$label: ';
  }

  @override
  String get studioRegionLocalName => 'Known locally as';

  @override
  String get studioRegionPageSize => 'Page size';

  @override
  String get studioRegionPersonalDetails => 'Personal details';

  @override
  String get studioRegionPhoto => 'Photo';

  @override
  String get studioRegionPickerBody =>
      'Conventions differ by market. This sets the page size, the expected length, and the guidance below. It does not set the language your CV is written in, and it never rewrites your career content.';

  @override
  String get studioRegionPickerDefaultBody =>
      'Sets the region every new CV starts with. Changing it never touches a CV you have already created — switch those individually from Studio.';

  @override
  String get studioRegionPickerDefaultTitle => 'Default region';

  @override
  String get studioRegionPickerSetDefault => 'Set as default';

  @override
  String get studioRegionPickerTitle => 'Choose a region';

  @override
  String get studioRegionPickerUse => 'Use this region';

  @override
  String get studioRegionSpelling => 'English spelling';

  @override
  String get studioRegionTypicalLength => 'Typical length';

  @override
  String get studioResetWording => 'Reset wording to Vault';

  @override
  String get studioResetWordingConfirm =>
      'Every line goes back to how your Vault words it, discarding your edits, any AI rewrites and any translation on this CV. Which entries are included is not affected.';

  @override
  String get studioSectionHeadline => 'Headline';

  @override
  String get studioSectionNavPersistError =>
      'Your last selection change couldn\'t be saved.';

  @override
  String get studioSectionsResetDefault => 'Reset sections to Vault';

  @override
  String get studioSectionsResetDefaultConfirm =>
      'The sections on this CV go back to the order and visibility saved in your Vault, discarding how you have arranged this one. What each line says is not affected.';

  @override
  String get studioSectionsTitle => 'Sections';

  @override
  String get studioSectionSummary => 'Summary';

  @override
  String studioSkillLinkedBullets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Linked to $count bullets in this CV',
      one: 'Linked to 1 bullet in this CV',
    );
    return '$_temp0';
  }

  @override
  String get studioSkillsFilter => 'Filter skills…';

  @override
  String get studioSkillsNoLinks =>
      'Link skills to bullets in the Vault to use this';

  @override
  String get studioSkillsNoNewEvidenced =>
      'No new evidenced skills to add — every skill linked to an included bullet is already selected';

  @override
  String studioSkillsSelectedCount(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String studioSkillsSelectEvidenced(int count) {
    return 'Select $count evidenced skills';
  }

  @override
  String get studioSkillsSelectEvidencedTooltip =>
      'Selects every skill linked to a bullet already included in this CV';

  @override
  String get studioSkillsTitle => 'Skills';

  @override
  String get studioSortLabel => 'Sort';

  @override
  String get studioSortNameAtoZ => 'Name A–Z';

  @override
  String get studioSortRecentlyUpdated => 'Recently updated';

  @override
  String get studioTabConfigure => 'Configure';

  @override
  String get studioTabPreview => 'Preview';

  @override
  String get studioTailoringEditText => 'Edit text';

  @override
  String get studioTailoringFromVault => 'From your Vault — not yet tailored';

  @override
  String get studioTailoringOnlyThisCv => 'Only affects this CV.';

  @override
  String get studioTailoringReverted =>
      'Revert to Vault — tailored for this CV';

  @override
  String get studioTemplateCurrent => 'Current';

  @override
  String get studioTemplatePickerTitle => 'Choose a template';

  @override
  String get studioTemplatePickerUse => 'Use this template';

  @override
  String get studioTranslateCardBody =>
      'Rewrite everything this CV prints into its document language, leaving your Vault in the language you wrote it.';

  @override
  String get studioTranslateCardBodyNoKey =>
      'Translating a CV uses the same AI provider as tailoring. Add a key in Settings to turn it on.';

  @override
  String studioTranslateCardStale(String translated, String current) {
    return 'Translated into $translated, but this CV is now set to $current.';
  }

  @override
  String studioTranslateCardTarget(String language) {
    return 'This CV\'s language is $language.';
  }

  @override
  String get studioTranslateCardTitle => 'Translate';

  @override
  String studioTranslateCardTranslated(String language) {
    return 'Translated into $language.';
  }

  @override
  String studioTranslateDialogLanguageNote(String language) {
    return 'Every line this CV prints will be rewritten into $language — job titles, bullet points, skills and section content. Employers, schools and publication titles are left exactly as they are.';
  }

  @override
  String get studioTranslateDialogReplaceNote =>
      'This CV already has a translation. Running again replaces it.';

  @override
  String get studioTranslateDialogTitle => 'Translate this CV';

  @override
  String get studioTranslateErrorGeneric =>
      'Couldn\'t translate this CV — try again.';

  @override
  String studioTranslateErrorInvalidRequest(String provider) {
    return '$provider rejected the request. This CV may be too long to translate in one pass.';
  }

  @override
  String get studioTranslateErrorMalformedResponse =>
      'The translation came back in a form CVForge couldn\'t read — try again.';

  @override
  String studioTranslateErrorNetwork(String provider) {
    return 'Couldn\'t reach $provider — check your connection and try again.';
  }

  @override
  String get studioTranslateErrorNoKey =>
      'No API key set up yet — add one in Settings.';

  @override
  String studioTranslateErrorOverloaded(String provider) {
    return '$provider is busy right now — try again in a moment.';
  }

  @override
  String get studioTranslateErrorRateLimited =>
      'You\'ve hit your provider\'s rate limit — wait a moment and try again.';

  @override
  String get studioTranslateErrorRefusal =>
      'The provider declined to translate this CV.';

  @override
  String get studioTranslateErrorTimeout =>
      'The translation took too long and timed out — try again.';

  @override
  String get studioTranslateErrorUnauthorized =>
      'Your API key was rejected — check it in Settings.';

  @override
  String get studioTranslateFailedTitle => 'Translation failed';

  @override
  String get studioTranslateRemove => 'Remove translation';

  @override
  String get studioTranslateRemoveConfirm =>
      'This restores every line to how it read before translating, including anything you\'ve edited since. Remove it?';

  @override
  String studioTranslateResultBody(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Translated $count of $total lines.',
      one: 'Translated 1 of $total lines.',
    );
    return '$_temp0';
  }

  @override
  String get studioTranslateRunAgain => 'Translate again';

  @override
  String get studioTranslateRunningBody =>
      'Translating every line this CV prints. This can take a few minutes.';

  @override
  String studioTranslateRunningProgress(int completed, int total) {
    return 'Section $completed of $total.';
  }

  @override
  String get studioTranslateRunningTitle => 'Translating your CV';

  @override
  String get studioTranslateTailorFirst =>
      'Tailor before translating — a tailoring pass rewrites in English and would undo this.';

  @override
  String get studioTranslateWarning =>
      'Machine-translated. Have a fluent speaker read it before you send it.';

  @override
  String get templateDescriptionClassicCentered =>
      'Centred headings and a justified summary, with whitespace in place of section rules.';

  @override
  String get templateDescriptionCompact =>
      'A plain single column, tightly set — the most content per page.';

  @override
  String get templateDescriptionPhotoHeader =>
      'A tinted header band around your Vault photo. Expected in DACH, common in southern Europe; in the US and UK a photo invites rejection.';

  @override
  String get templateNameClassicCentered => 'Traditional';

  @override
  String get templateNameCompact => 'Compact';

  @override
  String get templateNamePhotoHeader => 'Modern with photo';

  @override
  String get templateTagAcademic => 'Academic';

  @override
  String get templateTagAtsSafe => 'ATS-safe';

  @override
  String get templateTagCompact => 'Compact';

  @override
  String get templateTagModern => 'Modern';

  @override
  String get templateTagPhoto => 'Photo';

  @override
  String get templateTagTraditional => 'Traditional';

  @override
  String get templateTagTwoColumn => 'Two-column';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeSystem => 'Match device';

  @override
  String themeToggleTooltip(String current, String next) {
    return 'Theme: $current — switch to $next';
  }

  @override
  String get vaultAddBasics => 'Add your basics';

  @override
  String get vaultAddEducation => 'Add education';

  @override
  String get vaultAddExperience => 'Add experience';

  @override
  String get vaultAddProject => 'Add project';

  @override
  String get vaultAddPublication => 'Add publication';

  @override
  String get vaultBasicsDeleteLink => 'Delete link';

  @override
  String get vaultBasicsEmail => 'Email';

  @override
  String get vaultBasicsFullName => 'Full name';

  @override
  String get vaultBasicsHeadline => 'Headline';

  @override
  String get vaultBasicsHeadlineHint => 'e.g. Senior Software Engineer';

  @override
  String get vaultBasicsLinkLabel => 'Label';

  @override
  String get vaultBasicsLinkLabelHint => 'e.g. LinkedIn';

  @override
  String get vaultBasicsLinks => 'Links';

  @override
  String get vaultBasicsLinkUrl => 'URL';

  @override
  String get vaultBasicsLocation => 'Location';

  @override
  String get vaultBasicsPhone => 'Phone';

  @override
  String get vaultBasicsReferences => 'References';

  @override
  String get vaultBasicsReferencesHint => 'e.g. \"Available on request.\"';

  @override
  String get vaultBasicsSummary => 'Professional summary';

  @override
  String get vaultBasicsTitle => 'Basics';

  @override
  String get vaultBulletAddSkill => 'Add skill';

  @override
  String get vaultBulletCategory => 'Category';

  @override
  String get vaultBulletDelete => 'Delete bullet';

  @override
  String get vaultBulletLabel => 'Label (optional)';

  @override
  String get vaultBulletLabelHint => 'e.g. Performance';

  @override
  String vaultBulletLinkedSkills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Linked to $count skills',
      one: 'Linked to 1 skill',
    );
    return '$_temp0';
  }

  @override
  String get vaultBulletLinkToSkills => 'Link to skills';

  @override
  String get vaultBulletNewCategory => 'New category…';

  @override
  String get vaultBulletNewCategoryName => 'New category name';

  @override
  String get vaultBulletNoSkillMatches => 'No skills match your search.';

  @override
  String get vaultBulletNoSkillsYet => 'No skills in your Vault yet.';

  @override
  String get vaultBulletSearchSkills => 'Search or add a skill…';

  @override
  String get vaultBulletsEmpty => 'No bullets yet.';

  @override
  String vaultBulletSkillNotInVault(String query) {
    return '\"$query\" isn\'t in your Vault yet';
  }

  @override
  String get vaultBulletsTitle => 'Bullets';

  @override
  String get vaultBulletText => 'Text';

  @override
  String get vaultConfirmDeleteFallbackTitle => 'Delete this?';

  @override
  String get vaultCropPhotoBody =>
      'Drag the frame to choose what appears. The shape is fixed to the 35 × 45 mm size European CVs expect.';

  @override
  String get vaultCropPhotoConfirm => 'Use this photo';

  @override
  String get vaultCropPhotoSaving => 'Saving…';

  @override
  String get vaultCropPhotoTitle => 'Position your photo';

  @override
  String get vaultCvDefaultsCardEmpty => 'Region and language';

  @override
  String get vaultCvDefaultsChange => 'Change';

  @override
  String get vaultCvDefaultsLanguageHelp =>
      'The language your CV is written in — separate from the market above, and from the language CVForge itself is shown in, which you set in Settings.';

  @override
  String get vaultCvDefaultsLanguageLabel => 'Language';

  @override
  String get vaultCvDefaultsPanelBody =>
      'What every new CV starts out as. Changing these never rewrites a CV you have already made — switch those individually from Studio.';

  @override
  String vaultCvDefaultsPanelTitle(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'resume': 'Résumé defaults',
      'other': 'CV defaults',
    });
    return '$_temp0';
  }

  @override
  String get vaultCvDefaultsRegionHelp =>
      'Sets the page size, the expected length, and the advice the AI Assistant follows. Not the language — that is the row below.';

  @override
  String get vaultCvDefaultsRegionLabel => 'Region';

  @override
  String get vaultCvDefaultsSectionsHelp =>
      'Which sections a new CV includes, and the order they print in. Drag to reorder.';

  @override
  String get vaultCvDefaultsSectionsLabel => 'Sections';

  @override
  String get vaultCvDefaultsTemplateHelp =>
      'The design a new CV starts with — its layout, its type, and whether a photo is printed.';

  @override
  String get vaultCvDefaultsTemplateLabel => 'Template';

  @override
  String get vaultDeleteCategoryBody =>
      'This removes it and all of its skills.';

  @override
  String get vaultDeleteCategoryTitle => 'Delete this category?';

  @override
  String get vaultDeleteExperienceTitle => 'Delete this experience?';

  @override
  String get vaultDeleteProjectTitle => 'Delete this project?';

  @override
  String get vaultDeletePublicationTitle => 'Delete this publication?';

  @override
  String get vaultDeleteQualificationTitle => 'Delete this qualification?';

  @override
  String get vaultDeleteUndoneBody => 'This can\'t be undone.';

  @override
  String get vaultDeleteWithBulletsBody =>
      'This removes it and all of its bullets. This can\'t be undone.';

  @override
  String get vaultEducationDetails => 'Details (optional)';

  @override
  String get vaultEducationGrade => 'Grade (optional)';

  @override
  String get vaultEducationGradeHint => 'e.g. First Class Honours';

  @override
  String get vaultEducationInstitution => 'Institution';

  @override
  String get vaultEducationLocation => 'Location (optional)';

  @override
  String get vaultEducationNew => 'New qualification';

  @override
  String get vaultEducationQualification => 'Qualification';

  @override
  String get vaultEducationQualificationHint => 'e.g. BSc Computer Science';

  @override
  String get vaultEducationYear => 'Year (optional)';

  @override
  String get vaultEmptyBody =>
      'Add your work history, skills, and education here — this is your master record, separate from any CV you export.';

  @override
  String get vaultEmptyLoadExample => 'Load example CV';

  @override
  String get vaultEmptyStartScratch => 'Start from scratch';

  @override
  String get vaultEmptyTitle => 'Your Vault is empty';

  @override
  String get vaultExperienceCompany => 'Company';

  @override
  String get vaultExperienceCurrent => 'I currently work here';

  @override
  String get vaultExperienceEnd => 'End';

  @override
  String get vaultExperienceLocation => 'Location';

  @override
  String get vaultExperienceNew => 'New experience';

  @override
  String get vaultExperiencePromotionGroup => 'Promotion — group with';

  @override
  String get vaultExperienceRole => 'Role';

  @override
  String get vaultExperienceStart => 'Start';

  @override
  String vaultHobbiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hobbies',
      one: '1 hobby',
    );
    return '$_temp0';
  }

  @override
  String get vaultHobbiesEmptyShort => 'Nothing yet.';

  @override
  String get vaultHobbiesItems => 'Items';

  @override
  String get vaultHobbiesNoneYet => 'None yet';

  @override
  String get vaultHobbiesTitle => 'Hobbies and interests';

  @override
  String get vaultInvalidUrlNotice =>
      'That page doesn\'t exist — here\'s your Vault.';

  @override
  String get vaultMonthApr => 'Apr';

  @override
  String get vaultMonthAug => 'Aug';

  @override
  String get vaultMonthDec => 'Dec';

  @override
  String get vaultMonthFeb => 'Feb';

  @override
  String get vaultMonthJan => 'Jan';

  @override
  String get vaultMonthJul => 'Jul';

  @override
  String get vaultMonthJun => 'Jun';

  @override
  String get vaultMonthMar => 'Mar';

  @override
  String get vaultMonthMay => 'May';

  @override
  String get vaultMonthNov => 'Nov';

  @override
  String get vaultMonthOct => 'Oct';

  @override
  String get vaultMonthSep => 'Sep';

  @override
  String get vaultNoEducation => 'No education yet.';

  @override
  String get vaultNoExperience => 'No experience yet.';

  @override
  String get vaultNoProjects => 'No projects yet.';

  @override
  String get vaultNoPublications => 'No publications yet.';

  @override
  String get vaultNoSearchMatches => 'No matches for your search.';

  @override
  String get vaultNoSkillsYet => 'No skills yet';

  @override
  String get vaultPersistError => 'Your last change couldn\'t be saved.';

  @override
  String get vaultPhotoAdd => 'Add photo';

  @override
  String get vaultPhotoErrorPrepareFailed =>
      'That photo couldn\'t be prepared. Try a different image.';

  @override
  String get vaultPhotoErrorUnreadable =>
      'That file couldn\'t be read as an image. Try a JPEG or PNG.';

  @override
  String get vaultPhotoHelpInUse =>
      'Used by templates that include a photo. Others ignore it.';

  @override
  String get vaultPhotoHelpOptional =>
      'Optional. Only used by templates that include a photo — expected in DACH, best left off for the US and UK.';

  @override
  String get vaultPhotoLoading => 'Loading…';

  @override
  String get vaultPhotoRemove => 'Remove';

  @override
  String get vaultPhotoReplace => 'Replace';

  @override
  String get vaultPhotoTitle => 'Photo';

  @override
  String get vaultProjectLink => 'Link (optional)';

  @override
  String get vaultProjectLinkHint => 'e.g. github.com/you/project';

  @override
  String get vaultProjectNew => 'New project';

  @override
  String get vaultProjectTitle => 'Title';

  @override
  String get vaultPublicationCitation => 'Citation (optional)';

  @override
  String get vaultPublicationCitationHint =>
      'e.g. Trujillo, L. (2021). Journal Name, 11(2), 194–206.';

  @override
  String get vaultPublicationLink => 'Link (optional)';

  @override
  String get vaultPublicationLinkHint => 'e.g. doi.org/10.1234/example';

  @override
  String get vaultPublicationNew => 'New publication';

  @override
  String get vaultPublicationTitle => 'Title';

  @override
  String get vaultPublicationTitleHint =>
      'e.g. Community resistance in Doña Juana';

  @override
  String vaultQualificationAtInstitution(
    String qualification,
    String institution,
  ) {
    return '$qualification · $institution';
  }

  @override
  String vaultRoleAtCompany(String role, String company) {
    return '$role · $company';
  }

  @override
  String get vaultSearch => 'Search your Vault…';

  @override
  String get vaultSectionAboutYou => 'About you';

  @override
  String vaultSectionCvDefaults(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'resume': 'Résumé defaults',
      'other': 'CV defaults',
    });
    return '$_temp0';
  }

  @override
  String get vaultSectionEducation => 'Education';

  @override
  String get vaultSectionExperience => 'Work history';

  @override
  String get vaultSectionProjects => 'Projects';

  @override
  String get vaultSectionPublications => 'Publications';

  @override
  String vaultSkillLinkedBullets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Linked to $count bullets',
      one: 'Linked to 1 bullet',
    );
    return '$_temp0';
  }

  @override
  String get vaultSkillLinkToBullets => 'Link to bullets';

  @override
  String get vaultSkillNoBulletMatches => 'No bullets match your search.';

  @override
  String get vaultSkillsAddCategory => 'Add category';

  @override
  String get vaultSkillsAddSkill => 'Add skill';

  @override
  String get vaultSkillsCategories => 'Categories';

  @override
  String get vaultSkillsCategoryName => 'Category name';

  @override
  String get vaultSkillsCategoryNameHint => 'e.g. Languages & Frameworks';

  @override
  String get vaultSkillsDeleteCategory => 'Delete category';

  @override
  String get vaultSkillsDeleteSkill => 'Delete skill';

  @override
  String get vaultSkillSearchBullets => 'Search bullets…';

  @override
  String get vaultSkillsNoCategories => 'No skill categories yet.';

  @override
  String get vaultSkillsNoMatches => 'No skills match your search.';

  @override
  String get vaultSkillsSearch => 'Search skills…';

  @override
  String get vaultSkillsSkillLabel => 'Skill';

  @override
  String vaultSkillsSummary(int categories, int skills) {
    return '$categories categories, $skills skills';
  }

  @override
  String get vaultSkillsTitle => 'Skills';

  @override
  String get vaultUntitledProject => 'Untitled project';

  @override
  String get vaultUntitledPublication => 'Untitled publication';

  @override
  String get vaultUntitledQualification => 'Untitled qualification';

  @override
  String get vaultUntitledRole => 'Untitled role';

  @override
  String get vaultYearMonthClear => 'Clear';

  @override
  String get vaultYearMonthEmpty => 'Pick a date';

  @override
  String get vaultYearMonthNextYear => 'Next year';

  @override
  String get vaultYearMonthNextYears => 'Later years';

  @override
  String get vaultYearMonthPickYear => 'Choose a year';

  @override
  String get vaultYearMonthPreviousYear => 'Previous year';

  @override
  String get vaultYearMonthPreviousYears => 'Earlier years';
}
