import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'privacy_viewmodel.dart';

/// Static legal content, linked from the Google OAuth consent screen
/// (`GoogleAuthServiceWeb`'s only reason to exist) — Google requires a
/// privacy policy for any External app requesting a scope beyond basic
/// sign-in, hosted on the same domain as the app itself. A single,
/// non-responsive `StackedView` rather than the usual `.desktop`/
/// `.tablet`/`.mobile` split: this content doesn't change shape by
/// breakpoint, just a column that reflows, so three near-identical files
/// would be exactly what this repo's own "responsive variants that only
/// differ by constants share one widget" rule warns against.
const _contentMaxWidth = 640.0;

class PrivacyView extends StackedView<PrivacyViewModel> {
  const PrivacyView({super.key});

  @override
  Widget builder(
    BuildContext context,
    PrivacyViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.appSpacing.paddingPage),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        locator<RouterService>().replaceWithVaultView(),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Text(context.l10n.legalBackToApp),
                  ),
                  const VGap.medium(),
                  Text(
                    context.l10n.privacyTitle,
                    style: context.appTypography.titleMedium,
                  ),
                  const VGap.tiny(),
                  Text(
                    context.l10n.legalEffectiveDate,
                    style: context.appTypography.caption,
                  ),
                  const VGap.medium(),
                  ..._section(context, null, [context.l10n.privacyIntro]),
                  ..._section(context, context.l10n.privacyStorageTitle, [
                    context.l10n.privacyStorageBody,
                  ]),
                  ..._section(context, context.l10n.privacyAiTitle, [
                    context.l10n.privacyAiBody,
                  ]),
                  ..._section(context, context.l10n.privacyDriveTitle, [
                    context.l10n.privacyDriveScope,
                    context.l10n.privacyDriveFile,
                    context.l10n.privacyDriveEmail,
                    context.l10n.privacyDriveDisconnect,
                  ]),
                  ..._section(context, context.l10n.privacyNoTrackingTitle, [
                    context.l10n.privacyNoTrackingBody,
                  ]),
                  ..._section(context, context.l10n.privacyControlTitle, [
                    context.l10n.privacyControlBody,
                  ]),
                  ..._section(context, context.l10n.privacyContactTitle, [
                    context.l10n.privacyContactBody,
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    String? heading,
    List<String> paragraphs,
  ) => [
    if (heading != null) ...[
      Text(
        heading,
        style: context.appTypography.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const VGap.tiny(),
    ],
    for (final paragraph in paragraphs) ...[
      Text(paragraph, style: context.appTypography.bodySmall),
      const VGap.small(),
    ],
    const VGap.medium(),
  ];

  @override
  PrivacyViewModel viewModelBuilder(BuildContext context) => PrivacyViewModel();
}
