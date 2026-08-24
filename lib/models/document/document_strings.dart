import 'document_language.dart';

export 'document_language.dart';

/// What every shipped document language calls each section of a CV, keyed
/// by [DocumentLanguage].
///
/// Kept apart from the type declarations for the same reason
/// `region_presets.dart` is: this is the half that grows, and it lets
/// `cv_draft.dart`, `document_defaults.dart` and `year_month.dart` — which
/// name only the enum — import `document_language.dart` alone rather than
/// transitively pulling seventeen languages of copy into everything.
///
/// The month abbreviations were transcribed from CLDR via `package:intl`
/// rather than written by hand; see [DocumentStrings.cldrTag] for why they
/// are checked in rather than read at render time, and for the test that
/// keeps them honest.
///
/// **Translation status: English is the original; every other language
/// here is unreviewed.** They are a careful first pass against each
/// market's conventional CV vocabulary, and should be treated as
/// provisional until a speaker has read them — a wrong section heading on
/// someone's CV is a good deal more damaging than a wrong label in the
/// app's own chrome, because the reader is a hiring manager rather than
/// the person who chose the setting. Prefer getting these reviewed over
/// adding an eighteenth language.
const Map<DocumentLanguage, DocumentStrings> documentStrings = {
  /// UK, Ireland, New Zealand, South Africa, Singapore, India.
  DocumentLanguage.enGb: DocumentStrings(
    cldrTag: 'en_GB',
    promptName: 'British English',
    summary: 'Professional summary',
    experience: 'Experience',
    projects: 'Projects',
    skills: 'Skills',
    education: 'Education',
    hobbies: 'Hobbies and interests',
    references: 'References',
    publications: 'Publications',
    present: 'Present',
    months: [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec',
    ],
  ),

  /// United States, Canada.
  DocumentLanguage.enUs: DocumentStrings(
    cldrTag: 'en',
    promptName: 'American English',
    summary: 'Professional summary',
    experience: 'Experience',
    projects: 'Projects',
    skills: 'Skills',
    education: 'Education',
    hobbies: 'Hobbies and interests',
    references: 'References',
    publications: 'Publications',
    present: 'Present',
    months: [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ],
  ),

  /// Australia.
  DocumentLanguage.enAu: DocumentStrings(
    cldrTag: 'en_AU',
    promptName: 'Australian English',
    summary: 'Professional summary',
    experience: 'Experience',
    projects: 'Projects',
    skills: 'Skills',
    education: 'Education',
    hobbies: 'Hobbies and interests',
    references: 'References',
    publications: 'Publications',
    present: 'Present',
    months: [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'June',
      'July',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec',
    ],
  ),

  /// Germany, Switzerland.
  DocumentLanguage.de: DocumentStrings(
    cldrTag: 'de',
    promptName: 'German',
    summary: 'Kurzprofil',
    experience: 'Berufserfahrung',
    projects: 'Projekte',
    skills: 'Kenntnisse',
    education: 'Ausbildung',
    hobbies: 'Hobbys und Interessen',
    references: 'Referenzen',
    publications: 'Veröffentlichungen',
    present: 'Heute',
    months: [
      'Jan.',
      'Feb.',
      'März',
      'Apr.',
      'Mai',
      'Juni',
      'Juli',
      'Aug.',
      'Sept.',
      'Okt.',
      'Nov.',
      'Dez.',
    ],
  ),

  /// Austria. Section titles match Germany; the months do not.
  DocumentLanguage.deAt: DocumentStrings(
    cldrTag: 'de_AT',
    promptName: 'Austrian German',
    summary: 'Kurzprofil',
    experience: 'Berufserfahrung',
    projects: 'Projekte',
    skills: 'Kenntnisse',
    education: 'Ausbildung',
    hobbies: 'Hobbys und Interessen',
    references: 'Referenzen',
    publications: 'Veröffentlichungen',
    present: 'Heute',
    months: [
      'Jän.',
      'Feb.',
      'März',
      'Apr.',
      'Mai',
      'Juni',
      'Juli',
      'Aug.',
      'Sep.',
      'Okt.',
      'Nov.',
      'Dez.',
    ],
  ),

  /// France, Belgium, Switzerland.
  DocumentLanguage.fr: DocumentStrings(
    cldrTag: 'fr',
    promptName: 'French',
    summary: 'Profil professionnel',
    experience: 'Expérience professionnelle',
    projects: 'Projets',
    skills: 'Compétences',
    education: 'Formation',
    hobbies: "Loisirs et centres d'intérêt",
    references: 'Références',
    publications: 'Publications',
    present: "Aujourd'hui",
    months: [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ],
  ),

  /// Canada. Section titles match France; the months do not.
  DocumentLanguage.frCa: DocumentStrings(
    cldrTag: 'fr_CA',
    promptName: 'Canadian French',
    summary: 'Profil professionnel',
    experience: 'Expérience professionnelle',
    projects: 'Projets',
    skills: 'Compétences',
    education: 'Formation',
    hobbies: "Loisirs et centres d'intérêt",
    references: 'Références',
    publications: 'Publications',
    present: "Aujourd'hui",
    months: [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juill.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ],
  ),

  /// Netherlands, Belgium.
  DocumentLanguage.nl: DocumentStrings(
    cldrTag: 'nl',
    promptName: 'Dutch',
    summary: 'Profiel',
    experience: 'Werkervaring',
    projects: 'Projecten',
    skills: 'Vaardigheden',
    education: 'Opleiding',
    hobbies: "Hobby's en interesses",
    references: 'Referenties',
    publications: 'Publicaties',
    present: 'Heden',
    months: [
      'jan',
      'feb',
      'mrt',
      'apr',
      'mei',
      'jun',
      'jul',
      'aug',
      'sep',
      'okt',
      'nov',
      'dec',
    ],
  ),

  /// Italy, Switzerland.
  DocumentLanguage.it: DocumentStrings(
    cldrTag: 'it',
    promptName: 'Italian',
    summary: 'Profilo professionale',
    experience: 'Esperienza professionale',
    projects: 'Progetti',
    skills: 'Competenze',
    education: 'Istruzione',
    hobbies: 'Hobby e interessi',
    references: 'Referenze',
    publications: 'Pubblicazioni',
    present: 'Presente',
    months: [
      'gen',
      'feb',
      'mar',
      'apr',
      'mag',
      'giu',
      'lug',
      'ago',
      'set',
      'ott',
      'nov',
      'dic',
    ],
  ),

  /// Spain.
  DocumentLanguage.es: DocumentStrings(
    cldrTag: 'es',
    promptName: 'European Spanish',
    summary: 'Perfil profesional',
    experience: 'Experiencia profesional',
    projects: 'Proyectos',
    skills: 'Competencias',
    education: 'Formación académica',
    hobbies: 'Aficiones e intereses',
    references: 'Referencias',
    publications: 'Publicaciones',
    present: 'Actualidad',
    months: [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sept',
      'oct',
      'nov',
      'dic',
    ],
  ),

  /// Latin America. Differs from Spain in three titles: Habilidades over
  /// Competencias, Educación over Formación académica, and Pasatiempos over
  /// Aficiones.
  DocumentLanguage.es419: DocumentStrings(
    cldrTag: 'es_419',
    promptName: 'Latin American Spanish',
    summary: 'Perfil profesional',
    experience: 'Experiencia profesional',
    projects: 'Proyectos',
    skills: 'Habilidades',
    education: 'Educación',
    hobbies: 'Pasatiempos e intereses',
    references: 'Referencias',
    publications: 'Publicaciones',
    present: 'Actualidad',
    months: [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sept',
      'oct',
      'nov',
      'dic',
    ],
  ),

  /// Portugal. Note académica, against Brazil's acadêmica.
  DocumentLanguage.ptPt: DocumentStrings(
    cldrTag: 'pt_PT',
    promptName: 'European Portuguese',
    summary: 'Perfil profissional',
    experience: 'Experiência profissional',
    projects: 'Projetos',
    skills: 'Competências',
    education: 'Formação académica',
    hobbies: 'Passatempos e interesses',
    references: 'Referências',
    publications: 'Publicações',
    present: 'Atualidade',
    months: [
      'jan.',
      'fev.',
      'mar.',
      'abr.',
      'mai.',
      'jun.',
      'jul.',
      'ago.',
      'set.',
      'out.',
      'nov.',
      'dez.',
    ],
  ),

  /// Brazil. Shares its months with Portugal; the titles differ.
  DocumentLanguage.ptBr: DocumentStrings(
    cldrTag: 'pt_BR',
    promptName: 'Brazilian Portuguese',
    summary: 'Perfil profissional',
    experience: 'Experiência profissional',
    projects: 'Projetos',
    skills: 'Competências',
    education: 'Formação acadêmica',
    hobbies: 'Hobbies e interesses',
    references: 'Referências',
    publications: 'Publicações',
    present: 'Atualmente',
    months: [
      'jan.',
      'fev.',
      'mar.',
      'abr.',
      'mai.',
      'jun.',
      'jul.',
      'ago.',
      'set.',
      'out.',
      'nov.',
      'dez.',
    ],
  ),

  /// Sweden.
  DocumentLanguage.sv: DocumentStrings(
    cldrTag: 'sv',
    promptName: 'Swedish',
    summary: 'Profil',
    experience: 'Arbetslivserfarenhet',
    projects: 'Projekt',
    skills: 'Färdigheter',
    education: 'Utbildning',
    hobbies: 'Intressen',
    references: 'Referenser',
    publications: 'Publikationer',
    present: 'Nuvarande',
    months: [
      'jan.',
      'feb.',
      'mars',
      'apr.',
      'maj',
      'juni',
      'juli',
      'aug.',
      'sep.',
      'okt.',
      'nov.',
      'dec.',
    ],
  ),

  /// Norway.
  DocumentLanguage.nb: DocumentStrings(
    cldrTag: 'nb',
    promptName: 'Norwegian Bokmål',
    summary: 'Profil',
    experience: 'Arbeidserfaring',
    projects: 'Prosjekter',
    skills: 'Ferdigheter',
    education: 'Utdanning',
    hobbies: 'Interesser',
    references: 'Referanser',
    publications: 'Publikasjoner',
    present: 'Nåværende',
    months: [
      'jan.',
      'feb.',
      'mars',
      'apr.',
      'mai',
      'juni',
      'juli',
      'aug.',
      'sep.',
      'okt.',
      'nov.',
      'des.',
    ],
  ),

  /// Denmark.
  DocumentLanguage.da: DocumentStrings(
    cldrTag: 'da',
    promptName: 'Danish',
    summary: 'Profil',
    experience: 'Erhvervserfaring',
    projects: 'Projekter',
    skills: 'Kompetencer',
    education: 'Uddannelse',
    hobbies: 'Interesser',
    references: 'Referencer',
    publications: 'Publikationer',
    present: 'Nuværende',
    months: [
      'jan.',
      'feb.',
      'mar.',
      'apr.',
      'maj',
      'jun.',
      'jul.',
      'aug.',
      'sep.',
      'okt.',
      'nov.',
      'dec.',
    ],
  ),

  /// Finland.
  DocumentLanguage.fi: DocumentStrings(
    cldrTag: 'fi',
    promptName: 'Finnish',
    summary: 'Profiili',
    experience: 'Työkokemus',
    projects: 'Projektit',
    skills: 'Osaaminen',
    education: 'Koulutus',
    hobbies: 'Harrastukset',
    references: 'Suosittelijat',
    publications: 'Julkaisut',
    present: 'Nykyinen',
    months: [
      'tammi',
      'helmi',
      'maalis',
      'huhti',
      'touko',
      'kesä',
      'heinä',
      'elo',
      'syys',
      'loka',
      'marras',
      'joulu',
    ],
  ),
};

extension DocumentLanguageX on DocumentLanguage {
  DocumentStrings get strings => documentStrings[this]!;

  /// Whether a CV in this language is written in English.
  ///
  /// Read by the AI Assistant's prompt, which describes a region's
  /// expected *English* spelling convention (`RegionSpelling` has three
  /// cases and all three are English). Telling a model to write German and
  /// to use British spelling in the same breath is incoherent, so the
  /// spelling line is omitted when this is false.
  ///
  /// Derived from [DocumentStrings.cldrTag] rather than listed out, so
  /// adding another English locale cannot silently miss it.
  bool get isEnglish =>
      strings.cldrTag == 'en' || strings.cldrTag.startsWith('en_');
}
