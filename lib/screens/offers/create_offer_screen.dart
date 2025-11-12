import 'package:flutter/material.dart';
import '../../services/offer_post_service.dart';
import '../../services/post_service.dart';
import '../../models/post_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _discountPercentageController = TextEditingController();
  final _maxRedemptionsController = TextEditingController();
  final _termsController = TextEditingController();

  String _offerType = 'discount';
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  
  List<Post> _posts = [];
  Post? _selectedPost;
  bool _isLoading = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
    
    // Set default values
    _maxRedemptionsController.text = '100';
  }

  @override
  void dispose() {
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _discountPercentageController.dispose();
    _maxRedemptionsController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPosts() async {
    try {
      setState(() => _isLoading = true);
      
      final postService = PostService();
      final posts = await postService.getMyPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading posts: $e');
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to load your posts: ${e.toString()}');
    }
  }

  Future<void> _createOffer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPost == null) {
      _showErrorDialog('Please select a post for this offer');
      return;
    }

    try {
      setState(() => _isCreating = true);

      final originalPrice = double.parse(_originalPriceController.text);
      final discountedPrice = _discountedPriceController.text.isNotEmpty
          ? double.parse(_discountedPriceController.text)
          : null;
      final discountPercentage = _discountPercentageController.text.isNotEmpty
          ? double.parse(_discountPercentageController.text)
          : null;
      final maxRedemptions = int.parse(_maxRedemptionsController.text);

      await OfferPostService.createOfferPost(
        postId: _selectedPost!.id,
        offerType: _offerType,
        originalPrice: originalPrice,
        discountedPrice: discountedPrice,
        discountPercentage: discountPercentage,
        validFrom: _validFrom,
        validUntil: _validUntil,
        termsAndConditions: _termsController.text.isNotEmpty
            ? _termsController.text
            : null,
        maxRedemptions: maxRedemptions,
      );

      _showSuccessDialog();
    } catch (e) {
      AppLogger.error('Error creating offer: $e');
      _showErrorDialog('Failed to create offer: ${e.toString()}');
    } finally {
      setState(() => _isCreating = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: const Text('Offer created successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to offers list
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isValidFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isValidFrom ? _validFrom : _validUntil,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isValidFrom) {
          _validFrom = picked;
          if (_validUntil.isBefore(_validFrom)) {
            _validUntil = _validFrom.add(const Duration(days: 1));
          }
        } else {
          _validUntil = picked;
        }
      });
    }
  }

  void _onDiscountPercentageChanged(String value) {
    if (value.isNotEmpty && _originalPriceController.text.isNotEmpty) {
      try {
        final originalPrice = double.parse(_originalPriceController.text);
        final discountPercentage = double.parse(value);
        final discountedPrice = originalPrice * (1 - discountPercentage / 100);
        _discountedPriceController.text = discountedPrice.toStringAsFixed(2);
      } catch (e) {
        // Invalid input, ignore
      }
    }
  }

  void _onDiscountedPriceChanged(String value) {
    if (value.isNotEmpty && _originalPriceController.text.isNotEmpty) {
      try {
        final originalPrice = double.parse(_originalPriceController.text);
        final discountedPrice = double.parse(value);
        final discountPercentage = ((originalPrice - discountedPrice) / originalPrice) * 100;
        _discountPercentageController.text = discountPercentage.toStringAsFixed(1);
      } catch (e) {
        // Invalid input, ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Offer'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostSelection(),
                    const SizedBox(height: 24),
                    _buildOfferTypeSection(),
                    const SizedBox(height: 24),
                    _buildPricingSection(),
                    const SizedBox(height: 24),
                    _buildValiditySection(),
                    const SizedBox(height: 24),
                    _buildAdditionalDetailsSection(),
                    const SizedBox(height: 32),
                    _buildCreateButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPostSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Post>(
              value: _selectedPost,
              decoration: const InputDecoration(
                labelText: 'Choose a post for this offer',
                border: OutlineInputBorder(),
              ),
              items: _posts.map((post) {
                return DropdownMenuItem<Post>(
                  value: post,
                  child: Text(
                    post.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (Post? newValue) {
                setState(() => _selectedPost = newValue);
              },
              validator: (value) => value == null ? 'Please select a post' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferTypeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Offer Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _offerType,
              decoration: const InputDecoration(
                labelText: 'Offer Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'discount', child: Text('Discount')),
                DropdownMenuItem(value: 'bogo', child: Text('Buy One Get One')),
                DropdownMenuItem(value: 'flash_sale', child: Text('Flash Sale')),
                DropdownMenuItem(value: 'clearance', child: Text('Clearance')),
              ],
              onChanged: (String? newValue) {
                setState(() => _offerType = newValue!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pricing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _originalPriceController,
              labelText: 'Original Price (\$)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the original price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _discountPercentageController,
                    labelText: 'Discount (%)',
                    keyboardType: TextInputType.number,
                    onChanged: _onDiscountPercentageChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _discountedPriceController,
                    labelText: 'Discounted Price (\$)',
                    keyboardType: TextInputType.number,
                    onChanged: _onDiscountedPriceChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValiditySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Validity Period',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Valid From'),
                    subtitle: Text('${_validFrom.day}/${_validFrom.month}/${_validFrom.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Valid Until'),
                    subtitle: Text('${_validUntil.day}/${_validUntil.month}/${_validUntil.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _maxRedemptionsController,
              labelText: 'Maximum Redemptions',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter maximum redemptions';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _termsController,
              labelText: 'Terms & Conditions (Optional)',
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isCreating ? 'Creating Offer...' : 'Create Offer',
        onPressed: _isCreating ? null : _createOffer,
        isLoading: _isCreating,
      ),
    );
  }
}
