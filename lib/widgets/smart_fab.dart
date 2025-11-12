import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SmartFAB extends StatelessWidget {
  final String screenType;
  final VoidCallback? onPressed;

  const SmartFAB({
    super.key,
    required this.screenType,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    switch (screenType) {
      case 'offers':
        return FloatingActionButton.extended(
          onPressed: onPressed ?? () => Navigator.pushNamed(context, '/offers/create'),
          backgroundColor: Colors.orange,
          icon: const Icon(Icons.local_offer, color: Colors.white),
          label: const Text('Create Offer', style: TextStyle(color: Colors.white)),
        );
      
      case 'services':
        return FloatingActionButton.extended(
          onPressed: onPressed ?? () {
            // TODO: Navigate to create service
          },
          backgroundColor: Colors.cyan,
          icon: const Icon(Icons.work, color: Colors.white),
          label: const Text('Offer Service', style: TextStyle(color: Colors.white)),
        );
      
      case 'rentals':
        return FloatingActionButton.extended(
          onPressed: onPressed ?? () => Navigator.pushNamed(context, '/rentals/create'),
          backgroundColor: Colors.green,
          icon: const Icon(Icons.home, color: Colors.white),
          label: const Text('List Property', style: TextStyle(color: Colors.white)),
        );
      
      case 'matchmaking':
        return FloatingActionButton(
          onPressed: onPressed ?? () {
            // TODO: Navigate to create profile
          },
          backgroundColor: Colors.pink,
          child: const Icon(Icons.add, color: Colors.white),
        );
      
      default:
        return FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
    }
  }
}

// Quick Actions Speed Dial
class QuickActionsSpeedDial extends StatefulWidget {
  const QuickActionsSpeedDial({super.key});

  @override
  State<QuickActionsSpeedDial> createState() => _QuickActionsSpeedDialState();
}

class _QuickActionsSpeedDialState extends State<QuickActionsSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildSpeedDialActions(),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppColors.primary,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isOpen ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSpeedDialActions() {
    if (!_isOpen) return [];

    final actions = [
      _buildSpeedDialAction(
        icon: Icons.local_offer,
        label: 'Offer',
        color: Colors.orange,
        onTap: () => Navigator.pushNamed(context, '/offers'),
      ),
      _buildSpeedDialAction(
        icon: Icons.build,
        label: 'Service',
        color: Colors.cyan,
        onTap: () => Navigator.pushNamed(context, '/services'),
      ),
      _buildSpeedDialAction(
        icon: Icons.home,
        label: 'Rental',
        color: Colors.green,
        onTap: () => Navigator.pushNamed(context, '/rentals'),
      ),
      _buildSpeedDialAction(
        icon: Icons.favorite,
        label: 'Dating',
        color: Colors.pink,
        onTap: () => Navigator.pushNamed(context, '/matchmaking'),
      ),
    ];

    return actions
        .asMap()
        .entries
        .map((entry) => AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -60.0 * (entry.key + 1) * _animation.value),
                  child: Opacity(
                    opacity: _animation.value,
                    child: child,
                  ),
                );
              },
              child: entry.value,
            ))
        .toList();
  }

  Widget _buildSpeedDialAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            mini: true,
            onPressed: () {
              _toggle();
              onTap();
            },
            backgroundColor: color,
            heroTag: label,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
