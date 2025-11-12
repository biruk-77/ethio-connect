import 'package:flutter/material.dart';

class SearchFiltersDialog extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final List<dynamic> categories;
  final List<dynamic> regions;
  final List<dynamic> cities;

  const SearchFiltersDialog({
    super.key,
    required this.initialFilters,
    required this.categories,
    required this.regions,
    required this.cities,
  });

  @override
  State<SearchFiltersDialog> createState() => _SearchFiltersDialogState();
}

class _SearchFiltersDialogState extends State<SearchFiltersDialog> {
  late Map<String, dynamic> filters;
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.initialFilters);
    _priceMinController.text = filters['priceMin']?.toString() ?? '';
    _priceMaxController.text = filters['priceMax']?.toString() ?? '';
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Search Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Type
                  _buildSectionTitle('Content Type', theme),
                  _buildTypeSelector(theme),
                  const SizedBox(height: 20),
                  
                  // Category
                  if (widget.categories.isNotEmpty) ...[
                    _buildSectionTitle('Category', theme),
                    _buildCategorySelector(theme),
                    const SizedBox(height: 20),
                  ],
                  
                  // Region
                  if (widget.regions.isNotEmpty) ...[
                    _buildSectionTitle('Region', theme),
                    _buildRegionSelector(theme),
                    const SizedBox(height: 20),
                  ],
                  
                  // City (if region selected)
                  if (filters['regionId'] != null && widget.cities.isNotEmpty) ...[
                    _buildSectionTitle('City', theme),
                    _buildCitySelector(theme),
                    const SizedBox(height: 20),
                  ],
                  
                  // Price Range
                  _buildSectionTitle('Price Range', theme),
                  _buildPriceRange(theme),
                  const SizedBox(height: 20),
                  
                  // Sort By
                  _buildSectionTitle('Sort By', theme),
                  _buildSortSelector(theme),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, filters),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    final types = ['posts', 'products', 'jobs', 'services', 'rentals'];
    
    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = filters['type'] == type;
        return FilterChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              filters['type'] = selected ? type : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return DropdownButtonFormField<String>(
      initialValue: filters['categoryId'],
      decoration: InputDecoration(
        hintText: 'Select category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: <DropdownMenuItem<String>>[
        const DropdownMenuItem<String>(value: null, child: Text('All Categories')),
        ...widget.categories.map((cat) {
          return DropdownMenuItem<String>(
            value: cat['id']?.toString(),
            child: Text(cat['categoryName'] ?? cat['name'] ?? 'Category'),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          filters['categoryId'] = value;
        });
      },
    );
  }

  Widget _buildRegionSelector(ThemeData theme) {
    return DropdownButtonFormField<String>(
      initialValue: filters['regionId'],
      decoration: InputDecoration(
        hintText: 'Select region',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: <DropdownMenuItem<String>>[
        const DropdownMenuItem<String>(value: null, child: Text('All Regions')),
        ...widget.regions.map((region) {
          return DropdownMenuItem<String>(
            value: region['id']?.toString(),
            child: Text(region['name'] ?? 'Region'),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          filters['regionId'] = value;
          filters['cityId'] = null; // Reset city when region changes
        });
      },
    );
  }

  Widget _buildCitySelector(ThemeData theme) {
    // Filter cities by selected region
    final regionCities = widget.cities.where((city) {
      return city['regionId'] == filters['regionId'];
    }).toList();
    
    return DropdownButtonFormField<String>(
      initialValue: filters['cityId'],
      decoration: InputDecoration(
        hintText: 'Select city',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: <DropdownMenuItem<String>>[
        const DropdownMenuItem<String>(value: null, child: Text('All Cities')),
        ...regionCities.map((city) {
          return DropdownMenuItem<String>(
            value: city['id']?.toString(),
            child: Text(city['name'] ?? 'City'),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          filters['cityId'] = value;
        });
      },
    );
  }

  Widget _buildPriceRange(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _priceMinController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Min Price',
              prefixText: 'ETB ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              filters['priceMin'] = double.tryParse(value);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _priceMaxController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max Price',
              prefixText: 'ETB ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              filters['priceMax'] = double.tryParse(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortSelector(ThemeData theme) {
    final sortOptions = [
      {'value': 'createdAt', 'label': 'Date'},
      {'value': 'price', 'label': 'Price'},
      {'value': 'title', 'label': 'Title'},
    ];
    
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: filters['sortBy'] ?? 'createdAt',
          decoration: InputDecoration(
            hintText: 'Sort by',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: sortOptions.map((option) {
            return DropdownMenuItem(
              value: option['value'],
              child: Text(option['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              filters['sortBy'] = value;
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Newest First'),
                value: 'DESC',
                groupValue: filters['sortOrder'] ?? 'DESC',
                onChanged: (value) {
                  setState(() {
                    filters['sortOrder'] = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Oldest First'),
                value: 'ASC',
                groupValue: filters['sortOrder'] ?? 'DESC',
                onChanged: (value) {
                  setState(() {
                    filters['sortOrder'] = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      filters = {
        'type': null,
        'categoryId': null,
        'regionId': null,
        'cityId': null,
        'priceMin': null,
        'priceMax': null,
        'sortBy': 'createdAt',
        'sortOrder': 'DESC',
      };
      _priceMinController.clear();
      _priceMaxController.clear();
    });
  }
}
