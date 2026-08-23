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

    test('available lists Gemini before Anthropic in the Settings dropdown',
        () {
      final registry = LlmProviderRegistry();

      expect(registry.available.map((p) => p.id), ['gemini', 'anthropic']);
    });
  });
}
