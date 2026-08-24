import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/services/drive_sync_service.dart';
import 'package:stacked/stacked.dart';

/// Backs [DriveSyncIndicator]. `AppChrome` (this widget's only caller) is
/// deliberately modelless — a plain `StatelessWidget`, see its own doc
/// comment — and a `StatelessWidget` has no way to subscribe to
/// `DriveSyncService`'s `ListenableServiceMixin` notifications on its
/// own. Carrying a tiny `ReactiveViewModel` just for this one widget
/// keeps that reactivity local to the one place that needs it, rather
/// than pulling `AppChrome` itself into having state.
class DriveSyncIndicatorModel extends ReactiveViewModel {
  final _driveSyncService = locator<DriveSyncService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_driveSyncService];

  bool get isAvailable => _driveSyncService.isAvailable;
  DriveSyncStatus get status => _driveSyncService.status;
}
