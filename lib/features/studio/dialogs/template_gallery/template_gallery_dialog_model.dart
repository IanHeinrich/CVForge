import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/template_thumbnail_service.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:stacked/stacked.dart';

import 'template_gallery_dialog_data.dart';

/// Backs [TemplateGalleryDialog]. Grouping is by [TemplateTag] rather than
/// a filter control (7.5 decision 5) — a template with several tags files
/// under the first one it declares, same rule [tagGroups] and each card's
/// remaining-tag chips both follow.
class TemplateGalleryDialogModel extends BaseViewModel {
  TemplateGalleryDialogModel({required this.data})
    : _selectedId = data.currentTemplateId;

  final TemplateGalleryDialogData data;

  final _templateRegistry = locator<TemplateRegistryService>();
  final _thumbnailService = locator<TemplateThumbnailService>();

  String _selectedId;
  String get selectedTemplateId => _selectedId;

  void selectTemplate(String templateId) {
    if (_selectedId == templateId) return;
    _selectedId = templateId;
    notifyListeners();
  }

  /// One group per first-declared [TemplateTag], in [TemplateTag]'s own
  /// declaration order — not alphabetical, and not insertion order off
  /// whichever template happens to be registered first.
  List<MapEntry<TemplateTag, List<CvTemplate>>> get tagGroups {
    final byTag = <TemplateTag, List<CvTemplate>>{};
    for (final template in _templateRegistry.available) {
      final primaryTag = template.tags.first;
      (byTag[primaryTag] ??= []).add(template);
    }
    return [
      for (final tag in TemplateTag.values)
        if (byTag[tag] case final templates?) MapEntry(tag, templates),
    ];
  }

  /// Cached per template id so a card's `FutureBuilder` doesn't re-request
  /// a render on every rebuild — [TemplateThumbnailService] has its own
  /// cache too, but that still means an extra render/raster round trip
  /// each time this getter would otherwise be called fresh.
  final _thumbnailFutures = <String, Future<Uint8List>>{};

  Future<Uint8List> thumbnailFor(String templateId) =>
      _thumbnailFutures[templateId] ??= _thumbnailService.thumbnail(
        cv: data.cv,
        templateId: templateId,
        format: data.pageFormat,
      );
}
