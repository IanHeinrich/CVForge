import 'package:cv_forge/services/llm/llm_provider_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LlmProviderRegistryTest -', () {
    test('byId falls back to the default provider for an unknown id, '
        'rather than throwing', () {
      final registry = LlmProviderRegistry();

      final provider = registry.byId('does-not-exist');

      expect(provider.id, registry.defaultProvider.id);
    });

    test('byId resolves a known id to the matching provider', () {
      final registry = LlmProviderRegistry();
      final knownId = registry.defaultProvider.id;

      expect(registry.byId(knownId).id, knownId);
    });

    test('available lists every registered provider, each with at least '
        'one model', () {
      final registry = LlmProviderRegistry();

      expect(registry.available, isNotEmpty);
      for (final provider in registry.available) {
        expect(
          provider.models,
          isNotEmpty,
          reason:
              '${provider.id} must offer at least one model, or the '
              'Settings dropdown would render empty',
        );
      }
    });

    test('available lists Gemini before Anthropic in the Settings '
        'dropdown', () {
      final registry = LlmProviderRegistry();

      expect(registry.available.map((p) => p.id), ['gemini', 'anthropic']);
    });

    test('every provider ships the key-setup guide the Settings help '
        'panel renders', () {
      final registry = LlmProviderRegistry();

      for (final provider in registry.available) {
        expect(
          provider.apiKeySteps,
          isNotEmpty,
          reason:
              '${provider.id} must explain how to get a key, or the help '
              'panel renders a heading with nothing under it',
        );
        for (final url in [
          provider.apiKeyConsoleUrl,
          provider.billingConsoleUrl,
        ]) {
          expect(
            url.scheme,
            'https',
            reason:
                '${provider.id} link $url must be https — these open in '
                "the user's browser straight from Settings",
          );
          expect(url.host, isNotEmpty, reason: '${provider.id}: $url');
        }
      }
    });
  });
}
