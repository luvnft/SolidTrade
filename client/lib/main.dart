import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solidtrade/providers/localization.provider.dart';
import 'package:solidtrade/providers/theme.provider.dart';
import 'package:solidtrade/screens/startup/startup_screen.dart';

void main() => runApp(
      const ProviderScope(child: MyApp()),
    );

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localizationProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Solidtrade™',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
      themeMode: themeMode,
      theme: ThemeData.light().copyWith(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: const StartupScreen(),
    );
  }
}
