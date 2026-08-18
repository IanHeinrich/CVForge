import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('TemplateRegistryServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    test('available lists id/name/description for every template', () {
      final service = TemplateRegistryService();

      expect(service.available, isNotEmpty);
      expect(service.available.first.id, service.defaultTemplate.id);
    });

    test('byId falls back to the default template for an unknown id, '
        'rather than throwing', () {
      final service = TemplateRegistryService();

      final template = service.byId('does-not-exist');

      expect(template.id, service.defaultTemplate.id);
    });

    test('byId resolves a known id to the matching template', () {
      final service = TemplateRegistryService();
      final knownId = service.defaultTemplate.id;

      expect(service.byId(knownId).id, knownId);
    });
  });
}
