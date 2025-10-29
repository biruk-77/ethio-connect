import 'app_localizations.dart';

AppLocalizations? _l10n;

AppLocalizations get l10n => _l10n!;

void setL10n(AppLocalizations localizations) {
  _l10n = localizations;
}
