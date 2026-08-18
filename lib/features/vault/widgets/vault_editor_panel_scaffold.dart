import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: kcWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: kcLightGrey),
                onPressed: onClose,
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: kcMediumGrey),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
