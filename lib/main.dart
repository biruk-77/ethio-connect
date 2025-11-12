import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/app_localizations.dart';
import 'l10n/custom_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/landing_provider.dart';
import 'services/role_service.dart';
import 'services/auth/auth_wrapper.dart';
import 'screens/auth/unified_login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/enhanced_login_screen.dart';
import 'screens/auth/enhanced_register_screen.dart';
import 'screens/auth/enhanced_otp_screen.dart';
import 'screens/verification/verification_center_screen.dart';
import 'screens/verification/submit_verification_screen.dart';
import 'screens/posts/create_post_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/verification_history_screen.dart';
import 'screens/messaging/conversations_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/offers/offers_list_screen.dart';
import 'screens/offers/create_offer_screen.dart';
import 'screens/services/services_list_screen.dart';
import 'screens/rentals/rental_listings_screen.dart';
import 'screens/rentals/create_rental_screen.dart';
import 'screens/matchmaking/matchmaking_list_screen.dart';
import 'models/auth/user_model.dart';
import 'services/favorites_service.dart';
import 'services/notification_service.dart';
// 🚀 NEW COMMUNICATION SERVICES - 100% COMPLETE
import 'services/room_management_service.dart';
import 'services/enhanced_messaging_service.dart';
import 'services/enhanced_notification_service.dart';
import 'services/comment_like_service.dart';
import 'services/comment_analytics_service.dart';
import 'services/comment_typing_service.dart';
import 'services/analytics_service.dart';
import 'services/user_status_service.dart';
import 'theme/themes.dart';
import 'utils/app_logger.dart';
import 'utils/config_debug.dart';

Future<void> main() async {
  AppLogger.section('ETHIOCONNECT APP STARTING');
  AppLogger.startup('Initializing Flutter bindings...');
  WidgetsFlutterBinding.ensureInitialized();

  // DEBUG: Print configuration
  ConfigDebug.printConfig();
  ConfigDebug.checkForTypos();

  // Initialize services (Socket will connect after auth)
  AppLogger.info('Initializing communication services...');
  FavoritesService().initialize();
  NotificationService().initialize();
  
  // 🚀 Initialize NEW Communication Services - 100% Complete
  AppLogger.info('🏠 Initializing Room Management...');
  RoomManagementService().initialize();
  
  AppLogger.info('💬 Initializing Enhanced Messaging...');
  EnhancedMessagingService().initialize();
  
  AppLogger.info('🔔 Initializing Enhanced Notifications...');
  EnhancedNotificationService().initialize();
  
  AppLogger.info('👍 Initializing Comment Services...');
  CommentLikeService().initialize();
  CommentAnalyticsService().initialize();
  CommentTypingService().initialize();
  
  AppLogger.info('📊 Initializing Analytics...');
  AnalyticsService().initialize();
  
  AppLogger.info('👤 Initializing User Status...');
  // UserStatusService doesn't need initialize() - it's ready to use
  
  AppLogger.success('✨ All Communication Services Initialized - 100% Complete!');

  AppLogger.info('Initializing date formatting for all locales...');
  // Initialize date formatting for all supported locales
  await Future.wait([
    initializeDateFormatting('en', null),
    initializeDateFormatting('am', null),
    initializeDateFormatting('om', null),
    initializeDateFormatting('so', null),
    initializeDateFormatting('ti', null),
  ]);

  AppLogger.success('All locales initialized');
  AppLogger.info('Starting app with MultiProvider...');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LandingProvider()),
        ChangeNotifierProvider(create: (_) => RoleService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'EthioConnect',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        OromoMaterialLocalizationsDelegate(),
        OromoCupertinoLocalizationsDelegate(),
        SomaliMaterialLocalizationsDelegate(),
        SomaliCupertinoLocalizationsDelegate(),
        TigrinyaMaterialLocalizationsDelegate(),
        TigrinyaCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('om'),
        Locale('so'),
        Locale('ti'),
      ],
      home: const AuthWrapper(),
      routes: {
        '/auth/login': (context) => const EnhancedLoginScreen(),
        '/auth/register': (context) => const EnhancedRegisterScreen(),
        '/auth/login/old': (context) => const UnifiedLoginScreen(),
        '/auth/register/old': (context) => const RegisterScreen(),
        '/verification/center': (context) => const VerificationCenterScreen(),
        '/verification/submit': (context) => const SubmitVerificationScreen(),
        '/posts/create': (context) => const CreatePostScreen(),
        '/messages': (context) => const ConversationsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/home': (context) => const HomeScreen(),
        '/landing': (context) => const LandingScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/profile/verifications': (context) =>
            const VerificationHistoryScreen(),
        '/offers': (context) => const OffersListScreen(),
        '/offers/create': (context) => const CreateOfferScreen(),
        '/services': (context) => const ServicesListScreen(),
        '/rentals': (context) => const RentalListingsScreen(),
        '/rentals/create': (context) => const CreateRentalScreen(),
        '/matchmaking': (context) => const MatchmakingListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/profile/edit') {
          final user = settings.arguments as User?;
          return MaterialPageRoute(
            builder: (context) => EditProfileScreen(user: user),
          );
        }
        if (settings.name == '/auth/otp') {
          final phoneNumber = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => EnhancedOTPScreen(phoneNumber: phoneNumber),
          );
        }
        return null;
      },
    );
  }
}

// AuthWrapper is now imported from services/auth/auth_wrapper.dart
