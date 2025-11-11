# 🔐 Backend Auth System - Frontend Alignment

## 📋 **Backend JWT Token Structure**

When the backend sends a JWT token, it contains **EVERYTHING**:

```javascript
// Decoded JWT Token Payload
{
  id: "f06cde8a-713c-429b-ad6e-9ef30278b756",
  username: "johndoe",
  email: "john@example.com",
  phone: "+251912345678",
  authProvider: "local", // or "google", "facebook"
  
  // 🎯 ROLES IS AN ARRAY!
  roles: ["doctor", "employee"], // Array of role names
  
  // 📋 PROFILE WITH VERIFICATION STATUS
  profile: {
    verificationStatus: "kyc", // 'none' | 'kyc' | 'professional' | 'full'
    fullName: "John Doe",
    bio: "Software Engineer...",
    profession: "Software Developer",
    // ... other profile fields
  },
  
  // ✅ VERIFICATION BOOLEAN
  isVerified: true, // Must be true for posting
  
  status: "active" // 'active' | 'inactive' | 'suspended'
}
```

---

## 🔒 **Backend Middleware Authentication**

### **1. `verifyUserToken` - Required Auth**
- Verifies JWT token
- Sets `req.user` with all decoded data
- Returns 401 if no token or invalid token

### **2. `optionalAuth` - Optional Auth**
- Doesn't fail if no token
- Sets `req.user = null` if not authenticated
- Allows both authenticated and guest access

### **3. `authorize(roles)` - Role Check**
```javascript
authorize(['doctor', 'admin']) // User must have one of these roles
```

### **4. `requireVerification(level)` - Verification Level**
```javascript
requireVerification('kyc') // Requires at least 'kyc' level
// Levels: 'none' < 'kyc' < 'professional' < 'full'
```

### **5. `requireVerifiedUser` - Post Creation Guard**
**Requirements to create posts:**
- ✅ `isVerified: true`
- ✅ `verificationStatus` in `['kyc', 'professional', 'full']`
- ❌ Admins exempt from verification

---

## 🎯 **Frontend User Model (Updated)**

```dart
class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? authProvider;
  final List<String> roles;        // Array of role names!
  final UserProfile? profile;       // Contains verificationStatus
  final bool isVerified;            // Boolean for quick check
  final String status;              // active/inactive
  
  // 🔥 Helper Methods
  
  // Check if user has a specific role
  bool hasRole(String roleName) {
    return roles.contains(roleName.toLowerCase());
  }
  
  // Get verification status from profile
  String get verificationStatus {
    return profile?.verificationStatus ?? 'none';
  }
  
  // Check if can create posts (backend rule)
  bool get canCreatePosts {
    if (!isVerified) return false;
    final allowedStatuses = ['kyc', 'professional', 'full'];
    return allowedStatuses.contains(verificationStatus);
  }
}

class UserProfile {
  final String? verificationStatus; // 'none', 'kyc', 'professional', 'full'
  final String? fullName;
  final String? bio;
  final String? profession;
  final String? photoUrl;
  // ... other fields
}
```

---

## 🔄 **Authentication Flow**

### **1. Login/Register**
```dart
POST /api/auth/login
{
  "email": "john@example.com",
  "password": "password123"
}

Response:
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGc...",  // JWT with all user data
    "refreshToken": "eyJhbGc...",
    "user": {
      "id": "...",
      "username": "johndoe",
      "email": "john@example.com",
      // ... full user object
    }
  }
}
```

### **2. Store Tokens Securely**
```dart
await _storage.write(key: 'accessToken', value: response.accessToken);
await _storage.write(key: 'refreshToken', value: response.refreshToken);
await _storage.write(key: 'user', value: jsonEncode(response.user));
```

### **3. Decode Token on Frontend (Optional)**
You can decode the JWT to get user data WITHOUT calling API:
```dart
import 'package:jwt_decoder/jwt_decoder.dart';

Map<String, dynamic> decoded = JwtDecoder.decode(accessToken);
User user = User.fromJson(decoded);
```

### **4. Make Authenticated Requests**
```dart
final token = await _storage.read(key: 'accessToken');

dio.options.headers['Authorization'] = 'Bearer $token';

// Backend middleware extracts user from token automatically!
```

---

## 🎨 **UI/UX Based on Verification**

### **Verification Badge Colors**

```dart
Widget _buildVerificationBadge() {
  if (!user.isVerified) {
    return Badge(
      color: Colors.grey,
      text: 'Not Verified',
      icon: Icons.cancel,
    );
  }
  
  switch (user.verificationStatus) {
    case 'none':
      return Badge(color: Colors.grey, text: 'No Verification');
    case 'kyc':
      return Badge(color: Colors.blue, text: 'KYC Verified');
    case 'professional':
      return Badge(color: Colors.purple, text: 'Professional');
    case 'full':
      return Badge(color: Colors.green, text: 'Fully Verified');
    default:
      return Badge(color: Colors.grey, text: 'Unknown');
  }
}
```

### **Post Creation Check**

```dart
FloatingActionButton(
  onPressed: () {
    if (!currentUser.canCreatePosts) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Verification Required'),
          content: Text(
            'You need to complete ${currentUser.isVerified ? 'KYC verification' : 'account verification'} to create posts.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/verification/submit'),
              child: Text('Verify Now'),
            ),
          ],
        ),
      );
      return;
    }
    
    // Create post
    Navigator.pushNamed(context, '/create-post');
  },
  child: Icon(Icons.add),
)
```

### **Role-Based UI**

```dart
if (user.hasRole('doctor')) {
  // Show doctor-specific features
  ListTile(
    title: Text('My Patients'),
    leading: Icon(Icons.people),
  ),
}

if (user.hasRole('admin')) {
  // Show admin panel
  ListTile(
    title: Text('Admin Dashboard'),
    leading: Icon(Icons.admin_panel_settings),
  ),
}
```

---

## 📱 **Verification Status Meanings**

| Status | What It Means | Can Create Posts? | Description |
|--------|--------------|------------------|-------------|
| `none` | No verification submitted | ❌ No | User hasn't submitted any verification |
| `kyc` | Basic identity verified | ✅ Yes | ID/Passport verified |
| `professional` | Professional credentials verified | ✅ Yes | Doctor license, teaching cert, etc. |
| `full` | Fully verified with all checks | ✅ Yes | All verifications completed |

**Note:** `isVerified: false` overrides everything - even if status is `kyc`, they can't post.

---

## 🔄 **Verification Status Flow**

```
1. User registers
   isVerified: false
   verificationStatus: 'none'
   ❌ Cannot create posts

2. User submits KYC documents
   isVerified: false (pending approval)
   verificationStatus: 'none'
   ❌ Cannot create posts

3. Admin approves KYC
   isVerified: true ✅
   verificationStatus: 'kyc'
   ✅ CAN create posts!

4. User applies for doctor role
   Submits doctor license
   
5. Admin approves doctor verification
   isVerified: true ✅
   verificationStatus: 'professional'
   roles: ['doctor']
   ✅ CAN create posts + doctor features!
```

---

## 🎯 **Key Takeaways**

1. **Token = Everything**: JWT contains all user data, no need to call `/api/auth/me` constantly

2. **Two Checks for Posting**:
   - `isVerified` must be `true`
   - `verificationStatus` must be in `['kyc', 'professional', 'full']`

3. **Roles is Array**: `roles: ["doctor", "teacher"]` - user can have multiple roles

4. **Profile Has Verification**: `profile.verificationStatus` is the key field

5. **Frontend Helpers**: Use `hasRole()`, `canCreatePosts`, `verificationStatus` getters

---

## 🚀 **Implementation Checklist**

- [x] Update User model with roles array
- [x] Add UserProfile class with verificationStatus
- [x] Add helper methods: `hasRole()`, `canCreatePosts`, `verificationStatus`
- [ ] Update AuthService to decode token properly
- [ ] Add token refresh logic
- [ ] Update UI to show verification badges
- [ ] Add post creation guards
- [ ] Show role-based features
- [ ] Test all verification flows

---

## 💡 **Pro Tips**

1. **Cache User Data**: Store decoded token data to avoid repeated decoding
2. **Auto-Refresh**: Use interceptor to refresh token on 401 errors
3. **Role Display**: Show user's roles in profile/settings
4. **Verification CTA**: Prominently display "Get Verified" if not verified
5. **Guard Features**: Disable posting UI if `!canCreatePosts`

---

**Your User model is now aligned with the backend! 🎉**
