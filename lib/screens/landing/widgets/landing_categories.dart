import 'package:flutter/material.dart';
import '../../../models/role_model.dart';

class LandingCategories extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String>? onCategoryTap;
  final List<Role> roles;
  final bool isLoading;

  const LandingCategories({
    super.key,
    this.selectedCategory,
    this.onCategoryTap,
    required this.roles,
    this.isLoading = false,
  });

  // Fallback categories with emojis if roles are not loaded
  static final List<Map<String, String>> _defaultCategories = [
    {'id': 'jobs', 'name': 'Jobs', 'emoji': '💼'},
    {'id': 'products', 'name': 'Products', 'emoji': '🛍️'},
    {'id': 'rentals', 'name': 'Rentals', 'emoji': '🏠'},
    {'id': 'services', 'name': 'Services', 'emoji': '🔧'},
    {'id': 'matchmaking', 'name': 'Matchmaking', 'emoji': '💑'},
    {'id': 'events', 'name': 'Events', 'emoji': '🎉'},
  ];

  // Map role names to emojis
  static String _getRoleEmoji(String roleName) {
    final Map<String, String> roleEmojis = {
      'user': '👤',
      'employee': '👔',
      'employer': '💼',
      'doctor': '🩺',
      'teacher': '👨‍🏫',
      'admin': '⚡',
      'business': '🏢',
      'jobs': '💼',
      'products': '🛍️',
      'rentals': '🏠',
      'services': '🔧',
      'matchmaking': '💑',
      'events': '🎉',
    };

    return roleEmojis[roleName.toLowerCase()] ?? '📋';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Use roles if available, otherwise use default categories
    final displayCategories = roles.isNotEmpty
        ? roles.map((role) {
            return {
              'id': role.id,
              'name': role.name.capitalize(),
              'emoji': _getRoleEmoji(role.name),
            };
          }).toList()
        : _defaultCategories;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = displayCategories[index];
            final isSelected = selectedCategory == category['id'];

            return _CategoryCard(
              emoji: category['emoji']!,
              title: category['name']!,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => onCategoryTap?.call(category['id']!),
            );
          },
          childCount: displayCategories.length,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String title;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.title,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: isSelected ? 36 : 32,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
