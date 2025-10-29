import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool showTitle;
  
  const LanguageSelector({
    super.key,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          Text(
            l10n.language,
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
            child: DropdownButton<Locale?>(
              value: localeProvider.locale,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
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
                  child: Row(
                    children: [
                      const Icon(Icons.phone_android, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.systemMode),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: Locale('en'),
                  child: Row(
                    children: [
                      Text('🇺🇸', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('English'),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: Locale('am'),
                  child: Row(
                    children: [
                      Text('🇪🇹', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('አማርኛ'),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: Locale('om'),
                  child: Row(
                    children: [
                      Text('🇪🇹', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('Afaan Oromoo'),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: Locale('so'),
                  child: Row(
                    children: [
                      Text('🇸🇴', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('Soomaali'),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: Locale('ti'),
                  child: Row(
                    children: [
                      Text('🇪🇹', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('ትግርኛ'),
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
