import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth/auth_service.dart';
import '../models/auth/user_model.dart';
import '../utils/app_logger.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
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
      if (_currentUser!.email.isNotEmpty) {
        return _currentUser!.email[0].toUpperCase();
      }
      return 'U';
    }
    return _currentUser!.username[0].toUpperCase();
  }

  String _getUserDisplayName() {
    if (_currentUser == null) return 'Guest';
    if (_currentUser!.username.isEmpty) {
      return _currentUser!.email.split('@')[0];
    }
    return _currentUser!.username;
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.logout();
      AppLogger.info('🚪 User logged out');
      
      if (mounted) {
        Navigator.of(context).pop(); // Close drawer
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the current screen
        setState(() {
          _currentUser = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getUserInitial(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            accountName: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    _getUserDisplayName(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            accountEmail: _currentUser != null
                ? Text(_currentUser!.email)
                : const Text('Not logged in'),
            otherAccountsPictures: [
              if (_currentUser != null && _currentUser!.isVerified)
                const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Profile (if logged in)
                if (_currentUser != null) ...[
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_user),
                    title: const Text('Verification Center'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/verification/center');
                    },
                  ),
                  const Divider(),
                ],

                // Settings Section
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),

                // Theme Toggle
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(
                    themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),

                // Language Selector
                ExpansionTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: Text(_getLanguageName(localeProvider.locale?.languageCode ?? 'en')),
                  children: [
                    _buildLanguageTile(
                      context,
                      'English',
                      'en',
                      Icons.flag,
                      localeProvider,
                    ),
                    _buildLanguageTile(
                      context,
                      'አማርኛ (Amharic)',
                      'am',
                      Icons.flag,
                      localeProvider,
                    ),
                    _buildLanguageTile(
                      context,
                      'Oromoo (Oromo)',
                      'om',
                      Icons.flag,
                      localeProvider,
                    ),
                    _buildLanguageTile(
                      context,
                      'Soomaali (Somali)',
                      'so',
                      Icons.flag,
                      localeProvider,
                    ),
                    _buildLanguageTile(
                      context,
                      'ትግርኛ (Tigrinya)',
                      'ti',
                      Icons.flag,
                      localeProvider,
                    ),
                  ],
                ),

                const Divider(),

                // Help & Support
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to help screen
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),

                const Divider(),

                // Login/Logout
                if (_currentUser == null)
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.green),
                    title: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/auth/login');
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: _handleLogout,
                  ),
              ],
            ),
          ),

          // Version Info at Bottom
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'EthioConnect v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String title,
    String languageCode,
    IconData icon,
    LocaleProvider localeProvider,
  ) {
    final isSelected = localeProvider.locale?.languageCode == languageCode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        localeProvider.setLocale(Locale(languageCode));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'am':
        return 'አማርኛ';
      case 'om':
        return 'Oromoo';
      case 'so':
        return 'Soomaali';
      case 'ti':
        return 'ትግርኛ';
      default:
        return 'English';
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'EthioConnect',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const SizedBox(height: 16),
        const Text(
          'EthioConnect is a comprehensive platform connecting professionals, '
          'services, products, and opportunities across Ethiopia.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Professional role verification\n'
          '• Job listings and services\n'
          '• Product marketplace\n'
          '• Rental listings\n'
          '• Multi-language support',
        ),
      ],
    );
  }
}
