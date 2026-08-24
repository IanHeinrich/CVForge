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
///
/// ## All or nothing
///
/// One CV is several requests (see [CvTranslationPayload]), and if any of
/// them fails the whole pass fails and nothing is written. That keeps the
/// single atomic apply and the single undo snapshot that
/// [DraftService.applyCvTranslationResult] is built around, and spares the
/// user a CV translated in patches with no way to tell which parts are
/// which.
/// How many translation requests may be in flight at once.
///
/// Deliberately modest. The win from running chunks concurrently is
/// already most of the way there at this width, whereas firing a dozen at
/// once is a reliable way to meet a provider's rate limit and turn a slow
/// pass into a failed one — and the pass is all-or-nothing, so one 429
/// costs every other request in it.
const _maxConcurrentRequests = 4;

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
    void Function(int completed, int total)? onProgress,
  }) async {
    final chunks = CvTranslationPayload.chunksFor(vault, draft);
    if (chunks.isEmpty) return CvTranslationResult.merge(const []);

    final systemPrompt = cvTranslationSystemPromptFor(
      targetLanguage,
      region: region,
    );

    var completed = 0;
    onProgress?.call(0, chunks.length);

    Future<CvTranslationResult> runChunk(CvTranslationPayload chunk) async {
      final response = await _llmService.completeJson(
        providerId: providerId,
        modelId: modelId,
        apiKey: apiKey,
        systemPrompt: systemPrompt,
        userContent: jsonEncode(chunk.toJson()),
        schema: buildCvTranslationResponseSchema(chunk),
      );
      onProgress?.call(++completed, chunks.length);
      return CvTranslationResult.fromLlmResponse(response.data, chunk);
    }

    final results = <CvTranslationResult>[];
    // Bounded rather than firing every chunk at once: a CV with many
    // entries would otherwise open a dozen simultaneous connections and
    // walk straight into the provider's rate limit, turning a slow pass
    // into a failed one.
    for (var i = 0; i < chunks.length; i += _maxConcurrentRequests) {
      final window = chunks.skip(i).take(_maxConcurrentRequests);
      // Fails the whole pass if any request in the window does, which is
      // the intended contract — see the class doc.
      results.addAll(await Future.wait(window.map(runChunk)));
    }

    return CvTranslationResult.merge(results);
  }
}
