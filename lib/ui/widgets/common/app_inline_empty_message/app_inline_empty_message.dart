import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

/// The "Nothing yet." line shown under a section heading when its list is
/// empty — the same padded, muted-grey text repeated across every Vault
/// editor list (bullets, hobbies, the card lists) rather than each
/// restating the same `Padding`/`Text` pair.
class AppInlineEmptyMessage extends StatelessWidget {
  const AppInlineEmptyMessage(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.appSpacing.paddingTight),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
