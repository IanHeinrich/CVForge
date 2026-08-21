import 'package:freezed_annotation/freezed_annotation.dart';

part 'ats_document_info.freezed.dart';

/// Document-level metadata from `pdf.js`'s `getMetadata()` and `getDocument`
/// itself. `producer` is the cheapest, highest-signal input for
/// producer-conditioned tolerances (confirmed in the spike: cv-forge's own
/// export reports `Producer: https://github.com/DavBfr/dart_pdf`) — not yet
/// used to adjust check tolerances in v1, but threaded through from day
/// one so a later calibration pass has it without another extraction-layer
/// change.
@freezed
abstract class AtsDocumentInfo with _$AtsDocumentInfo {
  const factory AtsDocumentInfo({
    required int pageCount,
    String? producer,
    String? creator,
    String? language,

    /// Whether `page.getStructTree()` returned non-null for at least one
    /// page — a tagged/accessible PDF. `null` across the entire spike
    /// corpus (no genuinely tagged sample was available), so no check
    /// depends on this in v1; kept for a later calibration pass.
    @Default(false) bool hasStructTree,
  }) = _AtsDocumentInfo;
}
