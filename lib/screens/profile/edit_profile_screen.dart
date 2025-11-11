import 'package:flutter/material.dart';
import '../../models/auth/user_model.dart';
import '../../services/auth/auth_service.dart';
import '../../utils/app_logger.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;

  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late TextEditingController _professionController;
  late TextEditingController _phoneController;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _fullNameController = TextEditingController(text: widget.user?.profile?.fullName ?? '');
    _bioController = TextEditingController(text: widget.user?.profile?.bio ?? '');
    _professionController = TextEditingController(text: widget.user?.profile?.profession ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // TODO: Call API to update profile
      // For now, just simulate a save
      await Future.delayed(const Duration(seconds: 1));

      AppLogger.success('Profile updated successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      AppLogger.error('Failed to update profile: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save',
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Photo Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: widget.user?.profile?.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              widget.user!.profile!.photoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                            ),
                          )
                        : _buildDefaultAvatar(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () {
                          // TODO: Implement photo picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Photo upload coming soon!'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username *',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Your unique username',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username is required';
                }
                if (value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
              enabled: !_isSaving,
            ),

            const SizedBox(height: 16),

            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Your real name',
              ),
              enabled: !_isSaving,
            ),

            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'e.g., +251912345678',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.startsWith('+')) {
                    return 'Phone number must start with country code (e.g., +251)';
                  }
                }
                return null;
              },
              enabled: !_isSaving,
            ),

            const SizedBox(height: 16),

            // Profession
            TextFormField(
              controller: _professionController,
              decoration: InputDecoration(
                labelText: 'Profession',
                prefixIcon: const Icon(Icons.work),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'e.g., Software Engineer, Doctor, Teacher',
              ),
              enabled: !_isSaving,
            ),

            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Tell us about yourself',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
              enabled: !_isSaving,
            ),

            const SizedBox(height: 24),

            // Account Info (Read-only)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyField('Email', widget.user?.email ?? 'N/A'),
                    _buildReadOnlyField('User ID', widget.user?.id ?? 'N/A'),
                    _buildReadOnlyField('Status', widget.user?.status.toUpperCase() ?? 'N/A'),
                    _buildReadOnlyField(
                      'Verification',
                      widget.user?.isVerified == true ? 'Verified ✓' : 'Not Verified',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final initial = widget.user?.username.isNotEmpty == true
        ? widget.user!.username[0].toUpperCase()
        : widget.user?.email.isNotEmpty == true
            ? widget.user!.email[0].toUpperCase()
            : '?';

    return Text(
      initial,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
