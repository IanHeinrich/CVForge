/// What happens to an open inline editor when the list around it is
/// rebuilt.
///
/// A pumped widget test rather than a unit one, because the behaviour
/// lives entirely in `didUpdateWidget` — it only runs when the list is
/// handed new items, which is exactly what a keystroke in Studio does.
library;

import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';
import 'package:cv_forge/features/studio/widgets/vault_item_selector_list.dart';
import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remixicon/remixicon.dart';

/// A bullet id in the shape the app really produces: the worked example's
/// `exp-1-b1`, and a uuid for one the user added. Neither contains an
/// underscore, which is the whole point — nothing about a bullet's id
/// says which entry it belongs to.
const _fixtureBulletId = 'exp-1-b1';
const _uuidBulletId = '9f8b2c14-6a3d-4e51-90cf-7d2b1a4e8c33';

SelectorItem _bullet(String id) => SelectorItem(
  id: id,
  title: 'Cut deploy time in half',
  selected: true,
  onToggle: () {},
  titleField: TailorableField(
    hasOverride: false,
    effectiveText: 'Cut deploy time in half',
    vaultText: 'Cut deploy time in half',
    onChanged: (_) async {},
    onRevert: () async {},
  ),
);

SelectorItem _entry({
  required bool selected,
  required List<String> bulletIds,
}) => SelectorItem(
  id: 'exp-1',
  title: 'Senior Software Engineer',
  selected: selected,
  onToggle: () {},
  bullets: [for (final id in bulletIds) _bullet(id)],
);

Future<void> _pump(WidgetTester tester, SelectorItem item) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: VaultItemSelectorList(
            title: 'Work history',
            items: [item],
            unselectedCount: 0,
            selectedCount: 1,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Opens the bullet sub-list and then the first bullet's inline editor.
Future<void> _openBulletEditor(WidgetTester tester) async {
  await tester.tap(find.textContaining('bullet'));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(RemixIcons.edit_line).first);
  await tester.pumpAndSettle();
}

void main() {
  group('VaultItemSelectorList - a bullet editor left open -', () {
    for (final id in [_fixtureBulletId, _uuidBulletId]) {
      testWidgets('survives the list being rebuilt around it, for id "$id" — '
          'a bullet id carries no entry name to parse back out, and every '
          'keystroke in Studio rebuilds this list', (tester) async {
        await _pump(tester, _entry(selected: true, bulletIds: [id]));
        await _openBulletEditor(tester);
        expect(find.byType(TextField), findsOneWidget);

        // The rebuild a keystroke causes: same rows, new SelectorItem
        // instances.
        await _pump(tester, _entry(selected: true, bulletIds: [id]));
        await tester.pump();

        // Specifically not `isNull`: an open editor also trips Flutter's
        // debug-only "ListTile inside a DecoratedBox" ink warning, which
        // predates this and is not what this test is about.
        expect(tester.takeException(), isNot(isA<RangeError>()));
        expect(find.byType(TextField), findsOneWidget);
      });
    }

    testWidgets('closes when its entry is dropped from the CV — the row it '
        'belongs to is no longer on screen, and leaving the id behind '
        'reopened an editor nobody asked for on re-include', (tester) async {
      await _pump(
        tester,
        _entry(selected: true, bulletIds: [_fixtureBulletId]),
      );
      await _openBulletEditor(tester);
      expect(find.byType(TextField), findsOneWidget);

      await _pump(
        tester,
        _entry(selected: false, bulletIds: [_fixtureBulletId]),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNot(isA<RangeError>()));
      expect(find.byType(TextField), findsNothing);

      // Back in the CV, and the editor stays shut.
      await _pump(
        tester,
        _entry(selected: true, bulletIds: [_fixtureBulletId]),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
    });
  });
}
