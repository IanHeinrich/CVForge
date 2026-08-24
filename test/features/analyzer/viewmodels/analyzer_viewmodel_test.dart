import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_viewmodel.dart';
import 'package:cv_forge/models/ats/ats_analysis_result.dart';
import 'package:cv_forge/models/ats/ats_document_info.dart';
import 'package:cv_forge/models/ats/ats_extracted_document.dart';
import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/services/ats_analyzer_service.dart';
import 'package:cv_forge/services/file_upload_service.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockFileUploadService fileUpload;
  late MockPdfExtractionService extraction;
  late MockAtsAnalyzerService analyzer;
  late MockVaultService vault;
  late AnalyzerViewModel viewModel;

  setUp(() {
    registerServices();
    fileUpload = locator<FileUploadService>() as MockFileUploadService;
    extraction = locator<PdfExtractionService>() as MockPdfExtractionService;
    analyzer = locator<AtsAnalyzerService>() as MockAtsAnalyzerService;
    vault = locator<VaultService>() as MockVaultService;
    when(vault.vault).thenReturn(CvVault.empty());
    viewModel = AnalyzerViewModel();
  });
  tearDown(() => locator.reset());

  group('AnalyzerViewModel Tests - documentNoun', () {
    void withRegion(RegionProfile region) => when(vault.vault).thenReturn(
      CvVault.empty().copyWith(
        documentDefaults: DocumentDefaults(region: region),
      ),
    );

    test("follows the Vault's default region — no region concept of its own, "
        'since Analyzer has no draft. Reports the ICU select branch id, not '
        'a display word: a translated sentence cannot have a foreign noun '
        'interpolated into it and stay grammatical', () {
      withRegion(RegionProfile.uk);
      expect(viewModel.documentNoun, 'cv');

      withRegion(RegionProfile.us);
      expect(viewModel.documentNoun, 'resume');
    });

    test('loads the Vault, so a direct link to /analyzer reports the real '
        'default rather than the uk fallback', () async {
      await viewModel.initialise();
      verify(vault.load()).called(1);
    });
  });

  group('AnalyzerViewModel Tests - pickAndAnalyze', () {
    test(
      'cancelling the file picker leaves the model idle with no result',
      () async {
        when(fileUpload.pickPdfFile()).thenAnswer((_) async => null);

        await viewModel.pickAndAnalyze();

        expect(viewModel.hasResult, isFalse);
        expect(viewModel.isAnalyzing, isFalse);
        expect(viewModel.hasAnalyzeError, isFalse);
        verifyNever(extraction.extract(any));
      },
    );

    test(
      'a picked file is extracted then analyzed, and the result is exposed',
      () async {
        final bytes = Uint8List.fromList([1, 2, 3]);
        final extracted = AtsExtractedDocument(
          info: const AtsDocumentInfo(pageCount: 1),
          nodes: const [],
          fonts: const {},
        );
        final result = AtsAnalysisResult(
          info: const AtsDocumentInfo(pageCount: 1),
          totalNodeCount: 0,
          findings: const [
            AtsFinding(
              category: AtsFindingCategory.noTextLayer,
              severity: AtsFindingSeverity.critical,
              title: 'No extractable text found',
              message: 'x',
            ),
          ],
        );

        when(fileUpload.pickPdfFile()).thenAnswer((_) async => bytes);
        when(extraction.extract(bytes)).thenAnswer((_) async => extracted);
        when(analyzer.analyze(extracted)).thenReturn(result);

        await viewModel.pickAndAnalyze();

        expect(viewModel.hasResult, isTrue);
        expect(viewModel.result, result);
        expect(viewModel.isAnalyzing, isFalse);
        verify(extraction.extract(bytes)).called(1);
        verify(analyzer.analyze(extracted)).called(1);
      },
    );

    test(
      'an extraction failure surfaces via hasAnalyzeError without a result',
      () async {
        when(
          fileUpload.pickPdfFile(),
        ).thenAnswer((_) async => Uint8List.fromList([1]));
        when(extraction.extract(any)).thenThrow(
          const PdfExtractionException(PdfExtractionFailure.invalidPdf, 'x'),
        );

        await viewModel.pickAndAnalyze();

        expect(viewModel.hasResult, isFalse);
        expect(viewModel.hasAnalyzeError, isTrue);
        verifyNever(analyzer.analyze(any));
      },
    );
  });

  group('AnalyzerViewModel Tests - analyzeErrorMessage', () {
    test('gives distinct copy per PdfExtractionFailure', () async {
      when(
        fileUpload.pickPdfFile(),
      ).thenAnswer((_) async => Uint8List.fromList([1]));

      final messages = <String>{};
      for (final failure in PdfExtractionFailure.values) {
        when(
          extraction.extract(any),
        ).thenThrow(PdfExtractionException(failure, 'x'));
        await viewModel.pickAndAnalyze();
        messages.add(viewModel.analyzeErrorMessage);
      }

      // One distinct message per failure mode — not a generic fallback
      // string repeated for all three.
      expect(messages, hasLength(PdfExtractionFailure.values.length));
    });

    test(
      'falls back to a generic message for a non-tagged exception',
      () async {
        when(
          fileUpload.pickPdfFile(),
        ).thenAnswer((_) async => Uint8List.fromList([1]));
        when(extraction.extract(any)).thenThrow(Exception('boom'));

        await viewModel.pickAndAnalyze();

        expect(viewModel.analyzeErrorMessage, isNotEmpty);
      },
    );
  });

  group('AnalyzerViewModel Tests - reset', () {
    test('clears the result, returning to the upload prompt', () async {
      final bytes = Uint8List.fromList([1]);
      final extracted = AtsExtractedDocument(
        info: const AtsDocumentInfo(pageCount: 1),
        nodes: const [],
        fonts: const {},
      );
      final result = AtsAnalysisResult(
        info: const AtsDocumentInfo(pageCount: 1),
        totalNodeCount: 0,
      );
      when(fileUpload.pickPdfFile()).thenAnswer((_) async => bytes);
      when(extraction.extract(bytes)).thenAnswer((_) async => extracted);
      when(analyzer.analyze(extracted)).thenReturn(result);
      await viewModel.pickAndAnalyze();
      expect(viewModel.hasResult, isTrue);

      viewModel.reset();

      expect(viewModel.hasResult, isFalse);
      expect(viewModel.result, isNull);
    });
  });
}
