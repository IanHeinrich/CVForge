import 'package:cv_forge/templates/ats_minimal/ats_minimal_template.dart';
import 'package:cv_forge/templates/cv_template.dart';

/// Template lookup, backed by a plain const list — no reflection, so
/// unused templates tree-shake out of a release build.
class TemplateRegistryService {
  static const List<CvTemplate> _templates = [AtsMinimalTemplate()];

  CvTemplate get defaultTemplate => _templates.first;

  /// Falls back to [defaultTemplate] for an unknown id — never throws, so
  /// a draft referencing a since-removed template still renders something.
  CvTemplate byId(String id) =>
      _templates.firstWhere((t) => t.id == id, orElse: () => defaultTemplate);
}
