# 🎯 Flutter Verification Flow Integration

## Complete End-to-End Example: Dr. Sarah Posts Medical Advice

This guide shows how to implement category-based verification in your Flutter app.

---

## 📋 Overview

The verification flow ensures only qualified professionals can post in restricted categories:
- **Medical** → Requires `doctor_license` verification
- **Education** → Requires `teacher_cert` verification  
- **Jobs** → Requires `business_license` verification
- **General** → Requires `kyc` verification

---

## 🔧 Implementation

### Step 1: Check Category Access Before Posting

Before showing the "Create Post" screen, check if the user has access:

```dart
import 'package:ethio_connect/services/post_service.dart';
import 'package:ethio_connect/utils/category_verification_map.dart';

class CreatePostScreen extends StatefulWidget {
  final String category; // e.g., "medical", "education", "jobs"
  
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final PostService _postService = PostService();
  bool _isVerified = false;
  bool _isLoading = true;
  String? _verificationMessage;

  @override
  void initState() {
    super.initState();
    _checkCategoryAccess();
  }

  Future<void> _checkCategoryAccess() async {
    setState(() => _isLoading = true);

    try {
      // Check if user can post in this category
      final result = await _postService.checkCategoryAccess(widget.category);

      if (result != null) {
        setState(() {
          _isVerified = result.isVerified;
          _verificationMessage = result.isVerified 
              ? 'You are verified as ${result.roleName}'
              : result.reason ?? 'Verification required';
          _isLoading = false;
        });

        // Show warning if not verified
        if (!result.isVerified) {
          _showVerificationRequiredDialog(result);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _verificationMessage = 'Failed to check verification status';
      });
    }
  }

  void _showVerificationRequiredDialog(VerificationCheckResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Verification Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(CategoryVerificationMap.getVerificationMessage(widget.category)),
            SizedBox(height: 16),
            Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('✗ Has ${result.roleName} role: ${result.hasRole}'),
            Text('✗ Has verification: ${result.hasVerification}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to verification screen
              Navigator.pushNamed(context, '/verify');
            },
            child: Text('Get Verified'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Create Post')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post in ${widget.category}'),
        actions: [
          if (_isVerified)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Chip(
                avatar: Icon(Icons.verified, color: Colors.white),
                label: Text('Verified', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
      body: _isVerified ? _buildPostForm() : _buildVerificationRequired(),
    );
  }

  Widget _buildPostForm() {
    // Your post creation form here
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Add your form fields here
          TextField(
            decoration: InputDecoration(labelText: 'Title'),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'Description'),
            maxLines: 5,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createPost,
            child: Text('Create Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRequired() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'Verification Required',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Text(
              _verificationMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/verify'),
              icon: Icon(Icons.verified_user),
              label: Text('Get Verified'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final post = await _postService.createPost(
        categoryId: 'category-uuid-here',
        postType: 'offer',
        title: 'Your title',
        description: 'Your description',
      );

      Navigator.pop(context); // Close loading dialog

      if (post != null) {
        // Success!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Post created successfully!')),
        );
        Navigator.pop(context); // Go back
      }
    } on DioException catch (e) {
      Navigator.pop(context); // Close loading dialog

      // Handle verification error from backend
      if (e.response?.statusCode == 403) {
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Verification required';
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('❌ Cannot Post'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/verify');
                },
                child: Text('Get Verified'),
              ),
            ],
          ),
        );
      } else {
        // Other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: ${e.message}')),
        );
      }
    }
  }
}
```

---

### Step 2: Submit Verification

```dart
import 'package:ethio_connect/services/verification_service.dart';
import 'package:ethio_connect/models/verification_model.dart';

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final VerificationService _verificationService = VerificationService();
  VerificationType _selectedType = VerificationType.kyc;
  String? _documentPath;
  TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Get Verified')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Verification Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            
            // Verification type selector
            _buildVerificationTypeCard(
              VerificationType.doctorLicense,
              '🏥 Medical Professional',
              'For doctors, nurses, and healthcare providers',
            ),
            _buildVerificationTypeCard(
              VerificationType.teacherCert,
              '🎓 Educator',
              'For teachers, tutors, and education professionals',
            ),
            _buildVerificationTypeCard(
              VerificationType.businessLicense,
              '💼 Business',
              'For businesses and employers',
            ),
            _buildVerificationTypeCard(
              VerificationType.kyc,
              '✅ Basic KYC',
              'For general users',
            ),
            
            SizedBox(height: 24),
            
            // Document upload
            ElevatedButton.icon(
              onPressed: _pickDocument,
              icon: Icon(Icons.upload_file),
              label: Text(_documentPath == null 
                  ? 'Upload Document' 
                  : 'Document Selected'),
            ),
            
            if (_documentPath != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('📄 ${_documentPath!.split('/').last}'),
              ),
            
            SizedBox(height: 16),
            
            // Notes
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'E.g., Board certified, 10 years experience',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _documentPath != null ? _submitVerification : null,
                child: Text('Submit for Verification'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationTypeCard(
    VerificationType type,
    String title,
    String description,
  ) {
    final isSelected = _selectedType == type;
    
    return Card(
      color: isSelected ? Colors.blue.shade50 : null,
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: isSelected ? Icon(Icons.check_circle, color: Colors.blue) : null,
        onTap: () => setState(() => _selectedType = type),
      ),
    );
  }

  Future<void> _pickDocument() async {
    // Use file_picker package
    // final result = await FilePicker.platform.pickFiles();
    // if (result != null) {
    //   setState(() => _documentPath = result.files.single.path);
    // }
    
    // For demo purposes:
    setState(() => _documentPath = '/path/to/document.pdf');
  }

  Future<void> _submitVerification() async {
    if (_documentPath == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final verification = await _verificationService.submitVerification(
        type: _selectedType,
        documentPath: _documentPath!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      Navigator.pop(context); // Close loading dialog

      if (verification != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('🎉 Success!'),
            content: Text(
              'Your verification has been submitted and is pending review. '
              'You will be notified once it\'s approved.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit verification: $e')),
      );
    }
  }
}
```

---

### Step 3: Show Verification Badge on Posts

```dart
import 'package:ethio_connect/utils/category_verification_map.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with verification badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (post.verifiedWith != null)
                  _buildVerificationBadge(post.verifiedWith!),
              ],
            ),
            
            SizedBox(height: 8),
            
            Text(post.description),
            
            SizedBox(height: 12),
            
            // Post details
            Row(
              children: [
                Icon(Icons.category, size: 16),
                SizedBox(width: 4),
                Text(post.category),
                Spacer(),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(String verificationType) {
    final type = VerificationType.fromString(verificationType);
    final badgeText = CategoryVerificationMap.getVerificationBadge(type);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 12,
          color: Colors.green.shade900,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format as needed
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

---

## 🔄 Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    USER OPENS CREATE POST                    │
│                    (Medical Category)                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              PostService.checkCategoryAccess()               │
│  1. Maps "medical" → "doctor_license"                        │
│  2. Calls VerificationService.isVerified()                   │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│           User Service API: GET /is-verified                 │
│  Returns: { isVerified: true/false, hasRole, ... }          │
└─────────────────────────────────────────────────────────────┘
                           │
                ┌──────────┴──────────┐
                ▼                     ▼
      ✅ VERIFIED              ❌ NOT VERIFIED
                │                     │
                ▼                     ▼
   Show Post Form        Show "Get Verified" Message
                │                     │
                ▼                     ▼
   User Creates Post      User Goes to Verification
                │
                ▼
┌─────────────────────────────────────────────────────────────┐
│           PostService.createPost()                           │
│  Backend validates again and creates post                    │
└─────────────────────────────────────────────────────────────┘
                           │
                ┌──────────┴──────────┐
                ▼                     ▼
        ✅ SUCCESS            ❌ 403 FORBIDDEN
                │                     │
                ▼                     ▼
   Post Published         Show Verification Error
   Show Success              Redirect to Verify
```

---

## 🎯 Key Features

### ✅ Pre-Flight Check
```dart
// Check before showing form
final canPost = await postService.checkCategoryAccess('medical');
if (!canPost?.isVerified) {
  // Show warning or redirect
}
```

### ✅ Backend Validation
```dart
// Backend always validates, even if frontend check passes
// Returns 403 if user is not verified
```

### ✅ User-Friendly Messages
```dart
// Get helpful message for any category
final message = CategoryVerificationMap.getVerificationMessage('medical');
// "You need to be a verified medical professional..."
```

### ✅ Verification Badges
```dart
// Show verification badge on posts
final badge = CategoryVerificationMap.getVerificationBadge(
  VerificationType.doctorLicense
);
// "🏥 Verified Doctor"
```

---

## 📝 Summary

### What You Get:
1. ✅ Category-based access control
2. ✅ Pre-flight verification checks for better UX
3. ✅ Backend validation for security
4. ✅ Clear error messages for users
5. ✅ Verification badge display
6. ✅ Complete verification submission flow

### How It Works:
1. User tries to post in a category
2. Frontend checks if they're verified (optional, for UX)
3. Backend validates verification (required, for security)
4. If not verified, user is redirected to verification
5. Once verified, user can post in restricted categories
6. Posts display verification badges

### Security:
- ✅ JWT authentication on all requests
- ✅ Backend always validates verification
- ✅ Frontend check is only for UX, not security
- ✅ Role + verification both required
- ✅ Admin approval needed for verifications

---

## 🚀 Next Steps

1. **Test the flow**: Try posting in different categories
2. **Submit verifications**: Test the verification submission
3. **Admin panel**: Build admin screens to approve verifications
4. **Notifications**: Add push notifications when verification is approved
5. **Analytics**: Track verification conversion rates

---

🎉 **Your Flutter app now has complete end-to-end verification!**
