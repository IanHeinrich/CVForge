// Dev-only: renders the photo template so a header change can be looked at
// rather than guessed at. Not part of the app or the test suite.
//
//   flutter test tool/render_photo_samples.dart
import 'dart:convert';
import 'dart:io';

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/services/font_service.dart';
import 'package:cv_forge/templates/compact/compact_template.dart';
import 'package:cv_forge/templates/photo_header/photo_header_template.dart';
import 'package:cv_forge/templates/photo_header/photo_header_tokens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';

String _photo() {
  // A recognisable stand-in: warm oval on a light ground, so the circular
  // mask and the ring are both obvious in the render.
  final im = img.Image(width: 512, height: 512);
  img.fill(im, color: img.ColorRgb8(206, 214, 224));
  img.fillCircle(
    im,
    x: 256,
    y: 300,
    radius: 190,
    color: img.ColorRgb8(226, 190, 160),
  );
  img.fillCircle(
    im,
    x: 256,
    y: 210,
    radius: 120,
    color: img.ColorRgb8(238, 205, 178),
  );
  return base64Encode(img.encodeJpg(im, quality: 90));
}

/// The labels `photo_header` prints beside each contact detail. Two sets
/// so a render can show they actually follow the document language — that
/// block used to be hard-coded English on every CV.
const _englishLabels = ResolvedContactLabels(
  location: 'Location',
  phone: 'Phone',
  email: 'Email',
  link: 'Link',
);

const _germanLabels = ResolvedContactLabels(
  location: 'Ort',
  phone: 'Telefon',
  email: 'E-Mail',
  link: 'Link',
);

ResolvedCv _cv({
  required bool withPhoto,
  String name = 'Jordan Ellery',
  int repeatExperience = 1,
  String? workAuthorization =
      'Right to work in the UK, no sponsorship '
      'required',
  ResolvedContactLabels labels = _englishLabels,
}) => ResolvedCv(
  header: ResolvedHeader(
    fullName: name,
    headline: 'Senior Software Engineer',
    email: 'jordan.ellery@example.com',
    phone: '+44 7700 900123',
    location: 'Manchester',
    links: const [
      ResolvedLink(label: 'LinkedIn', url: 'linkedin.com/in/jordanellery'),
    ],
    workAuthorization: workAuthorization,
    contactLabels: labels,
    photoJpegBase64: withPhoto ? _photo() : null,
  ),
  sections: [
    ResolvedSection.summary(
      title: 'Professional summary',
      text:
          'Backend engineer with nine years building payment systems '
          'that stay up. Comfortable owning a service end to end, from '
          'schema to on-call.',
    ),
    ResolvedSection.experience(
      title: 'Experience',
      titleFormal: 'Professional Experience',
      groups: [
        for (var i = 0; i < repeatExperience; i++)
          ResolvedCompanyGroup(
            company: 'Acme Payments',
            location: 'Manchester',
            positions: [
              ResolvedPosition(
                role: 'Senior Software Engineer',
                dateRange: 'Jan 2021 - Present',
                bullets: [
                  ResolvedBullet(
                    text:
                        'Cut settlement latency by 40% by replacing a '
                        'nightly batch with an event-driven pipeline.',
                  ),
                  ResolvedBullet(
                    text:
                        'Led the migration of 30 services onto a shared '
                        'deployment platform.',
                  ),
                ],
              ),
            ],
          ),
      ],
    ),
    ResolvedSection.skills(
      title: 'Skills',
      groups: [
        ResolvedSkillGroup(
          category: 'Languages',
          skills: ['Dart', 'Go', 'Python', 'SQL'],
        ),
        ResolvedSkillGroup(
          category: 'Platform',
          skills: ['Kubernetes', 'Terraform', 'Postgres'],
        ),
      ],
    ),
    ResolvedSection.projects(
      title: 'Projects',
      items: [
        ResolvedProject(
          title: 'Ledger reconciliation toolkit',
          link: 'github.com/jordanellery/ledger',
          bullets: [
            ResolvedBullet(
              text:
                  'Open-source library for reconciling double-entry '
                  'ledgers against bank feeds.',
            ),
          ],
        ),
        ResolvedProject(
          title: 'Schema drift detector',
          bullets: [
            ResolvedBullet(
              text:
                  'Catches breaking migrations before they reach '
                  'staging.',
            ),
          ],
        ),
      ],
    ),
    ResolvedSection.education(
      title: 'Education',
      items: [
        ResolvedQualification(
          qualification: 'MSc Distributed Systems',
          institution: 'University of Manchester',
          yearLabel: '2016',
        ),
        ResolvedQualification(
          qualification: 'BSc Computer Science',
          institution: 'University of Leeds',
          yearLabel: '2015',
        ),
      ],
    ),
    ResolvedSection.publications(
      title: 'Publications',
      items: [
        ResolvedPublication(
          title: 'Idempotency keys at scale',
          citation: 'Ellery, J. (2024). Journal of Examples, 1(1), 1-12.',
        ),
        ResolvedPublication(
          title: 'A note on settlement windows',
          citation: 'Ellery, J. (2023). Payments Review, 8(2), 44-51.',
        ),
      ],
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render photo header samples', () async {
    final fonts = await FontService().load();
    final out = Directory('build/photo_samples')..createSync(recursive: true);

    Future<void> write(
      String label,
      ResolvedCv cv, {
      PhotoHeaderStyle style = photoHeaderStyle,
    }) async {
      final bytes = await PhotoHeaderTemplate(
        style: style,
      ).buildDocument(cv, PdfPageFormat.a4, fonts).save();
      File('${out.path}/$label.pdf').writeAsBytesSync(bytes);
    }

    PhotoHeaderStyle tinted(int fill, int accent) => PhotoHeaderStyle(
      bandFillArgb: fill,
      accentArgb: accent,
      bandHeightPt: photoHeaderStyle.bandHeightPt,
      bandHeightNoPhotoPt: photoHeaderStyle.bandHeightNoPhotoPt,
      photoDiameterPt: photoHeaderStyle.photoDiameterPt,
      photoRingPt: photoHeaderStyle.photoRingPt,
      photoRingArgb: photoHeaderStyle.photoRingArgb,
      photoInsetPt: photoHeaderStyle.photoInsetPt,
      contactLabelWidthPt: photoHeaderStyle.contactLabelWidthPt,
      contactLineHeightPt: photoHeaderStyle.contactLineHeightPt,
      nameToContactPt: photoHeaderStyle.nameToContactPt,
      workAuthorizationGapPt: photoHeaderStyle.workAuthorizationGapPt,
      workAuthorizationBandPt: photoHeaderStyle.workAuthorizationBandPt,
      afterRuleGapPt: photoHeaderStyle.afterRuleGapPt,
      continuationTopPt: photoHeaderStyle.continuationTopPt,
      markTopWidthPt: photoHeaderStyle.markTopWidthPt,
      markTopHeightPt: photoHeaderStyle.markTopHeightPt,
      markTopYPt: photoHeaderStyle.markTopYPt,
      markBottomWidthPt: photoHeaderStyle.markBottomWidthPt,
      markBottomHeightPt: photoHeaderStyle.markBottomHeightPt,
      markBottomRightPt: photoHeaderStyle.markBottomRightPt,
    );

    await write('with_photo', _cv(withPhoto: true));
    // The same content through Compact, for comparing how each template's
    // entry layout behaves under `AtsAnalyzerService`'s column-gap rule.
    File('${out.path}/compact_baseline.pdf').writeAsBytesSync(
      await const CompactTemplate()
          .buildDocument(_cv(withPhoto: false), PdfPageFormat.a4, fonts)
          .save(),
    );
    // Long enough to spill onto a second page: checks that the band and
    // the top mark do NOT repeat there, and that the continuation page
    // gets its top margin back.
    await write('two_page', _cv(withPhoto: true, repeatExperience: 6));
    await write('no_photo', _cv(withPhoto: false));
    await write(
      'long_name',
      _cv(withPhoto: true, name: 'Alexandra Fitzwilliam-Beaumont'),
    );
    // The work-authorisation line is a whole sentence, so it is the one
    // header value that can wrap. Long enough here to prove it wraps
    // rather than clipping, and that the band still seats every row.
    await write(
      'long_work_authorization',
      _cv(
        withPhoto: true,
        workAuthorization:
            'Authorised to work in the United Kingdom and across the '
            'European Union indefinitely; no visa sponsorship required '
            'for either.',
      ),
    );
    // Same CV with German labels: the contact block used to say
    // "Location" whatever language the document was in.
    await write('german_labels', _cv(withPhoto: true, labels: _germanLabels));
    await write(
      'no_work_authorization',
      _cv(withPhoto: true, workAuthorization: null),
    );

    // Colourways, for picking by eye rather than by hex code.
    await write('colour_a_sage', _cv(withPhoto: true));
    await write(
      'colour_b_slate',
      _cv(withPhoto: true),
      style: tinted(0xFFE7ECF0, 0xFF74849A),
    );
    await write(
      'colour_c_stone',
      _cv(withPhoto: true),
      style: tinted(0xFFEFEAE3, 0xFF9A8A73),
    );
    await write(
      'colour_d_mist',
      _cv(withPhoto: true),
      style: tinted(0xFFEAEDEE, 0xFF8A9698),
    );
    stdout.writeln('wrote ${out.path}');
  });
}
