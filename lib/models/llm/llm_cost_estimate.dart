import 'package:cv_forge/models/llm/llm_model_option.dart';

/// Characters per token, near enough for an estimate.
///
/// Real tokenizers are provider-specific and are not available to us
/// client-side, so this is the standard rule of thumb for English prose.
/// It runs slightly optimistic on text with many short words and
/// slightly pessimistic on long compounds — which is one reason the
/// figure this produces is presented as approximate rather than exact.
const _charsPerToken = 4;

/// What one pass will cost, in **US cents**.
///
/// US cents rather than pence deliberately: both providers price and bill
/// in USD, so this is the number that will appear on the user's invoice.
/// Converting would need an exchange rate the app has no way to keep
/// current, and would produce a figure that quietly stops matching the
/// bill it is meant to predict.
///
/// An estimate, and honest about it. Token counts are inferred from
/// character counts, and the output length is a guess about how a model
/// will answer. It exists so spending is visible before the user commits
/// rather than only afterwards — see [LlmModelOption], whose prices are
/// shipped as constants for the same reason.
double estimatedCentsFor({
  required LlmModelOption model,
  required int inputChars,
  required int expectedOutputChars,
}) {
  final inputTokens = inputChars / _charsPerToken;
  final outputTokens = expectedOutputChars / _charsPerToken;
  // Prices are dollars per million tokens; ×100 turns dollars into cents.
  final dollars =
      (inputTokens * model.inputPricePerMTok +
          outputTokens * model.outputPricePerMTok) /
      1000000;
  return dollars * 100;
}

/// [cents] rounded for display, where 0 means "less than a cent" and the
/// copy says so rather than claiming a run is free.
int displayCents(double cents) => cents < 1 ? 0 : cents.round();
