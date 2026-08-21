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

import 'package:cv_forge/features/vault/dialogs/confirm_delete/confirm_delete_dialog.dart';

import 'package:cv_forge/services/template_registry_service.dart';

import 'package:cv_forge/services/font_service.dart';

import 'package:cv_forge/services/pdf_export_service.dart';

import 'package:cv_forge/features/studio/dialogs/edit_draft/edit_draft_dialog.dart';

import 'package:cv_forge/features/studio/views/drafts_list/drafts_list_view.dart';

import 'package:cv_forge/services/settings_service.dart';

import 'package:cv_forge/services/backup_service.dart';

import 'package:cv_forge/services/file_upload_service.dart';

import 'package:cv_forge/features/settings/views/settings/settings_view.dart';

import 'package:cv_forge/services/ats_analyzer_service.dart';

import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_view.dart';

import 'package:cv_forge/services/llm_service.dart';

import 'package:cv_forge/services/copilot_service.dart';

import 'package:cv_forge/features/studio/dialogs/copilot_run/copilot_run_dialog.dart';

// @stacked-import

@StackedApp(
  routes: [
    CustomRoute(page: StartupView, initial: true),
    CustomRoute(page: VaultView, path: '/vault'),
    CustomRoute(page: StudioView, path: '/studio'),
    CustomRoute(page: DraftsListView, path: '/drafts'),
    CustomRoute(page: SettingsView, path: '/settings'),
    CustomRoute(page: AnalyzerView, path: '/analyzer'),
    // @stacked-route

    CustomRoute(page: UnknownView, path: '/404'),

    /// When none of the above routes match, redirect to UnknownView
    RedirectRoute(path: '*', redirectTo: '/404'),
  ],
  dependencies: [
    LazySingleton(classType: DialogService),
    LazySingleton(classType: RouterService),
    LazySingleton(classType: LocalStorageService),
    LazySingleton(classType: VaultService),
    LazySingleton(classType: DraftService),
    LazySingleton(classType: FileDownloadService),
    LazySingleton(classType: TemplateRegistryService),
    LazySingleton(classType: FontService),
    LazySingleton(classType: PdfExportService),
    LazySingleton(classType: SettingsService),
    LazySingleton(classType: BackupService),
    LazySingleton(classType: FileUploadService),
    // PdfExtractionService is deliberately absent here — its real
    // implementation, PdfExtractionServiceWeb, imports package:web, which
    // does not compile under the Dart VM. Registering it through this
    // list would pull that import into the centrally-generated
    // app.locator.dart, which nearly every test file imports, and break
    // the whole VM-run test suite. See PdfExtractionService's doc comment
    // and main.dart's manual registration.
    LazySingleton(classType: AtsAnalyzerService),
    LazySingleton(classType: LlmService),
    LazySingleton(classType: CopilotService),
    // @stacked-service
  ],
  bottomsheets: [
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: ConfirmDeleteDialog),
    StackedDialog(classType: EditDraftDialog),
    StackedDialog(classType: CopilotRunDialog),
    // @stacked-dialog
  ],
)
class App {}
