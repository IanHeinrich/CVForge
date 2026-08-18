import 'package:pdf/widgets.dart' as pw;

/// The four static faces (regular/bold/italic/bold-italic) of one family,
/// loaded once as [pw.Font] objects. Populated by `FontService`, which
/// caches the loaded set so pages don't reload fonts per export.
class CvFontSet {
  const CvFontSet({
    required this.base,
    required this.bold,
    required this.italic,
    required this.boldItalic,
  });

  final pw.Font base;
  final pw.Font bold;
  final pw.Font italic;
  final pw.Font boldItalic;
}
