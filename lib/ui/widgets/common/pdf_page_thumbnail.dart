import 'dart:typed_data';

import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// A rasterised PDF page's loading/failed/ready states, filling whatever
/// box it's given (typically an [AspectRatio] matching the page's own
/// proportions). Shared by the template gallery and the drafts grid — both
/// render a card-sized preview through [TemplateThumbnailService], and the
/// failed state matters in both: a font-load failure under a deployed
/// `--base-href` would fail every thumbnail at once, and a card should
/// degrade to a plain icon rather than an error box.
class PdfPageThumbnail extends StatelessWidget {
  const PdfPageThumbnail({super.key, required this.future});

  final Future<Uint8List> future;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: FutureBuilder<Uint8List>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Icon(
                RemixIcons.file_paper_2_line,
                color: context.appPalette.placeholder,
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          // cover, not contain — the slot is already the page's own
          // aspect ratio, so this fills it exactly and any rounding
          // difference crops by a pixel rather than leaving a visible
          // band.
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        },
      ),
    );
  }
}
