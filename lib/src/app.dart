import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zup/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'i18n/app_locale.dart';
import 'pages/home_page.dart';
import 'services/app_database.dart';

class ZupApp extends StatefulWidget {
  const ZupApp({super.key});

  @override
  State<ZupApp> createState() => _ZupAppState();
}

class _ZupAppState extends State<ZupApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _restoreLocalePreference();
  }

  Future<void> _restoreLocalePreference() async {
    final code = await AppDatabase.instance.getPreferredLocaleCode();
    if (!mounted) {
      return;
    }
    setState(() {
      _locale = appLocaleFromCode(code);
    });
  }

  void _handleLocaleChanged(Locale? locale) {
    if (!mounted) {
      return;
    }
    if (_locale == locale) {
      return;
    }
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.ibmPlexSansTextTheme(base.textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: supportedAppLocales,
      theme: base.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: textTheme,
        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xFFFF7A35),
          secondary: const Color(0xFF42E2B8),
          surface: const Color(0xFF10243B),
        ),
      ),
      home: HomePage(onLocaleChanged: _handleLocaleChanged),
    );
  }
}
