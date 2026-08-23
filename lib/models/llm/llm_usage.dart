import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_usage.freezed.dart';

/// Token counts reported back by [LlmProvider.completeJson]'s response —
/// the input for the per-run spend display (`usage.inputTokens *
/// LlmModelOption.inputPricePerMTok / 1e6`, plus the output side). Not
/// persisted: a Copilot run's cost is shown once, live, never stored.
@freezed
abstract class LlmUsage with _$LlmUsage {
  const factory LlmUsage({
    required int inputTokens,
    required int outputTokens,
  }) = _LlmUsage;
}
