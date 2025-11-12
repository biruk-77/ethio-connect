import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/role_service.dart';
import '../../services/auth/auth_service.dart';
import '../../models/role_model.dart';
import '../../models/auth/user_model.dart';
import '../../providers/landing_provider.dart';
import '../../utils/app_logger.dart';
import './widgets/landing_app_bar.dart';
import './widgets/category_navigation_grid.dart';
import './widgets/landing_search_bar.dart';
import './widgets/landing_categories.dart';
import './widgets/content_categories_grid.dart';
import './widgets/search_filters_dialog.dart';
import './widgets/quick_action_buttons.dart';
import './widgets/posts_carousel.dart';
import './widgets/products_carousel.dart';
import './widgets/jobs_carousel.dart';
import './widgets/services_carousel.dart';
import './widgets/rentals_carousel.dart';
import './widgets/matchmaking_carousel.dart';
import './widgets/landing_footer.dart';
import '../messaging/widgets/chat_carousel.dart';
import '../../widgets/app_drawer.dart';
import './search/search_results_panel.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _selectedCategory;
  String? _expandedCategoryId;
  String? _selectedContentCategory; // Selected content category name (job, product, etc.)
  List<Role> _roles = [];
  bool _isLoadingRoles = true;
  bool _showSearchResults = false;
  User? _currentUser;
  bool _isCheckingAuth = true;
  
  // Search filters
  Map<String, dynamic> _searchFilters = {
    'type': null,
    'categoryId': null,
    'regionId': null,
    'cityId': null,
    'priceMin': null,
    'priceMax': null,
    'sortBy': 'createdAt',
    'sortOrder': 'DESC',
  };
  
  @override
  void initState() {
    super.initState();
    AppLogger.section('LANDING SCREEN INITIALIZED');
    AppLogger.info('User viewing landing page');
    
    // Schedule data loading after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
      _loadRoles();
      _loadLandingData();
    });
  }
  
  Future<void> _checkAuthStatus() async {
    final user = await _authService.getStoredUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isCheckingAuth = false;
      });
    }
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoadingRoles = true;
    });
    
    try {
      final roleService = Provider.of<RoleService>(context, listen: false);
      final roles = await roleService.getAllRoles();
      
      if (mounted) {
        setState(() {
          _roles = roles;
          _isLoadingRoles = false;
        });
        AppLogger.success('Loaded ${roles.length} roles for categories');
      }
    } catch (e) {
      AppLogger.error('Failed to load roles', error: e);
      if (mounted) {
        setState(() {
          _isLoadingRoles = false;
        });
      }
    }
  }
  
  Future<void> _loadLandingData() async {
    final landingProvider = Provider.of<LandingProvider>(context, listen: false);
    
    AppLogger.section('LOADING LANDING PAGE DATA');
    AppLogger.info('Post Service URL: https://ethiopost.unitybingo.com');
    
    // Fetch all content types in parallel - NO FILTERS, GET EVERYTHING
    await Future.wait([
      // Location data
      landingProvider.fetchRegions(),
      landingProvider.fetchCategories(),
      landingProvider.fetchCities(),
      
      // All content types - without any filtering
      landingProvider.fetchPosts(
        limit: 20,
      ),
      landingProvider.fetchProducts(
        limit: 20,
      ),
      landingProvider.fetchJobPosts(
        limit: 20,
      ),
      landingProvider.fetchServices(
        limit: 20,
      ),
      landingProvider.fetchRentalListings(
        limit: 20,
      ),
      landingProvider.fetchMatchmakingPosts(
        limit: 20,
      ),
    ]);
    
    if (landingProvider.errorMessage != null) {
      AppLogger.error('Landing data error: ${landingProvider.errorMessage}');
    } else {
      AppLogger.celebrate('ALL LANDING DATA LOADED! 🎉');
      AppLogger.info('📍 Regions: ${landingProvider.regions.length}');
      AppLogger.info('📝 Posts: ${landingProvider.posts.length}');
      AppLogger.info('🛍️ Products: ${landingProvider.products.length}');
      AppLogger.info('💼 Jobs: ${landingProvider.jobPosts.length}');
      AppLogger.info('🔧 Services: ${landingProvider.services.length}');
      AppLogger.info('🏠 Rentals: ${landingProvider.rentalListings.length}');
      AppLogger.info('💕 Matchmaking: ${landingProvider.matchmakingPosts.length}');
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleCategoryTap(String? categoryId) async {
    if (categoryId == null) return;
    
    // Check if user is logged in
    if (_currentUser == null) {
      // Show login prompt
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.orange),
              SizedBox(width: 12),
              Text('Login Required'),
            ],
          ),
          content: const Text('You need to login to apply for professional roles and get verified.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Login'),
            ),
          ],
        ),
      );
      
      if (result == true && mounted) {
        Navigator.pushNamed(context, '/auth/login');
      }
      return;
    }
    
    // Find the role name from the ID
    String roleName = 'other';
    String roleDisplayName = 'Role';
    
    if (_roles.isNotEmpty) {
      final selectedRole = _roles.firstWhere(
        (role) => role.id == categoryId,
        orElse: () => Role(id: '', name: '', createdAt: DateTime.now()),
      );
      if (selectedRole.name.isNotEmpty) {
        roleName = selectedRole.name.toLowerCase();
        roleDisplayName = selectedRole.name;
      }
    }
    
    AppLogger.info('🎯 Role selected for application: $roleDisplayName');
    
    // Map role names to verification types
    String verificationType = 'other';
    if (roleName.contains('doctor')) {
      verificationType = 'doctor_license';
    } else if (roleName.contains('teacher')) {
      verificationType = 'teacher_cert';
    } else if (roleName.contains('business') || roleName.contains('employer')) {
      verificationType = 'business_license';
    } else if (roleName.contains('employee')) {
      verificationType = 'employer_cert';
    }
    
    // Show application confirmation dialog
    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply for $roleDisplayName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are applying to become a verified $roleDisplayName.'),
            const SizedBox(height: 16),
            const Text(
              'You will need to:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Upload verification documents'),
            const Text('• Provide additional information'),
            const Text('• Wait for admin approval'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    
    if (apply == true && mounted) {
      // Navigate to verification submission with the role type
      Navigator.pushNamed(
        context,
        '/verification/submit',
        arguments: {
          'verificationType': verificationType,
          'roleName': roleDisplayName,
        },
      );
    }
  }

  void _handleSearch(String query) {
    // Check if we have filters applied
    final hasFilters = _searchFilters['categoryId'] != null ||
        _searchFilters['regionId'] != null ||
        _searchFilters['cityId'] != null ||
        _searchFilters['priceMin'] != null ||
        _searchFilters['priceMax'] != null ||
        _searchFilters['type'] != null;
    
    // Hide panel if no query and no filters
    if ((query.isEmpty || query.length < 2) && !hasFilters) {
      setState(() {
        _showSearchResults = false;
      });
      return;
    }
    
    // Show search results panel
    setState(() {
      _showSearchResults = true;
    });
    
    _performSearch(query);
  }

  void _performSearch(String query) {
    final landingProvider = Provider.of<LandingProvider>(context, listen: false);
    
    // Check if we have filters applied
    final hasFilters = _searchFilters['categoryId'] != null ||
        _searchFilters['regionId'] != null ||
        _searchFilters['cityId'] != null ||
        _searchFilters['priceMin'] != null ||
        _searchFilters['priceMax'] != null;
    
    AppLogger.info('🔍 Searching for: $query');
    AppLogger.info('📋 Filters: $_searchFilters');
    AppLogger.info('🎯 Has filters: $hasFilters');
    
    if (hasFilters) {
      // Advanced search with filters
      landingProvider.performAdvancedSearch(
        query: query.isNotEmpty ? query : '',
        categoryId: _searchFilters['categoryId'],
        regionId: _searchFilters['regionId'],
        cityId: _searchFilters['cityId'],
        priceMin: _searchFilters['priceMin'],
        priceMax: _searchFilters['priceMax'],
        sortBy: _searchFilters['sortBy'] ?? 'createdAt',
        sortOrder: _searchFilters['sortOrder'] ?? 'DESC',
        limit: 20,
      ).then((_) {
        AppLogger.success('✅ Advanced search completed!');
        
        // Log actual response data in pretty format
        if (landingProvider.searchResults.isNotEmpty) {
          AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          AppLogger.info('📋 FILTERED SEARCH RESULTS:');
          AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          
          for (var i = 0; i < landingProvider.searchResults.length; i++) {
            final result = landingProvider.searchResults[i];
            AppLogger.info('');
            AppLogger.info('🔹 Result ${i + 1}:');
            AppLogger.info('   📌 Type: ${result['type'] ?? 'N/A'}');
            AppLogger.info('   📝 Title: ${result['title'] ?? 'N/A'}');
            AppLogger.info('   💰 Price: ${result['price'] != null ? 'ETB ${result['price']}' : 'N/A'}');
            AppLogger.info('   📍 Region: ${result['region']?['name'] ?? 'N/A'}');
            AppLogger.info('   🏙️  City: ${result['city']?['name'] ?? 'N/A'}');
            AppLogger.info('   🗂️  Category: ${result['category']?['categoryName'] ?? result['category']?['name'] ?? 'N/A'}');
            AppLogger.info('   📄 Description: ${result['description'] != null ? (result['description'].toString().length > 50 ? '${result['description'].toString().substring(0, 50)}...' : result['description']) : 'N/A'}');
            AppLogger.info('   🆔 ID: ${result['id'] ?? 'N/A'}');
          }
          
          AppLogger.info('');
          AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        } else {
          AppLogger.warning('⚠️  No results found for the applied filters');
        }
      });
    } else {
      // Global search - no filters
      if (query.isNotEmpty && query.length >= 2) {
        final type = _searchFilters['type'];
        landingProvider.performGlobalSearch(
          query: query,
          type: type,
          limit: 20,
        ).then((_) {
          AppLogger.success('✅ Global search completed!');
          AppLogger.info('📊 Results: ${landingProvider.searchResults.length}');
          
          // Log actual response data in pretty format
          if (landingProvider.searchResults.isNotEmpty) {
            AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            AppLogger.info('📋 SEARCH RESULTS DATA:');
            AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            
            for (var i = 0; i < landingProvider.searchResults.length; i++) {
              final result = landingProvider.searchResults[i];
              AppLogger.info('');
              AppLogger.info('🔹 Result ${i + 1}:');
              AppLogger.info('   📌 Type: ${result['type'] ?? 'N/A'}');
              AppLogger.info('   📝 Title: ${result['title'] ?? 'N/A'}');
              AppLogger.info('   💰 Price: ${result['price'] != null ? 'ETB ${result['price']}' : 'N/A'}');
              AppLogger.info('   📍 Region: ${result['region']?['name'] ?? 'N/A'}');
              AppLogger.info('   🏙️  City: ${result['city']?['name'] ?? 'N/A'}');
              AppLogger.info('   🗂️  Category: ${result['category']?['categoryName'] ?? result['category']?['name'] ?? 'N/A'}');
              AppLogger.info('   📄 Description: ${result['description'] != null ? (result['description'].toString().length > 50 ? '${result['description'].toString().substring(0, 50)}...' : result['description']) : 'N/A'}');
              AppLogger.info('   🆔 ID: ${result['id'] ?? 'N/A'}');
              if (result['company'] != null) {
                AppLogger.info('   🏢 Company: ${result['company']}');
              }
              if (result['condition'] != null) {
                AppLogger.info('   ⚙️  Condition: ${result['condition']}');
              }
              AppLogger.info('   ⏰ Created: ${result['createdAt'] ?? 'N/A'}');
            }
            
            AppLogger.info('');
            AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          }
        });
      }
    }
  }

  Future<void> _handleContentCategoryTap(String categoryId) async {
    final landingProvider = Provider.of<LandingProvider>(context, listen: false);
    
    // Find the category name
    final category = landingProvider.categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => null,
    );
    
    final categoryName = category?['categoryName']?.toString().toLowerCase();
    
    setState(() {
      if (_expandedCategoryId == categoryId) {
        // Collapse if already expanded
        _expandedCategoryId = null;
        _selectedContentCategory = null;
        landingProvider.clearCategoryDetails();
      } else {
        // Expand and fetch details
        _expandedCategoryId = categoryId;
        _selectedContentCategory = categoryName;
        landingProvider.fetchCategoryDetails(categoryId);
      }
    });
  }
  
  Future<void> _showFilterDialog() async {
    final landingProvider = Provider.of<LandingProvider>(context, listen: false);
    
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => SearchFiltersDialog(
          initialFilters: _searchFilters,
          categories: landingProvider.categories,
          regions: landingProvider.regions,
          cities: landingProvider.cities,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _searchFilters = result;
        _showSearchResults = true;
      });
      
      // Use current search query or empty string for filter-only search
      final query = _searchController.text.trim();
      
      // Trigger search with filters
      _performSearch(query);
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    final icons = {
      'job': Icons.work,
      'product': Icons.shopping_bag,
      'service': Icons.handyman,
      'rental': Icons.home,
      'tutor': Icons.school,
    };
    return icons[categoryName.toLowerCase()] ?? Icons.category;
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    // Not logged in -> Show "Login" banner
    if (_currentUser == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade500, Colors.indigo.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.login,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Join EthioConnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Login to unlock all features and apply for roles',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/auth/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }
    
    // Logged in but not verified and has no roles -> Show "Get Verified" banner
    if (!_currentUser!.isVerified && _currentUser!.roles.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.verified_user,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get Verified',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete verification to create posts and apply for roles',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/verification/center');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
      );
    }
    
    // Logged in and verified -> No banner
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
          // App Bar
          LandingAppBar(l10n: l10n),

          // Search Bar
          LandingSearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
              if (value.length >= 2) {
                _handleSearch(value);
              } else if (value.isEmpty) {
                setState(() {
                  _showSearchResults = false;
                });
              }
            },
            onSubmit: _handleSearch,
            onFilterTap: _showFilterDialog,
          ),

          // Banner: Login (if not authenticated) OR Verify (if authenticated but not verified)
          if (!_isCheckingAuth)
            SliverToBoxAdapter(
              child: _buildBanner(),
            ),

          // Quick Action Buttons (Create Post, Verification, Profile, etc.)
          if (!_isCheckingAuth)
            SliverToBoxAdapter(
              child: QuickActionButtons(currentUser: _currentUser),
            ),

          // Recent Chats Carousel - Only show if user is authenticated
          if (!_isCheckingAuth && _currentUser != null)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recent Chats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/messages');
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                  const ChatCarousel(),
                ],
              ),
            ),

          // Divider after chat carousel
          if (!_isCheckingAuth && _currentUser != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
            ),

          // Category Navigation Grid
          Consumer<LandingProvider>(
            builder: (context, landingProvider, _) {
              return SliverToBoxAdapter(
                child: CategoryNavigationGrid(
                  jobs: landingProvider.jobPosts,
                  products: landingProvider.products,
                  rentals: landingProvider.rentalListings,
                  services: landingProvider.services,
                  matchmaking: const [], // TODO: Add matchmaking to landing provider
                  events: const [], // TODO: Add events to landing provider
                ),
              );
            },
          ),

          // Divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
          ),

          // User Interests Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply for Professional Roles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Become a verified professional',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User Interests Grid (Roles)
          LandingCategories(
            selectedCategory: _selectedCategory,
            onCategoryTap: _handleCategoryTap,
            roles: _roles,
            isLoading: _isLoadingRoles,
          ),

          // Content Categories Grid
          Consumer<LandingProvider>(
            builder: (context, provider, _) {
              return ContentCategoriesGrid(
                categories: provider.categories,
                isLoading: provider.isLoadingCategories,
                expandedCategoryId: _expandedCategoryId,
                categoryDetails: provider.categoryDetails,
                isLoadingDetails: provider.isLoadingCategoryDetails,
                onCategoryTap: _handleContentCategoryTap,
              );
            },
          ),

          // All Content Carousels - Show based on selected category
          Consumer<LandingProvider>(
            builder: (context, landingProvider, _) {
              // If no category selected, show all carousels
              final showAll = _selectedContentCategory == null;
              final selected = _selectedContentCategory?.toLowerCase();
              
              return SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  
                  // Selected Category Header
                  if (_selectedContentCategory != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(selected ?? ''),
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Showing ${_selectedContentCategory?.toUpperCase()} only',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedContentCategory = null;
                                _expandedCategoryId = null;
                              });
                            },
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Show All'),
                          ),
                        ],
                      ),
                    ),
                  
                  // Posts Carousel - Show for general posts or when no specific category selected
                  if (showAll || selected == 'post' || selected == 'offer' || selected == 'request')
                    PostsCarousel(
                      posts: landingProvider.posts,
                      isLoading: landingProvider.isLoadingPosts,
                      title: _selectedCategory != null
                          ? _roles.firstWhere(
                              (role) => role.id == _selectedCategory,
                              orElse: () => Role(id: '', name: 'Posts', createdAt: DateTime.now()),
                            ).name
                          : 'Latest Posts',
                    ),
                  
                  if (showAll || selected == 'post' || selected == 'offer' || selected == 'request')
                    const SizedBox(height: 20),
                  
                  // Products Carousel - Show only when product category selected or showing all
                  if (showAll || selected == 'product')
                    ProductsCarousel(
                      products: landingProvider.products,
                      isLoading: landingProvider.isLoadingProducts,
                    ),
                  
                  if (showAll || selected == 'product')
                    const SizedBox(height: 20),
                  
                  // Jobs Carousel - Show only when job category selected or showing all
                  if (showAll || selected == 'job')
                    JobsCarousel(
                      jobs: landingProvider.jobPosts,
                      isLoading: landingProvider.isLoadingJobPosts,
                    ),
                  
                  if (showAll || selected == 'job')
                    const SizedBox(height: 20),
                  
                  // NEW VERIFIED USER FEATURES SECTION
                  if (_currentUser != null && _roles.isNotEmpty) ...[
                    // Verified User Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: const Icon(Icons.verified, color: Colors.amber, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verified Member Features',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'Premium access to all marketplace features',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Special Offers Carousel - Show for all users with different access levels
                  if (showAll || selected == 'offer') ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('🎁', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentUser != null && _roles.isNotEmpty
                                      ? 'Exclusive Premium Offers'
                                      : 'Special Offers',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _currentUser != null && _roles.isNotEmpty
                                      ? 'Access verified-only deals and discounts'
                                      : 'Discover great deals and promotions',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/offers'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Services Carousel - Show only when service category selected or showing all
                  if (showAll || selected == 'service') ...[
                    ServicesCarousel(
                      services: landingProvider.services,
                      isLoading: landingProvider.isLoadingServices,
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Rentals Carousel - Show only when rental category selected or showing all
                  if (showAll || selected == 'rental') ...[
                    RentalsCarousel(
                      rentals: landingProvider.rentalListings,
                      isLoading: landingProvider.isLoadingRentals,
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Matchmaking Carousel - Show with different access levels
                  if (_currentUser != null) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.pink.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('💕', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _roles.isNotEmpty
                                      ? 'Verified Dating & Matchmaking'
                                      : 'Dating & Matchmaking',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _roles.isNotEmpty
                                      ? 'Connect with verified members for authentic relationships'
                                      : 'Find meaningful connections and relationships',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/matchmaking'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Explore'),
                          ),
                        ],
                      ),
                    ),
                    MatchmakingCarousel(
                      matchmakingPosts: landingProvider.matchmakingPosts,
                      isLoading: landingProvider.isLoadingMatchmaking,
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                ]),
              );
            },
          ),

        
          // Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),

          // Footer
          const LandingFooter(),
            ],
          ),

          // Search Results Overlay
          if (_showSearchResults && _searchController.text.isNotEmpty)
            SearchResultsPanel(
              searchQuery: _searchController.text,
              onClose: () {
                setState(() {
                  _showSearchResults = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
