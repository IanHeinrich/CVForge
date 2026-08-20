import 'package:freezed_annotation/freezed_annotation.dart';

import 'ats_document_info.dart';
import 'ats_finding.dart';

part 'ats_analysis_result.freezed.dart';

/// `AtsAnalyzerService.analyze`'s output — the document metadata plus
/// every finding, ordered most-severe first.
@freezed
abstract class AtsAnalysisResult with _$AtsAnalysisResult {
  const factory AtsAnalysisResult({
    required AtsDocumentInfo info,
    required int totalNodeCount,
    @Default(<AtsFinding>[]) List<AtsFinding> findings,
  }) = _AtsAnalysisResult;
}
