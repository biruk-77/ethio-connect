# Landing Page API Integration Guide

## Overview
This integration provides access to all public API endpoints that don't require authentication. Perfect for the landing page to display posts, products, jobs, and other content.

## Files Created

1. **`lib/config/landing_api_config.dart`** - API endpoint configuration
2. **`lib/services/landing_service.dart`** - Service layer for API calls
3. **`lib/providers/landing_provider.dart`** - State management provider

## Quick Start

### 1. Add Provider to Your App

In your `main.dart`, add the `LandingProvider`:

```dart
import 'package:provider/provider.dart';
import 'providers/landing_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LandingProvider()),
        // ... other providers
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Use in Landing Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/landing_provider.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LandingProvider>();
      provider.fetchCategories();
      provider.fetchRegions();
      provider.fetchPosts(limit: 20, isActive: true, featured: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LandingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingPosts) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          return ListView.builder(
            itemCount: provider.posts.length,
            itemBuilder: (context, index) {
              final post = provider.posts[index];
              return ListTile(
                title: Text(post['title'] ?? 'No title'),
                subtitle: Text(post['description'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
```

## Available Methods

### Categories
```dart
provider.fetchCategories();
// Access: provider.categories
```

### Regions & Cities
```dart
provider.fetchRegions();
provider.fetchCities(regionId: 'region-id'); // Optional filter by region
// Access: provider.regions, provider.cities
```

### Posts
```dart
provider.fetchPosts(
  page: 1,
  limit: 10,
  categoryId: 'category-id',  // Optional
  regionId: 'region-id',      // Optional
  cityId: 'city-id',          // Optional
  postType: 'offer',          // 'offer' or 'request'
  priceMin: 1000.0,           // Optional
  priceMax: 50000.0,          // Optional
  isActive: true,             // Optional
  search: 'developer',        // Optional search term
  featured: true,             // Optional - featured posts
  verified: true,             // Optional - verified posts
  sortBy: 'createdAt',        // Default sorting
  sortOrder: 'DESC',          // 'ASC' or 'DESC'
);
// Access: provider.posts
```

### Products
```dart
provider.fetchProducts(
  page: 1,
  limit: 10,
  condition: 'new',           // 'new', 'used', 'refurbished'
  productCategory: 'Electronics',
  categoryId: 'category-id',
  regionId: 'region-id',
  priceMin: 1000.0,
  priceMax: 50000.0,
  search: 'laptop',
);
// Access: provider.products
```

### Job Posts
```dart
provider.fetchJobPosts(
  page: 1,
  limit: 10,
  employmentType: 'full_time',  // 'full_time', 'part_time', 'contract', 'internship'
  experienceLevel: 'mid',        // 'junior', 'mid', 'senior', 'lead'
  remote: true,
  salaryMin: 30000.0,
  salaryMax: 100000.0,
  company: 'TechCorp',
  search: 'developer',
);
// Access: provider.jobPosts
```

### Rental Listings
```dart
provider.fetchRentalListings(
  page: 1,
  limit: 10,
  propertyType: 'apartment',
  bedrooms: 3,
  furnished: true,
  minRent: 5000.0,
  maxRent: 20000.0,
);
// Access: provider.rentalListings
```

### Services
```dart
provider.fetchServices(
  page: 1,
  limit: 10,
  serviceType: 'professional',
  minRate: 500.0,
  maxRate: 2000.0,
);
// Access: provider.services
```

### Matchmaking Posts
```dart
provider.fetchMatchmakingPosts(
  page: 1,
  limit: 10,
  visibility: 'public',
  religion: 'Christian',
);
// Access: provider.matchmakingPosts
```

### Search
```dart
// Global Search
provider.performGlobalSearch(
  query: 'developer',
  type: 'posts',  // Optional: 'posts', 'products', 'jobs'
  page: 1,
  limit: 20,
);

// Advanced Search
provider.performAdvancedSearch(
  query: 'laptop',
  categoryId: 'category-id',
  regionId: 'region-id',
  priceMin: 10000.0,
  priceMax: 50000.0,
  sortBy: 'createdAt',
  sortOrder: 'DESC',
  page: 1,
  limit: 20,
);
// Access: provider.searchResults
```

## Pagination

All list methods return paginated results. Access pagination info:

```dart
provider.currentPage   // Current page number
provider.totalPages    // Total pages available
provider.totalItems    // Total items count
```

## Loading States

Each data type has its own loading state:

```dart
provider.isLoadingCategories
provider.isLoadingRegions
provider.isLoadingCities
provider.isLoadingPosts
provider.isLoadingProducts
provider.isLoadingJobPosts
provider.isLoadingRentals
provider.isLoadingServices
provider.isLoadingMatchmaking
provider.isSearching
```

## Error Handling

```dart
if (provider.errorMessage != null) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(provider.errorMessage!)),
  );
  provider.clearError();
}
```

## Direct Service Usage (Without Provider)

If you prefer to use the service directly without the provider:

```dart
import '../services/landing_service.dart';

final landingService = LandingService();

// Example: Fetch posts
final response = await landingService.getAllPosts(
  page: 1,
  limit: 10,
  isActive: true,
);

if (response != null && response['success'] == true) {
  final posts = response['data']['posts'];
  // Use posts data
}
```

## API Configuration

The base URL is configured in `landing_api_config.dart`:

```dart
static const String baseUrl = 'https://ethiopost.unitybingo.com';
static const String localUrl = 'http://localhost:3000';
```

To switch to local development, change:
```dart
static const String apiUrl = localUrl;  // Use local server
```

## Important Notes

1. **No Authentication Required**: All endpoints in this integration are public and don't require JWT tokens
2. **Query Parameters**: All filter parameters are optional - only use what you need
3. **Minimum Search Length**: Search queries must be at least 3 characters
4. **Pagination**: Default is page 1 with 10 items per page
5. **Error Handling**: Always check for `errorMessage` after API calls

## Example: Complete Landing Page Flow

```dart
class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<LandingProvider>();
    
    // Load initial data
    await Future.wait([
      provider.fetchCategories(),
      provider.fetchRegions(),
      provider.fetchPosts(limit: 20, featured: true, isActive: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LandingProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          slivers: [
            // Categories Section
            SliverToBoxAdapter(
              child: CategoriesWidget(
                categories: provider.categories,
                isLoading: provider.isLoadingCategories,
              ),
            ),
            
            // Featured Posts Section
            SliverToBoxAdapter(
              child: FeaturedPostsWidget(
                posts: provider.posts,
                isLoading: provider.isLoadingPosts,
              ),
            ),
            
            // Error handling
            if (provider.errorMessage != null)
              SliverToBoxAdapter(
                child: ErrorWidget(message: provider.errorMessage!),
              ),
          ],
        );
      },
    );
  }
}
```

## Next Steps

1. Add the `LandingProvider` to your app's provider list
2. Use the provider in your landing screen
3. Customize the UI based on the data received
4. Add error handling and loading states
5. Implement pagination for better UX

Happy coding! 🚀
