import 'package:flutter/material.dart';
import '../../screens/landing/landing_screen.dart';
import '../../utils/app_logger.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Brief delay for splash effect
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    
    AppLogger.success('✅ App initialized - Landing screen ready');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading EthioConnect...'),
            ],
          ),
        ),
      );
    }

    // Always show landing screen
    // Users can browse freely
    // Login/Register buttons in app bar
    // Verification banner shows when needed
    return const LandingScreen();
  }
}
