import 'package:freezed_annotation/freezed_annotation.dart';

import 'skill.dart';

part 'skill_category.freezed.dart';
part 'skill_category.g.dart';

@freezed
abstract class SkillCategory with _$SkillCategory {
  const factory SkillCategory({
    required String id,
    required String name,
    @Default(<Skill>[]) List<Skill> skills,
  }) = _SkillCategory;

  factory SkillCategory.fromJson(Map<String, dynamic> json) =>
      _$SkillCategoryFromJson(json);
}

extension SkillCategoryDisplay on SkillCategory {
  /// A category is legitimately unnamed while it's being filled in — new
  /// ones start blank so they prune like any other unfilled entry (see
  /// `CvVaultPruning.withoutBlankEntries`). Anywhere the name is *shown*
  /// — a chip-group heading, a menu item — needs something to render;
  /// the editor field itself still binds to the raw [name].
  String get displayName => name.trim().isEmpty ? 'Unnamed category' : name;
}
