import 'package:cv_forge/models/ats/ats_analysis_result.dart';
import 'package:cv_forge/models/ats/ats_finding.dart';

import 'ats_xray_page_loader.dart';
import 'ats_xray_painter.dart';

/// Turns one page's extracted geometry plus a finished analysis into the
/// flat [AtsXrayBox] list [AtsXrayPainter] draws.
///
/// Shared because the two surfaces that draw this overlay want the same
/// boxes from the same inputs and differ only in whether a finding can be
/// selected: the Analyzer's X-Ray panel passes [selectedNodeIndices] from
/// its rail, and Studio's inline overlay always passes none — it is a
/// glance at what the extractor sees, not an inspection tool with a
/// selection model of its own.
///
/// Every node gets an ambient box; a node carrying evidence gets a second,
/// severity-coloured box stacked on top of it. Two boxes rather than one
/// styled box because [AtsXrayPainter] paints in style layers, so the
/// faint backdrop can never draw over an evidence box.
List<AtsXrayBox> atsXrayBoxesFor({
  required XrayPageData data,
  required AtsAnalysisResult result,
  required int pageIndex,
  Set<int> selectedNodeIndices = const {},
}) {
  // result.findings is already severity-sorted (critical first), so the
  // first finding claiming a node wins — "highest severity wins" falls
  // out of iteration order rather than needing its own comparison.
  final severityByNode = <int, AtsFindingSeverity>{};
  for (final finding in result.findings) {
    for (final ev in finding.evidence) {
      if (ev.pageIndex != pageIndex) continue;
      severityByNode.putIfAbsent(ev.nodeIndex, () => finding.severity);
    }
  }

  final boxes = <AtsXrayBox>[];
  for (final idx in data.orderedNodeIndices) {
    final rect = data.rectByNodeIndex[idx]!;
    boxes.add((rect: rect, style: AtsXrayBoxStyle.ambient, severity: null));
    final severity = severityByNode[idx];
    if (severity != null) {
      boxes.add((
        rect: rect,
        style: selectedNodeIndices.contains(idx)
            ? AtsXrayBoxStyle.selected
            : AtsXrayBoxStyle.evidence,
        severity: severity,
      ));
    }
  }
  return boxes;
}
