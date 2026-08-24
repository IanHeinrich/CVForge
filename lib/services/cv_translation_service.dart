import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/llm/cv_translation_payload.dart';
import 'package:cv_forge/models/llm/cv_translation_result.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/services/llm/cv_translation_prompt.dart';
import 'package:cv_forge/services/llm/cv_translation_response_schema.dart';
import 'package:cv_forge/services/llm_service.dart';

/// Runs a translation pass: builds the request from what this draft
/// actually prints, calls [LlmService], and validates the answer against
/// the Vault and draft before handing it back.
///
/// A structural sibling of [AiAssistantService] — same thinness, same
/// division of labour, and the same deliberate ignorance of which
/// provider/model/key to use, which stays [SettingsService]'s job.
///
/// ## Translate last
///
/// The result lands in the same override layer a tailoring pass writes to
/// (see [CvDraft]'s own doc on why there is one layer and not two), and it
/// is applied on top of whatever is already there — so the order of the
/// two passes matters and only one order works:
///
/// 1. Tailor, which rewrites bullets against a job ad, in whatever
///    language they were written in.
/// 2. Translate, which takes the tailored text as its input.
///
/// Running them the other way round re-runs an English rewriter over a
/// translated CV and puts English back on the page. Nothing here can
/// prevent that — an override records no provenance, by design — so the
/// Studio card says it in the UI instead.
class CvTranslationService {
  final _llmService = locator<LlmService>();

  /// [targetLanguage] is the draft's own [CvDraft.documentLanguage], never
  /// the Vault's default: a translation exists to make one CV match one
  /// application.
  ///
  /// [region] steers word choice only — which market's professional
  /// vocabulary to reach for — and the prompt says so explicitly, because
  /// a region block that reads as licence to reshape the CV would undo the
  /// selection the user already made.
  ///
  /// The source language is deliberately not a parameter. Nothing in the
  /// app records what language the Vault was written in, and a per-string
  /// answer is better than a per-document one anyway: a Vault can
  /// legitimately hold a German role title beside English bullets.
  Future<CvTranslationResult> runTranslationPass({
    required CvVault vault,
    required CvDraft draft,
    required DocumentLanguage targetLanguage,
    required RegionProfile region,
    required String providerId,
    required String modelId,
    required String apiKey,
  }) async {
    final payload = CvTranslationPayload.from(vault, draft);
    final response = await _llmService.completeJson(
      providerId: providerId,
      modelId: modelId,
      apiKey: apiKey,
      systemPrompt: cvTranslationSystemPromptFor(
        targetLanguage,
        region: region,
      ),
      userContent: jsonEncode(payload.toJson()),
      schema: buildCvTranslationResponseSchema(payload),
    );
    return CvTranslationResult.fromLlmResponse(response.data, vault, draft);
  }
}
