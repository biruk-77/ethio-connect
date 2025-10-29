import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${l10n.welcome}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'User: ${authService.userEmail ?? "Unknown"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => authService.signOut(),
              child: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Theme Settings
            ListTile(
              title: Text(l10n.theme),
              subtitle: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) {
                        themeProvider.setThemeMode(mode);
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(l10n.systemMode),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(l10n.lightMode),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(l10n.darkMode),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Language Settings
            ListTile(
              title: Text(l10n.language),
              subtitle: Consumer<LocaleProvider>(
                builder: (context, localeProvider, child) {
                  return DropdownButton<Locale?>(
                    value: localeProvider.locale,
                    onChanged: (Locale? locale) {
                      if (locale != null) {
                        localeProvider.setLocale(locale);
                      } else {
                        localeProvider.clearLocale();
                      }
                    },
                    items: [
                      DropdownMenuItem<Locale?>(
                        value: null,
                        child: Text(l10n.systemMode),
                      ),
                      const DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      const DropdownMenuItem(
                        value: Locale('am'),
                        child: Text('አማርኛ'),
                      ),
                      const DropdownMenuItem(
                        value: Locale('om'),
                        child: Text('Afaan Oromoo'),
                      ),
                      const DropdownMenuItem(
                        value: Locale('so'),
                        child: Text('Soomaali'),
                      ),
                      const DropdownMenuItem(
                        value: Locale('ti'),
                        child: Text('ትግርኛ'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
