import '../draft/cv_draft.dart';
import '../draft/cv_section_type.dart';
import '../vault/cv_vault.dart';
import '../vault/experience.dart';
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
  }) {
    final header = ResolvedHeader(
      fullName: vault.basics.fullName,
      headline: vault.basics.headline,
      email: vault.basics.email,
      phone: vault.basics.phone,
      location: vault.basics.location,
      links: [
        for (final link in vault.basics.links)
          ResolvedLink(label: link.label, url: link.url),
      ],
    );

    final sections = <ResolvedSection>[];

    // Declaration order of CvSectionType.values IS the canonical print
    // order — iterate it rather than hand-ordering the section builds.
    for (final type in CvSectionType.values) {
      if (draft.hiddenSections.contains(type)) continue;

      final section = switch (type) {
        CvSectionType.summary => _buildSummary(vault, draft),
        CvSectionType.experience => _buildExperience(vault, draft, region),
        CvSectionType.skills => _buildSkills(vault, draft),
        CvSectionType.education => _buildEducation(vault, draft),
        CvSectionType.hobbies => _buildHobbies(vault, draft),
        CvSectionType.references => _buildReferences(vault),
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
    final roles = <ResolvedRole>[];

    for (final expId in draft.experienceIds) {
      final experience = byId[expId];
      if (experience == null) continue; // dangling id — silently dropped

      final bulletsById = {for (final b in experience.bullets) b.id: b};
      final selectedBulletIds = draft.bulletIds[expId] ?? const <String>[];
      final bullets = <ResolvedBullet>[
        for (final bulletId in selectedBulletIds)
          if (bulletsById[bulletId] case final bullet?)
            ResolvedBullet(
              label: bullet.label,
              text: draft.bulletOverrides[bulletId] ?? bullet.text,
            ),
      ];

      roles.add(
        ResolvedRole(
          role: experience.role,
          company: experience.company,
          location: experience.location,
          dateRange: _formatDateRange(experience, region),
          bullets: bullets,
        ),
      );
    }

    if (roles.isEmpty) return null;
    return ResolvedSection.experience(title: 'Work history', roles: roles);
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
            details: edu.details,
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

  static ResolvedSection? _buildReferences(CvVault vault) {
    final text = vault.referencesNote;
    if (text == null || text.trim().isEmpty) return null;
    return ResolvedSection.references(title: 'References', text: text);
  }

  static String _formatDateRange(Experience experience, RegionProfile region) {
    // Single case today; this switch is the seam a future US date format
    // (and spelling normalisation) plugs into.
    switch (region) {
      case RegionProfile.uk:
        final start = experience.start.toMmYyyy();
        if (experience.isCurrent) return '$start - current';
        final end = experience.end?.toMmYyyy();
        return end == null ? start : '$start - $end';
    }
  }
}
