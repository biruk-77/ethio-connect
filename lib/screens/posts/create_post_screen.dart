import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/post_service.dart';
import '../../services/auth/auth_service.dart';
import '../../models/verification_model.dart';
import '../../utils/category_verification_map.dart';
import '../../utils/app_logger.dart';

class CreatePostScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const CreatePostScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _tagsController = TextEditingController();
  
  // State
  bool _isLoading = true;
  bool _isVerified = false;
  bool _isSubmitting = false;
  String? _verificationMessage;
  VerificationCheckResult? _verificationResult;
  
  // Images
  List<File> _selectedImages = [];
  
  // Form values
  String _postType = 'offer';
  String? _selectedCategoryId;
  String? _selectedRegionId;
  String? _selectedCityId;
  
  // Data lists
  List<dynamic> _categories = [];
  List<dynamic> _regions = [];
  List<dynamic> _cities = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Check if user is authenticated
      final isAuth = await _authService.isAuthenticated();
      if (!isAuth) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login first')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Load categories and regions
      final categories = await _postService.getCategories();
      final regions = await _postService.getRegions();
      
      AppLogger.info('Loaded ${categories.length} categories');
      AppLogger.info('Loaded ${regions.length} regions');

      if (categories.isEmpty) {
        AppLogger.warning('⚠️ No categories loaded!');
      }

      setState(() {
        _categories = categories;
        _regions = regions;
      });

      // Check verification if category is pre-selected
      if (widget.categoryName != null) {
        await _checkCategoryAccess(widget.categoryName!);
      } else {
        setState(() {
          _isLoading = false;
          _isVerified = true; // Allow form if no specific category
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load data: $e');
      setState(() {
        _isLoading = false;
        _verificationMessage = 'Failed to load form data';
      });
    }
  }

  Future<void> _checkCategoryAccess(String categoryName) async {
    AppLogger.info('🔍 Checking access for category: $categoryName');

    try {
      final result = await _postService.checkCategoryAccess(categoryName);

      setState(() {
        _verificationResult = result;
        _isVerified = result?.isVerified ?? false;
        _verificationMessage = result?.isVerified == true
            ? '✅ You are verified as ${result?.roleName}'
            : result?.reason ?? 'Verification required';
        _isLoading = false;
      });

      // Show dialog if not verified
      if (!_isVerified && mounted) {
        _showVerificationRequiredDialog();
      }
    } catch (e) {
      AppLogger.error('Verification check failed: $e');
      setState(() {
        _isLoading = false;
        _isVerified = false;
        _verificationMessage = 'Failed to check verification status';
      });
    }
  }

  void _showVerificationRequiredDialog() {
    final categoryName = widget.categoryName ?? 'this category';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Verification Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CategoryVerificationMap.getVerificationMessage(categoryName),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Current Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              'Has Required Role',
              _verificationResult?.hasRole ?? false,
            ),
            _buildStatusRow(
              'Has Verification',
              _verificationResult?.hasVerification ?? false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/verification/submit');
            },
            icon: const Icon(Icons.verified_user),
            label: const Text('Get Verified'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _loadCitiesByRegion(String regionId) async {
    try {
      final cities = await _postService.getCitiesByRegion(regionId);
      setState(() {
        _cities = cities;
        _selectedCityId = null; // Reset city selection
      });
    } catch (e) {
      AppLogger.error('Failed to load cities: $e');
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images.map((xfile) => File(xfile.path)).toList();
        });
        AppLogger.success('Selected ${images.length} images');
      }
    } catch (e) {
      AppLogger.error('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Parse price
      double? price;
      if (_priceController.text.isNotEmpty) {
        price = double.tryParse(_priceController.text);
      }

      AppLogger.info('📝 Creating post...');
      
      final post = await _postService.createPost(
        categoryId: _selectedCategoryId!,
        postType: _postType,
        title: _titleController.text,
        description: _descriptionController.text,
        price: price,
        regionId: _selectedRegionId,
        cityId: _selectedCityId,
        tags: tags.isNotEmpty ? tags : null,
        isActive: true,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (post != null) {
          AppLogger.celebrate('✅ Post created successfully!');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Post created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Go back after short delay
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create post')),
          );
        }
      }
    } on DioException catch (e) {
      setState(() => _isSubmitting = false);

      // Handle authentication error (401)
      if (e.response?.statusCode == 401) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('🔐 Authentication Required'),
              content: const Text(
                'Your session has expired or you are not logged in. Please login again.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacementNamed(context, '/auth/login');
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Handle verification error (403)
      if (e.response?.statusCode == 403) {
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Verification required';
        final details = errorData?['details'];

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('❌ Cannot Create Post'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message),
                  if (details != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('Required: ${details['requiredVerification']}'),
                    const SizedBox(height: 4),
                    Text('Action: ${details['action']}'),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/verification/submit');
                  },
                  child: const Text('Get Verified'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      AppLogger.error('Error creating post: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Post')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName != null
              ? 'Create Post in ${widget.categoryName}'
              : 'Create Post',
        ),
        actions: [
          if (_isVerified && _verificationResult != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                avatar: const Icon(Icons.verified, color: Colors.white, size: 16),
                label: Text(
                  _verificationResult?.roleName ?? 'Verified',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
      body: _isVerified ? _buildForm() : _buildVerificationRequired(),
      bottomNavigationBar: _isVerified
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Post'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Type
            const Text('Post Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'offer', label: Text('Offer')),
                ButtonSegment(value: 'request', label: Text('Request')),
              ],
              selected: {_postType},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _postType = selection.first);
              },
            ),
            const SizedBox(height: 24),

            // Category
            const Text('Category *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a category',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'],
                  child: Text(category['name'] ?? ''),
                );
              }).toList(),
              onChanged: widget.categoryId == null
                  ? (value) => setState(() => _selectedCategoryId = value)
                  : null,
              validator: (value) => value == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // Title
            const Text('Title *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter post title',
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),

            // Images
            const Text('Images (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_selectedImages.isEmpty)
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          // Add more button
                          return GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40),
                                  SizedBox(height: 4),
                                  Text('Add More'),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        return Stack(
                          children: [
                            Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedImages.length} image(s) selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Description
            const Text('Description *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter detailed description',
              ),
              maxLines: 5,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 16),

            // Price
            const Text('Price (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter price',
                prefixText: 'ETB ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Region
            const Text('Region (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedRegionId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a region',
              ),
              items: _regions.map((region) {
                return DropdownMenuItem<String>(
                  value: region['id'],
                  child: Text(region['name'] ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedRegionId = value);
                if (value != null) {
                  _loadCitiesByRegion(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // City
            if (_selectedRegionId != null) ...[
              const Text('City (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCityId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select a city',
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city['id'],
                    child: Text(city['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCityId = value),
              ),
              const SizedBox(height: 16),
            ],

            // Tags
            const Text('Tags (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter tags separated by commas',
                helperText: 'Example: technology, laptop, new',
              ),
            ),
            const SizedBox(height: 80), // Space for bottom button
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Verification Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _verificationMessage ?? 'You need to be verified to post in this category',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/verification/submit'),
              icon: const Icon(Icons.verified_user),
              label: const Text('Get Verified'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
