import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/llm/ai_assistant_vault_payload.dart';
import 'package:cv_forge/models/llm/llm_cost_estimate.dart';
import 'package:cv_forge/services/llm/ai_assistant_prompt.dart';
import 'package:cv_forge/ui/common/l10n/document_language_labels.dart';
import 'package:cv_forge/ui/common/l10n/region_labels.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/models/llm/ai_assistant_result.dart';
import 'package:cv_forge/services/ai_assistant_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';

/// [AiAssistantRunDialog]'s state machine. `confirm` shows what's about to be
/// sent and to whom; `running` is the request in flight; `result` is a
/// successfully-applied pass' rationale/keywordGaps; `error` is a failed
/// pass, offering a retry. There is no separate "apply" step after
/// `result` — [run] already wrote it via [DraftService.applyAiAssistantResult]
/// by the time this phase is reached: the per-field `TailorableField`
/// revert controls are the review surface, not a second one here.
enum AiAssistantRunPhase { confirm, running, result, error }

class AiAssistantRunDialogModel extends BaseViewModel {
  AiAssistantRunDialogModel({required this.jobDescription});

  final String jobDescription;

  final _settingsService = locator<SettingsService>();
  final _vaultService = locator<VaultService>();
  final _draftService = locator<DraftService>();
  final _aiAssistantService = locator<AiAssistantService>();

  AiAssistantRunPhase _phase = AiAssistantRunPhase.confirm;
  AiAssistantRunPhase get phase => _phase;

  AiAssistantResult? _result;
  AiAssistantResult? get result => _result;

  Object? _error;

  /// Resolved by `SettingsService` — see
  /// [SettingsService.selectedAiAssistantProvider] for the never-throw
  /// fallback, which matters here because a settings read must never crash
  /// this dialog's build.
  LlmProvider get _provider => _settingsService.selectedAiAssistantProvider;

  String get providerDisplayName => _provider.displayName;

  /// Named on the confirm screen so the region choice is visible before the
  /// run, not just inferable from the output — it steers length, spelling,
  /// and tone.
  String get regionDisplayName => _draftService.draft.region.displayName(
    locator<LocalizationService>().strings,
  );

  /// Named on the confirm screen for the same reason as
  /// [regionDisplayName], and rather more urgently: the assistant is about
  /// to rewrite someone's career history into this language, which is a
  /// larger surprise than a page size if they had not noticed the setting.
  String get documentLanguageDisplayName => _draftService.draft.documentLanguage
      .displayLabel(locator<LocalizationService>().strings);

  /// Same stored-id-may-be-stale fallback, resolved in the one place that
  /// owns it — see [SettingsService.selectedAiAssistantModel].
  String get _modelId => _settingsService.selectedAiAssistantModel.id;

  /// Roughly what this run will cost, in US cents.
  ///
  /// The output is a selection plus a handful of rewrites rather than a
  /// restatement of the input, so it is assumed to come back at about a
  /// third of the request's length. A rougher guess than the translation
  /// dialog's, which knows its answer is the same size as its question.
  int get estimatedCents {
    final contentChars = jsonEncode({
      'jobDescription': jobDescription,
      'vault': AiAssistantVaultPayload.from(_vaultService.vault).toJson(),
    }).length;
    final promptChars = aiAssistantSystemPromptFor(
      _draftService.draft.region,
      language: _draftService.draft.documentLanguage,
    ).length;
    return displayCents(
      estimatedCentsFor(
        model: _settingsService.selectedAiAssistantModel,
        inputChars: promptChars + contentChars,
        expectedOutputChars: contentChars ~/ 3,
      ),
    );
  }

  /// Mirrors `SettingsViewModel.connectionTestErrorMessage`'s per-failure
  /// copy — this dialog surfaces the same failure vocabulary as the
  /// Settings connection test, since both ultimately call [LlmService].
  String? get errorMessage {
    final error = _error;
    if (error == null) return null;
    final strings = locator<LocalizationService>().strings;
    if (error is! LlmException) return strings.studioAiErrorGeneric;
    return switch (error.failure) {
      LlmFailure.noKey => strings.studioAiErrorNoKey,
      LlmFailure.unauthorized => strings.studioAiErrorUnauthorized,
      LlmFailure.rateLimited => strings.studioAiErrorRateLimited,
      LlmFailure.overloaded => strings.studioAiErrorOverloaded(
        providerDisplayName,
      ),
      LlmFailure.network => strings.studioAiErrorNetwork(providerDisplayName),
      LlmFailure.timeout => strings.studioAiErrorTimeout,
      LlmFailure.refusal => strings.studioAiErrorRefusal,
      LlmFailure.invalidRequest => strings.studioAiErrorInvalidRequest(
        providerDisplayName,
      ),
      LlmFailure.malformedResponse => strings.studioAiErrorMalformedResponse,
    };
  }

  Future<void> run() async {
    _phase = AiAssistantRunPhase.running;
    _error = null;
    notifyListeners();
    try {
      final apiKey = await _settingsService.apiKeyFor(_provider.id) ?? '';
      final result = await _aiAssistantService.runTailoringPass(
        vault: _vaultService.vault,
        jobDescription: jobDescription,
        region: _draftService.draft.region,
        // The draft's own language, not the Vault's default — this pass
        // tailors one CV, and that CV's language is what its bullets have
        // to come back in.
        documentLanguage: _draftService.draft.documentLanguage,
        providerId: _provider.id,
        modelId: _modelId,
        apiKey: apiKey,
      );
      await _draftService.applyAiAssistantResult(result);
      _result = result;
      _phase = AiAssistantRunPhase.result;
    } catch (e) {
      _error = e;
      _phase = AiAssistantRunPhase.error;
    }
    notifyListeners();
  }
}
