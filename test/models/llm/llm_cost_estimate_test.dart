import 'package:cv_forge/models/llm/llm_cost_estimate.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';
import 'package:flutter_test/flutter_test.dart';

/// A pure pricing calculation with no ViewModel or Service of its own to
/// test through — the same carve-out from outside-in testing that
/// `ats_matrix_math_test.dart` documents.
void main() {
  // $3 per million in, $15 per million out — Sonnet's real rates.
  const model = LlmModelOption(
    id: 'claude-sonnet-5',
    label: 'Sonnet',
    inputPricePerMTok: 3,
    outputPricePerMTok: 15,
  );

  group('LlmCostEstimateTest -', () {
    test('prices input and output at their own rates', () {
      // 4M chars is 1M tokens at four characters each.
      final cents = estimatedCentsFor(
        model: model,
        inputChars: 4000000,
        expectedOutputChars: 4000000,
      );

      // $3 + $15 = $18 = 1800 cents.
      expect(cents, closeTo(1800, 0.001));
    });

    test('output costs more than the same amount of input, which is why a '
        'translation is dearer than its request length suggests', () {
      final inputHeavy = estimatedCentsFor(
        model: model,
        inputChars: 40000,
        expectedOutputChars: 0,
      );
      final outputHeavy = estimatedCentsFor(
        model: model,
        inputChars: 0,
        expectedOutputChars: 40000,
      );

      expect(outputHeavy, greaterThan(inputHeavy));
    });

    test('a realistic CV-sized pass costs a few cents, not pounds — the '
        'figure exists to reassure, so it had better be in the right '
        'order of magnitude', () {
      // ~30k characters each way is a full CV translated.
      final cents = estimatedCentsFor(
        model: model,
        inputChars: 30000,
        expectedOutputChars: 30000,
      );

      expect(cents, greaterThan(0));
      expect(cents, lessThan(50));
    });

    test('rounds to whole cents for display', () {
      expect(displayCents(3.4), 3);
      expect(displayCents(3.6), 4);
    });

    test('anything under a cent displays as zero, so the copy can say '
        '"under 1¢" rather than rounding a real cost down to free', () {
      expect(displayCents(0.9), 0);
      expect(displayCents(0.01), 0);
    });
  });
}
