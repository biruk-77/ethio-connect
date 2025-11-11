# 🔗 Flutter App ↔ Backend Integration Guide

## 📋 **How Flutter Interacts with Your Backend Flow**

Based on your `END_TO_END_SCENARIO.md`, here's how the Flutter app integrates with your User Service + Post Service architecture.

---

## 🎯 **Scenario: Dr. Sarah Using Flutter App**

### **Step 1: Registration & Login (Flutter → User Service)**

#### **Flutter Side:**
```dart
// lib/services/auth/auth_service.dart
class AuthService {
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _dio.post(
      'http://localhost:4000/api/auth/register',  // User Service
      data: {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      },
    );
    
    // Store JWT token
    await _secureStorage.write(
      key: 'accessToken',
      value: response.data['data']['token'],
    );
    
    return AuthResponse.fromJson(response.data);
  }
}
```

#### **Backend Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "username": "dr_sarah"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### **Step 2: Submit Verification (Flutter → User Service)**

#### **Flutter Screen:**
```dart
// lib/screens/verification/verification_submission_screen.dart
class VerificationSubmissionScreen extends StatelessWidget {
  final String verificationType; // "doctor_license"
  
  Future<void> _submitVerification() async {
    // 1. Upload document
    final documentUrl = await UploadService().uploadDocument(
      file: _selectedFile,
    );
    
    // 2. Submit verification to User Service
    final response = await _dio.post(
      'http://localhost:4000/api/verifications',
      data: {
        'type': verificationType,  // "doctor_license"
        'documentUrl': documentUrl,
        'notes': _notesController.text,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',  // JWT from login
        },
      ),
    );
    
    if (response.data['success']) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification submitted! Awaiting admin approval.'),
        ),
      );
    }
  }
}
```

#### **Backend Creates Verification:**
```json
{
  "verification": {
    "id": "ver-123",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "type": "doctor_license",
    "status": "pending"
  }
}
```

---

### **Step 3: Check Verification Status (Flutter → User Service)**

#### **Flutter Service:**
```dart
// lib/services/verification_service.dart
class VerificationService {
  Future<VerificationStatus> checkStatus(String type) async {
    final response = await _dio.get(
      'http://localhost:4000/api/verifications/is-verified',
      queryParameters: {'type': type},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    
    return VerificationStatus.fromJson(response.data['data']);
  }
}
```

#### **Backend Response:**
```json
{
  "success": true,
  "data": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "type": "doctor_license",
    "hasRole": true,
    "hasVerification": true,
    "isVerified": true,
    "roleName": "doctor",
    "verifiedAt": "2024-01-15T14:30:00.000Z"
  }
}
```

---

### **Step 4: Create Post (Flutter → Post Service)**

#### **Flutter Screen:**
```dart
// lib/screens/posts/create_post_screen.dart
class CreatePostScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            // Category Dropdown
            DropdownButton<String>(
              value: _selectedCategory,
              items: [
                DropdownMenuItem(value: 'medical', child: Text('Medical')),
                DropdownMenuItem(value: 'education', child: Text('Education')),
                DropdownMenuItem(value: 'jobs', child: Text('Jobs')),
                DropdownMenuItem(value: 'general', child: Text('General')),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value);
                _checkVerificationForCategory(value);
              },
            ),
            
            // Verification Status Badge
            if (_verificationRequired)
              Container(
                padding: EdgeInsets.all(8),
                color: _isVerified ? Colors.green : Colors.orange,
                child: Text(
                  _isVerified 
                    ? '✅ You are verified to post in this category'
                    : '⚠️ Verification required for this category',
                ),
              ),
            
            // Title, Content fields...
            
            // Submit Button
            ElevatedButton(
              onPressed: _isVerified ? _createPost : _promptVerification,
              child: Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _checkVerificationForCategory(String? category) async {
    if (category == null) return;
    
    // Map category to verification type (same as backend)
    final categoryVerificationMap = {
      'medical': 'doctor_license',
      'education': 'teacher_cert',
      'jobs': 'business_license',
      'general': 'kyc',
    };
    
    final verificationType = categoryVerificationMap[category];
    
    if (verificationType != null && verificationType != 'kyc') {
      setState(() => _verificationRequired = true);
      
      // Check if user is verified
      final status = await VerificationService().checkStatus(verificationType);
      
      setState(() {
        _isVerified = status.isVerified;
        _verificationStatus = status;
      });
    } else {
      setState(() {
        _verificationRequired = false;
        _isVerified = true;
      });
    }
  }
  
  Future<void> _createPost() async {
    try {
      final response = await _dio.post(
        'http://localhost:5000/api/posts',  // Post Service
        data: {
          'category': _selectedCategory,  // "medical"
          'title': _titleController.text,
          'content': _contentController.text,
          'tags': _selectedTags,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.data['success']) {
        // Post created successfully!
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post created successfully!')),
        );
      }
    } catch (e) {
      if (e.response?.statusCode == 403) {
        // Not verified for this category
        _showVerificationRequiredDialog();
      }
    }
  }
  
  void _showVerificationRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verification Required'),
        content: Text(
          'You need to verify your ${_selectedCategory} credentials to post in this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/verification/submit',
                arguments: {
                  'verificationType': _categoryVerificationMap[_selectedCategory],
                },
              );
            },
            child: Text('Get Verified'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔄 **Backend Flow Triggered by Flutter**

### **When Dr. Sarah Creates Medical Post:**

```
┌──────────────────────────┐
│   FLUTTER APP            │
│   CreatePostScreen       │
│                          │
│   Selected: "medical"    │
│   Title: "Diabetes Tips" │
└──────────────────────────┘
            │
            │ 1. POST /api/posts
            │    Headers: Authorization: Bearer <JWT>
            │    Body: { category: "medical", ... }
            ▼
┌──────────────────────────┐
│   POST SERVICE           │
│   (port 5000)            │
│                          │
│   checkVerification      │
│   middleware             │
└──────────────────────────┘
            │
            │ 2. GET /api/verifications/is-verified?type=doctor_license
            │    Headers: Authorization: Bearer <JWT>
            ▼
┌──────────────────────────┐
│   USER SERVICE           │
│   (port 4000)            │
│                          │
│   ✅ hasRole: true       │
│   ✅ hasVerification: true
│   → isVerified: true     │
└──────────────────────────┘
            │
            │ 3. Returns { isVerified: true }
            ▼
┌──────────────────────────┐
│   POST SERVICE           │
│                          │
│   ✅ ALLOW               │
│   Creates post in DB     │
└──────────────────────────┘
            │
            │ 4. Returns { success: true, post: {...} }
            ▼
┌──────────────────────────┐
│   FLUTTER APP            │
│                          │
│   ✅ Shows success       │
│   🏥 Post with badge     │
└──────────────────────────┘
```

---

## 📱 **Flutter UI States**

### **State 1: Not Verified User Selects Medical Category**

```dart
// Flutter shows warning
Container(
  color: Colors.orange.shade100,
  padding: EdgeInsets.all(16),
  child: Row(
    children: [
      Icon(Icons.warning, color: Colors.orange),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          '⚠️ You need doctor verification to post in Medical category',
        ),
      ),
      TextButton(
        onPressed: () => _navigateToVerification(),
        child: Text('Get Verified'),
      ),
    ],
  ),
)
```

### **State 2: Verified User Selects Medical Category**

```dart
// Flutter shows success
Container(
  color: Colors.green.shade100,
  padding: EdgeInsets.all(16),
  child: Row(
    children: [
      Icon(Icons.check_circle, color: Colors.green),
      SizedBox(width: 8),
      Text(
        '✅ You are verified to post in Medical category',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
)
```

### **State 3: Post Created with Badge**

```dart
// Post card shows verification badge
Card(
  child: Column(
    children: [
      ListTile(
        title: Text('5 Tips for Managing Diabetes'),
        subtitle: Row(
          children: [
            CircleAvatar(child: Text('DS')),
            SizedBox(width: 8),
            Text('Dr. Sarah Johnson'),
            SizedBox(width: 8),
            // Verification Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Verified Doctor',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
)
```

---

## 🎯 **Category → Verification Type Mapping**

### **Flutter Constants:**
```dart
// lib/constants/verification_constants.dart
class VerificationConstants {
  static const Map<String, String> categoryVerificationMap = {
    'medical': 'doctor_license',
    'education': 'teacher_cert',
    'jobs': 'business_license',
    'legal': 'lawyer_license',
    'general': 'kyc',
  };
  
  static String? getRequiredVerification(String category) {
    return categoryVerificationMap[category];
  }
  
  static bool requiresSpecialVerification(String category) {
    final type = categoryVerificationMap[category];
    return type != null && type != 'kyc';
  }
}
```

---

## 🔒 **Security Flow**

### **Flutter → Backend Security:**

1. **JWT Token in All Requests**
   ```dart
   _dio.options.headers['Authorization'] = 'Bearer $token';
   ```

2. **Token Refresh When Expired**
   ```dart
   _dio.interceptors.add(InterceptorsWrapper(
     onError: (error, handler) async {
       if (error.response?.statusCode == 401) {
         await _refreshToken();
         return handler.resolve(await _retry(error.requestOptions));
       }
       return handler.next(error);
     },
   ));
   ```

3. **Secure Storage for Tokens**
   ```dart
   await FlutterSecureStorage().write(
     key: 'accessToken',
     value: token,
   );
   ```

---

## 📊 **Error Handling**

### **Flutter Handles Backend Errors:**

```dart
try {
  await createPost();
} catch (e) {
  if (e is DioError) {
    switch (e.response?.statusCode) {
      case 401:
        // Not authenticated
        _navigateToLogin();
        break;
      case 403:
        // Not verified
        final message = e.response?.data['message'];
        final details = e.response?.data['details'];
        _showVerificationRequiredDialog(details);
        break;
      case 404:
        // Service not found
        _showErrorSnackBar('Service unavailable');
        break;
      default:
        _showErrorSnackBar('Something went wrong');
    }
  }
}
```

### **Backend 403 Response:**
```json
{
  "success": false,
  "message": "You are not verified to post in the medical category",
  "details": {
    "category": "medical",
    "requiredVerification": "doctor_license",
    "hasRole": false,
    "hasVerification": false
  }
}
```

### **Flutter Shows:**
```dart
AlertDialog(
  title: Text('Verification Required'),
  content: Text(
    'You need ${details['requiredVerification']} to post in ${details['category']} category.',
  ),
  actions: [
    ElevatedButton(
      onPressed: _startVerificationProcess,
      child: Text('Get Verified'),
    ),
  ],
)
```

---

## ✅ **Complete Integration Summary**

| Flutter Component | Backend Service | Action |
|-------------------|-----------------|--------|
| `AuthService.register()` | User Service (4000) | Create account |
| `AuthService.login()` | User Service (4000) | Get JWT token |
| `VerificationService.submit()` | User Service (4000) | Submit verification |
| `VerificationService.checkStatus()` | User Service (4000) | Check if verified |
| `PostService.createPost()` | Post Service (5000) | Create post (checks verification) |
| `PostService.getPosts()` | Post Service (5000) | Get posts |
| `SocketService.connect()` | Communication Service | Real-time chat |

---

## 🚀 **Testing the Flow**

### **1. Register Dr. Sarah (Flutter)**
```dart
await AuthService().register(
  username: 'dr_sarah',
  email: 'sarah@hospital.com',
  password: 'SecurePass123!',
  firstName: 'Sarah',
  lastName: 'Johnson',
);
// ✅ User created, JWT stored
```

### **2. Submit Verification (Flutter)**
```dart
await VerificationService().submit(
  type: 'doctor_license',
  documentUrl: uploadedUrl,
  notes: 'Board certified physician',
);
// ✅ Verification pending admin approval
```

### **3. Admin Approves (Backend Admin Panel)**
```
PUT /api/verifications/ver-123
{ "status": "approved" }
// ✅ User gets "doctor" role automatically
```

### **4. Check Status (Flutter)**
```dart
final status = await VerificationService().checkStatus('doctor_license');
print(status.isVerified); // true
// ✅ Flutter knows user is verified
```

### **5. Create Medical Post (Flutter)**
```dart
await PostService().createPost(
  category: 'medical',
  title: 'Diabetes Tips',
  content: '...',
);
// ✅ Post created with verification badge
```

---

## 🎉 **Result**

**Your backend architecture + Flutter integration = Complete verification system!**

- ✅ Flutter handles UI/UX
- ✅ User Service manages verification
- ✅ Post Service enforces rules
- ✅ JWT secures everything
- ✅ Clear error messages
- ✅ Seamless user experience

**Everything connects perfectly!** 🔗
