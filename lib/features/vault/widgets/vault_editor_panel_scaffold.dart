import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// The common chrome every editor panel (basics, one experience, one
/// education entry, skills, hobbies) renders inside: a title bar with a
/// close button, then a scrollable form body.
class VaultEditorPanelScaffold extends StatelessWidget {
  const VaultEditorPanelScaffold({
    super.key,
    required this.title,
    required this.onClose,
    required this.children,
  });

  final String title;
  final VoidCallback onClose;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.appSpacing.paddingPanel,
            context.appSpacing.paddingDefault,
            context.appSpacing.paddingCompact,
            context.appSpacing.paddingDefault,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: context.appTypography.titleMedium),
              ),
              IconButton(
                icon: Icon(
                  RemixIcons.close_line,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: onClose,
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.appSpacing.paddingPanel),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
