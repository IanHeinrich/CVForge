import 'dart:convert';

import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/models/vault/cv_photo.dart';
import 'package:cv_forge/services/profile_photo_service.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';

/// How wide the preview is drawn. Its height follows from
/// [ProfilePhotoService.cropAspectRatio], so the thumbnail is the same
/// shape as the box the PDF prints — a square avatar here would promise a
/// crop the document doesn't do.
const _previewWidth = 72.0;

/// The Vault's profile photo control: a preview of what a photo template
/// will print, plus the three things you can do to it.
///
/// Stateless and fully callback-driven like the rest of the Vault editor.
/// Picking is asynchronous and opens a dialog, so it can't ride
/// `BasicsEditorPanel`'s synchronous `onChanged` the way a text field
/// does — hence [onPick] and [onRemove] rather than a `CvPhoto` setter.
class PhotoEditorField extends StatelessWidget {
  const PhotoEditorField({
    super.key,
    required this.photo,
    required this.onPick,
    required this.onRemove,
    this.busy = false,
    this.errorText,
  });

  final CvPhoto? photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  /// True while the picked file is being decoded. Long enough to notice on
  /// a large photo, so the buttons say so rather than appearing dead.
  final bool busy;

  /// Shown under the buttons when a picked file couldn't be used. Null
  /// (the default) shows nothing — same convention as
  /// `AppTextField.errorText`.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final current = photo;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Preview(photo: current),
        const HGap.small(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.vaultPhotoTitle,
                style: context.appTypography.titleSmall,
              ),
              const VGap.tiny(),
              Text(
                // Deliberately names no template. This copy outlives any
                // one of them, and there may be more than one that
                // prints a photo later.
                current == null
                    ? context.l10n.vaultPhotoHelpOptional
                    : context.l10n.vaultPhotoHelpInUse,
                style: context.appTypography.bodySmall,
              ),
              const VGap.small(),
              Wrap(
                spacing: context.appSpacing.gapSmall,
                runSpacing: context.appSpacing.gapTiny,
                children: [
                  TextButton.icon(
                    onPressed: busy ? null : onPick,
                    icon: Icon(
                      RemixIcons.image_add_line,
                      size: context.appIconSize.medium,
                    ),
                    label: Text(
                      busy
                          ? context.l10n.vaultPhotoLoading
                          : current == null
                          ? context.l10n.vaultPhotoAdd
                          : context.l10n.vaultPhotoReplace,
                    ),
                  ),
                  if (current != null)
                    TextButton.icon(
                      onPressed: busy ? null : onRemove,
                      icon: Icon(
                        RemixIcons.delete_bin_line,
                        size: context.appIconSize.medium,
                      ),
                      label: Text(context.l10n.vaultPhotoRemove),
                    ),
                ],
              ),
              if (errorText != null) ...[
                const VGap.tiny(),
                Text(
                  errorText!,
                  style: context.appTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Stateful purely to hold the decoded [MemoryImage] across rebuilds.
///
/// `MemoryImage` compares equal by byte-buffer *identity*, so building one
/// inline from `base64Decode` would produce a fresh, never-equal provider
/// on every build — missing Flutter's image cache and re-decoding the JPEG
/// on every keystroke in the panel this sits in. Decoding once per actual
/// photo change, keyed on the base64 itself, is what makes the cache work.
class _Preview extends StatefulWidget {
  const _Preview({required this.photo});

  final CvPhoto? photo;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  MemoryImage? _decoded;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant _Preview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo?.jpegBase64 != widget.photo?.jpegBase64) _decode();
  }

  void _decode() {
    final photo = widget.photo;
    _decoded = photo == null
        ? null
        : MemoryImage(base64Decode(photo.jpegBase64));
  }

  @override
  Widget build(BuildContext context) {
    final decoded = _decoded;
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.appRadius.small),
      child: SizedBox(
        width: _previewWidth,
        height: _previewWidth / ProfilePhotoService.cropAspectRatio,
        child: decoded == null
            ? ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  RemixIcons.user_line,
                  size: context.appIconSize.large,
                  color: context.appPalette.placeholder,
                ),
              )
            : Image(image: decoded, fit: BoxFit.cover),
      ),
    );
  }
}
