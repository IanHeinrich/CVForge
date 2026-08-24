import 'package:dio/dio.dart';

/// Why an [LlmProvider] call failed — lets the UI show failure-specific
/// copy instead of one generic message (the same "no single generic
/// failure message" rule `PdfExportException`/`PdfExportStage` already
/// establish for exports). [refusal] is a `200` response that is still a
/// logical failure — Anthropic's `stop_reason: "refusal"` — so it has to
/// be classified explicitly rather than falling through to
/// [malformedResponse].
enum LlmFailure {
  noKey,
  unauthorized,
  rateLimited,
  overloaded,
  network,
  timeout,
  refusal,

  /// The provider rejected the request we built (a 4xx that isn't auth or
  /// rate limiting) — a bug on this side, not something the user can fix
  /// by retrying. Distinct from [malformedResponse], which is the
  /// provider's *reply* being unparseable.
  invalidRequest,
  malformedResponse,
}

/// Wraps whatever an [LlmProvider] call's failing stage threw, tagged with
/// [failure] so callers can classify it without inspecting the underlying
/// exception's type or message. Lives alongside [LlmProvider] rather than
/// in `llm_service.dart` because an `LlmProvider` adapter is what actually
/// throws it, and `llm_service.dart` importing `llm_provider_registry.dart`
/// which imports an adapter which would import back into
/// `llm_service.dart` for this type is a real import cycle, not a
/// hypothetical one.
class LlmException implements Exception {
  const LlmException(this.failure, [this.cause]);

  final LlmFailure failure;
  final Object? cause;

  @override
  String toString() => 'LlmException(failure: $failure, cause: $cause)';
}

/// The status/transport mapping every provider ends on, once its own
/// provider-specific checks have had first refusal — Anthropic reads 401
/// and 403 as auth, Gemini reads an `API_KEY_INVALID` reason out of a 400
/// body, and both then fall through to exactly this.
///
/// 429 and 5xx are worth retrying; any other 4xx is a request this client
/// built wrongly, and reporting *that* as a network failure ("check your
/// connection") sends the user to debug the wrong thing.
LlmException mapLlmTransportError(DioException e) {
  final status = e.response?.statusCode;
  if (status != null) {
    if (status == 429) return LlmException(LlmFailure.rateLimited, e);
    if (status >= 500) return LlmException(LlmFailure.overloaded, e);
    if (status >= 400) return LlmException(LlmFailure.invalidRequest, e);
  }
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => LlmException(LlmFailure.timeout, e),
    _ => LlmException(LlmFailure.network, e),
  };
}
