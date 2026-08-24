import 'package:dio/dio.dart';

import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';

/// One LLM vendor's dialect — auth header, structured-output format,
/// response shape and failure vocabulary all vary, and an implementation
/// translates all four into the one shape [LlmService] understands.
///
/// Narrow on purpose: one method for the AI Assistant's one kind of call.
/// Implementations are stateless and `const`-constructible, like
/// `CvTemplate` — the shared [Dio] is passed per call, never held here.
abstract interface class LlmProvider {
  /// Persisted as `CvPreferences.aiAssistantProviderId` — never rename
  /// once shipped, or every device that remembered a choice silently falls
  /// back to [LlmProviderRegistry.defaultProvider].
  String get id;

  String get displayName;

  /// id/label/pricing, for a Settings dropdown.
  List<LlmModelOption> get models;

  /// Where keys are created, and where spend caps are configured — links
  /// in Settings' "How do I get a key?" disclosure.
  ///
  /// On the interface rather than in the widget, like [models]: a provider
  /// that can't answer these isn't usable, and one that forgets won't
  /// compile. Two URLs because both providers put them in two places.
  Uri get apiKeyConsoleUrl;
  Uri get billingConsoleUrl;

  /// Ordered steps from "no key" to "key pasted into CVForge".
  ///
  /// Only steps that genuinely differ per provider. The budget and safety
  /// advice is identical everywhere and is stated once in the widget.
  List<String> get apiKeySteps;

  /// Sends [systemPrompt] and [userContent] to [modelId], constrained to
  /// [schema], returning parsed JSON plus token usage. Throws
  /// [LlmException] for every failure mode.
  Future<LlmJsonResponse> completeJson({
    required Dio client,
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userContent,
    required JsonSchema schema,
  });

  /// The cheapest proof a key is valid and CORS works — never a real
  /// inference call, so testing a connection spends nothing.
  Future<void> validateKey({required Dio client, required String apiKey});
}
