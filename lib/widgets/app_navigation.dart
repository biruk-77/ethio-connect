import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/offers/offers_list_screen.dart';
import '../screens/services/services_list_screen.dart';
import '../screens/rentals/rental_listings_screen.dart';
import '../screens/matchmaking/matchmaking_list_screen.dart';

class AppNavigation extends StatefulWidget {
  final int initialIndex;
  
  const AppNavigation({
    super.key, 
    this.initialIndex = 0,
  });

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  late int _currentIndex;
  late PageController _pageController;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      screen: const LandingScreen(),
    ),
    NavigationItem(
      icon: Icons.local_offer_outlined,
      activeIcon: Icons.local_offer,
      label: 'Offers',
      screen: const OffersListScreen(),
    ),
    NavigationItem(
      icon: Icons.build_outlined,
      activeIcon: Icons.build,
      label: 'Services',
      screen: const ServicesListScreen(),
    ),
    NavigationItem(
      icon: Icons.home_work_outlined,
      activeIcon: Icons.home_work,
      label: 'Rentals',
      screen: const RentalListingsScreen(),
    ),
    NavigationItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Dating',
      screen: const MatchmakingListScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                int index = entry.key;
                NavigationItem item = entry.value;
                bool isSelected = _currentIndex == index;
                
                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected 
                              ? AppColors.primary 
                              : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                            color: isSelected 
                                ? AppColors.primary 
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}

// Navigation Helper Methods
class AppNavigator {
  static void pushToOffers(BuildContext context) {
    Navigator.pushNamed(context, '/offers');
  }

  static void pushToServices(BuildContext context) {
    Navigator.pushNamed(context, '/services');
  }

  static void pushToRentals(BuildContext context) {
    Navigator.pushNamed(context, '/rentals');
  }

  static void pushToMatchmaking(BuildContext context) {
    Navigator.pushNamed(context, '/matchmaking');
  }

  static void pushToMessages(BuildContext context) {
    Navigator.pushNamed(context, '/messages');
  }

  static void pushToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  static void pushToCreateOffer(BuildContext context) {
    Navigator.pushNamed(context, '/offers/create');
  }

  static void pushToCreateRental(BuildContext context) {
    Navigator.pushNamed(context, '/rentals/create');
  }
}
