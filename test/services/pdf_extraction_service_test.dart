import 'package:flutter_test/flutter_test.dart';
import 'package:cv_forge/app/app.locator.dart';

import '../helpers/test_helpers.dart';

/// Deliberately empty. `PdfExtractionService` is an abstract interface
/// with no logic of its own (see its doc comment for why); its real
/// implementation, `PdfExtractionServiceWeb`, is `dart:js_interop`/
/// `package:web` marshalling that only runs in a browser and does not
/// even compile under the Dart VM `flutter test` runs on — so there is
/// nothing to test here directly. The real coverage lives in
/// `AtsAnalyzerService`'s tests, which exercise `AtsExtractedDocument`
/// fixtures built from real `pdf.js` output captured during the
/// ATS-analyzer spike.
void main() {
  group('PdfExtractionServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
