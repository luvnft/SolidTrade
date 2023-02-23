import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solidtrade/providers/localization.provider.dart';
import 'package:solidtrade/screens/home/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var locale = ref.watch(localizationProvider);

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
      theme: ThemeData(
        // backgroundColor: colors.background,
        // scaffoldBackgroundColor: colors.background,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
            // bodyColor: colors.foreground,
            // displayColor: colors.foreground,
            ),
      ),
      home: const HomeScreen(),
    );
  }
}
