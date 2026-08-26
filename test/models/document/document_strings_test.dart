import 'package:cv_forge/models/document/document_strings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// `documentStrings` is a lookup table with no ViewModel or Service above
/// it whose public API expresses it — the same carve-out
/// `ats_matrix_math_test.dart` documents. Reaching it through
/// `CvComposer` would assert one language's worth of it per test while
/// leaving the other sixteen uncovered.

void main() {
  setUpAll(initializeDateFormatting);

  test('every shipped language has a table', () {
    expect(
      documentStrings.keys.toSet(),
      DocumentLanguage.values.toSet(),
      reason:
          'A language without an entry throws on the null assertion in '
          'DocumentLanguageX.strings the first time anyone exports a CV in it.',
    );
  });

  test('every entry is complete', () {
    for (final language in DocumentLanguage.values) {
      final s = language.strings;
      final fields = {
        'summary': s.summary,
        'experience': s.experience,
        'projects': s.projects,
        'skills': s.skills,
        'education': s.education,
        'hobbies': s.hobbies,
        'languages': s.languages,
        'nativeLanguage': s.nativeLanguage,
        'references': s.references,
        'publications': s.publications,
        'experienceFormal': s.experienceFormal,
        'contactLocation': s.contactLocation,
        'contactPhone': s.contactPhone,
        'contactEmail': s.contactEmail,
        'contactLink': s.contactLink,
        'present': s.present,
      };
      fields.forEach((field, value) {
        expect(
          value.trim(),
          isNotEmpty,
          reason: '${language.name}.$field is blank',
        );
      });

      expect(s.months, hasLength(12), reason: '${language.name}.months');
      expect(
        s.months.map((m) => m.trim()).where((m) => m.isEmpty),
        isEmpty,
        reason: '${language.name} has a blank month',
      );
    }
  });

  test('no two languages carry an identical table', () {
    // A variant exists only to express a difference. Two that agree on
    // every string mean one should be deleted and its callers pointed at
    // the other — see DocumentLanguage's doc comment.
    final seen = <String, DocumentLanguage>{};
    for (final language in DocumentLanguage.values) {
      final s = language.strings;
      final fingerprint = [
        s.summary,
        s.experience,
        s.projects,
        s.skills,
        s.education,
        s.hobbies,
        s.languages,
        s.nativeLanguage,
        s.references,
        s.publications,
        s.experienceFormal,
        s.contactLocation,
        s.contactPhone,
        s.contactEmail,
        s.contactLink,
        s.present,
        ...s.months,
      ].join(' ');

      final clash = seen[fingerprint];
      expect(
        clash,
        isNull,
        reason:
            '${language.name} is identical to ${clash?.name} — collapse them '
            'into one entry rather than shipping a variant that varies '
            'nothing.',
      );
      seen[fingerprint] = language;
    }
  });

  test('the checked-in month abbreviations still match CLDR', () {
    // The tripwire described on DocumentStrings.cldrTag. `intl: any` is
    // pinned by the SDK, so CLDR data can shift under an SDK bump and
    // silently rewrite the date line of every exported PDF. Failing here
    // turns that into a decision someone makes on purpose: either adopt
    // the new abbreviations and regenerate the goldens, or keep ours and
    // say why.
    //
    // Compared against SHORTMONTHS rather than `DateFormat.MMM`, which is
    // the obvious reach and is wrong for this. `MMM` resolves through the
    // locale's own abbreviated-month *pattern*, which in several locales
    // is the standalone form: de_AT renders 'Mär', 'Jun', 'Jul' there
    // against SHORTMONTHS' 'März', 'Juni', 'Juli', and en_AU renders
    // 'Jun'/'Jul' against 'June'/'July'. A CV date is a month beside a
    // year — the format context, which is SHORTMONTHS.
    final symbols = dateTimeSymbolMap();

    for (final language in DocumentLanguage.values) {
      final s = language.strings;
      final cldr = symbols[s.cldrTag];

      expect(
        cldr,
        isNotNull,
        reason:
            '${language.name} names CLDR locale ${s.cldrTag}, which the '
            'installed intl does not ship.',
      );
      expect(
        s.months,
        cldr!.SHORTMONTHS,
        reason:
            '${language.name} (${s.cldrTag}) has drifted from the CLDR data '
            'in the installed intl.',
      );
    }
  });
}
