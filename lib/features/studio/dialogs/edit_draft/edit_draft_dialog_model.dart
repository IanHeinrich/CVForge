import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';

import 'edit_draft_dialog_data.dart';

/// Backs [EditDraftDialog] — a name (required) and free-text notes
/// (optional) editor shared by "New CV" and "Rename/edit notes", so the
/// two flows can't drift on validation or field behaviour.
class EditDraftDialogModel extends BaseViewModel {
  EditDraftDialogModel({required EditDraftDialogData initial})
    : nameController = TextEditingController(text: initial.name),
      notesController = TextEditingController(text: initial.notes);

  final TextEditingController nameController;
  final TextEditingController notesController;

  /// Which document noun the Vault's default region uses — `cv` or
  /// `resume` — as an ICU `select` branch id, not a display word.
  ///
  /// The same source `DraftsListViewModel` and `AppChrome` read, so this
  /// dialog's field copy never disagrees with the "New CV"/"New Résumé"
  /// button that opened it. The Vault's default rather than the edited
  /// draft's own region: [EditDraftDialogData] carries no region, and a
  /// name/notes editor is not worth plumbing one through for.
  ///
  /// Deliberately not an inflected English string: a translated sentence
  /// cannot have a foreign noun interpolated into it and stay grammatical,
  /// so each message spells out its own branches. See CLAUDE.md's
  /// Localization section.
  String get documentNoun => locator<VaultService>()
      .vault
      .documentDefaults
      .region
      .preset
      .documentNoun
      .name;

  bool _nameTouched = false;

  bool get _nameIsEmpty => nameController.text.trim().isEmpty;

  /// Only shown once the user has actually touched the field — flagging an
  /// empty name on first paint (before they've typed anything) reads as
  /// broken, not helpful.
  bool get showNameError => _nameTouched && _nameIsEmpty;

  void onNameChanged(String _) {
    _nameTouched = true;
    notifyListeners();
  }

  /// Validates and returns the confirmed data, or `null` (after flagging
  /// the error) if the name is blank.
  EditDraftDialogData? submit() {
    if (_nameIsEmpty) {
      _nameTouched = true;
      notifyListeners();
      return null;
    }
    return EditDraftDialogData(
      name: nameController.text.trim(),
      notes: notesController.text.trim(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
