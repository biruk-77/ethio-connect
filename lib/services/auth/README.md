# Authentication System

## 🔐 Complete Authentication & Verification System

This authentication system provides a comprehensive solution for user authentication, OTP login, role management, and verification workflows with secure token storage.

## 📁 Structure

```
lib/
├── config/
│   └── auth_api_config.dart          # API endpoints configuration
├── models/
│   └── auth/
│       ├── user_model.dart            # User data model
│       ├── auth_response.dart         # Authentication responses
│       ├── verification_model.dart    # Verification data
│       └── role_model.dart            # Role and UserRole models
├── services/
│   └── auth/
│       ├── auth_service.dart          # Main authentication service
│       └── auth_wrapper.dart          # Authentication state wrapper
└── screens/
    ├── auth/
    │   ├── login_screen.dart          # Email/password login
    │   ├── register_screen.dart       # User registration
    │   └── otp/
    │       └── otp_login_screen.dart  # Phone OTP authentication
    └── verification/
        ├── verification_center_screen.dart   # Central verification hub
        └── submit_verification_screen.dart   # Submit documents
```

## ✨ Features

### 1. **Secure Storage**
- Uses Flutter Secure Storage with encrypted shared preferences
- Stores access tokens, refresh tokens, and user data securely
- Automatic token refresh on 401 errors

### 2. **Multiple Authentication Methods**
- **Email/Password**: Traditional authentication
- **OTP**: Phone number verification with SMS codes
- **Auto-login**: Persistent sessions with secure token storage

### 3. **Verification System**
- Centralized verification management
- Multiple verification types:
  - KYC (ID/Passport)
  - Doctor License
  - Teacher Certificate
  - Business License
  - Employer Certificate
  - Other documents
- Real-time status tracking (Pending, Approved, Rejected)

### 4. **Role Management**
- Multi-role support per user
- Automatic role assignment on verification approval
- Role-based access control ready

### 5. **Auth Flow Management**
- Automatic routing based on auth state:
  - Not authenticated → Login/Register
  - Needs verification → Verification screens
  - Authenticated & verified → Main app
  
## 🚀 Usage

### Basic Authentication

```dart
import 'package:your_app/services/auth/auth_service.dart';

final authService = AuthService();

// Login with email/password
final response = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

// Register new user
final response = await authService.register(
  username: 'johndoe',
  email: 'john@example.com',
  password: 'password123',
  phone: '+251912345678',
);

// Check if authenticated
final isAuth = await authService.isAuthenticated();

// Get current user
final user = await authService.getCurrentUser();

// Logout
await authService.logout();
```

### OTP Authentication

```dart
// Request OTP
final response = await authService.requestOTP('+251912345678');

// Verify OTP
final authResponse = await authService.verifyOTP(
  phone: '+251912345678',
  otp: '123456',
);
```

### Verification

```dart
// Get my verifications
final verifications = await authService.getMyVerifications();

// Submit new verification
final verification = await authService.submitVerification(
  type: 'doctor_license',
  filePath: '/path/to/document.jpg',
  notes: 'Medical license verification',
);

// Check if needs verification
final needsVerif = await authService.needsVerification();
```

### Roles

```dart
// Get my roles
final myRoles = await authService.getMyRoles();

// Get all available roles
final allRoles = await authService.getAllRoles();
```

## 🔑 API Endpoints

All endpoints are configured in `auth_api_config.dart`:

- **POST** `/api/auth/register` - Register new user
- **POST** `/api/auth/login` - Login with email/password
- **GET** `/api/auth/me` - Get current user
- **POST** `/api/auth/refresh-token` - Refresh access token
- **POST** `/api/auth/otp/request` - Request OTP code
- **POST** `/api/auth/otp/verify` - Verify OTP code
- **GET** `/api/profiles` - Get user profile
- **GET** `/api/roles` - Get all roles
- **GET** `/api/user-roles/user/:userId` - Get user roles
- **GET** `/api/verifications` - Get my verifications
- **POST** `/api/verifications` - Submit verification

## 🛡️ Security Features

1. **Encrypted Storage**: All sensitive data encrypted at rest
2. **Automatic Token Refresh**: Seamless token renewal
3. **Secure Interceptors**: Auto-inject auth headers
4. **Error Handling**: Comprehensive error management
5. **Logging**: Detailed logging for debugging

## 📱 Screens

### Login Screen (`/auth/login`)
- Email/password authentication
- Toggle password visibility
- Link to OTP login and registration
- Error handling with visual feedback

### Register Screen (`/auth/register`)
- Username, email, phone, password fields
- Password confirmation
- Input validation
- Error feedback

### OTP Login Screen (`/auth/otp`)
- Phone number input (+251 format)
- OTP code entry with countdown
- Resend OTP functionality
- Switch to email login

### Verification Center (`/verification/center`)
- View all verifications
- See assigned roles
- Submit new verification
- Real-time status updates
- Logout functionality

### Submit Verification (`/verification/submit`)
- Select verification type
- Upload document (camera or gallery)
- Add optional notes
- Image preview
- Submission with progress

## 🔄 Authentication Flow

```
App Start
    ↓
AuthWrapper checks auth status
    ↓
├── Not Authenticated → Login/Register/OTP Screen
│   └── After login → Check verification
│       ├── Needs Verification → Verification Screen
│       └── Verified → Main App (Landing Screen)
│
└── Authenticated
    ├── Needs Verification → Verification Screen
    └── Verified → Main App (Landing Screen)
```

## 🎨 Customization

### Change Base URL

Edit `lib/config/auth_api_config.dart`:

```dart
static const String baseUrl = 'https://your-api.com';
```

### Add New Verification Type

1. Add to `VerificationTypes` in `verification_model.dart`:
```dart
static const String newType = 'new_type';
```

2. Add to verification types map in `submit_verification_screen.dart`:
```dart
VerificationTypes.newType: {
  'label': 'New Type',
  'icon': Icons.your_icon,
  'description': 'Your description',
},
```

## 📊 State Management

The auth system uses:
- **Flutter Secure Storage** for persistence
- **Dio** for HTTP requests with interceptors
- **Stateful Widgets** for screen state
- **Navigator routes** for screen transitions

## 🐛 Debugging

Enable detailed logging with `AppLogger`:

```dart
AppLogger.info('Your info message');
AppLogger.success('Success message');
AppLogger.error('Error message');
AppLogger.section('Section divider');
```

## 📝 Notes

- Tokens are automatically refreshed on 401 errors
- OTP codes expire after 60 seconds (backend controlled)
- Image quality is set to 80% for uploads
- All sensitive data is encrypted at rest
- Verification status updates require admin approval

## 🚧 Future Enhancements

- [ ] Biometric authentication
- [ ] Social login (Google, Facebook)
- [ ] Email verification
- [ ] Password reset flow
- [ ] Two-factor authentication
- [ ] Session management
- [ ] Remember me functionality

## 📄 License

Part of EthioConnect application.
