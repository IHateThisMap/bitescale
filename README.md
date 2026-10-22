# BiteScale

Track your weight, calories and food. Shows your weight trend, BMI or body fat, and a daily calorie target for reaching your weight goal.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Languages

The app is available in English and Finnish. The language can be changed
with the translate icon in the top bar; "System default" follows the phone.

All texts live in `lib/l10n/`, one file per language:

- `app_en.arb` – English, the main file. New texts are added here first.
- `app_fi.arb` – Finnish.

### Adding a language

1. Copy `app_en.arb` to `app_<code>.arb`, for example `app_sv.arb` for
   Swedish, and change `"@@locale"` to the new code.
2. Translate every text. Set `"languageName"` to the language's own name
   (e.g. `"Svenska"`); the language picker shows it automatically. Entries
   starting with `@` are notes for translators and can be removed.
3. Run `flutter gen-l10n` (or just run the app) and `flutter test`. The
   tests fail if the new file is missing any text that English has.

Texts with `{days, plural, ...}` change with the number; keep the
`=1{...}` and `other{...}` parts and translate the text inside them.
