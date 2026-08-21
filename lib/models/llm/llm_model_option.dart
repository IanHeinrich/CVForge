import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_model_option.freezed.dart';

/// One selectable model for a given [LlmProvider] — id, a display label,
/// and per-token pricing so the Copilot UI can show real cost rather than
/// leaving spend implicit. Rates are a `const` value the provider ships
/// with, not fetched — see [LlmProvider.models]' own doc comment for the
/// "label it with the date it was checked" caveat.
@freezed
abstract class LlmModelOption with _$LlmModelOption {
  const factory LlmModelOption({
    required String id,
    required String label,
    required double inputPricePerMTok,
    required double outputPricePerMTok,
  }) = _LlmModelOption;
}
