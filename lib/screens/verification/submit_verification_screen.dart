import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth/auth_service.dart';
import '../../models/auth/verification_model.dart';
import '../../utils/app_logger.dart';

class SubmitVerificationScreen extends StatefulWidget {
  const SubmitVerificationScreen({super.key});

  @override
  State<SubmitVerificationScreen> createState() => _SubmitVerificationScreenState();
}

class _SubmitVerificationScreenState extends State<SubmitVerificationScreen> {
  final AuthService _authService = AuthService();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  String _selectedType = VerificationTypes.kyc;
  File? _selectedFile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _roleName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get arguments from navigation
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _selectedType = args['verificationType'] as String? ?? VerificationTypes.kyc;
      _roleName = args['roleName'] as String?;
      AppLogger.info('📋 Pre-selected verification type: $_selectedType for role: $_roleName');
    }
  }

  final Map<String, Map<String, dynamic>> _verificationTypes = {
    VerificationTypes.kyc: {
      'label': 'KYC Verification',
      'icon': Icons.badge,
      'description': 'ID card or passport verification',
    },
    VerificationTypes.doctorLicense: {
      'label': 'Doctor License',
      'icon': Icons.medical_services,
      'description': 'Medical license verification',
    },
    VerificationTypes.teacherCert: {
      'label': 'Teacher Certificate',
      'icon': Icons.school,
      'description': 'Teaching certification',
    },
    VerificationTypes.businessLicense: {
      'label': 'Business License',
      'icon': Icons.business,
      'description': 'Business registration documents',
    },
    VerificationTypes.employerCert: {
      'label': 'Employer Certificate',
      'icon': Icons.work,
      'description': 'Employer verification documents',
    },
    VerificationTypes.other: {
      'label': 'Other',
      'icon': Icons.description,
      'description': 'Other verification documents',
    },
  };

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      AppLogger.error('Error picking image: $e');
      setState(() {
        _errorMessage = 'Failed to pick image';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _selectedFile = File(photo.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      AppLogger.error('Error taking photo: $e');
      setState(() {
        _errorMessage = 'Failed to take photo';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'Please select a document to upload';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final verification = await _authService.submitVerification(
      type: _selectedType,
      filePath: _selectedFile!.path,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (verification != null && mounted) {
      AppLogger.success('✅ Verification submitted successfully');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to submit verification. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_roleName != null ? 'Apply for $_roleName' : 'Submit Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(
                  Icons.verified_user,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _roleName != null ? 'Apply for $_roleName Role' : 'Verification Request',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _roleName != null 
                    ? 'Upload required documents to become a verified $_roleName'
                    : 'Upload your verification documents',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Verification Type
                const Text(
                  'Verification Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                ..._verificationTypes.entries.map((entry) {
                  return RadioListTile<String>(
                    value: entry.key,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    title: Row(
                      children: [
                        Icon(
                          entry.value['icon'] as IconData,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(entry.value['label'] as String),
                      ],
                    ),
                    subtitle: Text(
                      entry.value['description'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Document Upload
                const Text(
                  'Upload Document',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                if (_selectedFile == null) ...[
                  // Upload buttons
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ] else ...[
                  // Show selected image
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.edit),
                    label: const Text('Change Document'),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Notes
                const Text(
                  'Additional Notes (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Add any additional information...',
                    border: OutlineInputBorder(),
                  ),
                ),
                
                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Verification'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
