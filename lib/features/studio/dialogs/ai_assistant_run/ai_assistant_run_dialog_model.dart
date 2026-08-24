import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/llm/ai_assistant_result.dart';
import 'package:cv_forge/services/ai_assistant_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/models/region/region_presets.dart';
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
  String get regionDisplayName => _draftService.draft.region.preset.displayName;

  /// Same stored-id-may-be-stale fallback, resolved in the one place that
  /// owns it — see [SettingsService.selectedAiAssistantModel].
  String get _modelId => _settingsService.selectedAiAssistantModel.id;

  /// Mirrors `SettingsViewModel.connectionTestErrorMessage`'s per-failure
  /// copy — this dialog surfaces the same failure vocabulary as the
  /// Settings connection test, since both ultimately call [LlmService].
  String? get errorMessage {
    final error = _error;
    if (error == null) return null;
    if (error is! LlmException) return 'Something went wrong — try again.';
    return switch (error.failure) {
      LlmFailure.noKey => 'Add an AI Assistant API key in Settings first.',
      LlmFailure.unauthorized =>
        'Your API key was rejected — check it in Settings.',
      LlmFailure.rateLimited =>
        'Your API account is rate limited — try again in a moment.',
      LlmFailure.overloaded =>
        "$providerDisplayName's API is temporarily unavailable — try "
            'again shortly.',
      LlmFailure.network =>
        "Couldn't reach $providerDisplayName — check your connection.",
      LlmFailure.timeout => 'The request timed out — try again.',
      LlmFailure.refusal =>
        'The model declined to answer — try rephrasing the job '
            'description.',
      LlmFailure.invalidRequest =>
        "$providerDisplayName rejected the request. That's a bug in "
            'CVForge, not your input.',
      LlmFailure.malformedResponse => 'Got an unexpected response — try again.',
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
