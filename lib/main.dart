import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'l10n/labels.dart';
import 'screens/app_shell.dart';
import 'services/settings_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final language = await SettingsStorage().loadLanguage();
  runApp(CalorieApp(initialLanguage: language));
}

class CalorieApp extends StatefulWidget {
  const CalorieApp({super.key, this.initialLanguage});

  /// Language code such as 'fi', or null to follow the phone's language.
  final String? initialLanguage;

  /// The chosen language code, or null when following the phone.
  static String? languageOf(BuildContext context) =>
      context.findAncestorStateOfType<_CalorieAppState>()!._language;

  /// Switches the app language and remembers the choice.
  static void setLanguage(BuildContext context, String? code) =>
      context.findAncestorStateOfType<_CalorieAppState>()!._setLanguage(code);

  @override
  State<CalorieApp> createState() => _CalorieAppState();
}

class _CalorieAppState extends State<CalorieApp> {
  late String? _language = widget.initialLanguage;

  Future<void> _setLanguage(String? code) async {
    setState(() => _language = code);
    await SettingsStorage().saveLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      locale: _language == null ? null : Locale(_language!),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        // Number and date formatting follow the app language.
        Intl.defaultLocale = Localizations.localeOf(context).toLanguageTag();
        return child!;
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const AppShell(),
    );
  }
}
