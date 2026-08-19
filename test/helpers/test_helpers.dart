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
// @stacked-import

import 'test_helpers.mocks.dart';

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<RouterService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<BottomSheetService>(onMissingStub: OnMissingStub.returnDefault),
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
    // @stacked-mock-spec
  ],
)
void registerServices() {
  getAndRegisterRouterService();
  getAndRegisterBottomSheetService();
  getAndRegisterDialogService();
  getAndRegisterLocalStorageService();
  getAndRegisterVaultService();
  getAndRegisterDraftService();
  getAndRegisterFileDownloadService();
  getAndRegisterTemplateRegistryService();
  getAndRegisterFontService();
  getAndRegisterPdfExportService();
  // @stacked-mock-register
}

MockRouterService getAndRegisterRouterService() {
  _removeRegistrationIfExists<RouterService>();
  final service = MockRouterService();
  locator.registerSingleton<RouterService>(service);
  return service;
}

MockBottomSheetService getAndRegisterBottomSheetService<T>({
  SheetResponse<T>? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  when(
    service.showCustomSheet<T, T>(
      enableDrag: anyNamed('enableDrag'),
      enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
      exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
      ignoreSafeArea: anyNamed('ignoreSafeArea'),
      isScrollControlled: anyNamed('isScrollControlled'),
      barrierDismissible: anyNamed('barrierDismissible'),
      additionalButtonTitle: anyNamed('additionalButtonTitle'),
      variant: anyNamed('variant'),
      title: anyNamed('title'),
      hasImage: anyNamed('hasImage'),
      imageUrl: anyNamed('imageUrl'),
      showIconInMainButton: anyNamed('showIconInMainButton'),
      mainButtonTitle: anyNamed('mainButtonTitle'),
      showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
      secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
      showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
      takesInput: anyNamed('takesInput'),
      barrierColor: anyNamed('barrierColor'),
      barrierLabel: anyNamed('barrierLabel'),
      customData: anyNamed('customData'),
      data: anyNamed('data'),
      description: anyNamed('description'),
    ),
  ).thenAnswer(
    (realInvocation) =>
        Future.value(showCustomSheetResponse ?? SheetResponse<T>()),
  );

  locator.registerSingleton<BottomSheetService>(service);
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

MockTemplateRegistryService getAndRegisterTemplateRegistryService() {
  _removeRegistrationIfExists<TemplateRegistryService>();
  final service = MockTemplateRegistryService();
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
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
