import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/language_selector.dart';
import '../../../widgets/notification_bell.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/auth/auth_service.dart';
import '../../../models/auth/user_model.dart';

class LandingAppBar extends StatefulWidget {
  final AppLocalizations l10n;

  const LandingAppBar({
    super.key,
    required this.l10n,
  });

  @override
  State<LandingAppBar> createState() => _LandingAppBarState();
}

class _LandingAppBarState extends State<LandingAppBar> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = await _authService.getStoredUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  String _getUserInitial() {
    if (_currentUser == null) return '?';
    if (_currentUser!.username.isEmpty) {
      // Try email first letter
      if (_currentUser!.email.isNotEmpty) {
        return _currentUser!.email[0].toUpperCase();
      }
      return 'U'; // Default to 'U' for User
    }
    return _currentUser!.username[0].toUpperCase();
  }

  String _getUserDisplayName() {
    if (_currentUser == null) return 'User';
    if (_currentUser!.username.isEmpty) {
      return _currentUser!.email.split('@')[0];
    }
    return _currentUser!.username;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: 'Menu',
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '🇪🇹',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.l10n.appName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Discover Ethiopia',
                    style: TextStyle(
                      fontSize: 9,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Auth status / Login buttons
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_currentUser != null)
          // Logged in - Show user menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                _getUserInitial(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            tooltip: _getUserDisplayName(),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'verification') {
                Navigator.pushNamed(context, '/verification/center');
              } else if (value == 'logout') {
                await _authService.logout();
                if (mounted) {
                  setState(() {
                    _currentUser = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getUserDisplayName(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Show verification status based on roles and actual verification
                    if (_currentUser!.roles.isEmpty && !_currentUser!.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 12,
                              color: Colors.orange.shade900,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Not Verified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_currentUser!.roles.isNotEmpty || _currentUser!.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 12,
                              color: Colors.green.shade900,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentUser!.roles.isNotEmpty 
                                  ? _currentUser!.roles.first.toUpperCase()
                                  : 'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 12),
                    Text('My Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'verification',
                child: Row(
                  children: [
                    Icon(Icons.verified_user),
                    SizedBox(width: 12),
                    Text('Verification Center'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          )
        else
          // Not logged in - Show login/register buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/auth/login');
                },
                child: const Text('Login'),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/auth/register');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        
        // Favorites button (logged in users only)
        if (_currentUser != null)
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
            tooltip: 'My Favorites',
          ),
        
        // Notification bell (logged in users only)
        if (_currentUser != null) const NotificationBell(),
        
        const SizedBox(width: 8),
        
        // Language selector icon
        IconButton(
          icon: Icon(
            Icons.language_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: () => _showLanguageDialog(context),
          tooltip: widget.l10n.language,
        ),
        // Theme toggle icon
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            themeProvider.toggleTheme(!isDark);
          },
          tooltip: widget.l10n.theme,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.l10n.language,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            const LanguageSelector(showTitle: false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
