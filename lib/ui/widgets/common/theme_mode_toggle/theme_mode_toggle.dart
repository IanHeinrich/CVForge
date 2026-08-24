import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/settings/app_theme_mode.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// The nav rail's appearance control: one button that cycles
/// Light → Dark → System, animating between a sun, a moon and a monitor.
///
/// A cycling button rather than a three-way picker because the rail has
/// room for one glyph, and the icon doubles as the read-out of the current
/// state. That makes the *next* state invisible, which is what the tooltip
/// is for — it names both. `AppearanceSettingsCard` in Settings is the
/// canonical control that shows all three at once, and is the only one
/// mobile has (there is no rail there to hang this on).
///
/// Reads `SettingsService` directly rather than taking a ViewModel: it is
/// shared chrome hosted by `AppChrome`, which several unrelated
/// ViewModels sit under. Rebuilds come from the `ListenableBuilder` around
/// `MaterialApp` in `main.dart`, which already rebuilds on every
/// `SettingsService` notification.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  /// Light → Dark → System → Light. System sits last so that a user who
  /// only ever wants to flip the lights taps between the two explicit
  /// modes, and reaches "follow my device" by carrying on round rather
  /// than by hunting for it.
  static AppThemeMode _next(AppThemeMode current) => switch (current) {
    AppThemeMode.light => AppThemeMode.dark,
    AppThemeMode.dark => AppThemeMode.system,
    AppThemeMode.system => AppThemeMode.light,
  };

  static IconData _iconFor(AppThemeMode mode) => switch (mode) {
    AppThemeMode.light => RemixIcons.sun_line,
    AppThemeMode.dark => RemixIcons.moon_line,
    AppThemeMode.system => RemixIcons.computer_line,
  };

  static String _labelFor(AppThemeMode mode) => switch (mode) {
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
    AppThemeMode.system => 'Match device',
  };

  @override
  Widget build(BuildContext context) {
    final settingsService = locator<SettingsService>();
    final mode = settingsService.settings.themeMode;
    final next = _next(mode);

    return IconButton(
      tooltip: 'Theme: ${_labelFor(mode)} — switch to ${_labelFor(next)}',
      onPressed: () => settingsService.setThemeMode(next),
      icon: AnimatedSwitcher(
        duration: context.appMotion.iconSwap,
        // The outgoing glyph turns out as the incoming one turns in, so
        // the swap reads as one object rotating rather than two icons
        // dissolving in place. A quarter turn: a full spin at this
        // duration reads as a loading indicator.
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          _iconFor(mode),
          // Keyed so `AnimatedSwitcher` treats a mode change as a new
          // child. Without it the `Icon` widget is the same type with a
          // different field and the switcher never animates.
          key: ValueKey(mode),
          size: context.appIconSize.medium,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
