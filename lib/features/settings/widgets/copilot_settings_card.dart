import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';

/// Copilot connection setup — enter a key, pick a model, test the
/// connection. The rest of the Copilot (4.5) isn't built yet; this card's
/// whole job is proving a key works and remembering the chosen model, per
/// plan.md's 4.4. Same block-card frame as [BackupSettingsCard].
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
        color: kcDarkGreyColor,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Copilot', style: context.appTypography.titleMedium),
          const VGap.tiny(),
          Text(
            'Bring your own Anthropic API key to enable AI-assisted '
            'tailoring. Your key never leaves this device except to call '
            "Anthropic's API directly — there is no CVForge server.",
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Anthropic API key',
              hintText: 'sk-ant-...',
            ),
          ),
          const VGap.small(),
          Row(
            children: [
              Checkbox(
                value: viewModel.rememberApiKey,
                onChanged: (value) =>
                    viewModel.setRememberApiKey(value ?? false),
              ),
              const HGap.small(),
              const Expanded(child: Text('Remember on this device')),
            ],
          ),
          const VGap.small(),
          DropdownButton<String>(
            value: viewModel.selectedCopilotModelId,
            isExpanded: true,
            items: [
              for (final model in viewModel.copilotModels)
                DropdownMenuItem(value: model.id, child: Text(model.label)),
            ],
            onChanged: (modelId) {
              if (modelId != null) viewModel.selectCopilotModel(modelId);
            },
          ),
          const VGap.medium(),
          FilledButton(
            onPressed: viewModel.isTestingConnection
                ? null
                : () => viewModel.testCopilotConnection(_apiKeyController.text),
            child: viewModel.isTestingConnection
                ? const _ButtonSpinner()
                : const Text('Test connection'),
          ),
          if (viewModel.connectionTestErrorMessage != null) ...[
            const VGap.small(),
            Text(
              viewModel.connectionTestErrorMessage!,
              style: context.appTypography.bodySmall.copyWith(
                color: kcErrorColor,
              ),
            ),
          ] else if (viewModel.connectionTestSucceeded) ...[
            const VGap.small(),
            Text('Connected.', style: context.appTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: kcWhite),
    );
  }
}
