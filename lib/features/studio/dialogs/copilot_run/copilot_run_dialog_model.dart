import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/llm/copilot_result.dart';
import 'package:cv_forge/services/copilot_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/services/llm/llm_provider_registry.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';

/// [CopilotRunDialog]'s state machine. `confirm` shows what's about to be
/// sent and to whom; `running` is the request in flight; `result` is a
/// successfully-applied pass' rationale/keywordGaps; `error` is a failed
/// pass, offering a retry. There is no separate "apply" step after
/// `result` — [run] already wrote it via [DraftService.applyCopilotResult]
/// by the time this phase is reached, per plan.md's 4.5: the per-field
/// `TailorableField` revert controls are the review surface, not a second
/// one here.
enum CopilotRunPhase { confirm, running, result, error }

class CopilotRunDialogModel extends BaseViewModel {
  CopilotRunDialogModel({required this.jobDescription});

  final String jobDescription;

  final _settingsService = locator<SettingsService>();
  final _vaultService = locator<VaultService>();
  final _draftService = locator<DraftService>();
  final _copilotService = locator<CopilotService>();

  /// Not locator-registered — see `LlmService`'s own doc comment for why
  /// (stateless, deterministic, nothing else needs one injected).
  final _providerRegistry = LlmProviderRegistry();

  CopilotRunPhase _phase = CopilotRunPhase.confirm;
  CopilotRunPhase get phase => _phase;

  CopilotResult? _result;
  CopilotResult? get result => _result;

  Object? _error;

  /// Falls back to [LlmProviderRegistry.defaultProvider] the same way
  /// `SettingsViewModel.selectedCopilotProvider` does — a settings read
  /// must never crash this dialog's build.
  LlmProvider get _provider =>
      _providerRegistry.byId(_settingsService.settings.copilotProviderId ?? '');

  String get providerDisplayName => _provider.displayName;

  /// Same stored-id-may-be-stale fallback as
  /// `SettingsViewModel.selectedCopilotModel`.
  String get _modelId {
    final storedId = _settingsService.settings.copilotModelId;
    final models = _provider.models;
    return models
        .firstWhere((m) => m.id == storedId, orElse: () => models.first)
        .id;
  }

  /// Mirrors `SettingsViewModel.connectionTestErrorMessage`'s per-failure
  /// copy (P1.7-G7: one generic message for every failure is a real
  /// defect) — this dialog surfaces the same failure vocabulary as the
  /// Settings connection test, since both ultimately call [LlmService].
  String? get errorMessage {
    final error = _error;
    if (error == null) return null;
    if (error is! LlmException) return 'Something went wrong — try again.';
    return switch (error.failure) {
      LlmFailure.noKey => 'Add a Copilot API key in Settings first.',
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
    _phase = CopilotRunPhase.running;
    _error = null;
    notifyListeners();
    try {
      final apiKey = await _settingsService.apiKeyFor(_provider.id) ?? '';
      final result = await _copilotService.runTailoringPass(
        vault: _vaultService.vault,
        jobDescription: jobDescription,
        providerId: _provider.id,
        modelId: _modelId,
        apiKey: apiKey,
      );
      await _draftService.applyCopilotResult(result);
      _result = result;
      _phase = CopilotRunPhase.result;
    } catch (e) {
      _error = e;
      _phase = CopilotRunPhase.error;
    }
    notifyListeners();
  }
}
