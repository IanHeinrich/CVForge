import 'package:freezed_annotation/freezed_annotation.dart';

import 'contact_basics.dart';
import 'document_defaults.dart';
import 'education.dart';
import 'experience.dart';
import 'hobby_item.dart';
import 'language_item.dart';
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
    @Default(<LanguageItem>[]) List<LanguageItem> languages,
    @Default(<Publication>[]) List<Publication> publications,
    String? referencesNote,

    /// What every new CV built from this Vault starts out as — region,
    /// language, and section layout.
    ///
    /// The one part of this aggregate that is configuration rather than
    /// career content, and it lives here for the reason [DocumentDefaults]
    /// gives: it shapes the document, so it belongs with the document's
    /// source material rather than with the app's own settings.
    ///
    /// That distinction is load-bearing in two places, both of which would
    /// otherwise destroy it silently: [CvVaultEmptiness.isEmpty] must not
    /// count it as content, and `VaultService`'s two replace-the-whole-
    /// aggregate methods must carry it across. See both.
    @Default(DocumentDefaults()) DocumentDefaults documentDefaults,
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
///
/// [CvVault.documentDefaults] is deliberately not consulted: this asks
/// whether the user has entered any *content*, and a region or language
/// choice is not content. It also could not usefully be — unlike a photo,
/// it is never absent, so counting it would make every Vault non-empty and
/// the first-run state unreachable. That is exactly why the photo's fix
/// below does not generalise, and why `VaultService.loadExampleVault` and
/// `clearVault` have to carry the defaults across by hand instead.
extension CvVaultEmptiness on CvVault {
  bool get isEmpty =>
      basics.fullName.trim().isEmpty &&
      // A photo counts as content, because the empty state it gates offers
      // "Load example CV" — which goes through `replaceAll` and would
      // silently discard a photo uploaded before anything was typed.
      basics.photo == null &&
      experiences.isEmpty &&
      skillCategories.isEmpty &&
      projects.isEmpty &&
      education.isEmpty &&
      hobbies.isEmpty &&
      languages.isEmpty &&
      publications.isEmpty;
}
