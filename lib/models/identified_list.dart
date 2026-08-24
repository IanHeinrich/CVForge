/// Small helpers for the "operate on the list element whose id matches"
/// shape that recurs across every Vault entity list (experiences,
/// projects, skills, education, …) and the Vault editor panel router.
/// [idOf] stays an explicit callback rather than an `Identifiable`
/// interface — every entity already carries a `String id` field, but none
/// currently implement a shared interface for it, and adding one to every
/// freezed model is a bigger change than this extension needs.
extension IdentifiedList<T> on List<T> {
  /// The item whose [idOf] matches [id], or `null` if none does (including
  /// when [id] itself is `null`).
  T? findById(String? id, String Function(T item) idOf) {
    for (final item in this) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  /// Replaces the item whose [idOf] matches [id] with [replacement],
  /// leaving every other item and the list order untouched.
  List<T> replaceById(String id, T replacement, String Function(T item) idOf) =>
      [
        for (final item in this)
          if (idOf(item) == id) replacement else item,
      ];

  /// Drops the item whose [idOf] matches [id].
  List<T> removeById(String id, String Function(T item) idOf) =>
      where((item) => idOf(item) != id).toList();

  /// Applies [update] to the single item whose [idOf] matches [id],
  /// leaving every other item untouched. The general form of
  /// [replaceById] for callers that need to derive the replacement from
  /// the current item rather than supplying it outright.
  List<T> updateById(
    String id,
    T Function(T current) update,
    String Function(T item) idOf,
  ) => [
    for (final item in this)
      if (idOf(item) == id) update(item) else item,
  ];

  /// Reorders this list to match [orderedIds], dropping any id in
  /// [orderedIds] that no item's [idOf] matches. Used wherever a
  /// drag-reorder hands back an ordered id list rather than an ordered
  /// item list.
  List<T> reorderByIds(List<String> orderedIds, String Function(T item) idOf) {
    final byId = {for (final item in this) idOf(item): item};
    return [for (final id in orderedIds) ?byId[id]];
  }
}

/// The three-way merge used by Drive sync, kept here because it's the same
/// "operate on the list element whose id matches" shape as [IdentifiedList]
/// and shares its explicit-[idOf] convention.
///
/// Separate extension only because it needs `T extends Object` — the merge
/// uses `T?` internally to mean "this id didn't survive", which would be
/// ambiguous if `T` were itself nullable.
extension IdentifiedListMerge<T extends Object> on List<T> {
  /// Three-way merges [local] and [remote] against `this` — the common
  /// ancestor both sides last agreed on — keying every element by [idOf].
  ///
  /// The ancestor is what makes deletes work at all. Without it, an id
  /// present on one side only is ambiguous ("added there" vs "deleted
  /// here"), and a plain union would resurrect every deleted record. See
  /// `cv_backup_merge.dart` for where the ancestor comes from.
  ///
  /// | in base | in local | in remote | outcome |
  /// |---|---|---|---|
  /// | — | ✓ | — | keep local (added here) |
  /// | — | — | ✓ | keep remote (added there) |
  /// | — | ✓ | ✓ | contested |
  /// | ✓ | — | — | drop (deleted on both) |
  /// | ✓ | ✓ | — | unchanged locally → drop. Else keep local |
  /// | ✓ | — | ✓ | unchanged remotely → drop. Else keep remote |
  /// | ✓ | ✓ | ✓ | equal → either · one side unchanged → the other · else contested |
  ///
  /// **Edit beats delete** is deliberate, and it's the pair of rows that
  /// matters most: an entry edited on one device and deleted on the other
  /// survives. The failure this app can live with is "a deleted job came
  /// back, delete it again"; the one it can't is "the paragraph I typed is
  /// gone".
  ///
  /// A contested element (both sides changed it since the ancestor) goes to
  /// [mergeItem] if given, else to whichever side [preferRemote] picks.
  /// [preferRemote] is a predicate rather than a flag so a caller with
  /// per-element timestamps can decide per element, while one with only an
  /// aggregate timestamp returns the same answer every time. Both callbacks
  /// take a nullable base: an id on both sides but absent from the ancestor
  /// has no ancestral version to merge against.
  ///
  /// Ordering is itself three-way — the side that reordered wins, and
  /// elements unique to the losing side splice in beside whichever
  /// neighbour they had there. Drag-reorder is a first-class Vault
  /// gesture, so a merge that silently reverted one would read as lost
  /// work.
  List<T> mergeThreeWay(
    List<T> local,
    List<T> remote, {
    required String Function(T item) idOf,
    required bool Function(T? base, T local, T remote) preferRemote,
    T Function(T? base, T local, T remote)? mergeItem,
  }) {
    final baseById = {for (final item in this) idOf(item): item};
    final localById = {for (final item in local) idOf(item): item};
    final remoteById = {for (final item in remote) idOf(item): item};

    final survivors = <String, T>{};
    for (final id in {...localById.keys, ...remoteById.keys}) {
      final b = baseById[id];
      final l = localById[id];
      final r = remoteById[id];

      final T? winner;
      if (l != null && r != null) {
        winner = l == r
            ? l
            : l == b
            ? r
            : r == b
            ? l
            : mergeItem?.call(b, l, r) ?? (preferRemote(b, l, r) ? r : l);
      } else if (l != null) {
        winner = l == b ? null : l;
      } else if (r != null) {
        winner = r == b ? null : r;
      } else {
        winner = null;
      }
      if (winner != null) survivors[id] = winner;
    }

    final baseIds = [for (final item in this) idOf(item)];
    final localIds = [for (final item in local) idOf(item)];
    final remoteIds = [for (final item in remote) idOf(item)];
    final followRemote =
        !_reordered(baseIds, localIds) && _reordered(baseIds, remoteIds);
    final spineIds = followRemote ? remoteIds : localIds;
    final otherIds = followRemote ? localIds : remoteIds;

    final spineIdSet = spineIds.toSet();
    final ordered = [
      for (final id in spineIds)
        if (survivors.containsKey(id)) id,
    ];
    for (var i = 0; i < otherIds.length; i++) {
      final id = otherIds[i];
      if (!survivors.containsKey(id) || ordered.contains(id)) continue;
      var at = ordered.length;
      String? anchorId;
      for (var j = i - 1; j >= 0; j--) {
        final anchor = ordered.indexOf(otherIds[j]);
        if (anchor >= 0) {
          at = anchor + 1;
          anchorId = otherIds[j];
          break;
        }
      }
      if (anchorId == null) {
        // Nothing it followed survived, so fall back to what it came
        // *before*. Only when neither neighbour is placeable — the two
        // sides share no elements at all — is there genuinely no evidence,
        // and then it appends rather than jumping the spine's own items.
        for (var j = i + 1; j < otherIds.length; j++) {
          final successor = ordered.indexOf(otherIds[j]);
          if (successor >= 0) {
            at = successor;
            break;
          }
        }
      }
      // When both sides appended after the same existing element there's
      // no ordering evidence either way, so the spine's own additions keep
      // their place and this one joins after them. Chaining off another
      // newcomer is different — that ordering *is* evidence, and the run
      // has to stay contiguous, so don't skip in that case.
      if (anchorId != null && spineIdSet.contains(anchorId)) {
        while (at < ordered.length && spineIdSet.contains(ordered[at])) {
          at++;
        }
      }
      ordered.insert(at, id);
    }
    return [for (final id in ordered) survivors[id]!];
  }
}

/// Whether [sideIds] moved any of the ids it shares with [baseIds] relative
/// to each other. Compares only the shared subsequence, so an add or a
/// delete on its own never reads as a reorder.
bool _reordered(List<String> baseIds, List<String> sideIds) {
  final sideSet = sideIds.toSet();
  final baseSet = baseIds.toSet();
  final inSide = [
    for (final id in sideIds)
      if (baseSet.contains(id)) id,
  ];
  final inBase = [
    for (final id in baseIds)
      if (sideSet.contains(id)) id,
  ];
  if (inSide.length != inBase.length) return false;
  for (var i = 0; i < inSide.length; i++) {
    if (inSide[i] != inBase[i]) return true;
  }
  return false;
}
