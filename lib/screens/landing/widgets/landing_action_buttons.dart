import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../auth/login_screen.dart';
import '../../auth/register_screen.dart';

class LandingActionButtons extends StatelessWidget {
  final AppLocalizations l10n;

  const LandingActionButtons({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Call to Action Title
            Text(
              'Ready to get started?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Join thousands of Ethiopians connecting every day',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      l10n.login,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Register Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_add, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      l10n.register,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Features Grid
            _FeaturesGrid(isDark: isDark),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  final bool isDark;

  const _FeaturesGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final features = [
      {'icon': Icons.verified_user, 'title': 'Verified Users', 'desc': 'Trust & Safety'},
      {'icon': Icons.language, 'title': '5 Languages', 'desc': 'Ethiopian Languages'},
      {'icon': Icons.trending_up, 'title': 'Growing Fast', 'desc': '1000+ Daily Users'},
      {'icon': Icons.support_agent, 'title': '24/7 Support', 'desc': 'Always Here'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feature['icon'] as IconData,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                feature['title'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                feature['desc'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
