import 'package:freezed_annotation/freezed_annotation.dart';

import 'contact_basics.dart';
import 'education.dart';
import 'experience.dart';
import 'hobby_item.dart';
import 'project.dart';
import 'publication.dart';
import 'skill_category.dart';

part 'cv_vault.freezed.dart';
part 'cv_vault.g.dart';

/// The master career store — "The Vault". One aggregate root, persisted as
/// a single JSON string. [schemaVersion] lives on the model (not in a
/// separate meta box) so the exact same migration path can later serve a
/// "import a JSON file exported months ago" feature.
@freezed
abstract class CvVault with _$CvVault {
  const factory CvVault({
    required int schemaVersion,
    required ContactBasics basics,
    @Default(<Experience>[]) List<Experience> experiences,
    @Default(<SkillCategory>[]) List<SkillCategory> skillCategories,
    @Default(<Project>[]) List<Project> projects,
    @Default(<Education>[]) List<Education> education,
    @Default(<HobbyItem>[]) List<HobbyItem> hobbies,
    @Default(<Publication>[]) List<Publication> publications,
    String? referencesNote,
    required DateTime updatedAt,
  }) = _CvVault;

  factory CvVault.fromJson(Map<String, dynamic> json) =>
      _$CvVaultFromJson(json);

  factory CvVault.empty() => CvVault(
    schemaVersion: 1,
    basics: ContactBasics.empty(),
    updatedAt: DateTime.now(),
  );
}

/// A pure structural predicate — not presentation logic — used to decide
/// whether to show the Vault's first-run empty state.
extension CvVaultEmptiness on CvVault {
  bool get isEmpty =>
      basics.fullName.trim().isEmpty &&
      experiences.isEmpty &&
      skillCategories.isEmpty &&
      projects.isEmpty &&
      education.isEmpty &&
      hobbies.isEmpty &&
      publications.isEmpty;
}
