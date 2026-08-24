import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

/// One section of a legal page: an optional heading and its paragraphs.
class LegalSection {
  const LegalSection({this.heading, required this.paragraphs});

  final String? heading;
  final List<String> paragraphs;
}

/// The page frame `PrivacyView` and `TermsView` share — a back link, a
/// title and effective date, then a column of [LegalSection]s.
///
/// Non-responsive on purpose: this content doesn't change shape by
/// breakpoint, just reflows, so a `.desktop`/`.tablet`/`.mobile` split
/// would be three near-identical files.
///
/// The copy is English in every locale — see CLAUDE.md's list of what is
/// deliberately not localized.
class LegalPageScaffold extends StatelessWidget {
  const LegalPageScaffold({
    super.key,
    required this.title,
    required this.effectiveDate,
    required this.sections,
  });

  static const _contentMaxWidth = 640.0;

  final String title;
  final String effectiveDate;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
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
                  Text(title, style: context.appTypography.titleMedium),
                  const VGap.tiny(),
                  Text(effectiveDate, style: context.appTypography.caption),
                  const VGap.medium(),
                  for (final section in sections) ..._section(context, section),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _section(BuildContext context, LegalSection section) => [
    if (section.heading != null) ...[
      Text(
        section.heading!,
        style: context.appTypography.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const VGap.tiny(),
    ],
    for (final paragraph in section.paragraphs) ...[
      Text(paragraph, style: context.appTypography.bodySmall),
      const VGap.small(),
    ],
    const VGap.medium(),
  ];
}
