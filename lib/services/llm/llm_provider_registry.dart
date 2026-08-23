import 'package:cv_forge/services/llm/anthropic_provider.dart';
import 'package:cv_forge/services/llm/gemini_provider.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';

/// Provider lookup, backed by a plain const list — no reflection, so an
/// unregistered provider tree-shakes out of a release build. Same shape
/// as `TemplateRegistryService`, deliberately: same problem (pick one of
/// N known implementations by a persisted id, fail soft on an unknown
/// one), same solution.
class LlmProviderRegistry {
  static const List<LlmProvider> _providers = [
    AnthropicProvider(),
    GeminiProvider(),
  ];

  LlmProvider get defaultProvider => _providers.first;

  /// id/displayName/models only, for a Settings dropdown — Gemini listed
  /// first, deliberately its own order rather than [_providers]'.
  /// [_providers] stays Anthropic-first because [defaultProvider] is
  /// [_providers.first]: a brand-new user's pre-selected provider (and
  /// every id-not-found fallback via [byId]) shouldn't change just
  /// because the dropdown's display order does.
  List<LlmProvider> get available => const [
    GeminiProvider(),
    AnthropicProvider(),
  ];

  /// Falls back to [defaultProvider] for an unknown id — never throws, so
  /// a stored `copilotProviderId` from a since-removed provider still
  /// resolves to something usable.
  LlmProvider byId(String id) =>
      _providers.firstWhere((p) => p.id == id, orElse: () => defaultProvider);
}
