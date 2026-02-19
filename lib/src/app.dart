import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/home_page.dart';

class ZupApp extends StatelessWidget {
  const ZupApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.ibmPlexSansTextTheme(base.textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zup',
      theme: base.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: textTheme,
        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xFFFF7A35),
          secondary: const Color(0xFF42E2B8),
          surface: const Color(0xFF10243B),
        ),
      ),
      home: const HomePage(),
    );
  }
}
