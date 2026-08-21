import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/llm/llm_usage.dart';

part 'llm_json_response.freezed.dart';

/// What [LlmProvider.completeJson] hands back: the parsed JSON payload
/// (validated against the [JsonSchema] the caller supplied) plus the
/// token usage for that call. `data`'s shape is whatever the caller's
/// schema described — this type doesn't know or care what's inside it,
/// the same way `ResolvedCv` doesn't know about `CvVault`/`CvDraft`.
@freezed
abstract class LlmJsonResponse with _$LlmJsonResponse {
  const factory LlmJsonResponse({
    required Map<String, dynamic> data,
    required LlmUsage usage,
  }) = _LlmJsonResponse;
}
