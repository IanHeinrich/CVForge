# cv-forge

CV Forge - resume/CV builder web app, built with Flutter Web using the
[Stacked](https://pub.dev/packages/stacked) MVVM architecture.

See [CLAUDE.md](CLAUDE.md) for development conventions (Stacked CLI usage,
freezed conventions, etc).

## Getting started

```bash
flutter pub get
flutter run -d chrome
```

## Golden tests

Golden tests are already set up for this project. To run the tests and
update the golden files, run:

```bash
flutter test --update-goldens
```

The golden test screenshots are stored under `test/golden/`.
