import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/llm/copilot_result.dart';
import 'package:cv_forge/models/llm/copilot_vault_payload.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/services/llm/copilot_prompt.dart';
import 'package:cv_forge/services/llm/copilot_response_schema.dart';
import 'package:cv_forge/services/llm_service.dart';

/// Runs a Copilot tailoring pass (plan.md's 4.5): builds the PII-stripped
/// request and the per-Vault response schema, calls [LlmService], and
/// validates the result against [vault] before handing it back.
///
/// Which provider/model/key to use is deliberately not this service's
/// concern — that's already `SettingsViewModel`'s job (mirrored by
/// whichever ViewModel drives the tailoring dialog), the same way
/// [LlmService] itself doesn't know or care who's calling it. Keeping
/// that resolution logic in exactly one place avoids a second copy of
/// `selectedCopilotModel`'s stored-id-may-be-stale fallback.
class CopilotService {
  final _llmService = locator<LlmService>();

  Future<CopilotResult> runTailoringPass({
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
      systemPrompt: copilotSystemPrompt,
      userContent: jsonEncode({
        'jobDescription': jobDescription,
        'vault': CopilotVaultPayload.from(vault).toJson(),
      }),
      schema: buildCopilotResponseSchema(vault),
    );
    return CopilotResult.fromLlmResponse(response.data, vault);
  }
}
