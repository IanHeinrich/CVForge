/// Direct tests of a pure text transformation, under the same carve-out
/// as `test/models/render/cv_markup_test.dart`: there is no ViewModel or
/// Service above this, and driving a real `TextField` through a widget
/// test would assert on far less of the actual logic — selection offsets
/// after the edit are the whole point, and they are what a widget test
/// would be least able to see.
library;

import 'package:cv_forge/ui/common/markup/markup_selection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs [marker] over `text` with the given selection and returns what
/// the field ends up holding, written as `text` with the selection marked
/// by `|` — so a case reads as what the user would see.
String _apply(String text, int start, int end, String marker) {
  final controller = TextEditingController(text: text)
    ..selection = TextSelection(baseOffset: start, extentOffset: end);
  wrapSelectionInMarker(controller, marker);
  final v = controller.value;
  final s = v.selection.start;
  final e = v.selection.end;
  return '${v.text.substring(0, s)}|${v.text.substring(s, e)}|'
      '${v.text.substring(e)}';
}

void main() {
  group('wrapSelectionInMarker -', () {
    test('wraps a selected word and keeps it selected', () {
      expect(
        _apply('Led the migration', 4, 7, boldMarker),
        'Led **|the|** migration',
      );
    });

    test('italic uses a single marker', () {
      expect(
        _apply('Led the migration', 4, 7, italicMarker),
        'Led *|the|* migration',
      );
    });

    test('an empty selection leaves the caret between the markers, ready '
        'to type', () {
      expect(
        _apply('Led  migration', 4, 4, boldMarker),
        'Led **||** migration',
      );
    });

    test('a second press unwraps rather than nesting — this is what stops '
        'the buttons producing ****', () {
      // The selection after wrapping is the inner text, so pressing again
      // is exactly this case.
      expect(
        _apply('Led **the** migration', 6, 9, boldMarker),
        'Led |the| migration',
      );
    });

    test('unwraps when the markers sit outside the selection, which is '
        'what double-clicking an already-bold word gives you', () {
      expect(
        _apply('Led **the** migration', 4, 11, boldMarker),
        'Led |the| migration',
      );
    });

    test('wrapping the whole field works at both boundaries', () {
      expect(_apply('everything', 0, 10, boldMarker), '**|everything|**');
    });

    test('bold and italic compose into bold-italic', () {
      final controller = TextEditingController(text: 'Led the migration')
        ..selection = const TextSelection(baseOffset: 4, extentOffset: 7);
      wrapSelectionInMarker(controller, boldMarker);
      wrapSelectionInMarker(controller, italicMarker);
      expect(controller.text, 'Led ***the*** migration');
    });

    test('unwrapping bold from a bold-italic word leaves the italic', () {
      final controller = TextEditingController(text: 'Led ***the*** migration')
        ..selection = const TextSelection(baseOffset: 7, extentOffset: 10);
      // Inner-most pair first: the selection is the bare word.
      wrapSelectionInMarker(controller, italicMarker);
      expect(controller.text, 'Led **the** migration');
    });

    test('italic on a bold word composes rather than stripping a marker — '
        'the case that proves this is a bit toggle, not string surgery', () {
      expect(
        _apply('Led **the** migration', 6, 9, italicMarker),
        'Led ***|the|*** migration',
      );
    });

    test('bold on an italic word composes the other way round', () {
      expect(
        _apply('Led *the* migration', 5, 8, boldMarker),
        'Led ***|the|*** migration',
      );
    });

    test('removing bold from a bold-italic word leaves it italic', () {
      expect(
        _apply('Led ***the*** migration', 7, 10, boldMarker),
        'Led *|the|* migration',
      );
    });

    test('an invalid selection is refused rather than guessed at', () {
      final controller = TextEditingController(text: 'Led the migration');
      expect(wrapSelectionInMarker(controller, boldMarker), isFalse);
      expect(controller.text, 'Led the migration');
    });

    test('wrapping is reversible — the text comes back exactly', () {
      const original = 'Cut p99 latency by 40%';
      final controller = TextEditingController(text: original)
        ..selection = const TextSelection(baseOffset: 4, extentOffset: 15);
      wrapSelectionInMarker(controller, boldMarker);
      expect(controller.text, isNot(original));
      wrapSelectionInMarker(controller, boldMarker);
      expect(controller.text, original);
    });
  });
}
