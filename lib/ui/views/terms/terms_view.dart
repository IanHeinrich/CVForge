import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
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
                    label: const Text('Back to CVForge'),
                  ),
                  const VGap.medium(),
                  Text(
                    'Terms of Service',
                    style: context.appTypography.titleMedium,
                  ),
                  const VGap.tiny(),
                  Text(
                    'Effective 23 August 2026',
                    style: context.appTypography.caption,
                  ),
                  const VGap.medium(),
                  ..._section(context, null, [
                    'CVForge is a free, source-available personal project '
                        '— not a company or a paid product. These terms '
                        'are intentionally short.',
                  ]),
                  ..._section(context, 'The app, as-is', [
                    'CVForge is provided free of charge, "as is" and "as '
                        'available", with no warranty of any kind, '
                        'express or implied — including no guarantee it '
                        'will always be available, error-free, or '
                        "suitable for a particular purpose. It's hosted "
                        'on GitHub Pages with no uptime commitment.',
                  ]),
                  ..._section(context, 'Your data, your responsibility', [
                    'Because CVForge stores your Vault and CVs only in '
                        'your own browser (and, if you choose to enable '
                        'it, your own Google Drive), you are responsible '
                        'for keeping your own backups. Clearing your '
                        "browser's site data, or disconnecting Drive "
                        'sync incorrectly, can result in permanent data '
                        'loss that CVForge cannot recover on your behalf.',
                  ]),
                  ..._section(context, 'Third-party services', [
                    'If you use Copilot or Google Drive sync, you are '
                        "also bound by that provider's own terms — "
                        "Anthropic's, Google's Gemini API terms, or "
                        "Google's own Terms of Service for your Drive "
                        'account. CVForge has no control over, and no '
                        "responsibility for, those providers' services.",
                  ]),
                  ..._section(context, 'Acceptable use', [
                    "Don't use CVForge to violate the law, or to abuse "
                        "any third-party API (Google's or an AI "
                        "provider's) beyond that provider's own "
                        'acceptable-use terms.',
                  ]),
                  ..._section(context, 'Open source', [
                    'CVForge is source-available on GitHub. See the '
                        "repository's own license file for the exact "
                        'terms governing the code itself.',
                  ]),
                  ..._section(context, 'Limitation of liability', [
                    "To the fullest extent permitted by law, CVForge's "
                        'developer is not liable for any damages arising '
                        'from your use of the app, including lost data.',
                  ]),
                  ..._section(context, 'Changes', [
                    'These terms may be updated from time to time; the '
                        'current version always lives at this page.',
                  ]),
                  ..._section(context, 'Contact', [
                    'heinrich-development-support@googlegroups.com',
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
