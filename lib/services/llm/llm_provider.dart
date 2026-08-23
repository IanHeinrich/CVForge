import 'package:dio/dio.dart';

import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';

/// One LLM vendor's dialect — auth header, structured-output format,
/// response shape, and failure vocabulary all vary per provider; an
/// [LlmProvider] implementation owns translating all four into the one
/// shape [LlmService] understands. Deliberately narrow: one method for
/// the Copilot's one kind of call. Streaming, tool use, multi-turn, and
/// per-provider prompt tuning are the next provider's problem, informed
/// by a real second provider, not a guess made now.
///
/// Implementations are stateless and `const`-constructible, mirroring
/// `CvTemplate`'s shape in `TemplateRegistryService` — the shared [Dio]
/// instance is passed in per call by [LlmService], never held here.
abstract interface class LlmProvider {
  /// Persisted (as `AppSettings.copilotProviderId`) — never rename once
  /// shipped, or every device that remembered a provider choice silently
  /// falls back to [LlmProviderRegistry.defaultProvider] on next load.
  String get id;

  String get displayName;

  /// id/label/pricing, for a Settings dropdown.
  List<LlmModelOption> get models;

  /// Where this provider's API keys are created, and where spend caps and
  /// auto top-up are configured — rendered as real links by Settings'
  /// "How do I get a key?" disclosure.
  ///
  /// Provider-specific facts live here beside [displayName] rather than in
  /// the widget, for the same reason [models] does: a new provider has to
  /// answer these questions to be usable at all, and an implementation
  /// that forgets one won't compile. Split into two URLs because they are
  /// two different destinations for both current providers, and the
  /// billing one is what the budget advice actually points at.
  Uri get apiKeyConsoleUrl;
  Uri get billingConsoleUrl;

  /// Ordered, provider-specific steps to get from "no key" to "key pasted
  /// into CVForge", rendered as a numbered list.
  ///
  /// Only the steps that genuinely differ per provider belong here. The
  /// budget/safety advice (turn off auto top-up, set a hard cap, use a
  /// dedicated key) is identical for every provider and is stated once in
  /// the widget instead — restating it per provider would rot in as many
  /// places as there are providers.
  List<String> get apiKeySteps;

  /// Sends [systemPrompt] + [userContent] to [modelId] via [client],
  /// constrained to answer in the shape [schema] describes, and returns
  /// the parsed JSON plus token usage. Throws [LlmException] for every
  /// failure mode — network, auth, rate limit, a structurally valid but
  /// logically refused response, or a malformed one.
  Future<LlmJsonResponse> completeJson({
    required Dio client,
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userContent,
    required JsonSchema schema,
  });

  /// The cheapest possible proof a key is valid and CORS actually works —
  /// never a real inference call. Anthropic's implementation is `GET
  /// /v1/models`, spending none of the user's money to prove the
  /// connection.
  Future<void> validateKey({required Dio client, required String apiKey});
}
