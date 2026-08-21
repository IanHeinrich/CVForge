import 'package:cv_forge/services/llm/anthropic_provider.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';

/// Provider lookup, backed by a plain const list — no reflection, so an
/// unregistered provider tree-shakes out of a release build. Same shape
/// as `TemplateRegistryService`, deliberately: same problem (pick one of
/// N known implementations by a persisted id, fail soft on an unknown
/// one), same solution.
class LlmProviderRegistry {
  static const List<LlmProvider> _providers = [AnthropicProvider()];

  LlmProvider get defaultProvider => _providers.first;

  /// id/displayName/models only, for a Settings dropdown.
  List<LlmProvider> get available => _providers;

  /// Falls back to [defaultProvider] for an unknown id — never throws, so
  /// a stored `copilotProviderId` from a since-removed provider still
  /// resolves to something usable.
  LlmProvider byId(String id) =>
      _providers.firstWhere((p) => p.id == id, orElse: () => defaultProvider);
}
