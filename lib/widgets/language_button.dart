import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../main.dart';

/// App bar button showing the current language's flag. Opens the language
/// picker.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.language,
      icon: Text(context.l10n.languageFlag,
          style: const TextStyle(fontSize: 22)),
      onPressed: () => _pickLanguage(context),
    );
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final current = CalorieApp.languageOf(context);
    // Every language with an app_<code>.arb file is listed automatically,
    // with the name and flag it gives itself.
    final languages = [
      for (final locale in AppLocalizations.supportedLocales)
        (code: locale.languageCode, texts: lookupAppLocalizations(locale)),
    ]..sort((a, b) => a.texts.languageName.compareTo(b.texts.languageName));

    final chosen = await showDialog<(String?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.language),
        children: [
          RadioGroup<String?>(
            groupValue: current,
            onChanged: (code) => Navigator.pop(context, (code,)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String?>(
                  value: null,
                  title: Text(context.l10n.systemDefault),
                  secondary: const Icon(Icons.phone_android),
                ),
                for (final l in languages)
                  RadioListTile<String?>(
                    value: l.code,
                    title: Text(l.texts.languageName),
                    secondary: Text(l.texts.languageFlag,
                        style: const TextStyle(fontSize: 22)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    // A record is used so "system default" (null) differs from cancelling.
    if (chosen != null && context.mounted) {
      CalorieApp.setLanguage(context, chosen.$1);
    }
  }
}
