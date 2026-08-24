import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/ui/common/l10n/month_labels.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// A month-precision date field: a summary row that expands into a year
/// stepper over a grid of months.
///
/// ## Why a grid rather than the two fields it replaces
///
/// This emits a whole [YearMonth] or nothing, so there is no invalid state
/// to reject and no half-typed value to write. That is the argument the
/// month dropdown's own doc comment already made for months — "a closed set
/// has no invalid state and no partial keystroke" — extended to years by
/// construction rather than by validation. It retired three error maps,
/// three error getters and a shared `_yearError` from `VaultViewModel`,
/// along with the three "the user typed 19" states they existed to
/// describe.
///
/// ## Not a dialog
///
/// The Vault autosaves and has no save buttons anywhere, so a modal
/// confirm here would be the only one in the feature. `LinkPickerShell`
/// already established the shape these panels use — a summary row that
/// expands in place — and this follows it.
///
/// Month labels come from the app's own translations, not from
/// `YearMonth.monthName`. The picker stores a month *number*, so its labels
/// are chrome: a Spanish reader sees "sept" while their German CV still
/// prints "Sept.". See [monthLabel].
class YearMonthPicker extends StatefulWidget {
  const YearMonthPicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onCleared,
    this.initialYearWhenEmpty,
    this.minYear = 1900,
    this.maxYear = 2100,
  });

  final String label;

  /// Null renders the empty placeholder.
  final YearMonth? value;

  final ValueChanged<YearMonth> onChanged;

  /// Null means the date is not clearable, which is the case for an
  /// experience's start.
  final VoidCallback? onCleared;

  /// Which year the grid opens on when [value] is null.
  ///
  /// An experience's *end* seeds from the current year rather than from
  /// its start — adopting the start year produces a plausible-looking but
  /// silently wrong end date the moment only the month is set afterwards.
  /// That reasoning moved here from `VaultViewModel`; it did not go away.
  final int? initialYearWhenEmpty;

  final int minYear;
  final int maxYear;

  @override
  State<YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  bool _open = false;
  bool _pickingYear = false;
  late int _shownYear = _initialYear;

  int get _initialYear =>
      widget.value?.year ?? widget.initialYearWhenEmpty ?? DateTime.now().year;

  /// Twelve years to a page, so the grid is the same 3x4 shape as the
  /// months and a decade is one tap away rather than twelve.
  static const _yearsPerPage = 12;

  int get _yearPageStart {
    final offset = (_shownYear - widget.minYear) ~/ _yearsPerPage;
    return widget.minYear + offset * _yearsPerPage;
  }

  void _toggle() => setState(() {
    _open = !_open;
    if (_open) {
      _shownYear = _initialYear;
      _pickingYear = false;
    }
  });

  void _pick(int month) {
    widget.onChanged(YearMonth(year: _shownYear, month: month));
    setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(context.appRadius.small),
          child: InputDecorator(
            decoration: InputDecoration(labelText: widget.label, isDense: true),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null
                        ? context.l10n.vaultYearMonthEmpty
                        : '${monthLabel(context.l10n, value.month)} '
                              '${value.year}',
                    style: context.appTypography.bodySmall.copyWith(
                      color: value == null
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                  ),
                ),
                if (value != null && widget.onCleared != null)
                  IconButton(
                    onPressed: () {
                      widget.onCleared!();
                      setState(() => _open = false);
                    },
                    icon: Icon(
                      RemixIcons.close_line,
                      size: context.appIconSize.small,
                    ),
                    tooltip: context.l10n.vaultYearMonthClear,
                    visualDensity: VisualDensity.compact,
                  ),
                Icon(
                  _open
                      ? RemixIcons.arrow_up_s_line
                      : RemixIcons.arrow_down_s_line,
                  size: context.appIconSize.small,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_open) ...[
          SizedBox(height: context.appSpacing.gapTiny),
          Container(
            padding: EdgeInsets.all(context.appSpacing.paddingCompact),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(context.appRadius.medium),
            ),
            child: Column(
              children: [
                _Header(
                  pickingYear: _pickingYear,
                  shownYear: _shownYear,
                  pageStart: _yearPageStart,
                  yearsPerPage: _yearsPerPage,
                  onPrevious: () => setState(() {
                    _shownYear = _pickingYear
                        ? (_shownYear - _yearsPerPage).clamp(
                            widget.minYear,
                            widget.maxYear,
                          )
                        : (_shownYear - 1).clamp(
                            widget.minYear,
                            widget.maxYear,
                          );
                  }),
                  onNext: () => setState(() {
                    _shownYear = _pickingYear
                        ? (_shownYear + _yearsPerPage).clamp(
                            widget.minYear,
                            widget.maxYear,
                          )
                        : (_shownYear + 1).clamp(
                            widget.minYear,
                            widget.maxYear,
                          );
                  }),
                  onToggleMode: () =>
                      setState(() => _pickingYear = !_pickingYear),
                ),
                SizedBox(height: context.appSpacing.gapTiny),
                if (_pickingYear)
                  _Grid(
                    cells: [
                      for (var i = 0; i < _yearsPerPage; i++)
                        if (_yearPageStart + i <= widget.maxYear)
                          _Cell(
                            label: '${_yearPageStart + i}',
                            selected: _yearPageStart + i == value?.year,
                            onTap: () => setState(() {
                              _shownYear = _yearPageStart + i;
                              _pickingYear = false;
                            }),
                          ),
                    ],
                  )
                else
                  _Grid(
                    cells: [
                      for (var month = 1; month <= 12; month++)
                        _Cell(
                          label: monthLabel(context.l10n, month),
                          selected:
                              value != null &&
                              value.month == month &&
                              value.year == _shownYear,
                          onTap: () => _pick(month),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A year-only field, for Education — the same grid with the month step
/// removed.
///
/// Education keeps a bare `int?` rather than being promoted to
/// [YearMonth]: a CV prints the year alone, and `withoutBlankEntries`
/// tests `year == null` as part of its blank predicate. What it gains is
/// a real clear affordance, which its old "empty is valid" text field
/// only ever implied.
class YearField extends StatefulWidget {
  const YearField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onCleared,
    this.minYear = 1900,
    this.maxYear = 2100,
  });

  final String label;
  final int? value;
  final ValueChanged<int> onChanged;
  final VoidCallback onCleared;
  final int minYear;
  final int maxYear;

  @override
  State<YearField> createState() => _YearFieldState();
}

class _YearFieldState extends State<YearField> {
  bool _open = false;
  late int _shownYear = widget.value ?? DateTime.now().year;

  static const _yearsPerPage = 12;

  int get _pageStart {
    final offset = (_shownYear - widget.minYear) ~/ _yearsPerPage;
    return widget.minYear + offset * _yearsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() {
            _open = !_open;
            if (_open) _shownYear = value ?? DateTime.now().year;
          }),
          borderRadius: BorderRadius.circular(context.appRadius.small),
          child: InputDecorator(
            decoration: InputDecoration(labelText: widget.label, isDense: true),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value?.toString() ?? context.l10n.vaultYearMonthEmpty,
                    style: context.appTypography.bodySmall.copyWith(
                      color: value == null
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                  ),
                ),
                if (value != null)
                  IconButton(
                    onPressed: () {
                      widget.onCleared();
                      setState(() => _open = false);
                    },
                    icon: Icon(
                      RemixIcons.close_line,
                      size: context.appIconSize.small,
                    ),
                    tooltip: context.l10n.vaultYearMonthClear,
                    visualDensity: VisualDensity.compact,
                  ),
                Icon(
                  _open
                      ? RemixIcons.arrow_up_s_line
                      : RemixIcons.arrow_down_s_line,
                  size: context.appIconSize.small,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_open) ...[
          SizedBox(height: context.appSpacing.gapTiny),
          Container(
            padding: EdgeInsets.all(context.appSpacing.paddingCompact),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(context.appRadius.medium),
            ),
            child: Column(
              children: [
                _Header(
                  pickingYear: true,
                  shownYear: _shownYear,
                  pageStart: _pageStart,
                  yearsPerPage: _yearsPerPage,
                  onPrevious: () => setState(() {
                    _shownYear = (_shownYear - _yearsPerPage).clamp(
                      widget.minYear,
                      widget.maxYear,
                    );
                  }),
                  onNext: () => setState(() {
                    _shownYear = (_shownYear + _yearsPerPage).clamp(
                      widget.minYear,
                      widget.maxYear,
                    );
                  }),
                  // The month/year toggle has nothing to toggle to here.
                  onToggleMode: null,
                ),
                SizedBox(height: context.appSpacing.gapTiny),
                _Grid(
                  cells: [
                    for (var i = 0; i < _yearsPerPage; i++)
                      if (_pageStart + i <= widget.maxYear)
                        _Cell(
                          label: '${_pageStart + i}',
                          selected: _pageStart + i == value,
                          onTap: () {
                            widget.onChanged(_pageStart + i);
                            setState(() => _open = false);
                          },
                        ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.pickingYear,
    required this.shownYear,
    required this.pageStart,
    required this.yearsPerPage,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleMode,
  });

  final bool pickingYear;
  final int shownYear;
  final int pageStart;
  final int yearsPerPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Null where there is nothing to switch to — see [YearField].
  final VoidCallback? onToggleMode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: Icon(
            RemixIcons.arrow_left_s_line,
            size: context.appIconSize.small,
          ),
          tooltip: pickingYear
              ? l10n.vaultYearMonthPreviousYears
              : l10n.vaultYearMonthPreviousYear,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: TextButton(
            onPressed: onToggleMode,
            child: Text(
              pickingYear
                  ? '$pageStart–${pageStart + yearsPerPage - 1}'
                  : '$shownYear',
              style: context.appTypography.titleSmall,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(
            RemixIcons.arrow_right_s_line,
            size: context.appIconSize.small,
          ),
          tooltip: pickingYear
              ? l10n.vaultYearMonthNextYears
              : l10n.vaultYearMonthNextYear,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

/// A 3-wide grid. Fixed rather than responsive: twelve cells of a month
/// abbreviation are legible at every width these panels are given, and a
/// column count that changed with the panel would move the cells under the
/// user's finger as the editor pane animates open.
class _Grid extends StatelessWidget {
  const _Grid({required this.cells});

  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: context.appSpacing.gapTiny,
      crossAxisSpacing: context.appSpacing.gapTiny,
      childAspectRatio: 2.4,
      children: cells,
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(context.appRadius.small),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.appRadius.small),
        child: Center(
          child: Text(
            label,
            style: context.appTypography.bodySmall.copyWith(
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}
