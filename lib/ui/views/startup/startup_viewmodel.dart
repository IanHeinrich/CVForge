import 'dart:async';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/font_service.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// Runs once before the app is usable: brings storage online and loads the
/// Vault/Draft into memory, then routes to [VaultViewRoute].
///
/// This is largely an optimisation, not a correctness requirement — see
/// [LocalStorageService] for why every service can self-initialize even
/// if this View never ran.
class StartupViewModel extends BaseViewModel {
  final _localStorageService = locator<LocalStorageService>();
  final _vaultService = locator<VaultService>();
  final _draftService = locator<DraftService>();
  final _fontService = locator<FontService>();
  final _routerService = locator<RouterService>();

  Future<void> runStartupLogic() async {
    await runBusyFuture(_initialize());
    if (!hasError) {
      await _routerService.replaceWith(VaultViewRoute());
    }
    // If an error occurred, runBusyFuture has already recorded it via
    // setError — StartupView renders a retry card instead of navigating.
  }

  Future<void> _initialize() async {
    await _localStorageService.ensureInitialized();
    await _vaultService.load();
    await _draftService.load();
    if (_draftService.isFreshDraft) await _selectAllFromVault();
    // Not awaited — fonts are ~1.5MB and a user who never exports
    // shouldn't have first paint blocked on them. By the time Studio's
    // export button is pressed, this has almost always already resolved.
    unawaited(_fontService.warmUp());
  }

  /// A first-time user (no draft has ever been persisted) starts with
  /// everything in their Vault selected, rather than an empty CV — once
  /// they check/uncheck anything, that becomes their real, persisted
  /// selection and this never runs again (see [DraftService.isFreshDraft]).
  Future<void> _selectAllFromVault() async {
    final vault = _vaultService.vault;
    await _draftService.selectAllFromVault(
      experienceIds: [for (final e in vault.experiences) e.id],
      bulletIds: {
        for (final e in vault.experiences)
          e.id: [for (final b in e.bullets) b.id],
      },
      projectIds: [for (final p in vault.projects) p.id],
      projectBulletIds: {
        for (final p in vault.projects) p.id: [for (final b in p.bullets) b.id],
      },
      skillIds: [
        for (final category in vault.skillCategories)
          for (final skill in category.skills) skill.id,
      ],
      educationIds: [for (final e in vault.education) e.id],
      hobbyIds: [for (final h in vault.hobbies) h.id],
    );
  }

  Future<void> retry() => runStartupLogic();
}
