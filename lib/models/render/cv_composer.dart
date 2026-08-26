import 'package:cv_forge/models/document/document_strings.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/draft/draft_omittable_field.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/language_proficiency.dart';
import 'resolved_cv.dart';
import 'resolved_section.dart';

/// Joins a [CvVault] with a [CvDraft] into a print-ready [ResolvedCv].
///
/// This is the ONLY place Vault and Draft data are combined — templates
/// never see either directly. Keeping the join logic here, and only here,
/// is what keeps the screen and PDF render trees from drifting on content.
///
/// A pure static function, not a Stacked service: it has no dependencies
/// of its own, and making it a service would add a mock every ViewModel
/// test would have to stub, reducing coverage of the most
/// correctness-critical code in the app rather than improving it.
abstract final class CvComposer {
  const CvComposer._();

  static ResolvedCv compose(
    CvVault vault,
    CvDraft draft, {
    required RegionProfile region,
    required DocumentLanguage language,
    required List<CvSectionType> sectionOrder,
  }) {
    // Resolved once and threaded down, rather than each builder reaching
    // for the table itself — the same reason [region] is a parameter.
    final strings = language.strings;
    final header = ResolvedHeader(
      fullName: vault.basics.fullName,
      // Empty rather than a nullable ResolvedCv.headline: every template
      // already guards on `headline.trim().isNotEmpty` to handle a Vault
      // that simply has none, so hiding reuses that one check instead of
      // adding a second, and no template signature moves.
      headline: draft.hideHeadline
          ? ''
          : (draft.headlineOverride ?? vault.basics.headline),
      email: vault.basics.email,
      phone: vault.basics.phone,
      location: vault.basics.location,
      // Same shape as [headline] above, and hidden the same way — except
      // this one stays null rather than becoming empty, because it is
      // already nullable for the Vault-has-none case.
      workAuthorization: draft.hideWorkAuthorization
          ? null
          : (draft.workAuthorizationOverride ?? vault.basics.workAuthorization),
      links: [
        for (final link in vault.basics.links)
          ResolvedLink(label: link.label, url: link.url),
      ],
      contactLabels: ResolvedContactLabels(
        location: strings.contactLocation,
        phone: strings.contactPhone,
        email: strings.contactEmail,
        link: strings.contactLink,
      ),
      photoJpegBase64: vault.basics.photo?.jpegBase64,
    );

    final sections = <ResolvedSection>[];

    // [sectionOrder] (the draft's own effective order) IS the canonical
    // print order — iterate it rather than hand-ordering the section
    // builds.
    for (final type in sectionOrder) {
      if (draft.hiddenSections.contains(type)) continue;

      final section = switch (type) {
        CvSectionType.summary => _buildSummary(vault, draft, strings),
        CvSectionType.skills => _buildSkills(vault, draft, strings),
        CvSectionType.languages => _buildLanguages(vault, draft, strings),
        CvSectionType.experience => _buildExperience(
          vault,
          draft,
          region,
          language,
        ),
        CvSectionType.projects => _buildProjects(vault, draft, strings),
        CvSectionType.education => _buildEducation(vault, draft, strings),
        CvSectionType.hobbies => _buildHobbies(vault, draft, strings),
        CvSectionType.references => _buildReferences(vault, draft, strings),
        CvSectionType.publications => _buildPublications(vault, draft, strings),
      };

      if (section != null) sections.add(section);
    }

    return ResolvedCv(header: header, sections: sections);
  }

  static ResolvedSection? _buildSummary(
    CvVault vault,
    CvDraft draft,
    DocumentStrings strings,
  ) {
    final text = draft.tailoredSummary ?? vault.basics.summary;
    if (text == null || text.trim().isEmpty) return null;
    return ResolvedSection.summary(title: strings.summary, text: text);
  }

  static ResolvedSection? _buildExperience(
    CvVault vault,
    CvDraft draft,
    RegionProfile region,
    DocumentLanguage language,
  ) {
    final byId = {for (final e in vault.experiences) e.id: e};

    // Both the groups and the roles within a group are sorted
    // reverse-chronologically rather than left in draft.experienceIds
    // order. That order starts as the vault's own insertion order and is
    // then shuffled by toggle-on order, neither of which has any
    // relationship to when a role was held, and there is no drag-reorder
    // UI to give it one. An experience with no companyGroupId is simply
    // the only member of its own group, which renders identically to a
    // one-position group, so there's no separate ungrouped code path.
    final grouped = <String, List<Experience>>{};
    for (final expId in draft.experienceIds) {
      final experience = byId[expId];
      if (experience == null) continue; // dangling id — silently dropped
      final key = experience.companyGroupId ?? 'ungrouped:$expId';
      (grouped[key] ??= <Experience>[]).add(experience);
    }

    if (grouped.isEmpty) return null;

    final members = grouped.values.toList();
    for (final roles in members) {
      roles.sort((a, b) => _recencyKey(b).compareTo(_recencyKey(a)));
    }
    // A group sorts by its most recent role, which after the sort above is
    // its first.
    members.sort(
      (a, b) => _recencyKey(b.first).compareTo(_recencyKey(a.first)),
    );

    return ResolvedSection.experience(
      title: language.strings.experience,
      titleFormal: language.strings.experienceFormal,
      groups: [
        for (final roles in members)
          ResolvedCompanyGroup(
            // Taken from the most recent role. A group's members share a
            // company by construction, but each carries its own location
            // field and they can legitimately differ (the same employer,
            // a different office).
            company: roles.first.company,
            // The location is the exception: it's overridable, and a
            // group prints one for all its roles, so an override on any
            // member must be able to reach it — otherwise editing the
            // location of anything but the newest role does nothing
            // visible. Newest override wins; see
            // `CvDraft.experienceLocationOverrides`.
            location:
                roles
                    .map((r) => draft.experienceLocationOverrides[r.id])
                    .nonNulls
                    .firstOrNull ??
                roles.first.location,
            positions: [
              for (final experience in roles)
                ResolvedPosition(
                  role: draft.roleOverrides[experience.id] ?? experience.role,
                  dateRange: _formatDateRange(experience, region, language),
                  bullets: _resolveBullets(
                    experience.bullets,
                    draft.bulletIds[experience.id] ?? const <String>[],
                    draft.bulletOverrides,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// Sort key for reverse-chronological ordering. An ongoing role sorts as
  /// if dated in the far future; otherwise it's the role's end month, or
  /// its start month if open-ended with no end recorded.
  static int _recencyKey(Experience experience) {
    if (experience.isCurrent) return 1 << 30;
    final effective = experience.end ?? experience.start;
    return effective.year * 12 + effective.month;
  }

  /// Shared by every bullet-owning section — each just filters and orders
  /// a [CvBullet] list by a selected-id list, applying any
  /// [CvDraft.bulletOverrides] on the way.
  static List<ResolvedBullet> _resolveBullets(
    List<CvBullet> bullets,
    List<String> selectedBulletIds,
    Map<String, String> overrides,
  ) {
    final bulletsById = {for (final b in bullets) b.id: b};
    return [
      for (final bulletId in selectedBulletIds)
        if (bulletsById[bulletId] case final bullet?)
          ResolvedBullet(text: overrides[bulletId] ?? bullet.text),
    ];
  }

  static ResolvedSection? _buildProjects(
    CvVault vault,
    CvDraft draft,
    DocumentStrings strings,
  ) {
    final byId = {for (final p in vault.projects) p.id: p};
    final items = <ResolvedProject>[
      for (final id in draft.projectIds)
        if (byId[id] case final project?)
          ResolvedProject(
            title: draft.projectTitleOverrides[id] ?? project.title,
            link: DraftOmittableField.projectLink.isOmittedFor(draft, id)
                ? null
                : project.link,
            bullets: _resolveBullets(
              project.bullets,
              draft.projectBulletIds[id] ?? const <String>[],
              draft.bulletOverrides,
            ),
          ),
    ];

    if (items.isEmpty) return null;
    return ResolvedSection.projects(title: strings.projects, items: items);
  }

  static ResolvedSection? _buildSkills(
    CvVault vault,
    CvDraft draft,
    DocumentStrings strings,
  ) {
    final selected = draft.skillIds.toSet();
    final groups = <ResolvedSkillGroup>[];

    for (final category in vault.skillCategories) {
      final skills = [
        for (final skill in category.skills)
          if (selected.contains(skill.id))
            draft.skillLabelOverrides[skill.id] ?? skill.label,
      ];
      if (skills.isNotEmpty) {
        groups.add(
          ResolvedSkillGroup(
            category:
                draft.skillCategoryNameOverrides[category.id] ?? category.name,
            skills: skills,
          ),
        );
      }
    }

    if (groups.isEmpty) return null;
    return ResolvedSection.skills(title: strings.skills, groups: groups);
  }

  static ResolvedSection? _buildEducation(
    CvVault vault,
    CvDraft draft,
    DocumentStrings strings,
  ) {
    final byId = {for (final e in vault.education) e.id: e};
    final items = <ResolvedQualification>[
      for (final id in draft.educationIds)
        if (byId[id] case final edu?)
          ResolvedQualification(
            qualification:
                draft.educationQualificationOverrides[edu.id] ??
                edu.qualification,
            institution: edu.institution,
            location: draft.educationLocationOverrides[edu.id] ?? edu.location,
            yearLabel:
                DraftOmittableField.educationYear.isOmittedFor(draft, edu.id)
                ? null
                : edu.year?.toString(),
            grade: draft.educationGradeOverrides[edu.id] ?? edu.grade,
            details: draft.educationDetailsOverrides[edu.id] ?? edu.details,
            bullets: _resolveBullets(
              edu.bullets,
              draft.educationBulletSelection(edu.id, [
                for (final b in edu.bullets) b.id,
              ]),
              draft.bulletOverrides,
            ),
          ),
    ];

    if (items.isEmpty) return null;
    return ResolvedSection.education(title: strings.education, items: items);
  }

  static ResolvedSection? _buildHobbies(
    CvVault vault,
    CvDraft draft,
    DocumentStrings strings,
  ) {
    final byId = {for (final h in vault.hobbies) h.id: h};
    final items = <String>[
      for (final id in draft.hobbyIds)
        if (byId[id] case final hobby?)
          draft.hobbyOverrides[hobby.id] ?? hobby.text,
    ];

    if (items.isEmpty) return null;
    return ResolvedSection.hobbies(title: strings.hobbies, items: items);
  }

  static ResolvedSection? _buildLanguages(
    CvVault vault,
    CvDraft draft,
    DocumentStrings strings,
  ) {
    final byId = {for (final l in vault.languages) l.id: l};
    final items = <ResolvedLanguage>[
      for (final id in draft.languageIds)
        if (byId[id] case final language?)
          ResolvedLanguage(
            name: draft.languageOverrides[language.id] ?? language.name,
            level: _formatProficiency(language.proficiency, strings),
          ),
    ];

    if (items.isEmpty) return null;
    return ResolvedSection.languages(title: strings.languages, items: items);
  }

  /// A CEFR band prints as its own code in every language — that is what
  /// the scale is for, and why adding a document language costs one word
  /// here rather than seven. Only the native band needs translating.
  static String? _formatProficiency(
    LanguageProficiency? proficiency,
    DocumentStrings strings,
  ) => switch (proficiency) {
    null => null,
    LanguageProficiency.native => strings.nativeLanguage,
    _ => proficiency.name.toUpperCase(),
  };

  static ResolvedSection? _buildReferences(
    CvVault vault,
    CvDraft draft,
    DocumentStrings strings,
  ) {
    final text = draft.referencesOverride ?? vault.referencesNote;
    if (text == null || text.trim().isEmpty) return null;
    return ResolvedSection.references(title: strings.references, text: text);
  }

  static ResolvedSection? _buildPublications(
    CvVault vault,
    CvDraft draft,
    DocumentStrings strings,
  ) {
    final byId = {for (final p in vault.publications) p.id: p};
    final items = <ResolvedPublication>[
      for (final id in draft.publicationIds)
        if (byId[id] case final publication?)
          ResolvedPublication(
            title: draft.publicationTitleOverrides[id] ?? publication.title,
            citation:
                draft.publicationCitationOverrides[id] ?? publication.citation,
            link: DraftOmittableField.publicationLink.isOmittedFor(draft, id)
                ? null
                : publication.link,
            bullets: _resolveBullets(
              publication.bullets,
              draft.publicationBulletIds[id] ?? const <String>[],
              draft.bulletOverrides,
            ),
          ),
    ];

    if (items.isEmpty) return null;
    return ResolvedSection.publications(
      title: strings.publications,
      items: items,
    );
  }

  /// The two axes meet here, and they answer different questions:
  /// [region] picks the date *convention*, [language] the words.
  static String _formatDateRange(
    Experience experience,
    RegionProfile region,
    DocumentLanguage language,
  ) {
    // uk and us both resolve to RegionDateStyle.monYyyy today — see
    // RegionPreset's doc comment — but the switch is on that seam, not on
    // RegionProfile directly, so a region with a different convention
    // needs only a new case here, not a new call site.
    switch (region.preset.dateStyle) {
      case RegionDateStyle.monYyyy:
        final start = experience.start.toMonYyyy(language);
        // Capitalized in every language — the ATS-recognized token for an
        // ongoing role, matched by regex date parsers reading whatever
        // language the document is in. See DocumentStrings.present.
        if (experience.isCurrent) {
          return '$start$documentDateRangeSeparator${language.strings.present}';
        }
        final end = experience.end?.toMonYyyy(language);
        return end == null ? start : '$start$documentDateRangeSeparator$end';
    }
  }
}
