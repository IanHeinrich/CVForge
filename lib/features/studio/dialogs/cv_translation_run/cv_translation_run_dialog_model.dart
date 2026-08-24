import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/llm/cv_translation_payload.dart';
import 'package:cv_forge/models/llm/llm_cost_estimate.dart';
import 'package:cv_forge/services/llm/cv_translation_prompt.dart';
import 'package:cv_forge/models/llm/cv_translation_result.dart';
import 'package:cv_forge/services/cv_translation_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/ui/common/l10n/document_language_labels.dart';
import 'package:stacked/stacked.dart';

/// [CvTranslationRunDialog]'s state machine, deliberately the same four
/// phases as `AiAssistantRunDialogModel`: `confirm` says what is about to
/// happen and to whom, `running` is the request in flight, `result` reports
/// an applied pass, `error` offers a retry.
///
/// As there, there is no separate "apply" step — [run] has already written
/// the translation through [DraftService.applyCvTranslationResult] by the
/// time `result` renders. The review surface is the ordinary per-field
/// revert control in each section editor, plus "Remove translation" on the
/// card.
enum CvTranslationRunPhase { confirm, running, result, error }

class CvTranslationRunDialogModel extends BaseViewModel {
  final _settingsService = locator<SettingsService>();
  final _vaultService = locator<VaultService>();
  final _draftService = locator<DraftService>();
  final _translationService = locator<CvTranslationService>();

  CvTranslationRunPhase _phase = CvTranslationRunPhase.confirm;
  CvTranslationRunPhase get phase => _phase;

  CvTranslationResult? _result;
  CvTranslationResult? get result => _result;

  Object? _error;

  /// How many of the run's requests have come back, and how many there
  /// are. A CV is translated as one request per section, so this actually
  /// moves during the wait instead of a loader sitting still for minutes.
  int _completed = 0;
  int _total = 0;
  int get completed => _completed;
  int get total => _total;

  LlmProvider get _provider => _settingsService.selectedAiAssistantProvider;

  String get providerDisplayName => _provider.displayName;

  /// Named first on the confirm screen. Rewriting a whole career history
  /// into another language is the largest thing any button in this app
  /// does, and the language it will use is a setting the user may have
  /// picked days ago on a different screen.
  String get targetLanguageDisplayName => _draftService.draft.documentLanguage
      .displayLabel(locator<LocalizationService>().strings);

  /// Whether running will overwrite an existing translation rather than
  /// produce the first one — surfaced on the confirm screen, since the
  /// second run silently discards the first.
  bool get replacesExisting => _draftService.draft.translatedTo != null;

  String get _modelId => _settingsService.selectedAiAssistantModel.id;

  /// Roughly what this run will cost, in US cents.
  ///
  /// Every string the CV prints goes out and comes back, so the answer is
  /// about as long as the request — which makes this the one LLM pass in
  /// the app whose output length can be predicted rather than guessed.
  int get estimatedCents {
    final chunks = CvTranslationPayload.chunksFor(
      _vaultService.vault,
      _draftService.draft,
    );
    if (chunks.isEmpty) return 0;
    final systemPromptChars = cvTranslationSystemPromptFor(
      _draftService.draft.documentLanguage,
      region: _draftService.draft.region,
    ).length;
    final contentChars = chunks.fold<int>(
      0,
      (total, chunk) => total + jsonEncode(chunk.toJson()).length,
    );
    return displayCents(
      estimatedCentsFor(
        model: _settingsService.selectedAiAssistantModel,
        // The system prompt is resent with every chunk.
        inputChars: systemPromptChars * chunks.length + contentChars,
        expectedOutputChars: contentChars,
      ),
    );
  }

  /// Mirrors `AiAssistantRunDialogModel.errorMessage` — the same failure
  /// vocabulary, in this feature's own keys, since both reach the same
  /// [LlmService] and can fail in exactly the same nine ways.
  String? get errorMessage {
    final error = _error;
    if (error == null) return null;
    final strings = locator<LocalizationService>().strings;
    if (error is! LlmException) return strings.studioTranslateErrorGeneric;
    return switch (error.failure) {
      LlmFailure.noKey => strings.studioTranslateErrorNoKey,
      LlmFailure.unauthorized => strings.studioTranslateErrorUnauthorized,
      LlmFailure.rateLimited => strings.studioTranslateErrorRateLimited,
      LlmFailure.overloaded => strings.studioTranslateErrorOverloaded(
        providerDisplayName,
      ),
      LlmFailure.network => strings.studioTranslateErrorNetwork(
        providerDisplayName,
      ),
      LlmFailure.timeout => strings.studioTranslateErrorTimeout,
      LlmFailure.refusal => strings.studioTranslateErrorRefusal,
      LlmFailure.invalidRequest => strings.studioTranslateErrorInvalidRequest(
        providerDisplayName,
      ),
      LlmFailure.malformedResponse =>
        strings.studioTranslateErrorMalformedResponse,
    };
  }

  Future<void> run() async {
    _phase = CvTranslationRunPhase.running;
    _error = null;
    notifyListeners();
    try {
      final apiKey = await _settingsService.apiKeyFor(_provider.id) ?? '';
      final draft = _draftService.draft;
      final result = await _translationService.runTranslationPass(
        onProgress: (completed, total) {
          _completed = completed;
          _total = total;
          notifyListeners();
        },
        vault: _vaultService.vault,
        draft: draft,
        targetLanguage: draft.documentLanguage,
        region: draft.region,
        providerId: _provider.id,
        modelId: _modelId,
        apiKey: apiKey,
      );
      await _draftService.applyCvTranslationResult(
        result,
        draft.documentLanguage,
      );
      _result = result;
      _phase = CvTranslationRunPhase.result;
    } catch (e) {
      _error = e;
      _phase = CvTranslationRunPhase.error;
    }
    notifyListeners();
  }
}
