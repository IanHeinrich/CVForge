import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

import '../../models/render/resolved_cv.dart';
import '../../models/render/resolved_section.dart';
import '../design/cv_design_tokens_flutter.dart';
import 'ats_minimal_tokens.dart';

const _fontFamily = 'Roboto';

/// Flutter-only rendering of [ResolvedCv] in the `ats_minimal` style. Lives
/// at natural PDF-point size — [CvPageSurface] owns scaling to the
/// viewport, not this widget.
class AtsMinimalScreenRenderer extends StatelessWidget {
  const AtsMinimalScreenRenderer({
    super.key,
    required this.cv,
    required this.format,
  });

  final ResolvedCv cv;
  final PdfPageFormat format;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: format.width,
      color: Colors.white,
      padding: atsMinimalTokens.pageMargins,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(header: cv.header),
          for (final section in cv.sections) ...[
            SizedBox(height: atsMinimalTokens.sectionGap),
            _Section(section: section),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.header});

  final ResolvedHeader header;

  @override
  Widget build(BuildContext context) {
    final contactLine = [
      header.location,
      header.phone,
      header.email,
      for (final link in header.links) link.url,
    ].where((s) => s.trim().isNotEmpty).join(' | ');

    return Column(
      children: [
        Text(
          header.fullName,
          textAlign: TextAlign.center,
          style: atsMinimalTokens.name.toTextStyle(_fontFamily),
        ),
        if (header.headline.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            header.headline,
            textAlign: TextAlign.center,
            style: atsMinimalTokens.company.toTextStyle(_fontFamily),
          ),
        ],
        if (contactLine.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            contactLine,
            textAlign: TextAlign.center,
            style: atsMinimalTokens.contact.toTextStyle(_fontFamily),
          ),
        ],
      ],
    );
  }
}

/// Resolves a [ResolvedSection] to its heading + body. One `switch` here
/// is what a new section type costs — no template-wide restructuring.
class _Section extends StatelessWidget {
  const _Section({required this.section});

  final ResolvedSection section;

  @override
  Widget build(BuildContext context) {
    // The summary sits directly under the header with no label of its
    // own, matching the r/EngineeringResumes template this design is
    // modelled on — every other section keeps its heading.
    final isSummary = section is ResolvedSummarySection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isSummary) _SectionHeading(title: section.title),
        switch (section) {
          ResolvedSummarySection(text: final text) => _BodyText(text: text),
          ResolvedSkillsSection(groups: final groups) => _SkillGroups(
            groups: groups,
          ),
          ResolvedExperienceSection(groups: final groups) => _CompanyGroups(
            groups: groups,
          ),
          ResolvedProjectsSection(items: final items) => _Projects(
            items: items,
          ),
          ResolvedEducationSection(items: final items) => _Education(
            items: items,
          ),
          ResolvedHobbiesSection(items: final items) => _BodyText(
            text: items.join(', '),
          ),
          ResolvedReferencesSection(text: final text) => _BodyText(text: text),
        },
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: atsMinimalTokens.sectionHeading.toTextStyle(_fontFamily),
        ),
        SizedBox(height: atsMinimalTokens.sectionRuleGap),
        Container(
          height: atsMinimalTokens.ruleThickness,
          color: Color(atsMinimalTokens.ruleColorArgb),
        ),
        SizedBox(height: atsMinimalTokens.sectionRuleGap),
      ],
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: atsMinimalTokens.body.toTextStyle(_fontFamily));
  }
}

/// A left label + right value on one row — the "role, dates" and
/// "institution, year" rows every section but Skills uses.
class _LabelledRow extends StatelessWidget {
  const _LabelledRow({required this.left, this.right});

  final InlineSpan left;
  final String? right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RichText(text: TextSpan(children: [left])),
        ),
        if (right != null && right!.isNotEmpty)
          Text(right!, style: atsMinimalTokens.meta.toTextStyle(_fontFamily)),
      ],
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.bullets});

  final List<ResolvedBullet> bullets;

  @override
  Widget build(BuildContext context) {
    if (bullets.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(
        top: atsMinimalTokens.bulletGap,
        left: atsMinimalTokens.bulletIndent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final bullet in bullets)
            Padding(
              padding: EdgeInsets.only(bottom: atsMinimalTokens.bulletGap),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(text: '• '),
                    if (bullet.label != null)
                      TextSpan(
                        text: '${bullet.label}: ',
                        style: atsMinimalTokens.bulletLabel.toTextStyle(
                          _fontFamily,
                        ),
                      ),
                    TextSpan(
                      text: bullet.text,
                      style: atsMinimalTokens.bullet.toTextStyle(_fontFamily),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillGroups extends StatelessWidget {
  const _SkillGroups({required this.groups});

  final List<ResolvedSkillGroup> groups;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups)
          Padding(
            padding: EdgeInsets.only(bottom: atsMinimalTokens.bulletGap),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${group.category}: ',
                    style: atsMinimalTokens.bulletLabel.toTextStyle(
                      _fontFamily,
                    ),
                  ),
                  TextSpan(
                    text: group.skills.join(', '),
                    style: atsMinimalTokens.body.toTextStyle(_fontFamily),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CompanyGroups extends StatelessWidget {
  const _CompanyGroups({required this.groups});

  final List<ResolvedCompanyGroup> groups;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups)
          Padding(
            padding: EdgeInsets.only(bottom: atsMinimalTokens.itemGap),
            child: group.positions.length == 1
                ? _singlePosition(group.positions.single, group)
                : _promotionGroup(group),
          ),
      ],
    );
  }

  Widget _singlePosition(
    ResolvedPosition position,
    ResolvedCompanyGroup group,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabelledRow(
          left: TextSpan(
            children: [
              TextSpan(
                text: '${position.role}, ',
                style: atsMinimalTokens.role.toTextStyle(_fontFamily),
              ),
              TextSpan(
                text: '${group.company} – ${group.location}',
                style: atsMinimalTokens.company.toTextStyle(_fontFamily),
              ),
            ],
          ),
          right: position.dateRange,
        ),
        _Bullets(bullets: position.bullets),
      ],
    );
  }

  /// A promotion: the company is shown once, then each role with its own
  /// date range and bullets nested beneath.
  Widget _promotionGroup(ResolvedCompanyGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${group.company} – ${group.location}',
          style: atsMinimalTokens.role.toTextStyle(_fontFamily),
        ),
        for (final position in group.positions)
          Padding(
            padding: EdgeInsets.only(
              top: atsMinimalTokens.bulletGap,
              left: atsMinimalTokens.bulletIndent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LabelledRow(
                  left: TextSpan(
                    text: position.role,
                    style: atsMinimalTokens.company.toTextStyle(_fontFamily),
                  ),
                  right: position.dateRange,
                ),
                _Bullets(bullets: position.bullets),
              ],
            ),
          ),
      ],
    );
  }
}

class _Projects extends StatelessWidget {
  const _Projects({required this.items});

  final List<ResolvedProject> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final project in items)
          Padding(
            padding: EdgeInsets.only(bottom: atsMinimalTokens.itemGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LabelledRow(
                  left: TextSpan(
                    text: project.title,
                    style: atsMinimalTokens.role.toTextStyle(_fontFamily),
                  ),
                  right: project.link,
                ),
                _Bullets(bullets: project.bullets),
              ],
            ),
          ),
      ],
    );
  }
}

class _Education extends StatelessWidget {
  const _Education({required this.items});

  final List<ResolvedQualification> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final edu in items)
          Padding(
            padding: EdgeInsets.only(bottom: atsMinimalTokens.bulletGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LabelledRow(
                  left: TextSpan(
                    children: [
                      TextSpan(
                        text: edu.institution,
                        style: atsMinimalTokens.role.toTextStyle(_fontFamily),
                      ),
                      TextSpan(
                        text: ' – ${edu.qualification}',
                        style: atsMinimalTokens.company.toTextStyle(
                          _fontFamily,
                        ),
                      ),
                    ],
                  ),
                  right: edu.yearLabel,
                ),
                if ([
                  edu.grade,
                  edu.details,
                ].any((s) => s != null && s.trim().isNotEmpty))
                  Text(
                    [edu.grade, edu.details]
                        .where((s) => s != null && s.trim().isNotEmpty)
                        .join(' – '),
                    style: atsMinimalTokens.meta.toTextStyle(_fontFamily),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
