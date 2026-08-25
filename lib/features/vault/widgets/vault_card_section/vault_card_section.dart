import 'package:cv_forge/features/vault/widgets/vault_section_heading.dart';
import 'package:flutter/material.dart';

/// A heading and the content it labels, as one item in the Vault's list.
///
/// Every section in that list is one of these — the multi-entry ones
/// (`VaultListSection`, which composes this) and the single-card ones
/// alike. That uniformity is the point: the heading names the section and
/// the card underneath shows the content, so no card has to spend its
/// title repeating the name of the section it is already sitting under.
///
/// It has to be one widget rather than two entries in the list, because
/// that list puts a gap after every item — a gap between a heading and the
/// card it labels would read as a separation rather than a grouping.
class VaultCardSection extends StatelessWidget {
  const VaultCardSection({
    super.key,
    required this.title,
    this.onAdd,
    this.addLabel,
    required this.child,
  });

  final String title;

  /// Multi-entry sections offer an add affordance in the heading; the
  /// single-card ones (About you, CV defaults, Skills, Hobbies) have
  /// nothing to add *to*, so they leave this null.
  final VoidCallback? onAdd;
  final String? addLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VaultSectionHeading(title: title, onAdd: onAdd, addLabel: addLabel),
        child,
      ],
    );
  }
}
