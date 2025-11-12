import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'theme_selector.dart';
import 'language_selector.dart';
import 'custom_bottom_sheet.dart';

class SettingsControls extends StatelessWidget {
  const SettingsControls({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Language Button
        IconButton(
          icon: Icon(
            Icons.language,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => _showLanguageBottomSheet(context),
          tooltip: l10n.language,
        ),
        // Theme Toggle Button
        const ThemeToggleButton(),
      ],
    );
  }

  static void _showLanguageBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    CustomBottomSheet.show(
      context: context,
      title: l10n.settings,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const LanguageSelector(showTitle: false),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            l10n.theme,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const ThemeSelector(showTitle: false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class SettingsFAB extends StatelessWidget {
  const SettingsFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return FloatingActionButton(
      mini: true,
      onPressed: () => SettingsControls._showLanguageBottomSheet(context),
      tooltip: l10n.settings,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      child: const Icon(Icons.settings),
    );
  }
}
