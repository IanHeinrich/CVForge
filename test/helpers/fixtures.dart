import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/draft/draft_omittable_field.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/language_item.dart';
import 'package:cv_forge/models/vault/language_proficiency.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:mockito/mockito.dart';

import 'test_helpers.mocks.dart';

/// Shared Vault/Draft test fixtures — previously copy-pasted, in whole or
/// in part, across `studio_viewmodel_{selection,lifecycle,overrides,
/// ai_assistant}_test.dart` and `drafts_list_viewmodel_test.dart`. Both
/// builders below are supersets of every field any of those five copies
/// used, so a test file only ever needs the subset it actually cares
/// about; the rest fall back to a harmless empty/default value.

/// A [CvVault] with only the collections a test cares about populated.
CvVault vaultWith({
  List<Experience> experiences = const [],
  List<Education> education = const [],
  List<Project> projects = const [],
  List<Publication> publications = const [],
  List<SkillCategory> skillCategories = const [],
  List<HobbyItem> hobbies = const [],
  List<LanguageItem> languages = const [],
  ContactBasics? basics,
  String? referencesNote,
}) => CvVault(
  schemaVersion: 1,
  basics: basics ?? ContactBasics.empty(),
  experiences: experiences,
  education: education,
  projects: projects,
  publications: publications,
  skillCategories: skillCategories,
  hobbies: hobbies,
  languages: languages,
  referencesNote: referencesNote,
  updatedAt: DateTime.now(),
);

/// A [CvDraft] with only the fields a test cares about set. `id` defaults
/// to `'current'` (the shape every `StudioViewModel` test wants — a
/// single active draft) and `updatedAt` to now; pass either explicitly
/// for a `DraftsListViewModel` test that cares about identity or
/// recency-sort order across several drafts.
CvDraft draftWith({
  String id = 'current',
  String name = 'My CV',
  String notes = '',
  String templateId = 'compact',
  RegionProfile region = RegionProfile.uk,
  DocumentLanguage documentLanguage = DocumentLanguage.enGb,
  List<String> experienceIds = const [],
  Map<String, List<String>> bulletIds = const {},
  List<String> projectIds = const [],
  Map<String, List<String>> projectBulletIds = const {},
  List<String> skillIds = const [],
  List<String> educationIds = const [],
  Map<String, List<String>> educationBulletIds = const {},
  List<String> hobbyIds = const [],
  List<String> languageIds = const [],
  List<String> publicationIds = const [],
  Map<String, List<String>> publicationBulletIds = const {},
  Map<DraftOmittableField, List<String>> omittedFields = const {},
  Set<CvSectionType> hiddenSections = const {},
  List<CvSectionType>? sectionOrder,
  Map<String, String> bulletOverrides = const {},
  String? tailoredSummary,
  String? headlineOverride,
  String? referencesOverride,
  Map<String, String> educationDetailsOverrides = const {},
  Map<String, String> roleOverrides = const {},
  Map<String, String> projectTitleOverrides = const {},
  Map<String, String> skillLabelOverrides = const {},
  Map<String, String> skillCategoryNameOverrides = const {},
  Map<String, String> hobbyOverrides = const {},
  Map<String, String> languageOverrides = const {},
  Map<String, String> educationQualificationOverrides = const {},
  Map<String, String> educationGradeOverrides = const {},
  Map<String, String> publicationTitleOverrides = const {},
  Map<String, String> publicationCitationOverrides = const {},
  Map<String, String> experienceLocationOverrides = const {},
  Map<String, String> educationLocationOverrides = const {},
  bool hideHeadline = false,
  DocumentLanguage? translatedTo,
  String? targetJobDescription,
  DateTime? updatedAt,
}) => CvDraft(
  schemaVersion: 1,
  id: id,
  name: name,
  notes: notes,
  templateId: templateId,
  region: region,
  documentLanguage: documentLanguage,
  experienceIds: experienceIds,
  bulletIds: bulletIds,
  projectIds: projectIds,
  projectBulletIds: projectBulletIds,
  skillIds: skillIds,
  educationIds: educationIds,
  educationBulletIds: educationBulletIds,
  hobbyIds: hobbyIds,
  languageIds: languageIds,
  publicationIds: publicationIds,
  publicationBulletIds: publicationBulletIds,
  omittedFields: omittedFields,
  hiddenSections: hiddenSections,
  bulletOverrides: bulletOverrides,
  tailoredSummary: tailoredSummary,
  headlineOverride: headlineOverride,
  referencesOverride: referencesOverride,
  educationDetailsOverrides: educationDetailsOverrides,
  roleOverrides: roleOverrides,
  projectTitleOverrides: projectTitleOverrides,
  skillLabelOverrides: skillLabelOverrides,
  skillCategoryNameOverrides: skillCategoryNameOverrides,
  hobbyOverrides: hobbyOverrides,
  languageOverrides: languageOverrides,
  educationQualificationOverrides: educationQualificationOverrides,
  educationGradeOverrides: educationGradeOverrides,
  publicationTitleOverrides: publicationTitleOverrides,
  publicationCitationOverrides: publicationCitationOverrides,
  experienceLocationOverrides: experienceLocationOverrides,
  educationLocationOverrides: educationLocationOverrides,
  hideHeadline: hideHeadline,
  translatedTo: translatedTo,
  targetJobDescription: targetJobDescription,
  sectionOrder: sectionOrder ?? CvSectionType.values,
  updatedAt: updatedAt ?? DateTime.now(),
);

/// One experience with two bullets — the same `exp-1`/`b1`/`b2` shape
/// every Studio selection/override test built by hand.
const sampleExperience = Experience(
  id: 'exp-1',
  role: 'Engineer',
  company: 'Acme',
  location: 'London',
  start: YearMonth(year: 2020, month: 1),
  isCurrent: true,
  bullets: [
    CvBullet(id: 'b1', text: 'Did a thing'),
    CvBullet(id: 'b2', text: 'Did another thing'),
  ],
);

const sampleEducation = Education(
  id: 'edu-1',
  qualification: 'BSc Computing',
  institution: 'Leeds',
);

const sampleProject = Project(
  id: 'proj-1',
  title: 'CV Forge',
  bullets: [
    CvBullet(id: 'pb1', text: 'Built a thing'),
    CvBullet(id: 'pb2', text: 'Built another thing'),
  ],
);

const samplePublication = Publication(
  id: 'pub-1',
  title: 'A Study of Things',
  bullets: [
    CvBullet(id: 'ub1', text: 'Cited by 40+ subsequent papers'),
    CvBullet(id: 'ub2', text: 'Led the fieldwork component'),
  ],
);

const sampleSkillCategory = SkillCategory(
  id: 'cat-1',
  name: 'Languages',
  skills: [Skill(id: 'skill-1', label: 'Dart')],
);

const sampleHobby = HobbyItem(id: 'hobby-1', text: 'Climbing');

const sampleLanguage = LanguageItem(
  id: 'lang-1',
  name: 'German',
  proficiency: LanguageProficiency.b2,
);

/// Backs a [MockLocalStorageService] with a plain in-memory map instead of
/// per-test `when(storage.read(...)).thenAnswer(...)` boilerplate —
/// `VaultServiceTest`/`DraftServiceTest` restubbed "read -> null, write ->
/// succeeds" in nearly every test before this existed. Returns the
/// backing map, keyed `'$box/$key'`, so a test can still seed or inspect
/// a specific entry directly (e.g. to pre-load a corrupt payload before
/// calling `service.load()`).
Map<String, String> stubInMemoryStorage(MockLocalStorageService storage) {
  final data = <String, String>{};
  String key(String box, String storageKey) => '$box/$storageKey';

  when(storage.ensureInitialized()).thenAnswer((_) => Future<void>.value());
  when(storage.read(any, any)).thenAnswer((invocation) async {
    final box = invocation.positionalArguments[0] as String;
    final storageKey = invocation.positionalArguments[1] as String;
    return data[key(box, storageKey)];
  });
  when(storage.write(any, any, any)).thenAnswer((invocation) async {
    final box = invocation.positionalArguments[0] as String;
    final storageKey = invocation.positionalArguments[1] as String;
    final value = invocation.positionalArguments[2] as String;
    data[key(box, storageKey)] = value;
  });
  when(storage.delete(any, any)).thenAnswer((invocation) async {
    final box = invocation.positionalArguments[0] as String;
    final storageKey = invocation.positionalArguments[1] as String;
    data.remove(key(box, storageKey));
  });
  return data;
}
