import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill.freezed.dart';
part 'skill.g.dart';

@freezed
abstract class Skill with _$Skill {
  const factory Skill({
    required String id,
    required String label,

    /// [ExperienceBullet] ids this skill was demonstrated in — bullet
    /// granularity, not experience granularity, because that's the unit a
    /// future Copilot actually rewrites (see `CvDraft.bulletOverrides`);
    /// grounding at the job level would leave it guessing which of a job's
    /// several bullets a given skill applies to. Bullet ids are already
    /// globally unique (`Uuid` from `VaultService`), so a flat list here
    /// needs no experience id alongside it. Purely descriptive metadata in
    /// Phase 1 — the composer/template don't read it.
    @Default(<String>[]) List<String> linkedBulletIds,
  }) = _Skill;

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);
}
