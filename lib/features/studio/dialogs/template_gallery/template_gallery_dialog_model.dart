import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/template_thumbnail_service.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:stacked/stacked.dart';

import 'template_gallery_dialog_data.dart';

/// Backs [TemplateGalleryDialog] — a flat grid, not grouped by
/// [TemplateTag]. Grouping under tag headings was tried and dropped: with
/// two templates it produced one card per group and a
/// mostly-empty dialog, which only gets worse rather than better once a
/// tag applies to most templates. [TemplateTag] still exists — each
/// card shows its own tags as chips, still useful at a glance — it just
/// no longer drives layout.
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

  /// Every registered template, in registry order — the grid the dialog
  /// renders.
  List<CvTemplate> get templates => _templateRegistry.available;

  /// The proportions of the page every thumbnail is rendered at, so each
  /// card's image slot can match its image. Derived from the draft's own
  /// [TemplateGalleryDialogData.pageFormat] — the same value handed to
  /// [TemplateThumbnailService.thumbnail] — rather than assumed to be A4,
  /// which letterboxed a US Letter draft's thumbnails inside a taller,
  /// narrower box.
  double get pageAspectRatio => data.pageFormat.width / data.pageFormat.height;

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
