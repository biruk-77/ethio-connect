import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.grey100,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Ethiopian Flag Decoration
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: AppColors.ethiopianGradient,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),

            const SizedBox(height: 24),

            // App Logo and Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🇪🇹', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Text(
                  'EthioConnect',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Connecting Ethiopia, One Click at a Time',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Quick Links
            Wrap(
              spacing: 24,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _FooterLink(
                  text: 'About Us',
                  onTap: () {},
                  isDark: isDark,
                ),
                _FooterLink(
                  text: 'Contact',
                  onTap: () {},
                  isDark: isDark,
                ),
                _FooterLink(
                  text: 'Privacy',
                  onTap: () {},
                  isDark: isDark,
                ),
                _FooterLink(
                  text: 'Terms',
                  onTap: () {},
                  isDark: isDark,
                ),
                _FooterLink(
                  text: 'Help',
                  onTap: () {},
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Social Media Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialIcon(
                  icon: Icons.facebook,
                  onTap: () {},
                  isDark: isDark,
                ),
                const SizedBox(width: 16),
                _SocialIcon(
                  icon: Icons.telegram,
                  onTap: () {},
                  isDark: isDark,
                ),
                const SizedBox(width: 16),
                _SocialIcon(
                  icon: Icons.phone,
                  onTap: () {},
                  isDark: isDark,
                ),
                const SizedBox(width: 16),
                _SocialIcon(
                  icon: Icons.email,
                  onTap: () {},
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Copyright
            Text(
              '© 2024 EthioConnect. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Made in Ethiopia
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Made with ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
                const Text('❤️', style: TextStyle(fontSize: 12)),
                Text(
                  ' in Ethiopia',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isDark;

  const _FooterLink({
    required this.text,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _SocialIcon({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}
