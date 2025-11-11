import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class ThemeSelector extends StatelessWidget {
  final bool showTitle;
  
  const ThemeSelector({
    super.key,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          Text(
            l10n.theme,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      const Icon(Icons.phone_android, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.systemMode),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      const Icon(Icons.light_mode, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.lightMode),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      const Icon(Icons.dark_mode, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.darkMode),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    
    return OutlinedButton(
      onPressed: () {
        themeProvider.toggleTheme(!isDark);
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.5),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(isDark),
              color: const Color(0xFF4E5F6C),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isDark ? 'Light' : 'Dark',
            style: const TextStyle(
              color: Color(0xFF4E5F6C),
            ),
          ),
        ],
      ),
    );
  }
}
