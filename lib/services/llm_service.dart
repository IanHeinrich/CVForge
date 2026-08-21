import 'package:dio/dio.dart';

import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider_registry.dart';

/// Owns Copilot *policy* — which provider to call, the shared transport,
/// and nothing about any vendor's wire format. An [LlmProvider]
/// (resolved through [LlmProviderRegistry]) owns *dialect*; see
/// `lib/services/llm/llm_provider.dart`'s doc comment for the split.
///
/// [LlmProviderRegistry] is instantiated directly rather than injected
/// through the locator — it's stateless and deterministic (same
/// reasoning plan.md already applies to `CvComposer` not getting its own
/// service wrapper), and nothing besides this service ever needs one.
class LlmService {
  /// [client] is a test seam — production code always uses the default
  /// real [Dio]. Nothing else needs one injected, so this isn't a locator
  /// registration, just a constructor default.
  LlmService({Dio? client}) : _client = client ?? Dio();

  final Dio _client;
  final LlmProviderRegistry _registry = LlmProviderRegistry();

  /// The cheapest possible proof [apiKey] is valid for [providerId] — see
  /// [LlmProvider.validateKey]. Propagates [LlmException] for the caller
  /// to map to UI copy.
  Future<void> testConnection(String providerId, String apiKey) {
    if (apiKey.isEmpty) throw const LlmException(LlmFailure.noKey);
    return _registry
        .byId(providerId)
        .validateKey(client: _client, apiKey: apiKey);
  }

  /// The seam 4.5's tailoring pass calls into — thin delegation to
  /// whichever [LlmProvider] [providerId] resolves to.
  Future<LlmJsonResponse> completeJson({
    required String providerId,
    required String modelId,
    required String apiKey,
    required String systemPrompt,
    required String userContent,
    required JsonSchema schema,
  }) {
    if (apiKey.isEmpty) throw const LlmException(LlmFailure.noKey);
    return _registry
        .byId(providerId)
        .completeJson(
          client: _client,
          apiKey: apiKey,
          modelId: modelId,
          systemPrompt: systemPrompt,
          userContent: userContent,
          schema: schema,
        );
  }
}
