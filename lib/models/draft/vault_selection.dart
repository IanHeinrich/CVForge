import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

/// Every id in a [CvVault], in Vault order — the "everything selected"
/// projection a CV starts from before the user narrows it.
///
/// A plain class rather than `@freezed`, against CLAUDE.md's default, for
/// `RegionPreset`'s reason one file over: this is a derived view of data
/// that is already a model, built and discarded within a single call. It is
/// never persisted (a [CvDraft] is what gets stored), never compared, and
/// has no use for `copyWith`.
///
/// It exists as its own type because two callers need the same projection
/// in genuinely different shapes, and computing it twice is how the two
/// quietly stop agreeing on what "everything" means the next time a
/// section type is added:
///
/// - Studio persists it onto a brand-new draft through
///   `DraftService.selectAllFromVault`, which takes plain id lists so the
///   service stays decoupled from the Vault — see its class doc.
/// - The Vault's default-template picker needs a throwaway draft to
///   compose thumbnails from, and must persist nothing at all.
class VaultSelection {
  VaultSelection.everythingIn(CvVault vault)
    : experienceIds = [for (final e in vault.experiences) e.id],
      bulletIds = {
        for (final e in vault.experiences)
          e.id: [for (final b in e.bullets) b.id],
      },
      projectIds = [for (final p in vault.projects) p.id],
      projectBulletIds = {
        for (final p in vault.projects) p.id: [for (final b in p.bullets) b.id],
      },
      skillIds = [
        for (final category in vault.skillCategories)
          for (final skill in category.skills) skill.id,
      ],
      educationIds = [for (final e in vault.education) e.id],
      educationBulletIds = {
        for (final e in vault.education)
          e.id: [for (final b in e.bullets) b.id],
      },
      hobbyIds = [for (final h in vault.hobbies) h.id],
      languageIds = [for (final l in vault.languages) l.id],
      publicationIds = [for (final p in vault.publications) p.id],
      publicationBulletIds = {
        for (final p in vault.publications)
          p.id: [for (final b in p.bullets) b.id],
      };

  final List<String> experienceIds;
  final Map<String, List<String>> bulletIds;
  final List<String> projectIds;
  final Map<String, List<String>> projectBulletIds;
  final List<String> skillIds;
  final List<String> educationIds;
  final Map<String, List<String>> educationBulletIds;
  final List<String> hobbyIds;
  final List<String> languageIds;
  final List<String> publicationIds;
  final Map<String, List<String>> publicationBulletIds;

  /// [draft] with this selection applied. Order and hidden sections are
  /// left alone — this decides *what* is included, never how it is
  /// arranged.
  CvDraft applyTo(CvDraft draft) => draft.copyWith(
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
  );
}
