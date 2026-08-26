/// What an [ExpandTextDialog] opens on, and what it hands back.
///
/// A record rather than a `@freezed` class, matching the other dialog
/// payloads here: it exists for the width of one call and never reaches
/// storage, JSON, or app state.
typedef ExpandTextDialogData = ({String label, String text, bool markup});
