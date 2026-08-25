/// One printed field of a Vault entity, as Studio's editor pane shows it.
///
/// Every row in that pane answers the same question — *is this value the
/// Vault's, or this CV's?* — so there is one type for the answer, with a
/// case per answer it can give. Adding a third case would be adding a
/// third answer, which is the point: a field that isn't editable here is
/// not the absence of a row, it's a row that says so.
///
/// A plain sealed class rather than a `@freezed` union, unlike the models
/// in `lib/models/`: these carry callbacks, not data, so they have no
/// meaningful equality, no JSON, and nothing to `copyWith`. The freezed
/// convention is for things that represent app state; this represents a
/// widget's arguments.
sealed class StudioEntryField {
  const StudioEntryField({this.fieldLabel, this.emptyMessage});

  /// The row's own label — which field this is. Null for a row that is
  /// the only one on its entry, or whose entry's title already names it.
  final String? fieldLabel;

  /// Shown instead of [displayText] when there is genuinely nothing yet
  /// — only ever set for a field the Vault can legitimately leave blank,
  /// like Education details.
  final String? emptyMessage;

  /// What this CV prints for this field, whatever the source.
  String get displayText;

  /// Whether this CV currently says something different from the Vault.
  /// Always false for a [VaultOnlyField] — it can't.
  bool get hasOverride;
}

/// A field this CV can say something different about. The override lives
/// on the draft; the Vault's own value is what it falls back to.
///
/// Same read-only-until-tailored, never-a-spurious-override contract as
/// `StudioFieldOverrideCard`'s page-level fields (headline, summary,
/// references), just shaped for a field that belongs to a specific Vault
/// entity rather than the whole draft — see `StudioViewModel`'s "text
/// overrides" section for where [onChanged]/[onRevert] ultimately lead.
final class TailorableField extends StudioEntryField {
  const TailorableField({
    required this.hasOverride,
    required this.effectiveText,
    required this.onChanged,
    required this.onRevert,
    super.emptyMessage,
    super.fieldLabel,
  });

  @override
  final bool hasOverride;
  final String effectiveText;
  final Future<void> Function(String value) onChanged;
  final Future<void> Function() onRevert;

  @override
  String get displayText => effectiveText;
}

/// A field that prints from the Vault and cannot be rewritten for one
/// CV, rendered as a row that says which field it is, what it says, and
/// — on the lock — *why* it's fixed.
///
/// This case exists because the alternative was worse: these values used
/// to appear as an inert subtitle with no affordance, visually identical
/// to a field nobody had wired up yet. There was no way to tell "fixed on
/// purpose" from "forgotten", which is most of why the pane read as
/// inconsistent.
///
/// [reason] is user-facing copy, so it belongs to the call site that
/// knows the actual reason — an employment check tests dates, a reader
/// finds a paper by its title — never a generic "not editable".
final class VaultOnlyField extends StudioEntryField {
  const VaultOnlyField({
    required this.value,
    required this.reason,
    super.fieldLabel,
    this.omitted = false,
    this.onToggleOmitted,
  });

  final String value;

  /// Why this field's *wording* is fixed. Shown on the lock. Still true
  /// for a field that can be dropped — "you can't say something else
  /// here" and "you can leave it off" are different claims.
  final String reason;

  /// Whether this CV drops the field entirely. Only meaningful alongside
  /// [onToggleOmitted]; a field with no way to drop it is never omitted.
  final bool omitted;

  /// Drops the field from this CV, or puts it back. Null — the default —
  /// is a field that always prints, and renders no action at all.
  ///
  /// This is the affordance [DraftOmittableField] exists for: a link or a
  /// graduation year can't be rewritten for one application without
  /// saying something untrue, but leaving it off is an ordinary choice.
  final Future<void> Function()? onToggleOmitted;

  @override
  String get displayText => value;

  @override
  bool get hasOverride => false;
}

/// Glyph size shared by every icon in an entry field row (see
/// `TailorIconButtons`), so nothing needs to be measured against anything
/// else to line up.
const double kdTailorIconSize = 20;

/// The square each of those glyphs is centred in, and what makes the two
/// buttons in the cluster actually clickable.
///
/// `IconButton`'s own default reserves a ~40dp box regardless of the
/// glyph's size, which in a dense row left obvious dead space around a
/// small glyph; collapsing it to the glyph itself (`padding: zero` plus
/// unbounded `constraints`) fixed the spacing but left a target barely
/// bigger than the ink. This is the middle: comfortably bigger than the
/// glyph, still short enough not to set the height of a two-line caption
/// row.
const double kdTailorHitSize = 32;

/// Gap between the two slots in that cluster.
const double kdTailorIconGap = 4;

/// Left inset that lines an inline editor up with a dense
/// `CheckboxListTile`'s *title* rather than its leading checkbox (see
/// `InlineTextOverrideEditor`'s call sites). Without it the editor hangs
/// further left than the row that opened it and reads as belonging to the
/// whole group instead of that one row. Measured against the rendered
/// tile (leading checkbox + its gap, minus the text field's own content
/// padding) rather than derived — Material doesn't expose the dense
/// tile's leading width as a constant.
const double kdCheckboxTitleInset = 52;
