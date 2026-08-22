import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/button_spinner/button_spinner.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';

/// Caps the API key field's width — 7.7 issue 4: a secret this short (and
/// `obscureText`, which buys nothing from extra width) doesn't need the
/// full ~1,000px content measure the card would otherwise stretch it to.
const _apiKeyFieldMaxWidth = 360.0;

/// Copilot connection setup — pick a provider (once more than one is
/// registered), enter a key, pick a model, test the connection. Same
/// block-card frame as [BackupSettingsCard]; the surrounding scroll and
/// page padding belong to `SettingsView`.
class CopilotSettingsCard extends StatefulWidget {
  const CopilotSettingsCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<CopilotSettingsCard> createState() => _CopilotSettingsCardState();
}

class _CopilotSettingsCardState extends State<CopilotSettingsCard> {
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return Container(
      padding: EdgeInsets.all(context.appSpacing.paddingPanel),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Copilot', style: context.appTypography.titleMedium),
          const VGap.tiny(),
          Text(
            'Bring your own API key to enable AI-assisted tailoring. Your '
            'key never leaves this device except to call the provider\'s '
            'API directly — there is no CVForge server.',
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          if (viewModel.showCopilotProviderSelector) ...[
            DropdownButtonFormField<String>(
              initialValue: viewModel.selectedCopilotProvider.id,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Provider'),
              items: [
                for (final provider in viewModel.copilotProviders)
                  DropdownMenuItem(
                    value: provider.id,
                    child: Text(provider.displayName),
                  ),
              ],
              onChanged: (providerId) {
                if (providerId == null) return;
                // A key typed for the previous provider is meaningless for
                // the new one — clear it rather than leave a stale value
                // sitting in the field.
                _apiKeyController.clear();
                viewModel.selectCopilotProvider(providerId);
              },
            ),
            const VGap.small(),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _apiKeyFieldMaxWidth),
            child: TextField(
              controller: _apiKeyController,
              obscureText: true,
              onChanged: (_) => viewModel.clearConnectionTestResult(),
              decoration: InputDecoration(
                labelText:
                    '${viewModel.selectedCopilotProvider.displayName} '
                    'API key',
                hintText: 'Paste your API key',
              ),
            ),
          ),
          const VGap.small(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: viewModel.rememberApiKey,
                onChanged: (value) =>
                    viewModel.setRememberApiKey(value ?? false),
              ),
              const HGap.small(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: context.appSpacing.paddingCompact,
                  ),
                  child: Text(
                    'Remember on this device — stored unencrypted in this '
                    "browser's local storage. Anyone with access to this "
                    'device can read it.',
                    style: context.appTypography.bodySmall,
                  ),
                ),
              ),
            ],
          ),
          const VGap.small(),
          DropdownButtonFormField<String>(
            initialValue: viewModel.selectedCopilotModelId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Model'),
            items: [
              for (final model in viewModel.copilotModels)
                DropdownMenuItem(value: model.id, child: Text(model.label)),
            ],
            onChanged: (modelId) {
              if (modelId != null) viewModel.selectCopilotModel(modelId);
            },
          ),
          const VGap.tiny(),
          Text(
            // "Provider's rate" up front — the price table is the
            // provider's own, not something CVForge charges (7.7 issue 7).
            "${viewModel.selectedCopilotProvider.displayName}'s own rate — "
            'not billed by CVForge: '
            '${viewModel.priceLabelFor(viewModel.selectedCopilotModel)}',
            style: context.appTypography.caption.copyWith(color: kcLightGrey),
          ),
          const VGap.medium(),
          FilledButton(
            onPressed: viewModel.isTestingConnection
                ? null
                : () => viewModel.testCopilotConnection(_apiKeyController.text),
            child: viewModel.isTestingConnection
                ? const ButtonSpinner()
                : const Text('Test connection'),
          ),
          if (viewModel.connectionTestErrorMessage != null) ...[
            const VGap.small(),
            _ConnectionResultBanner(
              icon: RemixIcons.error_warning_line,
              color: kcErrorColor,
              message: viewModel.connectionTestErrorMessage!,
            ),
          ] else if (viewModel.connectionTestSucceeded) ...[
            const VGap.small(),
            const _ConnectionResultBanner(
              icon: RemixIcons.checkbox_circle_line,
              color: kcSuccessColor,
              message: 'Connected.',
            ),
          ],
        ],
      ),
    );
  }
}

/// The connection test's success/error state — 7.7 issue 6: previously
/// plain body text with no colour or icon, indistinguishable from any
/// other line in the card. [CopilotSettingsCard] clears this (via
/// [SettingsViewModel.clearConnectionTestResult]) the moment the provider,
/// model, or key changes, so it can't go stale either.
class _ConnectionResultBanner extends StatelessWidget {
  const _ConnectionResultBanner({
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
