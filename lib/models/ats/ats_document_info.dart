import 'package:freezed_annotation/freezed_annotation.dart';

part 'ats_document_info.freezed.dart';

/// Document-level metadata from `pdf.js`'s `getMetadata()` and `getDocument`
/// itself. `producer` is the cheapest, highest-signal input for
/// producer-conditioned tolerances (confirmed empirically: cv-forge's own
/// export reports `Producer: https://github.com/DavBfr/dart_pdf`) — not
/// currently used to adjust check tolerances, but threaded through from
/// day one so a future calibration pass has it without another
/// extraction-layer change.
@freezed
abstract class AtsDocumentInfo with _$AtsDocumentInfo {
  const factory AtsDocumentInfo({
    required int pageCount,
    String? producer,
    String? creator,
    String? language,

    /// Whether `page.getStructTree()` returned non-null for at least one
    /// page — a tagged/accessible PDF. `null` across every corpus sample
    /// seen so far (no genuinely tagged sample was available), so no
    /// check currently depends on this.
    @Default(false) bool hasStructTree,
  }) = _AtsDocumentInfo;
}
