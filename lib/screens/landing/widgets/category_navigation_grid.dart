import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import '../jobs/jobs_screen.dart';
import '../products/products_screen.dart';
import '../rentals/rentals_screen.dart';
import '../services/services_screen.dart';
import '../matchmaking/matchmaking_screen.dart';
import '../events/events_screen.dart';

class CategoryNavigationGrid extends StatelessWidget {
  final List<dynamic> jobs;
  final List<dynamic> products;
  final List<dynamic> rentals;
  final List<dynamic> services;
  final List<dynamic> matchmaking;
  final List<dynamic> events;
  
  const CategoryNavigationGrid({
    super.key,
    required this.jobs,
    required this.products,
    required this.rentals,
    required this.services,
    required this.matchmaking,
    required this.events,
  });

  List<Map<String, dynamic>> get _categories => [
    {
      'id': 'jobs',
      'name': 'Jobs',
      'emoji': '💼',
      'color': const Color(0xFF3F51B5),
      'screen': JobsScreen(jobs: jobs),
    },
    {
      'id': 'products',
      'name': 'Products',
      'emoji': '🛍️',
      'color': const Color(0xFFE91E63),
      'screen': ProductsScreen(products: products.cast<Product>()),
    },
    {
      'id': 'rentals',
      'name': 'Rentals',
      'emoji': '🏠',
      'color': const Color(0xFF009688),
      'screen': RentalsScreen(rentals: rentals),
    },
    {
      'id': 'services',
      'name': 'Services',
      'emoji': '🔧',
      'color': const Color(0xFFFF9800),
      'screen': ServicesScreen(services: services),
    },
    {
      'id': 'matchmaking',
      'name': 'Matchmaking',
      'emoji': '💑',
      'color': const Color(0xFFE91E63),
      'screen': MatchmakingScreen(matchmaking: matchmaking),
    },
    {
      'id': 'events',
      'name': 'Events',
      'emoji': '🎉',
      'color': const Color(0xFF9C27B0),
      'screen': EventsScreen(events: events),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _CategoryCard(
                emoji: category['emoji'],
                title: category['name'],
                color: category['color'],
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => category['screen'],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.title,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(isDark ? 0.3 : 0.1),
                color.withOpacity(isDark ? 0.2 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
