import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/llm/ai_assistant_result.dart';
import 'package:cv_forge/models/llm/ai_assistant_vault_payload.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/services/llm/ai_assistant_prompt.dart';
import 'package:cv_forge/services/llm/ai_assistant_response_schema.dart';
import 'package:cv_forge/services/llm_service.dart';

/// Runs an AI Assistant tailoring pass: builds the PII-stripped request and the
/// per-Vault response schema, calls [LlmService], and
/// validates the result against [vault] before handing it back.
///
/// Which provider/model/key to use is deliberately not this service's
/// concern — that's already `SettingsViewModel`'s job (mirrored by
/// whichever ViewModel drives the tailoring dialog), the same way
/// [LlmService] itself doesn't know or care who's calling it. Keeping
/// that resolution logic in exactly one place avoids a second copy of
/// `selectedAiAssistantModel`'s stored-id-may-be-stale fallback.
class AiAssistantService {
  final _llmService = locator<LlmService>();

  Future<AiAssistantResult> runTailoringPass({
    required CvVault vault,
    required String jobDescription,
    required String providerId,
    required String modelId,
    required String apiKey,
  }) async {
    final response = await _llmService.completeJson(
      providerId: providerId,
      modelId: modelId,
      apiKey: apiKey,
      systemPrompt: aiAssistantSystemPrompt,
      userContent: jsonEncode({
        'jobDescription': jobDescription,
        'vault': AiAssistantVaultPayload.from(vault).toJson(),
      }),
      schema: buildAiAssistantResponseSchema(vault),
    );
    return AiAssistantResult.fromLlmResponse(response.data, vault);
  }
}
