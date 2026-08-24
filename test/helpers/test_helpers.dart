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
import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/services/llm/llm_provider_registry.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/file_upload_service.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';
import 'package:cv_forge/services/ats_analyzer_service.dart';
import 'package:cv_forge/templates/compact/compact_template.dart';
import 'package:cv_forge/templates/photo_header/photo_header_template.dart';
import 'package:cv_forge/templates/classic_centered/classic_centered_template.dart';
import 'package:cv_forge/services/llm_service.dart';
import 'package:cv_forge/services/ai_assistant_service.dart';
import 'package:cv_forge/services/template_thumbnail_service.dart';
import 'package:cv_forge/services/drive_api_client_service.dart';
import 'package:cv_forge/services/drive_sync_service.dart';
// Not registered through app.dart's @StackedApp dependencies list (see
// GoogleAuthService's own doc comment for why — same reasoning as
// PdfExtractionService just above), but every service the app can
// resolve still needs a mock here regardless of how it's wired.
import 'package:cv_forge/services/google_auth_service.dart';
import 'package:cv_forge/services/profile_photo_service.dart';
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
    MockSpec<LlmService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<AiAssistantService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<TemplateThumbnailService>(
      onMissingStub: OnMissingStub.returnDefault,
    ),
    MockSpec<DriveApiClientService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DriveSyncService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<GoogleAuthService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<ProfilePhotoService>(onMissingStub: OnMissingStub.returnDefault),
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
  getAndRegisterLlmService();
  getAndRegisterAiAssistantService();
  getAndRegisterTemplateThumbnailService();
  getAndRegisterDriveApiClientService();
  getAndRegisterDriveSyncService();
  getAndRegisterGoogleAuthService();
  getAndRegisterProfilePhotoService();
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
  // Real templates, in the real registry's order — a mock returning
  // stand-ins would not exercise `TemplateTag`, which is what
  // `StudioViewModel.photoRegionWarning` reads. Keep this list in step
  // with `TemplateRegistryService._templates`.
  const templates = [
    CompactTemplate(),
    ClassicCenteredTemplate(),
    PhotoHeaderTemplate(),
  ];
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

/// Stubs the AI Assistant selection getters to resolve exactly the way the
/// real [SettingsService] does, rather than returning a mockito `SmartFake`
/// whose every member throws.
///
/// Deliberately `thenAnswer` closures reading `service.settings` at call
/// time, not values captured at registration: a test that re-stubs
/// `settings` (to change the stored provider or model id) then gets a
/// correspondingly different provider back, with no second stub to
/// remember. Delegating to the real [LlmProviderRegistry] rather than
/// hardcoding an id keeps that resolution — including the never-throw
/// fallbacks — from drifting away from production.
MockSettingsService getAndRegisterSettingsService({
  ApiKeyOrigin apiKeyOrigin = ApiKeyOrigin.none,
  String? apiKey,
}) {
  _removeRegistrationIfExists<SettingsService>();
  final service = MockSettingsService();
  final providers = LlmProviderRegistry();

  LlmProvider provider() =>
      providers.byId(service.settings.preferences.aiAssistantProviderId ?? '');

  when(service.selectedAiAssistantProvider).thenAnswer((_) => provider());
  when(service.selectedAiAssistantModel).thenAnswer((_) {
    final models = provider().models;
    final storedId = service.settings.preferences.aiAssistantModelId;
    return models.firstWhere(
      (m) => m.id == storedId,
      orElse: () => models.first,
    );
  });
  when(service.apiKeyOriginFor(any)).thenReturn(apiKeyOrigin);
  when(service.maskedApiKeyFor(any)).thenReturn(
    apiKey == null || apiKey.length <= 4
        ? null
        : '••••••••${apiKey.substring(apiKey.length - 4)}',
  );
  when(service.apiKeyFor(any)).thenAnswer((_) => Future<String?>.value(apiKey));
  when(
    service.markAiAssistantConfigured(),
  ).thenAnswer((_) => Future<void>.value());

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

MockLlmService getAndRegisterLlmService() {
  _removeRegistrationIfExists<LlmService>();
  final service = MockLlmService();
  locator.registerSingleton<LlmService>(service);
  return service;
}

MockAiAssistantService getAndRegisterAiAssistantService() {
  _removeRegistrationIfExists<AiAssistantService>();
  final service = MockAiAssistantService();
  locator.registerSingleton<AiAssistantService>(service);
  return service;
}

MockTemplateThumbnailService getAndRegisterTemplateThumbnailService() {
  _removeRegistrationIfExists<TemplateThumbnailService>();
  final service = MockTemplateThumbnailService();
  locator.registerSingleton<TemplateThumbnailService>(service);
  return service;
}

MockDriveApiClientService getAndRegisterDriveApiClientService() {
  _removeRegistrationIfExists<DriveApiClientService>();
  final service = MockDriveApiClientService();
  locator.registerSingleton<DriveApiClientService>(service);
  return service;
}

MockDriveSyncService getAndRegisterDriveSyncService() {
  _removeRegistrationIfExists<DriveSyncService>();
  final service = MockDriveSyncService();
  locator.registerSingleton<DriveSyncService>(service);
  return service;
}

MockGoogleAuthService getAndRegisterGoogleAuthService() {
  _removeRegistrationIfExists<GoogleAuthService>();
  final service = MockGoogleAuthService();
  locator.registerSingleton<GoogleAuthService>(service);
  return service;
}

MockProfilePhotoService getAndRegisterProfilePhotoService() {
  _removeRegistrationIfExists<ProfilePhotoService>();
  final service = MockProfilePhotoService();
  locator.registerSingleton<ProfilePhotoService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
