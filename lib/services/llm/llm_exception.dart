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
/// in `llm_service.dart` (where `plan.md` originally placed it, mirroring
/// `PdfExportException`'s spot next to `PdfExportService`) because an
/// `LlmProvider` adapter is what actually throws it, and `llm_service.dart`
/// importing `llm_provider_registry.dart` which imports an adapter which
/// would import back into `llm_service.dart` for this type is a real
/// import cycle, not a hypothetical one.
class LlmException implements Exception {
  const LlmException(this.failure, [this.cause]);

  final LlmFailure failure;
  final Object? cause;

  @override
  String toString() => 'LlmException(failure: $failure, cause: $cause)';
}
