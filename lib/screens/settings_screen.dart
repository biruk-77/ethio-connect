import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth/auth_service.dart';
import '../models/auth/user_model.dart';
import '../utils/app_logger.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Account Section
                if (_currentUser != null) ...[
                  _buildSectionHeader('Account', Icons.person, theme),
                  _buildListTile(
                    context,
                    icon: Icons.account_circle,
                    title: 'Profile',
                    subtitle: 'View and edit your profile',
                    onTap: () {
                      // Navigate to profile
                      AppLogger.info('Navigate to profile');
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.verified_user,
                    title: 'Verification',
                    subtitle: 'Manage your verifications',
                    trailing: _currentUser!.isVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.warning, color: Colors.orange),
                    onTap: () {
                      Navigator.pushNamed(context, '/verification/center');
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.security,
                    title: 'Privacy & Security',
                    subtitle: 'Manage your privacy settings',
                    onTap: () {
                      _showPrivacySettings();
                    },
                  ),
                  const Divider(),
                ],

                // Appearance Section
                _buildSectionHeader('Appearance', Icons.palette, theme),
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(
                    themeProvider.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          themeProvider.isDarkMode
                              ? 'Switched to Dark Mode'
                              : 'Switched to Light Mode',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: _getLanguageName(localeProvider.locale?.languageCode ?? 'en'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showLanguageDialog(localeProvider);
                  },
                ),
                const Divider(),

                // Notifications Section
                _buildSectionHeader('Notifications', Icons.notifications, theme),
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_active,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive app notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                      if (!value) {
                        _emailNotifications = false;
                        _pushNotifications = false;
                      }
                    });
                  },
                ),
                SwitchListTile(
                  secondary: Icon(
                    Icons.email,
                    color: _notificationsEnabled
                        ? theme.colorScheme.primary
                        : Colors.grey,
                  ),
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive notifications via email'),
                  value: _emailNotifications,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _emailNotifications = value;
                          });
                        }
                      : null,
                ),
                SwitchListTile(
                  secondary: Icon(
                    Icons.mobile_friendly,
                    color: _notificationsEnabled
                        ? theme.colorScheme.primary
                        : Colors.grey,
                  ),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications'),
                  value: _pushNotifications,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _pushNotifications = value;
                          });
                        }
                      : null,
                ),
                const Divider(),

                // App Settings Section
                _buildSectionHeader('App Settings', Icons.settings, theme),
                _buildListTile(
                  context,
                  icon: Icons.storage,
                  title: 'Storage',
                  subtitle: 'Manage app data and cache',
                  onTap: () {
                    _showStorageDialog();
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.download,
                  title: 'Downloads',
                  subtitle: 'Manage downloaded files',
                  onTap: () {
                    AppLogger.info('Navigate to downloads');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.data_usage,
                  title: 'Data Usage',
                  subtitle: 'Monitor app data usage',
                  onTap: () {
                    _showDataUsageDialog();
                  },
                ),
                const Divider(),

                // Help & Support Section
                _buildSectionHeader('Help & Support', Icons.help, theme),
                _buildListTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  onTap: () {
                    AppLogger.info('Navigate to help center');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.bug_report,
                  title: 'Report a Bug',
                  subtitle: 'Help us improve the app',
                  onTap: () {
                    _showReportBugDialog();
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts',
                  onTap: () {
                    _showFeedbackDialog();
                  },
                ),
                const Divider(),

                // About Section
                _buildSectionHeader('About', Icons.info, theme),
                _buildListTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About EthioConnect',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.description,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () {
                    AppLogger.info('Navigate to terms of service');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    AppLogger.info('Navigate to privacy policy');
                  },
                ),
                const Divider(),

                // Danger Zone (if logged in)
                if (_currentUser != null) ...[
                  _buildSectionHeader('Danger Zone', Icons.warning, theme, color: Colors.red),
                  _buildListTile(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    iconColor: Colors.red,
                    onTap: () {
                      _handleLogout();
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.delete_forever,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    iconColor: Colors.red,
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'am':
        return 'አማርኛ (Amharic)';
      case 'om':
        return 'Oromoo (Oromo)';
      case 'so':
        return 'Soomaali (Somali)';
      case 'ti':
        return 'ትግርኛ (Tigrinya)';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'en', localeProvider),
            _buildLanguageOption('አማርኛ (Amharic)', 'am', localeProvider),
            _buildLanguageOption('Oromoo (Oromo)', 'om', localeProvider),
            _buildLanguageOption('Soomaali (Somali)', 'so', localeProvider),
            _buildLanguageOption('ትግርኛ (Tigrinya)', 'ti', localeProvider),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String title, String code, LocaleProvider provider) {
    final isSelected = provider.locale?.languageCode == code;
    
    return RadioListTile<String>(
      title: Text(title),
      value: code,
      groupValue: provider.locale?.languageCode,
      onChanged: (value) {
        if (value != null) {
          provider.setLocale(Locale(value));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Language changed to $title'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      selected: isSelected,
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy settings coming soon!'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Two-factor authentication'),
            Text('• Password management'),
            Text('• Login history'),
            Text('• Data export'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Images Cache'),
              subtitle: const Text('~25 MB'),
              trailing: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image cache cleared')),
                  );
                },
                child: const Text('Clear'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Downloads'),
              subtitle: const Text('~10 MB'),
              trailing: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloads cleared')),
                  );
                },
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All cache cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showDataUsageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Usage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Month:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Images: 45 MB'),
            Text('• Videos: 120 MB'),
            Text('• Documents: 15 MB'),
            SizedBox(height: 16),
            Text('Total: 180 MB', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportBugDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Help us improve by reporting bugs'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Describe the bug',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppLogger.info('Bug report: ${controller.text}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We value your feedback!'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Your feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppLogger.info('Feedback: ${controller.text}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback sent. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
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
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Text('Deleting your account will:'),
            Text('• Remove all your data'),
            Text('• Cancel all verifications'),
            Text('• Delete all posts and listings'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppLogger.info('Account deletion requested');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
