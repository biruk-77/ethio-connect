import 'package:flutter/material.dart';
import '../../models/auth/user_model.dart';
import '../../services/auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    // Get stored user
    final user = await _authService.getStoredUser();
    
    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
      // Not logged in, go back
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to view profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/profile/edit',
                arguments: _currentUser,
              );
              if (result == true) {
                _loadUserProfile(); // Refresh after edit
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(theme),
              
              const SizedBox(height: 16),

              // Verification Status Card
              _buildVerificationCard(theme),

              const SizedBox(height: 8),

              // View Verification History Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile/verifications');
                  },
                  icon: const Icon(Icons.history, size: 20),
                  label: const Text('View Verification History'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // User Roles Card
              _buildRolesCard(theme),

              const SizedBox(height: 16),

              // Account Information
              _buildAccountInfoCard(theme),

              const SizedBox(height: 16),

              // Profile Information
              _buildProfileInfoCard(theme),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: _currentUser!.profile?.photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _currentUser!.profile!.photoUrl!,
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
              if (_currentUser!.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Username
          Text(
            _currentUser!.username.isNotEmpty
                ? _currentUser!.username
                : 'No username',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Email
          Text(
            _currentUser!.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),

          if (_currentUser!.phone != null && _currentUser!.phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _currentUser!.phone!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentUser!.status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Text(
      _currentUser!.username.isNotEmpty
          ? _currentUser!.username[0].toUpperCase()
          : _currentUser!.email[0].toUpperCase(),
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildVerificationCard(ThemeData theme) {
    final verificationStatus = _currentUser!.verificationStatus;
    final isVerified = _currentUser!.isVerified;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: isVerified ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Verification Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getVerificationColor(verificationStatus),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getVerificationLabel(verificationStatus),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!isVerified || verificationStatus == 'none')
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/verification/center');
                    },
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Get Verified'),
                  ),
              ],
            ),
            if (isVerified) ...[
              const SizedBox(height: 12),
              Text(
                _getVerificationDescription(verificationStatus),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRolesCard(ThemeData theme) {
    final roles = _currentUser!.roles;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.badge,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Professional Roles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (roles.isEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/landing');
                    },
                    child: const Text('Apply'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (roles.isEmpty)
              Text(
                'No professional roles yet. Apply for roles from the landing page!',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: roles.map((role) {
                  return Chip(
                    avatar: const Icon(Icons.star, size: 18),
                    label: Text(
                      role.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: theme.colorScheme.primaryContainer,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(theme, 'User ID', _currentUser!.id),
            _buildInfoRow(theme, 'Username', _currentUser!.username),
            _buildInfoRow(theme, 'Email', _currentUser!.email),
            if (_currentUser!.phone != null && _currentUser!.phone!.isNotEmpty)
              _buildInfoRow(theme, 'Phone', _currentUser!.phone!),
            if (_currentUser!.authProvider != null)
              _buildInfoRow(theme, 'Auth Provider', _currentUser!.authProvider!.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(ThemeData theme) {
    final profile = _currentUser!.profile;

    if (profile == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.person_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('No profile information'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/profile/edit',
                    arguments: _currentUser,
                  );
                  if (result == true) {
                    _loadUserProfile();
                  }
                },
                child: const Text('Complete Profile'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Profile Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (profile.fullName != null && profile.fullName!.isNotEmpty)
              _buildInfoRow(theme, 'Full Name', profile.fullName!),
            if (profile.bio != null && profile.bio!.isNotEmpty)
              _buildInfoRow(theme, 'Bio', profile.bio!),
            if (profile.profession != null && profile.profession!.isNotEmpty)
              _buildInfoRow(theme, 'Profession', profile.profession!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not set',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_currentUser!.status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getVerificationColor(String status) {
    switch (status) {
      case 'kyc':
        return Colors.blue;
      case 'professional':
        return Colors.purple;
      case 'full':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getVerificationLabel(String status) {
    switch (status) {
      case 'kyc':
        return 'KYC Verified';
      case 'professional':
        return 'Professional';
      case 'full':
        return 'Fully Verified';
      default:
        return 'Not Verified';
    }
  }

  String _getVerificationDescription(String status) {
    switch (status) {
      case 'kyc':
        return 'Your identity has been verified. You can create posts and apply for roles.';
      case 'professional':
        return 'Your professional credentials are verified. Full access to professional features.';
      case 'full':
        return 'Congratulations! You have complete verification with full access to all features.';
      default:
        return 'Complete verification to unlock all features.';
    }
  }
}
