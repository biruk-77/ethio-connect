import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class SwipeableLanguageSelector extends StatefulWidget {
  const SwipeableLanguageSelector({super.key});

  @override
  State<SwipeableLanguageSelector> createState() => _SwipeableLanguageSelectorState();
}

class _SwipeableLanguageSelectorState extends State<SwipeableLanguageSelector> {
  final List<Map<String, dynamic>> _languages = [
    {'locale': null, 'flag': '📱', 'name': 'System'},
    {'locale': const Locale('en'), 'flag': '🇺🇸', 'name': 'English'},
    {'locale': const Locale('am'), 'flag': '🇪🇹', 'name': 'አማርኛ'},
    {'locale': const Locale('om'), 'flag': '🇪🇹', 'name': 'Afaan'},
    {'locale': const Locale('so'), 'flag': '🇸🇴', 'name': 'Somali'},
    {'locale': const Locale('ti'), 'flag': '🇪🇹', 'name': 'ትግርኛ'},
  ];

  int _currentIndex = 0;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentIndex();
    });
  }

  void _updateCurrentIndex() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale;
    
    _currentIndex = _languages.indexWhere((lang) => lang['locale'] == currentLocale);
    if (_currentIndex == -1) _currentIndex = 0;
    
    setState(() {});
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta ?? 0;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final threshold = MediaQuery.of(context).size.width * 0.15;
    
    if (_dragOffset > threshold && _currentIndex > 0) {
      // Swipe right - previous language
      _changeLanguage(_currentIndex - 1);
    } else if (_dragOffset < -threshold && _currentIndex < _languages.length - 1) {
      // Swipe left - next language
      _changeLanguage(_currentIndex + 1);
    }
    
    setState(() {
      _dragOffset = 0;
    });
  }

  void _changeLanguage(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
    
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final selectedLocale = _languages[newIndex]['locale'] as Locale?;
    
    if (selectedLocale != null) {
      localeProvider.setLocale(selectedLocale);
    } else {
      localeProvider.clearLocale();
    }
  }

  void _onTap() {
    // Cycle to next language on tap
    int nextIndex = (_currentIndex + 1) % _languages.length;
    _changeLanguage(nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLang = _languages[_currentIndex];
    
    return GestureDetector(
      onTap: _onTap,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Previous indicator
            Opacity(
              opacity: _currentIndex > 0 ? 0.3 : 0.0,
              child: Icon(
                Icons.chevron_left,
                size: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(width: 4),
            
            // Current language
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Row(
                key: ValueKey(_currentIndex),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentLang['flag'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    currentLang['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 4),
            
            // Next indicator
            Opacity(
              opacity: _currentIndex < _languages.length - 1 ? 0.3 : 0.0,
              child: Icon(
                Icons.chevron_right,
                size: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
