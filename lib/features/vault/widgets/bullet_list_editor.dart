import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_chip_group_selector/app_chip_group_selector.dart';
import 'package:cv_forge/ui/widgets/common/app_delete_icon_button/app_delete_icon_button.dart';
import 'package:cv_forge/ui/widgets/common/app_inline_empty_message/app_inline_empty_message.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'link_picker_shell/link_picker_shell.dart';
import 'vault_section_heading.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

/// A bullet's add/change/delete/reorder callbacks, bundled into one value
/// so every entity's editor panel (experience, project, education,
/// publication) passes a single prop through to [BulletListEditor] and
/// `VaultEditorPanelRouter` builds it once per case rather than repeating
/// the same four closures four times.
class BulletEditorCallbacks {
  const BulletEditorCallbacks({
    required this.onAdd,
    required this.onChanged,
    required this.onDelete,
    required this.onReorder,
  });

  final VoidCallback onAdd;
  final ValueChanged<CvBullet> onChanged;
  final ValueChanged<String> onDelete;
  final ValueChanged<List<String>> onReorder;
}

/// The bullet list inside an experience's editor panel — labelled/
/// unlabelled text, add, delete, and drag-to-reorder.
class BulletListEditor extends StatefulWidget {
  const BulletListEditor({
    super.key,
    required this.bullets,
    required this.skillCategories,
    required this.onUpdateSkill,
    required this.onAddSkill,
    required this.onAddCategory,
    required this.callbacks,
  });

  final List<CvBullet> bullets;

  /// This is the primary place a skill gets linked to a bullet — see
  /// [_BulletSkillLinkPicker]. The Skills panel's own
  /// `_SkillBulletLinkPicker` still exists for the opposite, bulk
  /// direction (a newly added skill, linking it across many existing
  /// bullets at once), so the two surfaces stay in sync via the same
  /// underlying [Skill.linkedBulletIds].
  final List<SkillCategory> skillCategories;

  /// Not owner-scoped (unlike [callbacks]) — a skill's category id is
  /// enough to route the update, regardless of which entity's bullet the
  /// link was toggled from.
  final void Function(String categoryId, Skill skill) onUpdateSkill;

  /// Lets [_BulletSkillLinkPicker] create a skill that doesn't exist yet
  /// without leaving this panel — see its own doc comment.
  final Future<Skill> Function(String categoryId, String label) onAddSkill;

  /// Lets [_BulletSkillLinkPicker] create a category on the fly too, for
  /// the same reason — see its own doc comment.
  final Future<SkillCategory> Function(String name) onAddCategory;
  final BulletEditorCallbacks callbacks;

  @override
  State<BulletListEditor> createState() => _BulletListEditorState();
}

class _BulletListEditorState extends State<BulletListEditor> {
  /// At most one bullet's skill-link picker open at a time within this
  /// entity's bullet list — same reasoning as `_SkillsEditorPanelState.
  /// _expandedSkillId`: without this, expanding one after another (which
  /// adding new bullets keeps inviting) grows the panel without bound.
  String? _expandedBulletId;

  void _toggleExpanded(String bulletId) {
    setState(
      () => _expandedBulletId = _expandedBulletId == bulletId ? null : bulletId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bullets = widget.bullets;
    final callbacks = widget.callbacks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VaultSectionHeading(title: 'Bullets', onAdd: callbacks.onAdd),
        if (bullets.isEmpty) const AppInlineEmptyMessage('No bullets yet.'),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: bullets.length,
          onReorderItem: (oldIndex, newIndex) {
            final ids = bullets.map((b) => b.id).toList();
            final id = ids.removeAt(oldIndex);
            ids.insert(newIndex, id);
            callbacks.onReorder(ids);
          },
          itemBuilder: (context, index) {
            final bullet = bullets[index];
            return Padding(
              key: ValueKey(bullet.id),
              padding: EdgeInsets.only(
                bottom: context.appSpacing.paddingDefault,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 14,
                        right: context.appSpacing.paddingHairline,
                      ),
                      child: const Icon(
                        RemixIcons.draggable,
                        color: kcMediumGrey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Label (optional)',
                          hint: 'e.g. Performance',
                          initialValue: bullet.label ?? '',
                          onChanged: (v) => callbacks.onChanged(
                            bullet.copyWith(label: v.orNullIfEmpty),
                          ),
                        ),
                        const VGap.tiny(),
                        AppTextField(
                          label: 'Text',
                          initialValue: bullet.text,
                          maxLines: 3,
                          onChanged: (v) =>
                              callbacks.onChanged(bullet.copyWith(text: v)),
                        ),
                        const VGap.tiny(),
                        _BulletSkillLinkPicker(
                          bullet: bullet,
                          skillCategories: widget.skillCategories,
                          onUpdateSkill: widget.onUpdateSkill,
                          onAddSkill: widget.onAddSkill,
                          onAddCategory: widget.onAddCategory,
                          expanded: _expandedBulletId == bullet.id,
                          onToggleExpanded: () => _toggleExpanded(bullet.id),
                        ),
                      ],
                    ),
                  ),
                  AppDeleteIconButton(
                    tooltip: 'Delete bullet',
                    onPressed: () => callbacks.onDelete(bullet.id),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// A single bullet's skill links — the primary place to create one (see
/// [BulletListEditor]'s doc comment on [BulletListEditor.skillCategories]).
/// Collapsed by default and filterable, same shape as the Skills panel's
/// own `_SkillBulletLinkPicker` (`skills_editor_panel.dart`) — that one
/// links one skill across many bullets; this one links one bullet across
/// many skills. [expanded]/[onToggleExpanded] are controlled by
/// `_BulletListEditorState`, which keeps at most one of these open per
/// bullet list — see `_BulletListEditorState._expandedBulletId`'s doc
/// comment. Local `_query` is still this widget's own presentation state.
class _BulletSkillLinkPicker extends StatefulWidget {
  const _BulletSkillLinkPicker({
    required this.bullet,
    required this.skillCategories,
    required this.onUpdateSkill,
    required this.onAddSkill,
    required this.onAddCategory,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final CvBullet bullet;
  final List<SkillCategory> skillCategories;
  final void Function(String categoryId, Skill skill) onUpdateSkill;

  /// Backs "Add '{query}' as a new skill" when a search finds nothing —
  /// saves a trip back to the Skills panel just to create a skill that
  /// obviously belongs on this bullet. Returns the created [Skill] so it
  /// can be linked to [bullet] in the same action.
  final Future<Skill> Function(String categoryId, String label) onAddSkill;

  /// Backs the "+ New category" option — a Vault with no categories yet
  /// (or none that fit a brand-new skill) shouldn't force a trip to the
  /// Skills panel just to create one first.
  final Future<SkillCategory> Function(String name) onAddCategory;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  State<_BulletSkillLinkPicker> createState() => _BulletSkillLinkPickerState();
}

class _BulletSkillLinkPickerState extends State<_BulletSkillLinkPicker> {
  /// A value no real category id can equal — Vault ids come from `Uuid`,
  /// never a ` `-prefixed string. Used only as the "+ New category"
  /// dropdown item's value, matched via [_isNewCategoryMode]'s logic.
  static const _newCategorySentinel = ' __new_category__';

  String _query = '';

  /// Same text as [_query], before lowercasing — used wherever the query
  /// is shown back to the user or saved as a new skill's label, so typing
  /// "Kubernetes" doesn't create a skill literally called "kubernetes".
  String _rawQuery = '';

  /// Which existing category a new skill would be added under — defaults
  /// to the first one there is, changeable via the dropdown next to "Add"
  /// for a Vault with more than one. Ignored while [_creatingNewCategory]
  /// is true.
  String? _addToCategoryId;

  /// True once "+ New category" is explicitly picked from the dropdown.
  /// Also treated as true whenever there are no categories at all — see
  /// [_isNewCategoryMode] — since there is nothing else to pick from.
  bool _creatingNewCategory = false;
  String _newCategoryName = '';

  Iterable<Skill> get _allSkills =>
      widget.skillCategories.expand((c) => c.skills);

  /// Backs the collapsed summary line, so a bullet's linked skills can be
  /// read without expanding anything — the read-only "Skills: A, B, C"
  /// text this picker replaced was at least good at that.
  List<Skill> get _linkedSkills => _allSkills
      .where((s) => s.linkedBulletIds.contains(widget.bullet.id))
      .toList();

  List<Skill> _matchingSkills(SkillCategory category) {
    if (_query.isEmpty) return category.skills;
    return category.skills
        .where((s) => s.label.toLowerCase().contains(_query))
        .toList();
  }

  bool get _hasExactMatch =>
      _allSkills.any((s) => s.label.toLowerCase() == _query);

  bool get _isNewCategoryMode =>
      _creatingNewCategory || widget.skillCategories.isEmpty;

  /// The dropdown's current value — an existing category's id, or
  /// [_newCategorySentinel] while [_isNewCategoryMode]. Falls back to the
  /// first category whenever [_addToCategoryId] no longer names a real
  /// one (e.g. that category was deleted elsewhere while this picker
  /// stayed open).
  String get _dropdownValue {
    if (_creatingNewCategory) return _newCategorySentinel;
    final stored = _addToCategoryId;
    if (stored != null && widget.skillCategories.any((c) => c.id == stored)) {
      return stored;
    }
    return widget.skillCategories.isNotEmpty
        ? widget.skillCategories.first.id
        : _newCategorySentinel;
  }

  bool get _canAdd => !_isNewCategoryMode || _newCategoryName.trim().isNotEmpty;

  Future<void> _addAndLinkSkill() async {
    final String categoryId;
    if (_isNewCategoryMode) {
      final category = await widget.onAddCategory(_newCategoryName.trim());
      categoryId = category.id;
    } else {
      categoryId = _dropdownValue;
    }
    final skill = await widget.onAddSkill(categoryId, _rawQuery);
    widget.onUpdateSkill(
      categoryId,
      skill.copyWith(linkedBulletIds: [widget.bullet.id]),
    );
    if (!mounted) return;
    setState(() {
      _creatingNewCategory = false;
      _addToCategoryId = categoryId;
      _newCategoryName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final linked = _linkedSkills;
    final groups = [
      for (final category in widget.skillCategories)
        if (_matchingSkills(category) case final skills when skills.isNotEmpty)
          AppChipGroup(
            label: category.displayName,
            items: [
              for (final skill in skills)
                AppChipGroupItem(
                  id: skill.id,
                  label: skill.label,
                  selected: skill.linkedBulletIds.contains(widget.bullet.id),
                  onToggle: (selected) {
                    final ids = [...skill.linkedBulletIds];
                    if (selected) {
                      ids.add(widget.bullet.id);
                    } else {
                      ids.remove(widget.bullet.id);
                    }
                    widget.onUpdateSkill(
                      category.id,
                      skill.copyWith(linkedBulletIds: ids),
                    );
                  },
                ),
            ],
          ),
    ];

    return LinkPickerShell(
      icon: RemixIcons.star_line,
      // Deliberately the same "Link to …" / "Linked to N …" pair as the
      // Skills panel's own picker: these are one relation seen from its
      // two ends, and symmetric wording is what makes that legible.
      label: linked.isEmpty
          ? 'Link to skills'
          : 'Linked to ${linked.length} skill${linked.length == 1 ? '' : 's'}',
      summary: linked.isEmpty ? null : linked.map((s) => s.label).join(' · '),
      searchHint: 'Search or add a skill…',
      onQueryChanged: (value) => setState(() {
        _rawQuery = value.trim();
        _query = _rawQuery.toLowerCase();
      }),
      expanded: widget.expanded,
      onToggleExpanded: widget.onToggleExpanded,
      children: [
        if (groups.isNotEmpty)
          AppChipGroupSelector(groups: groups)
        else
          AppInlineEmptyMessage(
            _query.isEmpty
                ? 'No skills in your Vault yet.'
                : 'No skills match your search.',
          ),
        if (_query.isNotEmpty && !_hasExactMatch) _buildAddSkill(context),
      ],
    );
  }

  /// The "that skill doesn't exist yet" affordance: a line naming what was
  /// typed, the category it would land in, and one button that creates and
  /// links it. Set off by a divider so picking an existing skill and
  /// minting a new one don't read as one undifferentiated pile of
  /// controls — this block only ever appears when the query matched
  /// nothing exactly, so it's the exception, not part of the main flow.
  Widget _buildAddSkill(BuildContext context) {
    final hasCategories = widget.skillCategories.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: context.appSpacing.gapMedium),
        Text(
          '"$_rawQuery" isn\'t in your Vault yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTypography.caption.copyWith(color: kcLightGrey),
        ),
        const VGap.small(),
        Row(
          children: [
            // With no categories at all there's nothing to choose between,
            // so the name field takes the dropdown's place rather than
            // sitting under a one-option dropdown.
            Expanded(
              child: hasCategories
                  ? _buildCategoryDropdown(context)
                  : _buildNewCategoryField(context),
            ),
            const HGap.small(),
            FilledButton.icon(
              onPressed: _canAdd ? _addAndLinkSkill : null,
              icon: Icon(RemixIcons.add_line, size: context.appIconSize.small),
              label: const Text('Add skill'),
            ),
          ],
        ),
        if (hasCategories && _creatingNewCategory) ...[
          const VGap.small(),
          _buildNewCategoryField(context),
        ],
      ],
    );
  }

  /// An [InputDecorator]-wrapped dropdown rather than a bare
  /// [DropdownButton], so it picks up the same outlined box as every
  /// neighbouring text field instead of being the one underlined control
  /// in the panel.
  Widget _buildCategoryDropdown(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(isDense: true, labelText: 'Category'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dropdownValue,
          isDense: true,
          isExpanded: true,
          items: [
            for (final category in widget.skillCategories)
              DropdownMenuItem(
                value: category.id,
                child: Text(
                  category.displayName,
                  style: context.appTypography.caption,
                ),
              ),
            DropdownMenuItem(
              value: _newCategorySentinel,
              child: Text(
                'New category…',
                style: context.appTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          onChanged: (value) => setState(() {
            _creatingNewCategory = value == _newCategorySentinel;
            if (!_creatingNewCategory) _addToCategoryId = value;
          }),
        ),
      ),
    );
  }

  Widget _buildNewCategoryField(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'New category name',
      ),
      onChanged: (value) => setState(() => _newCategoryName = value.trim()),
    );
  }
}
