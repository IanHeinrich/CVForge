/// The rule for when an open editor shows the Vault's own wording.
///
/// Tested through [InlineTextOverrideEditor]'s public surface rather than
/// by pumping the widget: the decision is the whole behaviour, and a
/// widget test would assert on the presence of a string while saying
/// nothing about the three cases where showing it would be noise.
library;

import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';
import 'package:cv_forge/features/studio/widgets/tailoring_controls.dart';
import 'package:flutter_test/flutter_test.dart';

InlineTextOverrideEditor _editor({
  required bool hasOverride,
  required String effectiveText,
  String? vaultText,
}) => InlineTextOverrideEditor(
  field: TailorableField(
    hasOverride: hasOverride,
    effectiveText: effectiveText,
    vaultText: vaultText,
    onChanged: (_) async {},
    onRevert: () async {},
  ),
  onDone: () {},
);

void main() {
  group('InlineTextOverrideEditor - the Vault original -', () {
    test('is shown when this CV says something else', () {
      expect(
        _editor(
          hasOverride: true,
          effectiveText: 'Staff Engineer',
          vaultText: 'Senior Platform Engineer',
        ).vaultOriginal,
        'Senior Platform Engineer',
      );
    });

    test('is not shown for a field that has not been tailored — there is '
        'nothing to diverge from yet', () {
      expect(
        _editor(
          hasOverride: false,
          effectiveText: 'Senior Platform Engineer',
          vaultText: 'Senior Platform Engineer',
        ).vaultOriginal,
        isNull,
      );
    });

    test('is not shown when the Vault has nothing to say', () {
      expect(
        _editor(
          hasOverride: true,
          effectiveText: 'Staff Engineer',
          vaultText: null,
        ).vaultOriginal,
        isNull,
      );
      expect(
        _editor(
          hasOverride: true,
          effectiveText: 'Staff Engineer',
          vaultText: '   ',
        ).vaultOriginal,
        isNull,
      );
    });

    test('is not shown when the override happens to match the Vault — '
        'printing the same sentence twice is noise, not context', () {
      expect(
        _editor(
          hasOverride: true,
          effectiveText: 'Senior Platform Engineer',
          vaultText: 'Senior Platform Engineer',
        ).vaultOriginal,
        isNull,
      );
    });

    test('keeps the Vault wording verbatim, markers included — it is drawn '
        'through the markup renderer, so it reads as the CV would print '
        'it rather than as raw text', () {
      expect(
        _editor(
          hasOverride: true,
          effectiveText: 'Staff Engineer',
          vaultText: '**Senior** Platform Engineer',
        ).vaultOriginal,
        '**Senior** Platform Engineer',
      );
    });
  });
}
