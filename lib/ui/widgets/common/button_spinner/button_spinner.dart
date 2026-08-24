import 'package:flutter/material.dart';

/// The in-button busy indicator, sized to sit inside a [FilledButton] or
/// [OutlinedButton] without changing its height. Shared rather than
/// redeclared per card — every settings/action button that swaps its label
/// for a spinner uses this one.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
