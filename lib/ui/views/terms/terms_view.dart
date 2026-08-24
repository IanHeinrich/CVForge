import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'terms_viewmodel.dart';

/// Static legal content — see [PrivacyView]'s doc comment for why this is
/// a single non-responsive view rather than the usual per-breakpoint
/// split. Not required by Google for the OAuth consent screen (only the
/// privacy policy is), but linked from the same "App domain" section for
/// completeness, and it's the natural place to state that CVForge is a
/// free, source-available personal project with no warranty.
const _contentMaxWidth = 640.0;

class TermsView extends StackedView<TermsViewModel> {
  const TermsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    TermsViewModel viewModel,
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
                    context.l10n.termsTitle,
                    style: context.appTypography.titleMedium,
                  ),
                  const VGap.tiny(),
                  Text(
                    context.l10n.legalEffectiveDate,
                    style: context.appTypography.caption,
                  ),
                  const VGap.medium(),
                  ..._section(context, null, [context.l10n.termsIntro]),
                  ..._section(context, context.l10n.termsAsIsTitle, [
                    context.l10n.termsAsIsBody,
                  ]),
                  ..._section(context, context.l10n.termsYourDataTitle, [
                    context.l10n.termsYourDataBody,
                  ]),
                  ..._section(context, context.l10n.termsThirdPartyTitle, [
                    context.l10n.termsThirdPartyBody,
                  ]),
                  ..._section(context, context.l10n.termsAcceptableUseTitle, [
                    context.l10n.termsAcceptableUseBody,
                  ]),
                  ..._section(context, context.l10n.termsOpenSourceTitle, [
                    context.l10n.termsOpenSourceBody,
                  ]),
                  ..._section(context, context.l10n.termsLiabilityTitle, [
                    context.l10n.termsLiabilityBody,
                  ]),
                  ..._section(context, context.l10n.termsChangesTitle, [
                    context.l10n.termsChangesBody,
                  ]),
                  ..._section(context, context.l10n.termsContactTitle, [
                    context.l10n.termsContactBody,
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
  TermsViewModel viewModelBuilder(BuildContext context) => TermsViewModel();
}
