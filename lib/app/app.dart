import 'package:cv_forge/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:cv_forge/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:cv_forge/ui/views/startup/startup_view.dart';
import 'package:cv_forge/ui/views/unknown/unknown_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:cv_forge/services/local_storage_service.dart';

import 'package:cv_forge/services/vault_service.dart';

import 'package:cv_forge/services/draft_service.dart';

import 'package:cv_forge/services/file_download_service.dart';

import 'package:cv_forge/features/vault/views/vault/vault_view.dart';

import 'package:cv_forge/features/studio/views/studio/studio_view.dart';

// @stacked-import

@StackedApp(
  routes: [
    CustomRoute(page: StartupView, initial: true),
    CustomRoute(page: VaultView, path: '/vault'),
    CustomRoute(page: StudioView, path: '/studio'),
    // @stacked-route

    CustomRoute(page: UnknownView, path: '/404'),

    /// When none of the above routes match, redirect to UnknownView
    RedirectRoute(path: '*', redirectTo: '/404'),
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: RouterService),
    LazySingleton(classType: LocalStorageService),
    LazySingleton(classType: VaultService),
    LazySingleton(classType: DraftService),
    LazySingleton(classType: FileDownloadService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
