import 'region_profile.dart';

export 'region_profile.dart';

/// Every region's conventions, keyed by [RegionProfile].
///
/// Persistence keys on [RegionProfile]'s own enum name, not on anything
/// here — so every value below can change between app versions without
/// invalidating a stored draft. The enum *names* (`uk`, `us`, …) are the
/// contract and must never be renamed; display names, page sizes, and
/// guidance text are free to move.
///
/// Kept in its own file, apart from the type declarations, because this is
/// the half that grows: eight regions of English prose on a different edit
/// cadence from the types they fill in. It also lets `cv_draft.dart`,
/// `cv_preferences.dart`, and the services — which name only the enum —
/// import `region_profile.dart` alone rather than transitively pulling all
/// of this guidance text into the model layer.
const Map<RegionProfile, RegionPreset> regionPresets = {
  RegionProfile.uk: RegionPreset(
    displayName: 'UK & Ireland',
    coverage: 'United Kingdom, Ireland',
    flags: ['🇬🇧', '🇮🇪'],
    page: PdfPageFormatToken.a4,
    documentNoun: RegionDocumentNoun.cv,
    localName: 'CV',
    dateStyle: RegionDateStyle.monYyyy,
    typicalMaxPages: 2,
    lengthNote:
        'Two pages is the standard. One page is fine for a recent '
        'graduate.',
    photo: RegionPhotoStance.discouraged,
    personalDetails: RegionPersonalDetailsStance.omit,
    spelling: RegionSpelling.enGb,
    toneNote:
        'Understated and factual. State achievements plainly with the '
        'evidence behind them; overt self-promotion reads as boastful.',
    conventions: [
      'Two pages is the norm. One page for a recent graduate; three only '
          'for academic or very senior roles.',
      'No photograph, date of birth, marital status, or nationality. UK '
          'equality law makes them a liability for the employer as much as '
          'for you.',
      'If writing in English, use British spelling throughout: organised, '
          'programme, centre, analyse.',
      '"References available on request" at the foot is still expected. Do '
          "not list referees' contact details.",
      'Open with a short personal statement or profile.',
      'Ireland follows the same conventions. State your work authorisation '
          'if you are not an EU or UK citizen.',
    ],
  ),

  RegionProfile.us: RegionPreset(
    displayName: 'US & Canada',
    coverage: 'United States, Canada',
    flags: ['🇺🇸', '🇨🇦'],
    page: PdfPageFormatToken.letter,
    documentNoun: RegionDocumentNoun.resume,
    localName: 'résumé',
    dateStyle: RegionDateStyle.monYyyy,
    typicalMaxPages: 2,
    lengthNote:
        "One page under about ten years' experience; two pages beyond that.",
    photo: RegionPhotoStance.prohibited,
    personalDetails: RegionPersonalDetailsStance.omit,
    spelling: RegionSpelling.enUs,
    toneNote:
        'Quantified and outcome-led. Lead each bullet with the result and a '
        'number — revenue, percentage, headcount, time saved.',
    conventions: [
      'One page until roughly ten years of experience, two beyond that. '
          'Three pages means an academic CV, which is a different document.',
      'Never include a photograph, date of birth, marital status, or '
          'gender. US employers routinely discard résumés carrying them to '
          'avoid discrimination claims.',
      'Single column. No tables, text boxes, headers, or footers — US '
          'applicant tracking systems are the strictest anywhere and '
          'mis-parse everything else.',
      'If writing in English, use US spelling: organized, program, '
          'center, analyze.',
      'Quantify everything you can. An unquantified bullet reads as a job '
          'description rather than an achievement.',
      'Do not add a references line; it is assumed.',
      'Canada follows the same conventions. Quebec roles may expect a '
          'French-language version alongside.',
    ],
  ),

  RegionProfile.anz: RegionPreset(
    displayName: 'Australia & New Zealand',
    coverage: 'Australia, New Zealand',
    flags: ['🇦🇺', '🇳🇿'],
    page: PdfPageFormatToken.a4,
    documentNoun: RegionDocumentNoun.resume,
    localName: 'resume (also "CV")',
    dateStyle: RegionDateStyle.monYyyy,
    typicalMaxPages: 3,
    lengthNote:
        'Two to three pages mid-career; three to five for executive roles.',
    photo: RegionPhotoStance.discouraged,
    personalDetails: RegionPersonalDetailsStance.omit,
    spelling: RegionSpelling.enAu,
    toneNote:
        'Context-rich and concrete. Explain what the organisation does, the '
        'size of your remit, then the outcome — Australasian readers expect '
        'more surrounding detail than a US résumé gives.',
    conventions: [
      'Two to three pages is normal and expected. A one-page resume reads '
          'as thin here.',
      'No photograph, date of birth, or marital status.',
      'State your work rights in the header — "Australian citizen", "NZ '
          'permanent resident", "482 visa". Recruiters filter on this first.',
      'Include a dedicated "Referees" section with two named referees, or '
          'state that details are available on request.',
      'Australian spelling: organised, centre, analyse. Be consistent — '
          'some sectors accept -ize, but mixing the two is what gets '
          'noticed.',
      'Give more context per role than a US résumé would: company scope, '
          'reporting lines, team size, budget.',
    ],
  ),

  RegionProfile.dach: RegionPreset(
    displayName: 'DACH',
    coverage: 'Germany, Austria, Switzerland',
    flags: ['🇩🇪', '🇦🇹', '🇨🇭'],
    page: PdfPageFormatToken.a4,
    documentNoun: RegionDocumentNoun.cv,
    localName: 'Lebenslauf',
    dateStyle: RegionDateStyle.monYyyy,
    typicalMaxPages: 3,
    lengthNote: 'Two to three pages, tabular and complete.',
    photo: RegionPhotoStance.expected,
    personalDetails: RegionPersonalDetailsStance.traditional,
    spelling: RegionSpelling.enGb,
    toneNote:
        'Formal, factual, complete. Understatement over salesmanship, '
        'verifiable facts over adjectives.',
    conventions: [
      'Around two thirds of German-speaking employers still expect a '
          'professional headshot, top right. Upload one in the Vault and '
          'choose a template that includes one; the rest leave it off.',
      'Date and place of birth, nationality, and sometimes marital status '
          'are traditional in the personal-details block, and CVForge has '
          'no field for any of them. Younger and international employers '
          'increasingly omit them: omitting is safe, including is '
          'conventional.',
      'The chronology must be gap-free and month-precise. An unexplained '
          'gap reads as concealment; label it plainly ("Parental leave", '
          '"Further education").',
      'Education stays prominent throughout your career, with the '
          'institution named and grades given.',
      'Certificates (Zeugnisse) are attached as a separate document; the '
          'Lebenslauf references them rather than reproducing them.',
      'If writing in English, use British spelling.',
    ],
  ),

  RegionProfile.nordics: RegionPreset(
    displayName: 'Nordics',
    coverage: 'Sweden, Norway, Denmark, Finland',
    flags: ['🇸🇪', '🇳🇴', '🇩🇰', '🇫🇮'],
    page: PdfPageFormatToken.a4,
    documentNoun: RegionDocumentNoun.cv,
    localName: 'CV',
    dateStyle: RegionDateStyle.monYyyy,
    typicalMaxPages: 2,
    lengthNote: 'One to two pages. Concision is read as a virtue here.',
    photo: RegionPhotoStance.optional,
    personalDetails: RegionPersonalDetailsStance.minimal,
    spelling: RegionSpelling.enGb,
    toneNote:
        'Factual and team-framed. Say what the team achieved and what your '
        'part in it was; "I single-handedly" reads badly across the Nordics.',
    conventions: [
      'One to two pages. A long CV reads as poor editing.',
      'A photograph is neither expected nor unwelcome. Include one only if '
          'it is genuinely professional.',
      'Keep personal data minimal: name, contact, city. No date of birth, '
          'marital status, or national ID number.',
      'Frame achievements around the team and the outcome rather than '
          'personal heroics.',
      'State Scandinavian language proficiency explicitly with a level '
          '("Swedish — B2"). It moves the needle.',
      'English CVs are widely accepted; use British spelling.',
    ],
  ),

  RegionProfile.europe: RegionPreset(
    displayName: 'Europe — international',
    coverage: 'France, Benelux, Southern Europe, and multinationals',
    flags: ['🇪🇺'],
    page: PdfPageFormatToken.a4,
    documentNoun: RegionDocumentNoun.cv,
    localName: 'CV / Curriculum Vitae',
    dateStyle: RegionDateStyle.monYyyy,
    typicalMaxPages: 2,
    lengthNote:
        'One to two pages. France prefers one; Southern Europe tolerates '
        'more.',
    photo: RegionPhotoStance.optional,
    personalDetails: RegionPersonalDetailsStance.minimal,
    spelling: RegionSpelling.enGb,
    toneNote:
        'Professional and measured. Concrete results, without the hard-sell '
        'register of a US résumé.',
    conventions: [
      'One to two pages. France in particular expects a single page for '
          "anything under about fifteen years' experience.",
      'A photograph is common in France, Spain, Italy, and Portugal, and '
          'unusual elsewhere. For an international or multinational '
          'application, leave it off.',
      'Keep personal data minimal for a multinational. A domestic French or '
          'Southern European employer may still expect date of birth and '
          'nationality.',
      'List language proficiencies with CEFR levels (A1–C2). European '
          'recruiters read these precisely.',
      'Southern European employers tolerate longer CVs — four or five pages '
          'is seen — but a tighter document still reads better.',
      'If writing in English, use British spelling. A local-language '
          'version is worth producing for a domestic application.',
    ],
  ),

  // Latin America splits on paper size, not on conventions: Mexico,
  // Colombia, Chile, and Central America use US Letter; Brazil, Argentina,
  // Uruguay, and Peru use A4. Page size is derived from region with no
  // separate override, so one preset cannot serve both — hence two, named
  // for the axis they actually differ on rather than for geography, which
  // stays true even if country membership shifts.
  RegionProfile.latamLetter: RegionPreset(
    displayName: 'Mexico, Colombia & Chile',
    coverage: 'Mexico, Colombia, Chile, Central America',
    flags: ['🇲🇽', '🇨🇴', '🇨🇱'],
    page: PdfPageFormatToken.letter,
    documentNoun: RegionDocumentNoun.cv,
    localName: 'Hoja de Vida / Currículum Vitae',
    dateStyle: RegionDateStyle.monYyyy,
    typicalMaxPages: 3,
    lengthNote: 'Two to three pages.',
    photo: RegionPhotoStance.optional,
    personalDetails: RegionPersonalDetailsStance.traditional,
    spelling: RegionSpelling.enUs,
    toneNote:
        'Formal and credential-forward. Qualifications, institutions, and '
        'certifications carry real weight — state them fully.',
    conventions: [
      'US Letter is standard across Mexico, Colombia, Chile, and Central '
          'America. For Brazil, Argentina, Uruguay, or Peru, pick "Brazil & '
          'Southern Cone" instead — those markets use A4.',
      'The document is a "Hoja de Vida" in Colombia and the Andean '
          'countries, and a "Currículum Vitae" in Mexico and Central '
          'America.',
      'A photograph, date of birth, marital status, and national ID number '
          '(CURP/RFC, Cédula) are common at domestic firms, and deliberately '
          'excluded by multinationals and their local subsidiaries. Match '
          'the employer, not the country. CVForge has no field for any of '
          'them.',
      'Two to three pages is normal.',
      'Certified language proficiency carries real weight: state TOEFL, '
          'IELTS, or DELE scores with the date taken.',
      'Name the institution for every qualification; university reputation '
          'is read closely.',
      'If writing in English, US spelling is the regional norm.',
    ],
  ),

  RegionProfile.latamA4: RegionPreset(
    displayName: 'Brazil & Southern Cone',
    coverage: 'Brazil, Argentina, Uruguay, Peru',
    flags: ['🇧🇷', '🇦🇷', '🇺🇾', '🇵🇪'],
    page: PdfPageFormatToken.a4,
    documentNoun: RegionDocumentNoun.cv,
    localName: 'Currículo / Curriculum Vitae',
    dateStyle: RegionDateStyle.monYyyy,
    typicalMaxPages: 3,
    lengthNote: 'Two to three pages.',
    photo: RegionPhotoStance.optional,
    personalDetails: RegionPersonalDetailsStance.traditional,
    spelling: RegionSpelling.enUs,
    toneNote:
        'Formal and credential-forward. Qualifications, institutions, and '
        'certifications carry real weight — state them fully.',
    conventions: [
      'A4 is standard across Brazil, Argentina, Uruguay, and Peru. For '
          'Mexico, Colombia, Chile, or Central America, pick "Mexico, '
          'Colombia & Chile" instead — those markets use US Letter.',
      'The document is a "Currículo" in Brazil and a "Curriculum Vitae" '
          'across the Southern Cone.',
      'A photograph, date of birth, marital status, and national ID number '
          '(CPF, DNI/CUIL) are common at domestic firms, and deliberately '
          'excluded by multinationals and their local subsidiaries. Match '
          'the employer, not the country. CVForge has no field for any of '
          'them.',
      'Two to three pages is normal.',
      'Certified language proficiency is a primary screening filter, '
          'especially in Brazil: state TOEFL, IELTS, DELE, or CELPE-Bras '
          'scores with the date taken.',
      'Name the institution for every qualification; university reputation '
          'is read closely.',
      'If writing in English, US spelling is the regional norm.',
    ],
  ),
};

extension RegionProfileX on RegionProfile {
  RegionPreset get preset => regionPresets[this]!;
}
