// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/router_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../services/ai_assistant_service.dart';
import '../services/ats_analyzer_service.dart';
import '../services/backup_service.dart';
import '../services/draft_service.dart';
import '../services/drive_api_client_service.dart';
import '../services/drive_sync_service.dart';
import '../services/file_download_service.dart';
import '../services/file_upload_service.dart';
import '../services/font_service.dart';
import '../services/llm_service.dart';
import '../services/local_storage_service.dart';
import '../services/localization_service.dart';
import '../services/pdf_export_service.dart';
import '../services/settings_service.dart';
import '../services/template_registry_service.dart';
import '../services/template_thumbnail_service.dart';
import '../services/vault_service.dart';
import 'app.router.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
  StackedRouterWeb? stackedRouter,
}) async {
  // Register environments
  locator.registerEnvironment(
    environment: environment,
    environmentFilter: environmentFilter,
  );

  // Register dependencies
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => RouterService());
  locator.registerLazySingleton(() => LocalStorageService());
  locator.registerLazySingleton(() => VaultService());
  locator.registerLazySingleton(() => DraftService());
  locator.registerLazySingleton(() => FileDownloadService());
  locator.registerLazySingleton(() => TemplateRegistryService());
  locator.registerLazySingleton(() => FontService());
  locator.registerLazySingleton(() => PdfExportService());
  locator.registerLazySingleton(() => SettingsService());
  locator.registerLazySingleton(() => BackupService());
  locator.registerLazySingleton(() => FileUploadService());
  locator.registerLazySingleton(() => AtsAnalyzerService());
  locator.registerLazySingleton(() => LlmService());
  locator.registerLazySingleton(() => AiAssistantService());
  locator.registerLazySingleton(() => TemplateThumbnailService());
  locator.registerLazySingleton(() => DriveApiClientService());
  locator.registerLazySingleton(() => DriveSyncService());
  locator.registerLazySingleton(() => LocalizationService());
  if (stackedRouter == null) {
    throw Exception(
      'Stacked is building to use the Router (Navigator 2.0) navigation but no stackedRouter is supplied. Pass the stackedRouter to the setupLocator function in main.dart',
    );
  }

  locator<RouterService>().setRouter(stackedRouter);
}
