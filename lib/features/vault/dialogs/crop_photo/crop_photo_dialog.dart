import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:cv_forge/models/vault/cv_photo.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'crop_photo_dialog_data.dart';
import 'crop_photo_dialog_model.dart';

/// Tall enough to frame a portrait crop without the user having to squint,
/// and short enough that the confirm row stays on screen on a laptop.
/// `CropImage` sizes itself from the image it is given, so it needs a
/// bounded height here — inside the dialog's scrolling body it has none.
const _cropAreaHeight = 380.0;

/// Frames the picked photo to the 35 x 45 mm standard the photo template
/// prints.
///
/// The frame's ratio is fixed by [CropPhotoDialogModel] rather than
/// offered as a choice: a free crop would only be re-cropped at render
/// time against a box the user never saw, which is exactly how a photo
/// ends up with the top of someone's head missing.
class CropPhotoDialog extends StackedView<CropPhotoDialogModel> {
  const CropPhotoDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  final DialogRequest request;
  final Function(DialogResponse) completer;

  CropPhotoDialogData get _data => request.data as CropPhotoDialogData;

  @override
  Widget builder(
    BuildContext context,
    CropPhotoDialogModel viewModel,
    Widget? child,
  ) {
    return AppDialogScaffold(
      title: 'Position your photo',
      maxWidth: 520,
      confirmLabel: viewModel.isBusy ? 'Saving…' : 'Use this photo',
      // Both null while encoding — it takes a moment on a large image, and
      // a second confirm would race a half-written crop into the Vault.
      onCancel: viewModel.isBusy
          ? null
          : () => completer(DialogResponse<CvPhoto>(confirmed: false)),
      onConfirm: viewModel.isBusy ? null : () => _confirm(viewModel),
      children: [
        const VGap.small(),
        Text(
          'Drag the frame to choose what appears. The shape is fixed to '
          'the 35 × 45 mm size European CVs expect.',
          style: context.appTypography.bodySmall,
        ),
        const VGap.medium(),
        SizedBox(
          height: _cropAreaHeight,
          width: double.maxFinite,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.appRadius.medium),
            child: CropImage(
              controller: viewModel.controller,
              image: Image.memory(_data.preparedJpeg),
              gridCornerSize: context.appSpacing.paddingPanel,
              alwaysShowThirdLines: true,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirm(CropPhotoDialogModel viewModel) async {
    final photo = await viewModel.buildPhoto();
    completer(DialogResponse<CvPhoto>(confirmed: photo != null, data: photo));
  }

  @override
  CropPhotoDialogModel viewModelBuilder(BuildContext context) =>
      CropPhotoDialogModel();
}
