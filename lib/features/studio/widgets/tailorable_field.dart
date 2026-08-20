/// The value bundle backing one entity-scoped tailorable field — a
/// bullet's own text, or one education entry's `details`. Same read-only-
/// until-tailored, never-a-spurious-override contract as
/// `StudioFieldOverrideCard`'s page-level fields (headline, summary,
/// references), just shaped for a field that belongs to a specific Vault
/// entity rather than the whole draft — see `StudioViewModel`'s "text
/// overrides" section for where [onChanged]/[onRevert] ultimately lead.
class TailorableField {
  const TailorableField({
    required this.hasOverride,
    required this.effectiveText,
    required this.onChanged,
    required this.onRevert,
    this.emptyMessage,
    this.fieldLabel,
  });

  final bool hasOverride;
  final String effectiveText;
  final Future<void> Function(String value) onChanged;
  final Future<void> Function() onRevert;

  /// Shown instead of [effectiveText] when there's genuinely nothing yet
  /// — only ever set for Education details, since a bullet always has
  /// Vault text to fall back to.
  final String? emptyMessage;

  /// The editor's field label — a bullet's own `CvBullet.label` when it
  /// has one (e.g. "STAR: Led..."), so it's explicit that only the body
  /// is being rewritten here, not the structural label alongside it.
  /// `CvBullet`'s doc comment is the source of that distinction; this is
  /// just surfacing it at the point of editing. Null for Education
  /// details, which has no comparable structural label.
  final String? fieldLabel;
}

/// Icon size shared by every icon in a tailorable row (see
/// `TailorIconButtons`), so nothing needs to be measured against anything
/// else to line up.
const double kdTailorIconSize = 18;

/// Left inset that lines an inline editor up with a dense
/// `CheckboxListTile`'s *title* rather than its leading checkbox (see
/// `InlineTextOverrideEditor`'s call sites). Without it the editor hangs
/// further left than the row that opened it and reads as belonging to the
/// whole group instead of that one row. Measured against the rendered
/// tile (leading checkbox + its gap, minus the text field's own content
/// padding) rather than derived — Material doesn't expose the dense
/// tile's leading width as a constant.
const double kdCheckboxTitleInset = 52;
