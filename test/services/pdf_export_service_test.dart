import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/services/font_service.dart';
import 'package:cv_forge/services/pdf_export_service.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

ResolvedCv _fixtureCv({String bulletText = 'Delivered a standard result.'}) =>
    ResolvedCv(
      header: const ResolvedHeader(
        fullName: 'Jordan Ellery',
        headline: 'Senior Software Engineer',
        email: 'jordan.ellery@example.com',
        phone: '+44 7700 900123',
        location: 'Manchester',
        links: [
          ResolvedLink(label: 'LinkedIn', url: 'linkedin.com/in/jordanellery'),
        ],
      ),
      sections: [
        const ResolvedSection.summary(
          title: 'Summary',
          text: 'Experienced engineer.',
        ),
        ResolvedSection.experience(
          title: 'Experience',
          groups: [
            ResolvedCompanyGroup(
              company: 'Acme',
              location: 'London',
              positions: [
                ResolvedPosition(
                  role: 'Engineer',
                  dateRange: '01/2020 - current',
                  bullets: [ResolvedBullet(text: bulletText)],
                ),
              ],
            ),
          ],
        ),
        const ResolvedSection.skills(
          title: 'Skills',
          groups: [
            ResolvedSkillGroup(category: 'Languages', skills: ['Dart']),
          ],
        ),
        const ResolvedSection.education(
          title: 'Education',
          items: [
            ResolvedQualification(
              qualification: 'BSc Computing',
              institution: 'Leeds',
              yearLabel: '2018',
            ),
          ],
        ),
        const ResolvedSection.publications(
          title: 'Publications',
          items: [
            ResolvedPublication(
              title: 'A Study of Things',
              citation: 'Ellery, J. (2024). Journal of Examples, 1(1), 1–2.',
              link: 'doi.org/10.1234/example',
            ),
          ],
        ),
      ],
    );

void main() {
  // rootBundle.load needs a real binding, not just the default test one
  // `test()` gets for free — this is what the flagged unknown ("does
  // rootBundle resolve declared assets under flutter_test?") resolves to.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfExportServiceTest -', () {
    late MockFileDownloadService fileDownload;

    setUp(() {
      locator.registerSingleton<TemplateRegistryService>(
        TemplateRegistryService(),
      );
      locator.registerSingleton<FontService>(FontService());
      fileDownload = getAndRegisterFileDownloadService();
      when(
        fileDownload.saveFile(
          nameWithoutExtension: anyNamed('nameWithoutExtension'),
          bytes: anyNamed('bytes'),
          extension: anyNamed('extension'),
          mimeType: anyNamed('mimeType'),
        ),
      ).thenAnswer((_) async {});
    });
    tearDown(() => locator.reset());

    test(
      'FontService resolves the real Roboto assets under flutter_test',
      () async {
        final fonts = await FontService().load();

        expect(fonts.base, isNotNull);
        expect(fonts.bold, isNotNull);
        expect(fonts.italic, isNotNull);
        expect(fonts.boldItalic, isNotNull);
      },
    );

    test(
      'render produces non-empty bytes starting with the PDF header',
      () async {
        final service = PdfExportService();

        final bytes = await service.render(
          cv: _fixtureCv(),
          templateId: 'compact',
        );

        expect(bytes, isNotEmpty);
        expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
      },
    );

    test('with compress:false, the PDF embeds a CID font via Identity-H with '
        'a ToUnicode CMap — proof of ATS-extractable text, not a rasterized '
        'or base-14-fallback font', () async {
      final service = PdfExportService();

      final bytes = await service.render(
        cv: _fixtureCv(),
        templateId: 'compact',
        compress: false,
      );

      // compress:false keeps every indirect object — including the font
      // dictionaries these markers live in — as plaintext PDF syntax
      // rather than grouped into a compressed object stream, so a naive
      // byte-level search finds them.
      final content = latin1.decode(bytes);
      expect(content, contains('/Identity-H'));
      expect(content, contains('/ToUnicode'));
    });

    test('a bullet with smart quotes, an em-dash, an ellipsis, and a euro '
        'sign renders without throwing — the entire justification for '
        "using Roboto's embedded glyphs over the base-14 fallback", () async {
      final service = PdfExportService();

      final bytes = await service.render(
        cv: _fixtureCv(bulletText: 'Delivered “results” — on budget… for €2m.'),
        templateId: 'compact',
      );

      expect(bytes, isNotEmpty);
      expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
    });

    test('an entry with far more bullets than fit on one page paginates '
        'across as many pages as it needs, rather than failing the '
        'export — each bullet is its own top-level pw.MultiPage widget, '
        'not grouped into a nested pw.Column, which is what makes genuine '
        'cross-page splitting between bullets possible at all', () async {
      final service = PdfExportService();

      final manyBullets = ResolvedCv(
        header: const ResolvedHeader(
          fullName: 'Jordan Ellery',
          headline: 'Senior Software Engineer',
          email: 'jordan.ellery@example.com',
          phone: '+44 7700 900123',
          location: 'Manchester',
          links: [],
        ),
        sections: [
          ResolvedSection.experience(
            title: 'Experience',
            groups: [
              ResolvedCompanyGroup(
                company: 'Acme',
                location: 'London',
                positions: [
                  ResolvedPosition(
                    role: 'Engineer',
                    dateRange: '01/2020 - current',
                    bullets: [
                      for (var i = 0; i < 200; i++)
                        ResolvedBullet(text: 'Delivered result number $i.'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final bytes = await service.render(
        cv: manyBullets,
        templateId: 'compact',
      );

      expect(bytes, isNotEmpty);
      expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
    });

    test('a single bullet whose own text is too long to fit on any one '
        'page — even a fresh one — fails the export with a clean '
        'PdfExportException rather than an uncaught crash. Neither the '
        'pagination guard nor PdfExportService.render\'s fallback retry '
        'can rescue this: a bullet is built from a pw.Row, which is '
        'inherently non-spanning regardless of pw.Inseparable, so a '
        'single bullet taller than a page is a genuine content limit, not '
        'a bug either mechanism is meant to paper over', () async {
      final service = PdfExportService();

      final oneEnormousBullet = ResolvedCv(
        header: const ResolvedHeader(
          fullName: 'Jordan Ellery',
          headline: 'Senior Software Engineer',
          email: 'jordan.ellery@example.com',
          phone: '+44 7700 900123',
          location: 'Manchester',
          links: [],
        ),
        sections: [
          ResolvedSection.experience(
            title: 'Experience',
            groups: [
              ResolvedCompanyGroup(
                company: 'Acme',
                location: 'London',
                positions: [
                  ResolvedPosition(
                    role: 'Engineer',
                    dateRange: '01/2020 - current',
                    // 1500 words wraps to far more lines than fit on a
                    // full A4 page even on its own, confirmed empirically
                    // against the real renderer, not just estimated.
                    bullets: [
                      ResolvedBullet(
                        text: List.generate(1500, (i) => 'word$i').join(' '),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await expectLater(
        service.render(cv: oneEnormousBullet, templateId: 'compact'),
        throwsA(
          isA<PdfExportException>().having(
            (e) => e.stage,
            'stage',
            PdfExportStage.render,
          ),
        ),
      );
    });

    test(
      'export slugifies name+draft into the saver filename with no '
      'extension in the name — an extension there would yield cv.pdf.pdf',
      () async {
        final service = PdfExportService();

        await service.export(
          cv: _fixtureCv(),
          templateId: 'compact',
          fullName: 'Jordan Ellery',
          draftName: 'My CV',
        );

        final captured = verify(
          fileDownload.saveFile(
            nameWithoutExtension: captureAnyNamed('nameWithoutExtension'),
            bytes: anyNamed('bytes'),
            extension: 'pdf',
            mimeType: MimeType.pdf,
          ),
        ).captured;

        expect(captured.single, 'jordan_ellery_my_cv');
        expect(captured.single, isNot(contains('.pdf')));
      },
    );

    group('classic_centered -', () {
      test('with compress:false, the PDF embeds a CID font via Identity-H '
          'with a ToUnicode CMap — the same ATS-extractability guarantee '
          'compact is held to, verified per-template rather than '
          'assumed to carry over', () async {
        final service = PdfExportService();

        final bytes = await service.render(
          cv: _fixtureCv(),
          templateId: 'classic_centered',
          compress: false,
        );

        final content = latin1.decode(bytes);
        expect(content, contains('/Identity-H'));
        expect(content, contains('/ToUnicode'));
      });

      test('a bullet with smart quotes, an em-dash, an ellipsis, and a euro '
          'sign renders without throwing', () async {
        final service = PdfExportService();

        final bytes = await service.render(
          cv: _fixtureCv(
            bulletText: 'Delivered “results” — on budget… for €2m.',
          ),
          templateId: 'classic_centered',
        );

        expect(bytes, isNotEmpty);
        expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
      });
    });
  });
}
