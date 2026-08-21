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
  // `test()` gets for free — this is what P1.6's flagged unknown ("does
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
          templateId: 'ats_minimal',
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
        templateId: 'ats_minimal',
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
        templateId: 'ats_minimal',
      );

      expect(bytes, isNotEmpty);
      expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
    });

    test(
      'export slugifies name+draft into the saver filename with no '
      'extension in the name — an extension there would yield cv.pdf.pdf',
      () async {
        final service = PdfExportService();

        await service.export(
          cv: _fixtureCv(),
          templateId: 'ats_minimal',
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

    group('structured_serif -', () {
      test('with compress:false, the PDF embeds a CID font via Identity-H '
          'with a ToUnicode CMap — the same ATS-extractability guarantee '
          'ats_minimal is held to, verified per-template rather than '
          'assumed to carry over', () async {
        final service = PdfExportService();

        final bytes = await service.render(
          cv: _fixtureCv(),
          templateId: 'structured_serif',
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
          templateId: 'structured_serif',
        );

        expect(bytes, isNotEmpty);
        expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
      });
    });
  });
}
