import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/file_download_service.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/font_service.dart';
import 'package:cv_forge/services/pdf_export_service.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/file_upload_service.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';
import 'package:cv_forge/services/ats_analyzer_service.dart';
import 'package:cv_forge/templates/compact/compact_template.dart';
import 'package:cv_forge/templates/classic_centered/classic_centered_template.dart';
// @stacked-import

import 'test_helpers.mocks.dart';

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<RouterService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<LocalStorageService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<VaultService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DraftService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<FileDownloadService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<TemplateRegistryService>(
      onMissingStub: OnMissingStub.returnDefault,
    ),
    MockSpec<FontService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<PdfExportService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<SettingsService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<BackupService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<FileUploadService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<PdfExtractionService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<AtsAnalyzerService>(onMissingStub: OnMissingStub.returnDefault),
    // @stacked-mock-spec
  ],
)
void registerServices() {
  getAndRegisterRouterService();
  getAndRegisterDialogService();
  getAndRegisterLocalStorageService();
  getAndRegisterVaultService();
  getAndRegisterDraftService();
  getAndRegisterFileDownloadService();
  getAndRegisterTemplateRegistryService();
  getAndRegisterFontService();
  getAndRegisterPdfExportService();
  getAndRegisterSettingsService();
  getAndRegisterBackupService();
  getAndRegisterFileUploadService();
  getAndRegisterPdfExtractionService();
  getAndRegisterAtsAnalyzerService();
  // @stacked-mock-register
}

MockRouterService getAndRegisterRouterService() {
  _removeRegistrationIfExists<RouterService>();
  final service = MockRouterService();
  locator.registerSingleton<RouterService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockLocalStorageService getAndRegisterLocalStorageService() {
  _removeRegistrationIfExists<LocalStorageService>();
  final service = MockLocalStorageService();
  locator.registerSingleton<LocalStorageService>(service);
  return service;
}

MockVaultService getAndRegisterVaultService() {
  _removeRegistrationIfExists<VaultService>();
  final service = MockVaultService();
  locator.registerSingleton<VaultService>(service);
  return service;
}

MockDraftService getAndRegisterDraftService() {
  _removeRegistrationIfExists<DraftService>();
  final service = MockDraftService();
  locator.registerSingleton<DraftService>(service);
  return service;
}

MockFileDownloadService getAndRegisterFileDownloadService() {
  _removeRegistrationIfExists<FileDownloadService>();
  final service = MockFileDownloadService();
  locator.registerSingleton<FileDownloadService>(service);
  return service;
}

/// Stubs [TemplateRegistryService.byId]/[TemplateRegistryService.
/// defaultTemplate]/[TemplateRegistryService.available] against the real
/// templates, not a further-mocked `CvTemplate` — every field a test
/// might read (`tokens`, `sectionOrder`, …) is then real data rather than
/// something each call site has to stub individually. A test that cares
/// about a specific template id can still override `byId` afterwards.
MockTemplateRegistryService getAndRegisterTemplateRegistryService() {
  _removeRegistrationIfExists<TemplateRegistryService>();
  final service = MockTemplateRegistryService();
  const templates = [CompactTemplate(), ClassicCenteredTemplate()];
  when(service.defaultTemplate).thenReturn(templates.first);
  when(service.available).thenReturn(templates);
  when(service.byId(any)).thenAnswer(
    (invocation) => templates.firstWhere(
      (t) => t.id == invocation.positionalArguments.first,
      orElse: () => templates.first,
    ),
  );
  locator.registerSingleton<TemplateRegistryService>(service);
  return service;
}

MockFontService getAndRegisterFontService() {
  _removeRegistrationIfExists<FontService>();
  final service = MockFontService();
  locator.registerSingleton<FontService>(service);
  return service;
}

MockPdfExportService getAndRegisterPdfExportService() {
  _removeRegistrationIfExists<PdfExportService>();
  final service = MockPdfExportService();
  locator.registerSingleton<PdfExportService>(service);
  return service;
}

MockSettingsService getAndRegisterSettingsService() {
  _removeRegistrationIfExists<SettingsService>();
  final service = MockSettingsService();
  locator.registerSingleton<SettingsService>(service);
  return service;
}

MockBackupService getAndRegisterBackupService() {
  _removeRegistrationIfExists<BackupService>();
  final service = MockBackupService();
  locator.registerSingleton<BackupService>(service);
  return service;
}

MockFileUploadService getAndRegisterFileUploadService() {
  _removeRegistrationIfExists<FileUploadService>();
  final service = MockFileUploadService();
  locator.registerSingleton<FileUploadService>(service);
  return service;
}

MockPdfExtractionService getAndRegisterPdfExtractionService() {
  _removeRegistrationIfExists<PdfExtractionService>();
  final service = MockPdfExtractionService();
  locator.registerSingleton<PdfExtractionService>(service);
  return service;
}

MockAtsAnalyzerService getAndRegisterAtsAnalyzerService() {
  _removeRegistrationIfExists<AtsAnalyzerService>();
  final service = MockAtsAnalyzerService();
  locator.registerSingleton<AtsAnalyzerService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
