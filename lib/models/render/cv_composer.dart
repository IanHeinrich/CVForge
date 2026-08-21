import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'region_profile.dart';
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
    required List<CvSectionType> sectionOrder,
  }) {
    final header = ResolvedHeader(
      fullName: vault.basics.fullName,
      headline: draft.headlineOverride ?? vault.basics.headline,
      email: vault.basics.email,
      phone: vault.basics.phone,
      location: vault.basics.location,
      links: [
        for (final link in vault.basics.links)
          ResolvedLink(label: link.label, url: link.url),
      ],
    );

    final sections = <ResolvedSection>[];

    // [sectionOrder] (the calling template's) IS the canonical print
    // order — iterate it rather than hand-ordering the section builds.
    for (final type in sectionOrder) {
      if (draft.hiddenSections.contains(type)) continue;

      final section = switch (type) {
        CvSectionType.summary => _buildSummary(vault, draft),
        CvSectionType.skills => _buildSkills(vault, draft),
        CvSectionType.experience => _buildExperience(vault, draft, region),
        CvSectionType.projects => _buildProjects(vault, draft),
        CvSectionType.education => _buildEducation(vault, draft),
        CvSectionType.hobbies => _buildHobbies(vault, draft),
        CvSectionType.references => _buildReferences(vault, draft),
        CvSectionType.publications => _buildPublications(vault, draft),
      };

      if (section != null) sections.add(section);
    }

    return ResolvedCv(header: header, sections: sections);
  }

  static ResolvedSection? _buildSummary(CvVault vault, CvDraft draft) {
    final text = draft.tailoredSummary ?? vault.basics.summary;
    if (text == null || text.trim().isEmpty) return null;
    return ResolvedSection.summary(title: 'Professional summary', text: text);
  }

  static ResolvedSection? _buildExperience(
    CvVault vault,
    CvDraft draft,
    RegionProfile region,
  ) {
    final byId = {for (final e in vault.experiences) e.id: e};

    // Each group's internal position order comes from draft.experienceIds
    // (a promotion's roles are entered oldest-first, so that stays as-is),
    // but the GROUPS themselves are sorted reverse-chronological below —
    // Phase 1 has no manual drag-reorder UI, so trusting toggle-on order
    // for the group sequence would scramble the CV unpredictably. An
    // experience with no companyGroupId is simply the only member of its
    // own group, which renders identically to a one-position group, so
    // there's no separate ungrouped code path.
    final groups = <ResolvedCompanyGroup>[];
    final mostRecentByGroup = <int>[];
    final groupIndexByKey = <String, int>{};

    for (final expId in draft.experienceIds) {
      final experience = byId[expId];
      if (experience == null) continue; // dangling id — silently dropped

      final position = ResolvedPosition(
        role: experience.role,
        dateRange: _formatDateRange(experience, region),
        bullets: _resolveBullets(
          experience.bullets,
          draft.bulletIds[experience.id] ?? const <String>[],
          draft.bulletOverrides,
        ),
      );

      final key = experience.companyGroupId ?? 'ungrouped:$expId';
      final recency = _recencyKey(experience);
      final existingIndex = groupIndexByKey[key];
      if (existingIndex != null) {
        final existing = groups[existingIndex];
        groups[existingIndex] = existing.copyWith(
          positions: [...existing.positions, position],
        );
        if (recency > mostRecentByGroup[existingIndex]) {
          mostRecentByGroup[existingIndex] = recency;
        }
      } else {
        groupIndexByKey[key] = groups.length;
        groups.add(
          ResolvedCompanyGroup(
            company: experience.company,
            location: experience.location,
            positions: [position],
          ),
        );
        mostRecentByGroup.add(recency);
      }
    }

    if (groups.isEmpty) return null;

    final order = List<int>.generate(groups.length, (i) => i)
      ..sort((a, b) => mostRecentByGroup[b].compareTo(mostRecentByGroup[a]));

    return ResolvedSection.experience(
      title: 'Experience',
      groups: [for (final i in order) groups[i]],
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

  /// Shared by [_buildExperience] and [_buildProjects] — both just filter
  /// and order a [CvBullet] list by a selected-id list, applying any
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
          ResolvedBullet(
            label: bullet.label,
            text: overrides[bulletId] ?? bullet.text,
          ),
    ];
  }

  static ResolvedSection? _buildProjects(CvVault vault, CvDraft draft) {
    final byId = {for (final p in vault.projects) p.id: p};
    final items = <ResolvedProject>[
      for (final id in draft.projectIds)
        if (byId[id] case final project?)
          ResolvedProject(
            title: project.title,
            link: project.link,
            bullets: _resolveBullets(
              project.bullets,
              draft.projectBulletIds[id] ?? const <String>[],
              draft.bulletOverrides,
            ),
          ),
    ];

    if (items.isEmpty) return null;
    return ResolvedSection.projects(title: 'Projects', items: items);
  }

  static ResolvedSection? _buildSkills(CvVault vault, CvDraft draft) {
    final selected = draft.skillIds.toSet();
    final groups = <ResolvedSkillGroup>[];

    for (final category in vault.skillCategories) {
      final skills = [
        for (final skill in category.skills)
          if (selected.contains(skill.id)) skill.label,
      ];
      if (skills.isNotEmpty) {
        groups.add(ResolvedSkillGroup(category: category.name, skills: skills));
      }
    }

    if (groups.isEmpty) return null;
    return ResolvedSection.skills(title: 'Skills', groups: groups);
  }

  static ResolvedSection? _buildEducation(CvVault vault, CvDraft draft) {
    final byId = {for (final e in vault.education) e.id: e};
    final items = <ResolvedQualification>[
      for (final id in draft.educationIds)
        if (byId[id] case final edu?)
          ResolvedQualification(
            qualification: edu.qualification,
            institution: edu.institution,
            location: edu.location,
            yearLabel: edu.year?.toString(),
            grade: edu.grade,
            details: draft.educationDetailsOverrides[edu.id] ?? edu.details,
          ),
    ];

    if (items.isEmpty) return null;
    return ResolvedSection.education(title: 'Education', items: items);
  }

  static ResolvedSection? _buildHobbies(CvVault vault, CvDraft draft) {
    final byId = {for (final h in vault.hobbies) h.id: h};
    final items = <String>[
      for (final id in draft.hobbyIds)
        if (byId[id] case final hobby?) hobby.text,
    ];

    if (items.isEmpty) return null;
    return ResolvedSection.hobbies(
      title: 'Hobbies and interests',
      items: items,
    );
  }

  static ResolvedSection? _buildReferences(CvVault vault, CvDraft draft) {
    final text = draft.referencesOverride ?? vault.referencesNote;
    if (text == null || text.trim().isEmpty) return null;
    return ResolvedSection.references(title: 'References', text: text);
  }

  static ResolvedSection? _buildPublications(CvVault vault, CvDraft draft) {
    final byId = {for (final p in vault.publications) p.id: p};
    final items = <ResolvedPublication>[
      for (final id in draft.publicationIds)
        if (byId[id] case final publication?)
          ResolvedPublication(
            title: publication.title,
            citation: publication.citation,
            link: publication.link,
          ),
    ];

    if (items.isEmpty) return null;
    return ResolvedSection.publications(title: 'Publications', items: items);
  }

  static String _formatDateRange(Experience experience, RegionProfile region) {
    // uk and us format identically today — "Mon YYYY" reads fine on both
    // sides of the Atlantic — but region stays threaded through as the
    // seam for whichever one needs to diverge first.
    switch (region) {
      case RegionProfile.uk || RegionProfile.us:
        final start = experience.start.toMonYyyy();
        // Capitalized — the ATS-recognized keyword token for an ongoing
        // role, matched by standard regex date parsers.
        if (experience.isCurrent) return '$start - Present';
        final end = experience.end?.toMonYyyy();
        return end == null ? start : '$start - $end';
    }
  }
}
