import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfessionalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool showProfile;
  final bool showNotifications;
  final bool showSearch;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const ProfessionalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.showProfile = false,
    this.showNotifications = false,
    this.showSearch = false,
    this.onSearchTap,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: leading ?? (showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : null),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: _buildActions(context),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    List<Widget> actionsList = [];

    if (showSearch) {
      actionsList.add(
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: onSearchTap,
          tooltip: 'Search',
        ),
      );
    }

    if (showNotifications) {
      actionsList.add(
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: onNotificationTap ?? () {
                Navigator.pushNamed(context, '/notifications');
              },
              tooltip: 'Notifications',
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (showProfile) {
      actionsList.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: onProfileTap ?? () {
              Navigator.pushNamed(context, '/profile');
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      );
    }

    if (actions != null) {
      actionsList.addAll(actions!);
    }

    return actionsList;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Specialized App Bars for different screens
class OffersAppBar extends ProfessionalAppBar {
  const OffersAppBar({super.key})
      : super(
          title: 'Special Offers',
          showSearch: true,
          showNotifications: true,
        );
}

class ServicesAppBar extends ProfessionalAppBar {
  const ServicesAppBar({super.key})
      : super(
          title: 'Professional Services',
          showSearch: true,
          showProfile: true,
        );
}

class RentalsAppBar extends ProfessionalAppBar {
  const RentalsAppBar({super.key})
      : super(
          title: 'Rental Properties',
          showSearch: true,
          showNotifications: true,
        );
}

class MatchmakingAppBar extends ProfessionalAppBar {
  const MatchmakingAppBar({super.key})
      : super(
          title: 'Find Your Match',
          showProfile: true,
          showNotifications: true,
        );
}
