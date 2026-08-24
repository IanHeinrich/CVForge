import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/button_spinner/button_spinner.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';
import 'package:cv_forge/features/settings/widgets/ai_assistant_key_help.dart';
import 'package:cv_forge/services/settings_service.dart';

/// Caps the API key field's width: a secret this short (and
/// `obscureText`, which buys nothing from extra width) doesn't need the
/// full ~1,000px content measure the card would otherwise stretch it to.
const _apiKeyFieldMaxWidth = 360.0;

/// AI Assistant connection setup — pick a provider (once more than one is
/// registered), enter a key, pick a model, test the connection. Same
/// block-card frame as [BackupSettingsCard]; the surrounding scroll and
/// page padding belong to `SettingsView`.
///
/// Renders in one of two modes, chosen by [SettingsViewModel.apiKeyOrigin]:
/// **configured** shows the key that's already there, masked, with replace
/// and remove actions; **entry** shows the field to paste a new one into.
/// A single always-empty password field served both states before, which
/// meant a stored key and no key at all looked exactly the same — the
/// thing this card most needed to tell you.
class AiAssistantSettingsCard extends StatefulWidget {
  const AiAssistantSettingsCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<AiAssistantSettingsCard> createState() =>
      _AiAssistantSettingsCardState();
}

class _AiAssistantSettingsCardState extends State<AiAssistantSettingsCard> {
  final _apiKeyController = TextEditingController();

  /// Forces entry mode over a key that's already stored, for "Replace key".
  /// Ephemeral by design — leaving Settings and coming back should show the
  /// stored key again, not a half-finished replacement.
  bool _replacing = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  bool get _hasTypedKey => _apiKeyController.text.trim().isNotEmpty;

  void _onApiKeyChanged(String _) {
    widget.viewModel.clearConnectionTestResult();
    // The button's label depends on whether anything has been typed, and
    // `clearConnectionTestResult` early-returns when there's no result to
    // clear — so the first keystroke can't rely on the ViewModel to
    // rebuild this card.
    setState(() {});
  }

  void _startReplacing() {
    _apiKeyController.clear();
    widget.viewModel.clearConnectionTestResult();
    setState(() => _replacing = true);
  }

  void _cancelReplacing() {
    _apiKeyController.clear();
    widget.viewModel.clearConnectionTestResult();
    setState(() => _replacing = false);
  }

  Future<void> _test() async {
    await widget.viewModel.testAiAssistantConnection(_apiKeyController.text);
    if (!mounted) return;
    // A successful entry has been stored by now, so drop back to the
    // configured view rather than leaving the typed key sitting in a field
    // that no longer has anything to do.
    if (widget.viewModel.connectionTestSucceeded) {
      _apiKeyController.clear();
      setState(() => _replacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final showEntryField = !viewModel.hasApiKey || _replacing;

    return Container(
      padding: EdgeInsets.all(context.appSpacing.paddingPanel),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsAiTitle,
            style: context.appTypography.titleMedium,
          ),
          const VGap.tiny(),
          Text(
            context.l10n.settingsAiBody,
            style: context.appTypography.bodySmall,
          ),
          const VGap.small(),
          _KeyStatusLine(viewModel: viewModel),
          const VGap.medium(),
          if (viewModel.showAiAssistantProviderSelector) ...[
            DropdownButtonFormField<String>(
              initialValue: viewModel.selectedAiAssistantProvider.id,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.l10n.settingsAiProviderLabel,
              ),
              items: [
                for (final provider in viewModel.aiAssistantProviders)
                  DropdownMenuItem(
                    value: provider.id,
                    child: Text(provider.displayName),
                  ),
              ],
              onChanged: (providerId) {
                if (providerId == null) return;
                // A key typed for the previous provider is meaningless for
                // the new one — clear it rather than leave a stale value
                // sitting in the field. Also drops any in-progress replace,
                // which belonged to the provider being navigated away from.
                _apiKeyController.clear();
                setState(() => _replacing = false);
                viewModel.selectAiAssistantProvider(providerId);
              },
            ),
            const VGap.small(),
          ],
          if (showEntryField) ...[
            if (viewModel.wasConfiguredElsewhere) ...[
              _SetUpElsewhereNotice(
                providerName: viewModel.selectedAiAssistantProvider.displayName,
              ),
              const VGap.small(),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _apiKeyFieldMaxWidth),
              child: TextField(
                controller: _apiKeyController,
                obscureText: true,
                autofocus: _replacing,
                onChanged: _onApiKeyChanged,
                decoration: InputDecoration(
                  labelText: context.l10n.settingsAiKeyFieldLabel(
                    viewModel.selectedAiAssistantProvider.displayName,
                  ),
                  hintText: context.l10n.settingsAiKeyFieldHint,
                ),
              ),
            ),
            const VGap.tiny(),
            // There is no separate save action, and the button alone can't
            // carry that: pressing something labelled "Test" is not an
            // obvious way to store a key, so without this the field reads
            // like it saves on its own. Also explains after the fact why a
            // rejected key didn't stick.
            Text(
              context.l10n.settingsAiKeySavedOnSuccess,
              style: context.appTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_replacing) ...[
              const VGap.tiny(),
              TextButton(
                onPressed: _cancelReplacing,
                child: Text(context.l10n.settingsAiKeepCurrentKey),
              ),
            ],
          ] else
            _StoredKeyRow(
              providerName: viewModel.selectedAiAssistantProvider.displayName,
              maskedKey: viewModel.maskedApiKey,
              onReplace: _startReplacing,
              onRemove: viewModel.removeApiKey,
            ),
          const VGap.small(),
          // The storage caveat outlived the "Remember on this device"
          // checkbox it used to label. That checkbox defaulted to off,
          // which made losing your key on reload the default experience,
          // and it singled the key out for an opt-in the Vault and every
          // CV — sitting in the same unencrypted IndexedDB — never asked
          // for. Keeping the disclosure at the same weight it had as a
          // checkbox label means removing the control costs no
          // transparency.
          _StatusLine(
            icon: RemixIcons.information_line,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            message: context.l10n.settingsAiStorageWarning,
          ),
          // Sits with the key field and its "remember" toggle rather than
          // further down: someone who has no key yet is stuck looking at
          // that field, and this is what unsticks them. Kept above the
          // model dropdown so the price caption stays adjacent to the
          // dropdown it describes.
          //
          // Shown in the configured state too, not just during entry. It's
          // a collapsed `ExpansionTile`, so it costs one line — and the
          // spend advice inside it (cap your billing, turn off auto
          // top-up, use a revocable key) is most actionable once a key is
          // live, which is exactly when hiding it would.
          AiAssistantKeyHelp(provider: viewModel.selectedAiAssistantProvider),
          const VGap.small(),
          DropdownButtonFormField<String>(
            initialValue: viewModel.selectedAiAssistantModelId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.l10n.settingsAiModelLabel,
            ),
            items: [
              for (final model in viewModel.aiAssistantModels)
                DropdownMenuItem(value: model.id, child: Text(model.label)),
            ],
            onChanged: (modelId) {
              if (modelId != null) viewModel.selectAiAssistantModel(modelId);
            },
          ),
          const VGap.tiny(),
          Text(
            // "Provider's rate" up front — the price table is the
            // provider's own, not something CVForge charges.
            context.l10n.settingsAiPriceLabel(
              viewModel.selectedAiAssistantProvider.displayName,
              viewModel.priceLabelFor(viewModel.selectedAiAssistantModel),
            ),
            style: context.appTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const VGap.medium(),
          FilledButton(
            onPressed: viewModel.isTestingConnection ? null : _test,
            child: viewModel.isTestingConnection
                ? const ButtonSpinner()
                // Names both actions once there's a typed key to save,
                // because this button is the only thing that saves one.
                // Stays plain "Test connection" over an already-stored key,
                // where nothing new is being saved and promising a save
                // would be untrue.
                : Text(
                    _hasTypedKey
                        ? context.l10n.settingsAiTestAndSave
                        : context.l10n.settingsAiTestConnection,
                  ),
          ),
          if (viewModel.connectionTestErrorMessage != null) ...[
            const VGap.small(),
            _StatusLine(
              icon: RemixIcons.error_warning_line,
              color: Theme.of(context).colorScheme.error,
              message: viewModel.connectionTestErrorMessage!,
            ),
          ] else if (viewModel.connectionTestSucceeded) ...[
            const VGap.small(),
            _StatusLine(
              icon: RemixIcons.checkbox_circle_line,
              color: context.appPalette.success,
              message: context.l10n.settingsAiConnected,
            ),
          ],
        ],
      ),
    );
  }
}

/// Whether a key is present, and how long it lasts — the card's headline
/// answer, shown before any of the controls that change it.
///
/// Distinct from the connection-test banner near the button, which reports
/// what the last click did. This one reports what is stored, so it survives
/// a reload and a trip to another screen; the copy is kept deliberately
/// non-overlapping so the two never read as the same sentence twice.
class _KeyStatusLine extends StatelessWidget {
  const _KeyStatusLine({required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final providerName = viewModel.selectedAiAssistantProvider.displayName;
    return switch (viewModel.apiKeyOrigin) {
      ApiKeyOrigin.remembered => _StatusLine(
        icon: RemixIcons.checkbox_circle_line,
        color: context.appPalette.success,
        message: context.l10n.settingsAiKeySaved(providerName),
      ),
      ApiKeyOrigin.session => _StatusLine(
        icon: RemixIcons.time_line,
        color: context.appPalette.warning,
        message: context.l10n.settingsAiKeySession(providerName),
      ),
      ApiKeyOrigin.none => _StatusLine(
        icon: RemixIcons.information_line,
        color: context.appPalette.placeholder,
        message: context.l10n.settingsAiKeyNone(providerName),
      ),
    };
  }
}

/// The configured state's key display: enough to identify which key is
/// loaded, never enough to read it back. Last-four-characters masking is
/// what every API console does, and it's the only way to tell two keys
/// apart without showing either.
class _StoredKeyRow extends StatelessWidget {
  const _StoredKeyRow({
    required this.providerName,
    required this.maskedKey,
    required this.onReplace,
    required this.onRemove,
  });

  final String providerName;
  final String? maskedKey;
  final VoidCallback onReplace;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.settingsAiKeyFieldLabel(providerName),
          style: context.appTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const VGap.tiny(),
        Text(maskedKey ?? '••••••••', style: context.appTypography.bodySmall),
        const VGap.tiny(),
        // A `Wrap`, not a `Row` — two buttons plus a long provider name
        // won't always fit one line inside Settings' 720px column on a
        // narrow viewport.
        Wrap(
          spacing: context.appSpacing.paddingCompact,
          children: [
            TextButton(
              onPressed: onReplace,
              child: Text(context.l10n.settingsAiReplaceKey),
            ),
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(context.l10n.settingsAiRemoveKey),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shown when this user has set the AI Assistant up before but this browser
/// has no key — see [SettingsViewModel.wasConfiguredElsewhere]. Names the
/// reason the key didn't come along with everything else that synced, so
/// its absence reads as deliberate rather than as sync having lost it.
class _SetUpElsewhereNotice extends StatelessWidget {
  const _SetUpElsewhereNotice({required this.providerName});

  final String providerName;

  @override
  Widget build(BuildContext context) {
    return _StatusLine(
      icon: RemixIcons.device_line,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      message: context.l10n.settingsAiConfiguredElsewhere(providerName),
    );
  }
}

/// An icon-plus-message line, used for both the persistent key status and
/// the connection test's success/error result — distinguished by colour and
/// icon rather than plain body text indistinguishable from any other line
/// in the card. [AiAssistantSettingsCard] clears the test result (via
/// [SettingsViewModel.clearConnectionTestResult]) the moment the provider,
/// model, or key changes, so that one can't go stale either.
class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: context.appIconSize.small, color: color),
        const HGap.small(),
        // Expanded — a connection test error is provider-supplied text
        // with no length guarantee; a bare Text here would overflow the
        // card's width on a narrow mobile viewport instead of wrapping.
        Expanded(
          child: Text(
            message,
            style: context.appTypography.bodySmall.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
