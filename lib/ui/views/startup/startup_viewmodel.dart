import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// Runs once before the app is usable: brings storage online and loads the
/// Vault/Draft into memory, then routes to [VaultViewRoute].
///
/// This is largely an optimisation, not a correctness requirement — this
/// is a web app with real URLs, and a user refreshing directly on
/// `/studio` bypasses this View entirely. `VaultService`/`DraftService`
/// each gate their own reads on an internal readiness future, so they
/// self-initialize correctly even if this never ran.
class StartupViewModel extends BaseViewModel {
  final _localStorageService = locator<LocalStorageService>();
  final _vaultService = locator<VaultService>();
  final _draftService = locator<DraftService>();
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
    // FontService.warmUp() (not awaited — fonts are ~1.5MB and a user who
    // never exports shouldn't have first paint blocked on them) is wired
    // in here once P1.6 adds that service.
  }

  Future<void> retry() => runStartupLogic();
}
