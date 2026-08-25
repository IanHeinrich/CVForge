/// The length budget's one load-bearing property: it measures what the
/// page receives, not what the keyboard produced.
///
/// A widget test rather than a unit one, because the threshold is a
/// rendering decision — the warning is either on screen or it is not, and
/// that is the whole behaviour worth pinning.
library;

import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/models/llm/llm_field_length_guard.dart';
import 'package:cv_forge/models/render/cv_markup.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, String text) async {
  await tester.pumpWidget(
    MaterialApp(
      // The real theme, not a bare MaterialApp: the field reads spacing,
      // typography and palette from `ThemeExtension`s that only exist on
      // it.
      theme: buildAppTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AppTextField(
          initialValue: text,
          onChanged: (_) {},
          maxLines: 4,
          markup: true,
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Text of roughly the given printed length, built from whole words.
String _prose(int printedChars) =>
    List.filled(printedChars ~/ 5, 'word').join(' ');

void main() {
  testWidgets('says nothing while a field is nowhere near the page limit', (
    tester,
  ) async {
    await _pump(tester, _prose(200));

    expect(find.textContaining('characters left'), findsNothing);
    expect(find.textContaining('Too long'), findsNothing);
  });

  testWidgets('warns once a field is close to filling the page', (
    tester,
  ) async {
    await _pump(tester, _prose((maxRenderableFieldChars * 0.95).round()));

    expect(find.textContaining('characters left'), findsOneWidget);
  });

  testWidgets('states the consequence once the field is past the limit', (
    tester,
  ) async {
    await _pump(tester, _prose(maxRenderableFieldChars + 500));

    expect(find.textContaining('Too long'), findsOneWidget);
  });

  testWidgets(
    'emphasis does not spend the budget — the markers occupy no page, so '
    'bolding a sentence must not bring the warning closer',
    (tester) async {
      // Comfortably under the limit as printed, but well over it once
      // every word carries markers.
      final plain = _prose(3000);
      final emphasised = plain.replaceAll('word', '**word**');
      expect(emphasised.length, greaterThan(maxRenderableFieldChars));
      expect(
        stripCvMarkup(emphasised).length,
        lessThan(maxRenderableFieldChars * 0.85),
      );

      await _pump(tester, emphasised);

      expect(find.textContaining('characters left'), findsNothing);
      expect(find.textContaining('Too long'), findsNothing);
    },
  );
}
