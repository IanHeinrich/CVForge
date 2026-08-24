import 'package:cv_forge/templates/compact/compact_template.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:cv_forge/templates/classic_centered/classic_centered_template.dart';
import 'package:cv_forge/templates/photo_header/photo_header_template.dart';

/// Template lookup, backed by a plain const list — no reflection, so
/// unused templates tree-shake out of a release build.
class TemplateRegistryService {
  static const List<CvTemplate> _templates = [
    CompactTemplate(),
    ClassicCenteredTemplate(),
    // Appended, not inserted — [defaultTemplate] is `_templates.first`,
    // and a photo must never become what a new draft gets by default.
    PhotoHeaderTemplate(),
  ];

  CvTemplate get defaultTemplate => _templates.first;

  /// id/displayName/description only, for a picker — deliberately typed as
  /// [CvTemplate] rather than a separate descriptor type, since every field
  /// a picker needs is already on the interface and nothing here ever
  /// touches `tokens`/`buildDocument`.
  List<CvTemplate> get available => _templates;

  /// Falls back to [defaultTemplate] for an unknown id — never throws, so
  /// a draft referencing a since-removed template still renders something.
  CvTemplate byId(String id) =>
      _templates.firstWhere((t) => t.id == id, orElse: () => defaultTemplate);
}
