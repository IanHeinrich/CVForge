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
