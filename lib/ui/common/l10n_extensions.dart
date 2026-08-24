import 'package:flutter/widgets.dart';

import 'package:cv_forge/l10n/generated/app_localizations.dart';

/// `context.l10n.someKey` — the access path for Views and Widgets.
///
/// Non-null because `l10n.yaml` sets `nullable-getter: false`, so no call site
/// needs a `!`.
///
/// ViewModels and Services do *not* use this; they have no context and read
/// `locator<LocalizationService>().strings` instead. Both resolve to the same
/// locale — see `LocalizationService` for why.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
