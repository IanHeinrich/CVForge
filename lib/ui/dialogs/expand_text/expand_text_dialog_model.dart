import 'package:stacked/stacked.dart';

/// Holds what the roomier editor currently says.
///
/// The dialog commits on confirm rather than on every keystroke, unlike
/// the inline fields: this is a deliberate detour into a bigger box, so
/// leaving it by cancelling should leave the field as it was.
class ExpandTextDialogModel extends BaseViewModel {
  ExpandTextDialogModel(this._text);

  String _text;

  String get text => _text;

  void setText(String value) => _text = value;
}
