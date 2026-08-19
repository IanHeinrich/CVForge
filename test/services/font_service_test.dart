import 'package:flutter_test/flutter_test.dart';
import 'package:cv_forge/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FontServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
