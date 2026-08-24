import 'package:cv_forge/ui/widgets/common/legal_page_scaffold/legal_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'privacy_viewmodel.dart';

/// The privacy policy Google's OAuth consent screen links to — required
/// for any External app requesting a scope beyond basic sign-in, and it
/// must be hosted on the app's own domain.
class PrivacyView extends StackedView<PrivacyViewModel> {
  const PrivacyView({super.key});

  @override
  Widget builder(
    BuildContext context,
    PrivacyViewModel viewModel,
    Widget? child,
  ) {
    return LegalPageScaffold(
      title: 'Privacy Policy',
      effectiveDate: 'Effective 23 August 2026',
      sections: const [
        LegalSection(
          paragraphs: [
            "CVForge doesn't have a server. It's a static web app "
                "that runs entirely in your browser, and this "
                "policy exists to explain exactly what that "
                'means for your data.',
          ],
        ),
        LegalSection(
          heading: 'What CVForge stores, and where',
          paragraphs: [
            'Your Vault (career history) and every CV you build '
                "are stored only in your browser's local storage "
                "(IndexedDB), on your own device. CVForge's "
                'developer cannot see, access, or receive this '
                'data. There is no backend for it to be sent to.',
          ],
        ),
        LegalSection(
          heading: 'AI-assisted tailoring',
          paragraphs: [
            'If you use the optional AI Assistant, the '
                'relevant CV content and job description are sent '
                "directly from your browser to the AI provider "
                "you choose (Anthropic or Google), using an API "
                "key you supply yourself. This call never passes "
                'through any CVForge server, and the key is '
                'stored only in your browser.',
          ],
        ),
        LegalSection(
          heading: 'Google Drive sync',
          paragraphs: [
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
          ],
        ),
        LegalSection(
          heading: "What CVForge doesn't do",
          paragraphs: [
            'No analytics, no tracking scripts, no advertising, '
                'no cookies beyond what your browser itself uses '
                'to keep you signed in to Google. Nothing about '
                'your usage of CVForge is collected or sold.',
          ],
        ),
        LegalSection(
          heading: 'Your control over your data',
          paragraphs: [
            'Export your whole Vault and every CV as a JSON file '
                'at any time from Settings, or clear your Vault '
                'entirely. Uninstalling/clearing this site\'s '
                'data in your browser removes everything CVForge '
                'ever stored locally.',
          ],
        ),
        LegalSection(
          heading: 'Contact',
          paragraphs: [
            'Questions about this policy: '
                'heinrich-development-support@googlegroups.com',
          ],
        ),
      ],
    );
  }

  @override
  PrivacyViewModel viewModelBuilder(BuildContext context) => PrivacyViewModel();
}
