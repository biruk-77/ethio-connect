import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/app_localizations.dart';
import 'l10n/custom_localizations.dart';
import 'l10n/l10n.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for all supported locales
  await Future.wait([
    initializeDateFormatting('en', null),
    initializeDateFormatting('am', null),
    initializeDateFormatting('om', null),
    initializeDateFormatting('so', null),
    initializeDateFormatting('ti', null),
  ]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'EthioConnect',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        OromoMaterialLocalizationsDelegate(),
        OromoCupertinoLocalizationsDelegate(),
        SomaliMaterialLocalizationsDelegate(),
        SomaliCupertinoLocalizationsDelegate(),
        TigrinyaMaterialLocalizationsDelegate(),
        TigrinyaCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('om'),
        Locale('so'),
        Locale('ti'),
      ],
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<AuthStatus>(
      stream: authService.authStatusStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          final authStatus = snapshot.data!;
          
          // Set global l10n
          setL10n(AppLocalizations.of(context)!);

          switch (authStatus) {
            case AuthStatus.authenticated:
              return const HomeScreen();
            case AuthStatus.needsProfileCompletion:
              // TODO: Create profile completion screen
              return const HomeScreen();
            case AuthStatus.unauthenticated:
            case AuthStatus.unknown:
            default:
              return const LoginScreen();
          }
        }

        return const LoginScreen();
      },
    );
  }
}
