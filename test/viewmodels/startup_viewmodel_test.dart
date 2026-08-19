import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/ui/views/startup/startup_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('StartupViewmodelTest -', () {
    late MockLocalStorageService storage;
    late MockVaultService vault;
    late MockDraftService draft;
    late MockRouterService router;

    setUp(() {
      storage = getAndRegisterLocalStorageService();
      vault = getAndRegisterVaultService();
      draft = getAndRegisterDraftService();
      router = getAndRegisterRouterService();
      getAndRegisterFontService();
    });
    tearDown(() => locator.reset());

    test('When storage/vault/draft all initialize successfully, loads both '
        'and navigates to VaultView', () async {
      when(storage.ensureInitialized()).thenAnswer((_) => Future<void>.value());
      when(vault.load()).thenAnswer((_) => Future<void>.value());
      when(draft.load()).thenAnswer((_) => Future<void>.value());

      final model = StartupViewModel();
      await model.runStartupLogic();

      verify(storage.ensureInitialized()).called(1);
      verify(vault.load()).called(1);
      verify(draft.load()).called(1);
      verify(router.replaceWith(argThat(isA<VaultViewRoute>()))).called(1);
      expect(model.hasError, isFalse);
    });

    test('When local storage fails to initialize, sets an error and does '
        'not navigate', () async {
      when(
        storage.ensureInitialized(),
      ).thenThrow(Exception('IndexedDB unavailable'));

      final model = StartupViewModel();
      await model.runStartupLogic();

      expect(model.hasError, isTrue);
      verifyNever(router.replaceWith(any));
    });

    test('retry() re-runs the same startup sequence', () async {
      when(
        storage.ensureInitialized(),
      ).thenThrow(Exception('IndexedDB unavailable'));

      final model = StartupViewModel();
      await model.runStartupLogic();
      expect(model.hasError, isTrue);

      when(storage.ensureInitialized()).thenAnswer((_) => Future<void>.value());
      when(vault.load()).thenAnswer((_) => Future<void>.value());
      when(draft.load()).thenAnswer((_) => Future<void>.value());

      await model.retry();

      expect(model.hasError, isFalse);
      verify(router.replaceWith(argThat(isA<VaultViewRoute>()))).called(1);
    });
  });
}
