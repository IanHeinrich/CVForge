import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
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
                    label: const Text('Back to CVForge'),
                  ),
                  const VGap.medium(),
                  Text(
                    'Privacy Policy',
                    style: context.appTypography.titleMedium,
                  ),
                  const VGap.tiny(),
                  Text(
                    'Effective 23 August 2026',
                    style: context.appTypography.caption,
                  ),
                  const VGap.medium(),
                  ..._section(context, null, [
                    "CVForge doesn't have a server. It's a static web app "
                        "that runs entirely in your browser, and this "
                        "policy exists to explain exactly what that "
                        'means for your data.',
                  ]),
                  ..._section(context, 'What CVForge stores, and where', [
                    'Your Vault (career history) and every CV you build '
                        "are stored only in your browser's local storage "
                        "(IndexedDB), on your own device. CVForge's "
                        'developer cannot see, access, or receive this '
                        'data. There is no backend for it to be sent to.',
                  ]),
                  ..._section(context, 'AI-assisted tailoring', [
                    'If you use the optional AI Assistant, the '
                        'relevant CV content and job description are sent '
                        "directly from your browser to the AI provider "
                        "you choose (Anthropic or Google), using an API "
                        "key you supply yourself. This call never passes "
                        'through any CVForge server, and the key is '
                        'stored only in your browser.',
                  ]),
                  ..._section(context, 'Google Drive sync', [
                    'If you choose to connect Google Drive, CVForge '
                        'requests exactly one Google OAuth scope: '
                        '`drive.appdata`. This scope only grants access '
                        "to a single hidden file CVForge creates for "
                        'itself in your Drive. It cannot see, list, or '
                        'touch any other file in your Google Drive.',
                    'That file is a copy of your Vault and CVs, letting '
                        'you recover them by signing in again on another '
                        'browser. It is readable only by CVForge acting '
                        "on your own Google account. CVForge's developer "
                        'has no access to it, and no other app can read '
                        'it either.',
                    'CVForge also reads your Google account email address '
                        '(via the same connection) purely to show which '
                        'account is connected in Settings. That address '
                        "is kept only in your browser's local storage, "
                        'never transmitted anywhere else.',
                    'You can disconnect at any time from Settings, which '
                        'stops syncing immediately. Disconnecting does '
                        'not delete the file already on Drive. You can '
                        'remove it yourself from your Google Account\'s '
                        '"Third-party apps & services" page at '
                        'myaccount.google.com, which also fully revokes '
                        "CVForge's access.",
                  ]),
                  ..._section(context, "What CVForge doesn't do", [
                    'No analytics, no tracking scripts, no advertising, '
                        'no cookies beyond what your browser itself uses '
                        'to keep you signed in to Google. Nothing about '
                        'your usage of CVForge is collected or sold.',
                  ]),
                  ..._section(context, 'Your control over your data', [
                    'Export your whole Vault and every CV as a JSON file '
                        'at any time from Settings, or clear your Vault '
                        'entirely. Uninstalling/clearing this site\'s '
                        'data in your browser removes everything CVForge '
                        'ever stored locally.',
                  ]),
                  ..._section(context, 'Contact', [
                    'Questions about this policy: '
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
  PrivacyViewModel viewModelBuilder(BuildContext context) => PrivacyViewModel();
}
