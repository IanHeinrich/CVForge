import 'package:cv_forge/ui/widgets/common/legal_page_scaffold/legal_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'terms_viewmodel.dart';

/// Linked from the same OAuth consent screen section as [PrivacyView],
/// though Google requires only the policy. States that CVForge is a
/// free, source-available personal project with no warranty.
class TermsView extends StackedView<TermsViewModel> {
  const TermsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    TermsViewModel viewModel,
    Widget? child,
  ) {
    return LegalPageScaffold(
      title: 'Terms of Service',
      effectiveDate: 'Effective 23 August 2026',
      sections: const [
        LegalSection(
          paragraphs: [
            'CVForge is a free, source-available personal '
                'project, not a company or a paid product. These '
                'terms are intentionally short.',
          ],
        ),
        LegalSection(
          heading: 'The app, as-is',
          paragraphs: [
            'CVForge is provided free of charge, "as is" and "as '
                'available", with no warranty of any kind, '
                'express or implied. That includes no guarantee '
                'it will always be available or error-free. '
                "It's hosted on GitHub Pages with no uptime "
                'commitment.',
          ],
        ),
        LegalSection(
          heading: 'Your data, your responsibility',
          paragraphs: [
            'Because CVForge stores your Vault and CVs only in '
                'your own browser (and, if you choose to enable '
                'it, your own Google Drive), you are responsible '
                'for keeping your own backups. Clearing your '
                "browser's site data, or disconnecting Drive "
                'sync incorrectly, can result in permanent data '
                'loss that CVForge cannot recover on your behalf.',
          ],
        ),
        LegalSection(
          heading: 'Third-party services',
          paragraphs: [
            'If you use the AI Assistant or Google Drive sync, '
                "you are also bound by that provider's own terms: "
                "Anthropic's, Google's Gemini API terms, or "
                "Google's own Terms of Service for your Drive "
                'account. CVForge has no control over, and no '
                "responsibility for, those providers' services.",
          ],
        ),
        LegalSection(
          heading: 'Acceptable use',
          paragraphs: [
            "Don't use CVForge to violate the law, or to abuse "
                "any third-party API (Google's or an AI "
                "provider's) beyond that provider's own "
                'acceptable-use terms.',
          ],
        ),
        LegalSection(
          heading: 'Source available',
          paragraphs: [
            'CVForge is source-available on GitHub under the '
                'PolyForm Noncommercial License 1.0.0. See the '
                "repository's own license file for the exact "
                'terms governing the code itself.',
          ],
        ),
        LegalSection(
          heading: 'Limitation of liability',
          paragraphs: [
            "To the fullest extent permitted by law, CVForge's "
                'developer is not liable for any damages arising '
                'from your use of the app, including lost data.',
          ],
        ),
        LegalSection(
          heading: 'Changes',
          paragraphs: [
            'These terms may be updated from time to time; the '
                'current version always lives at this page.',
          ],
        ),
        LegalSection(
          heading: 'Contact',
          paragraphs: ['heinrich-development-support@googlegroups.com'],
        ),
      ],
    );
  }

  @override
  TermsViewModel viewModelBuilder(BuildContext context) => TermsViewModel();
}
