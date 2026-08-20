import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft_index.freezed.dart';
part 'draft_index.g.dart';

/// The manifest [DraftService] persists alongside every individual
/// [CvDraft] — which draft ids exist, in what order, and which one is
/// currently open. Kept separate from the drafts themselves so opening or
/// reordering drafts never requires rewriting every draft's own JSON, and
/// so a single corrupted draft entry can be dropped without losing the
/// index of the others (see `DraftService.loadFromStorage`).
@freezed
abstract class DraftIndex with _$DraftIndex {
  const factory DraftIndex({
    required int schemaVersion,
    @Default(<String>[]) List<String> draftIds,
    String? activeDraftId,
  }) = _DraftIndex;

  factory DraftIndex.fromJson(Map<String, dynamic> json) =>
      _$DraftIndexFromJson(json);

  factory DraftIndex.empty() =>
      const DraftIndex(schemaVersion: 1, draftIds: [], activeDraftId: null);
}
