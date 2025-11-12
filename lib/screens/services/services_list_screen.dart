import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../services/service_api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_logger.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/professional_app_bar.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  List<Service> _services = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Filters
  String? _selectedServiceType;
  String? _selectedRateType;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadMoreServices();
      }
    }
  }

  Future<void> _loadServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final services = await ServiceApiService.getAllServices(
        page: 1,
        limit: 10,
        serviceType: _selectedServiceType,
        rateType: _selectedRateType,
      );

      setState(() {
        _services = services;
        _currentPage = 1;
        _hasMore = services.length == 10;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading services: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreServices() async {
    try {
      setState(() => _isLoading = true);

      final moreServices = await ServiceApiService.getAllServices(
        page: _currentPage + 1,
        limit: 10,
        serviceType: _selectedServiceType,
        rateType: _selectedRateType,
      );

      setState(() {
        _services.addAll(moreServices);
        _currentPage++;
        _hasMore = moreServices.length == 10;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading more services: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Services'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedServiceType,
              decoration: const InputDecoration(labelText: 'Service Type'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Types')),
                DropdownMenuItem(value: 'consulting', child: Text('Consulting')),
                DropdownMenuItem(value: 'development', child: Text('Development')),
                DropdownMenuItem(value: 'design', child: Text('Design')),
                DropdownMenuItem(value: 'marketing', child: Text('Marketing')),
                DropdownMenuItem(value: 'writing', child: Text('Writing')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => _selectedServiceType = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRateType,
              decoration: const InputDecoration(labelText: 'Rate Type'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Rates')),
                DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'project', child: Text('Project-based')),
              ],
              onChanged: (value) => _selectedRateType = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _selectedServiceType = null;
              _selectedRateType = null;
              Navigator.pop(context);
              _loadServices();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadServices();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfessionalAppBar(
        title: 'Professional Services',
        showSearch: true,
        showProfile: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Services',
          ),
          IconButton(
            icon: const Icon(Icons.work_outline),
            onPressed: () {
              // TODO: Navigate to create service
            },
            tooltip: 'Offer Service',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _services.isEmpty) {
      return const LoadingWidget();
    }

    if (_error != null && _services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_services.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No services available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _services.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _services.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingWidget()),
            );
          }

          return _buildServiceCard(_services[index]);
        },
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.post?.title ?? 'Professional Service',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service.serviceType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (service.post?.description != null)
              Text(
                service.post!.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  service.experienceLevel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (service.preferredRate != null)
                  Text(
                    '\$${service.preferredRate!.toStringAsFixed(2)}/${service.rateType}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            if (service.skillsRequired.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: service.skillsRequired.take(3).map((skill) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement service detail view
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement hire functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Hire'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
