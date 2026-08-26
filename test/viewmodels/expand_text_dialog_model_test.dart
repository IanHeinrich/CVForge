import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/ui/dialogs/expand_text/expand_text_dialog_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ExpandTextDialogModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    test('opens on the text it was given', () {
      expect(ExpandTextDialogModel('Cut p99 latency').text, 'Cut p99 latency');
    });

    test('keeps what was typed, so confirming hands back the edit', () {
      final model = ExpandTextDialogModel('Cut p99 latency')
        ..setText('Cut p99 latency by 40%');

      expect(model.text, 'Cut p99 latency by 40%');
    });

    test('holds the edit rather than publishing it — the field this was '
        'opened from must be unchanged until Save, so cancelling out of a '
        'roomier box leaves the original wording alone', () {
      final model = ExpandTextDialogModel('Cut p99 latency');
      var published = 0;
      model.addListener(() => published++);

      model.setText('Something else entirely');

      expect(published, isZero);
    });
  });
}
