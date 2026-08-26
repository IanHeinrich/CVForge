import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/identified_list.dart';
import 'package:cv_forge/models/settings/cv_preferences.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/language_item.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';

import 'cv_backup_bundle.dart';

/// Three-way merges two divergent [CvBackupBundle]s against the ancestor
/// they last agreed on.
///
/// This is what lets Drive sync reconcile two devices without asking the
/// user to discard a side. `DriveSyncService` persists the exact bundle it
/// last synced as the ancestor, so "this id is missing from the other side"
/// becomes answerable: present in the ancestor means deleted, absent means
/// the other side added it. [IdentifiedListMerge.mergeThreeWay] holds the
/// full truth table and the edit-beats-delete bias.
///
/// **Every input must be `BackupService.buildBundle()` output**, and this
/// function deliberately never prunes. `CvVaultPruning.withoutBlankEntries`
/// drops blank entries on the way to both storage and Drive, so a blank
/// vanishing genuinely *is* a delete as far as sync is concerned — but only
/// because all three sides were pruned identically. Re-pruning here would
/// paper over a violated invariant instead of surfacing it.
///
/// Nested entities carry ids but no timestamps of their own (only [CvVault]
/// and [CvDraft] have `updatedAt`), so a contested vault entry — one both
/// devices changed since the ancestor — is settled by whichever side's
/// whole-vault `updatedAt` is later. That's coarse, and deliberately so:
/// adding per-record timestamps wouldn't remove the need for an ancestor
/// (a deleted record takes its timestamp with it) and would break the
/// equality checks this merge relies on.
CvBackupBundle mergeBackupBundles({
  required CvBackupBundle base,
  required CvBackupBundle local,
  required CvBackupBundle remote,
}) {
  final drafts = base.drafts.mergeThreeWay(
    local.drafts,
    remote.drafts,
    idOf: (d) => d.id,
    // A draft is a curation of the Vault, and two devices editing the same
    // draft concurrently is the rarest case here — so a contested draft is
    // taken whole from the later side rather than merged field by field.
    preferRemote: (_, l, r) => r.updatedAt.isAfter(l.updatedAt),
  );
  return local.copyWith(
    vault: _mergeVaults(base.vault, local.vault, remote.vault),
    drafts: drafts,
    activeDraftId: _pickActiveDraftId(base, local, remote, drafts),
    preferences: _mergePreferences(
      base.preferences,
      local.preferences,
      remote.preferences,
    ),
  );
}

/// Preferences are flat scalars with no ids, so unlike the Vault there's
/// nothing finer to merge by — each field goes to whichever side changed
/// it, and a field both sides changed goes to the later [CvPreferences.
/// updatedAt]. A null side means "nothing to say", never "clear these".
///
/// Built with `local.copyWith` rather than a bare constructor call
/// deliberately: a field added to [CvPreferences] and forgotten here then
/// degrades to "keep this device's value" instead of silently resetting to
/// the class default on every sync. That is not hypothetical — `localeTag`
/// was added without a line here and was being reset to "follow the
/// browser" for anyone syncing, which is invisible until someone notices
/// their language choice not sticking on a second device.
CvPreferences? _mergePreferences(
  CvPreferences? base,
  CvPreferences? local,
  CvPreferences? remote,
) {
  if (local == null) return remote;
  if (remote == null) return local;
  final b = base ?? CvPreferences.empty();
  final pr = remote.updatedAt.isAfter(local.updatedAt);
  final merged = local.copyWith(
    aiAssistantProviderId: _pick(
      b.aiAssistantProviderId,
      local.aiAssistantProviderId,
      remote.aiAssistantProviderId,
      pr,
    ),
    aiAssistantModelId: _pick(
      b.aiAssistantModelId,
      local.aiAssistantModelId,
      remote.aiAssistantModelId,
      pr,
    ),
    aiAssistantConfiguredAt: _pick(
      b.aiAssistantConfiguredAt,
      local.aiAssistantConfiguredAt,
      remote.aiAssistantConfiguredAt,
      pr,
    ),
    localeTag: _pick(b.localeTag, local.localeTag, remote.localeTag, pr),
    updatedAt: local.updatedAt,
  );
  // Same reasoning as _stampMerged: a result identical to one side didn't
  // incorporate anything new, so it keeps that side's date rather than
  // claiming to be fresher and rigging the next tie-break.
  if (merged == local) return local;
  final asRemote = merged.copyWith(updatedAt: remote.updatedAt);
  if (asRemote == remote) return remote;
  return merged.copyWith(updatedAt: pr ? remote.updatedAt : local.updatedAt);
}

/// Whether [local] and [remote] describe the same Vault shape.
///
/// A `schemaVersion` mismatch means the other device is running a different
/// build, and merging field-wise across shapes would silently mis-map data.
/// `DriveSyncService` checks this before merging and surfaces it as "update
/// this device" rather than attempting a reconcile.
bool bundlesAreMergeable(CvBackupBundle local, CvBackupBundle remote) {
  final l = local.vault;
  final r = remote.vault;
  return l == null || r == null || l.schemaVersion == r.schemaVersion;
}

/// One field, three versions. Whichever side left it at its ancestral value
/// yields to the side that changed it; if both changed it, [preferRemote]
/// settles it.
V _pick<V>(V? base, V local, V remote, bool preferRemote) => local == remote
    ? local
    : local == base
    ? remote
    : remote == base
    ? local
    : (preferRemote ? remote : local);

CvVault? _mergeVaults(CvVault? base, CvVault? local, CvVault? remote) {
  if (local == null) return remote;
  if (remote == null) return local;

  // No ancestor means no evidence that any absence is a deletion, so an
  // empty one makes every id on both sides read as an addition and nothing
  // is dropped. This is also the whole of the migration path for users who
  // synced before the ancestor was persisted — see `StorageKeys.driveSyncBase`.
  final b =
      base ??
      CvVault(
        schemaVersion: local.schemaVersion,
        basics: ContactBasics.empty(),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
  final pr = remote.updatedAt.isAfter(local.updatedAt);

  // `local.copyWith` rather than a bare constructor call, for the same
  // reason as _mergePreferences: a field added to [CvVault] and forgotten
  // here degrades to "keep this device's value" instead of silently
  // resetting to the class default on every sync.
  final merged = local.copyWith(
    schemaVersion: local.schemaVersion,
    basics: _mergeBasics(b.basics, local.basics, remote.basics, pr),
    experiences: b.experiences.mergeThreeWay(
      local.experiences,
      remote.experiences,
      idOf: (e) => e.id,
      preferRemote: (_, _, _) => pr,
      mergeItem: (bb, l, r) => _mergeExperience(bb, l, r, pr),
    ),
    skillCategories: b.skillCategories.mergeThreeWay(
      local.skillCategories,
      remote.skillCategories,
      idOf: (c) => c.id,
      preferRemote: (_, _, _) => pr,
      mergeItem: (bb, l, r) => _mergeSkillCategory(bb, l, r, pr),
    ),
    projects: b.projects.mergeThreeWay(
      local.projects,
      remote.projects,
      idOf: (p) => p.id,
      preferRemote: (_, _, _) => pr,
      mergeItem: (bb, l, r) => _mergeProject(bb, l, r, pr),
    ),
    education: b.education.mergeThreeWay(
      local.education,
      remote.education,
      idOf: (e) => e.id,
      preferRemote: (_, _, _) => pr,
      mergeItem: (bb, l, r) => _mergeEducation(bb, l, r, pr),
    ),
    hobbies: b.hobbies.mergeThreeWay(
      local.hobbies,
      remote.hobbies,
      idOf: (h) => h.id,
      preferRemote: (_, _, _) => pr,
    ),
    // Unlike a hobby, a language is two fields — so it needs mergeItem,
    // or editing the name here and the level there would lose one of
    // them wholesale rather than keeping both.
    languages: b.languages.mergeThreeWay(
      local.languages,
      remote.languages,
      idOf: (l) => l.id,
      preferRemote: (_, _, _) => pr,
      mergeItem: (bb, l, r) => _mergeLanguage(bb, l, r, pr),
    ),
    publications: b.publications.mergeThreeWay(
      local.publications,
      remote.publications,
      idOf: (p) => p.id,
      preferRemote: (_, _, _) => pr,
      mergeItem: (bb, l, r) => _mergePublication(bb, l, r, pr),
    ),
    referencesNote: _pick(
      b.referencesNote,
      local.referencesNote,
      remote.referencesNote,
      pr,
    ),
    documentDefaults: _mergeDocumentDefaults(
      b.documentDefaults,
      local.documentDefaults,
      remote.documentDefaults,
      pr,
    ),
    // Placeholder — _stampMerged picks the real one below.
    updatedAt: local.updatedAt,
  );
  return _stampMerged(merged, local, remote);
}

/// Field by field, not whole-object.
///
/// A single [_pick] over the whole [DocumentDefaults] would drop one
/// device's edit whenever the two changed *different* fields — both would
/// differ from the ancestor, so it would fall through to the timestamp
/// tie-break and take one side entire. Same shape as [_mergeBasics], for
/// the same reason.
///
/// Every field, and it has to stay that way: this returns
/// `local.copyWith(...)`, so a field left out here is not merged
/// conservatively, it silently keeps the local value and discards the
/// remote one. [DocumentDefaults.hideHeadline] was missed when it was
/// added and did exactly that.
DocumentDefaults _mergeDocumentDefaults(
  DocumentDefaults base,
  DocumentDefaults local,
  DocumentDefaults remote,
  bool preferRemote,
) => local.copyWith(
  region: _pick(base.region, local.region, remote.region, preferRemote),
  language: _pick(base.language, local.language, remote.language, preferRemote),
  templateId: _pick(
    base.templateId,
    local.templateId,
    remote.templateId,
    preferRemote,
  ),
  sectionOrder: _pick(
    base.sectionOrder,
    local.sectionOrder,
    remote.sectionOrder,
    preferRemote,
  ),
  hiddenSections: _pick(
    base.hiddenSections,
    local.hiddenSections,
    remote.hiddenSections,
    preferRemote,
  ),
  hideHeadline: _pick(
    base.hideHeadline,
    local.hideHeadline,
    remote.hideHeadline,
    preferRemote,
  ),
  hideWorkAuthorization: _pick(
    base.hideWorkAuthorization,
    local.hideWorkAuthorization,
    remote.hideWorkAuthorization,
    preferRemote,
  ),
);

/// Dates the merged vault by what it actually turned out to be.
///
/// A result identical to one side didn't incorporate anything new, so it
/// keeps that side's `updatedAt` rather than claiming to be fresher than it
/// is — which also keeps the merge idempotent: reconciling a device that
/// was purely behind yields Drive's bundle byte-for-byte, so sync applies
/// it without a pointless write back. Only a genuinely combined result
/// takes `max`, meaning "incorporates edits up to here". Never `now()`,
/// which would rig every later tie-break in this device's favour.
CvVault _stampMerged(CvVault merged, CvVault local, CvVault remote) {
  final asLocal = merged.copyWith(updatedAt: local.updatedAt);
  if (asLocal == local) return asLocal;
  final asRemote = merged.copyWith(updatedAt: remote.updatedAt);
  if (asRemote == remote) return asRemote;
  return merged.copyWith(
    updatedAt: local.updatedAt.isAfter(remote.updatedAt)
        ? local.updatedAt
        : remote.updatedAt,
  );
}

ContactBasics _mergeBasics(
  ContactBasics base,
  ContactBasics local,
  ContactBasics remote,
  bool pr,
) => ContactBasics(
  fullName: _pick(base.fullName, local.fullName, remote.fullName, pr),
  headline: _pick(base.headline, local.headline, remote.headline, pr),
  email: _pick(base.email, local.email, remote.email, pr),
  phone: _pick(base.phone, local.phone, remote.phone, pr),
  location: _pick(base.location, local.location, remote.location, pr),
  summary: _pick(base.summary, local.summary, remote.summary, pr),
  workAuthorization: _pick(
    base.workAuthorization,
    local.workAuthorization,
    remote.workAuthorization,
    pr,
  ),
  photo: _pick(base.photo, local.photo, remote.photo, pr),
  links: base.links.mergeThreeWay(
    local.links,
    remote.links,
    idOf: (l) => l.id,
    preferRemote: (_, _, _) => pr,
  ),
);

Experience _mergeExperience(
  Experience? b,
  Experience l,
  Experience r,
  bool pr,
) => Experience(
  id: l.id,
  role: _pick(b?.role, l.role, r.role, pr),
  company: _pick(b?.company, l.company, r.company, pr),
  location: _pick(b?.location, l.location, r.location, pr),
  start: _pick(b?.start, l.start, r.start, pr),
  end: _pick(b?.end, l.end, r.end, pr),
  isCurrent: _pick(b?.isCurrent, l.isCurrent, r.isCurrent, pr),
  companyGroupId: _pick(
    b?.companyGroupId,
    l.companyGroupId,
    r.companyGroupId,
    pr,
  ),
  bullets: _mergeBullets(b?.bullets, l.bullets, r.bullets, pr),
);

Project _mergeProject(Project? b, Project l, Project r, bool pr) => Project(
  id: l.id,
  title: _pick(b?.title, l.title, r.title, pr),
  link: _pick(b?.link, l.link, r.link, pr),
  bullets: _mergeBullets(b?.bullets, l.bullets, r.bullets, pr),
);

Education _mergeEducation(Education? b, Education l, Education r, bool pr) =>
    Education(
      id: l.id,
      qualification: _pick(
        b?.qualification,
        l.qualification,
        r.qualification,
        pr,
      ),
      institution: _pick(b?.institution, l.institution, r.institution, pr),
      location: _pick(b?.location, l.location, r.location, pr),
      year: _pick(b?.year, l.year, r.year, pr),
      grade: _pick(b?.grade, l.grade, r.grade, pr),
      details: _pick(b?.details, l.details, r.details, pr),
      bullets: _mergeBullets(b?.bullets, l.bullets, r.bullets, pr),
    );

LanguageItem _mergeLanguage(
  LanguageItem? b,
  LanguageItem l,
  LanguageItem r,
  bool pr,
) => LanguageItem(
  id: l.id,
  name: _pick(b?.name, l.name, r.name, pr),
  proficiency: _pick(b?.proficiency, l.proficiency, r.proficiency, pr),
);

Publication _mergePublication(
  Publication? b,
  Publication l,
  Publication r,
  bool pr,
) => Publication(
  id: l.id,
  title: _pick(b?.title, l.title, r.title, pr),
  citation: _pick(b?.citation, l.citation, r.citation, pr),
  link: _pick(b?.link, l.link, r.link, pr),
  bullets: _mergeBullets(b?.bullets, l.bullets, r.bullets, pr),
);

SkillCategory _mergeSkillCategory(
  SkillCategory? b,
  SkillCategory l,
  SkillCategory r,
  bool pr,
) => SkillCategory(
  id: l.id,
  name: _pick(b?.name, l.name, r.name, pr),
  skills: (b?.skills ?? const <Skill>[]).mergeThreeWay(
    l.skills,
    r.skills,
    idOf: (s) => s.id,
    preferRemote: (_, _, _) => pr,
    mergeItem: (bb, ll, rr) => Skill(
      id: ll.id,
      label: _pick(bb?.label, ll.label, rr.label, pr),
      // Ids, so they merge as a list of their own — a skill linked to a new
      // bullet on each device ends up linked to both.
      linkedBulletIds: (bb?.linkedBulletIds ?? const <String>[]).mergeThreeWay(
        ll.linkedBulletIds,
        rr.linkedBulletIds,
        idOf: (id) => id,
        preferRemote: (_, _, _) => pr,
      ),
    ),
  ),
);

List<CvBullet> _mergeBullets(
  List<CvBullet>? base,
  List<CvBullet> local,
  List<CvBullet> remote,
  bool pr,
) => (base ?? const <CvBullet>[]).mergeThreeWay(
  local,
  remote,
  idOf: (x) => x.id,
  preferRemote: (_, _, _) => pr,
  mergeItem: (b, l, r) =>
      CvBullet(id: l.id, text: _pick(b?.text, l.text, r.text, pr)),
);

/// Which CV is open is device-scoped in spirit, so local wins unless it
/// never moved — otherwise syncing would yank the other device's choice
/// out from under whoever is mid-edit. Falls through to anything that
/// survived the merge rather than pointing at a deleted draft.
String? _pickActiveDraftId(
  CvBackupBundle base,
  CvBackupBundle local,
  CvBackupBundle remote,
  List<CvDraft> merged,
) {
  final ids = {for (final d in merged) d.id};
  final candidates = [
    _pick(base.activeDraftId, local.activeDraftId, remote.activeDraftId, false),
    local.activeDraftId,
    remote.activeDraftId,
  ];
  for (final candidate in candidates) {
    if (candidate != null && ids.contains(candidate)) return candidate;
  }
  return merged.isEmpty ? null : merged.first.id;
}
