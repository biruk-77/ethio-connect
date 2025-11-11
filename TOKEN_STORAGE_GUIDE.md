# 🔐 Token Storage & Refresh Guide

## 📍 Where Tokens Are Stored

### Flutter Secure Storage (Encrypted)

```dart
// File: lib/services/auth/auth_service.dart

// Storage Keys (Line 16-18)
static const String _keyAccessToken = 'access_token';
static const String _keyRefreshToken = 'refresh_token';
static const String _keyUser = 'user_data';

// Storage Instance (Line 25-29)
_storage = const FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true, // ✅ Encrypted on Android
  ),
);
```

---

## 💾 Token Save/Get Methods

### 1. Save Tokens (Line 76-80)
```dart
Future<void> saveTokens(String accessToken, String refreshToken) async {
  await _storage.write(key: _keyAccessToken, value: accessToken);
  await _storage.write(key: _keyRefreshToken, value: refreshToken);
  AppLogger.success('🔐 Tokens saved securely');
}
```

### 2. Get Access Token (Line 82-84)
```dart
Future<String?> getAccessToken() async {
  return await _storage.read(key: _keyAccessToken);
}
```

### 3. Get Refresh Token (Line 86-88)
```dart
Future<String?> getRefreshToken() async {
  return await _storage.read(key: _keyRefreshToken);
}
```

### 4. Clear All Auth Data (Line 117-122)
```dart
Future<void> clearAuth() async {
  await _storage.delete(key: _keyAccessToken);
  await _storage.delete(key: _keyRefreshToken);
  await _storage.delete(key: _keyUser);
  AppLogger.info('🗑️ Auth data cleared');
}
```

---

## 🔄 Automatic Token Refresh Flow

### How It Works:

```
User makes API request
    ↓
Request sent with Access Token
    ↓
Backend returns 401 (Token Expired)
    ↓
Interceptor catches 401 error
    ↓
Calls refreshAccessToken()
    ↓
Sends refresh token to backend
    ↓
Backend validates refresh token
    ↓
Returns new access token (+ optional new refresh token)
    ↓
Save new tokens to Flutter Secure Storage
    ↓
Retry original request with new access token
    ↓
✅ Success!
```

---

## 🛠️ Improved Refresh Token Implementation

### Key Improvements:

#### 1. **Prevent Circular Refresh** (Line 270-274)
```dart
// Create a new Dio instance without interceptors
// This prevents the refresh-token request from triggering another refresh
final dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
));
```

#### 2. **Exclude Refresh Endpoint from Interceptor** (Line 37)
```dart
// Don't add access token to refresh-token requests
if (!options.path.contains('/refresh-token')) {
  final token = await getAccessToken();
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
}
```

#### 3. **Handle New Refresh Token** (Line 288-292)
```dart
// If backend returns new refresh token, save it
if (data.containsKey('refreshToken') && data['refreshToken'] != null) {
  final newRefreshToken = data['refreshToken'];
  await _storage.write(key: _keyRefreshToken, value: newRefreshToken);
  AppLogger.success('✅ Both tokens refreshed');
}
```

#### 4. **Auto-Clear on Expired Refresh Token** (Line 305-309)
```dart
// If refresh token is invalid/expired, clear auth
if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
  AppLogger.info('🔑 Refresh token expired or invalid, clearing auth');
  await clearAuth(); // Logs user out
}
```

---

## 🔍 Debugging Token Issues

### Check Logs:

```dart
// When access token expires:
🔄 Access token expired, attempting refresh...
🔄 Refreshing access token with refresh token
🔑 Refresh token: eyJhbGciOiJIUzI1NiI...

// On success:
✅ Access token refreshed
✨ Token refreshed, retrying request...
✅ 200 https://ethiouser.zewdbingo.com/api/...

// On failure:
❌ Refresh response unsuccessful
🚫 Token refresh failed: {success: false, message: "Invalid or expired refresh token"}
🔑 Refresh token expired or invalid, clearing auth
🗑️ Auth data cleared
```

---

## 📱 Storage Locations

### Android:
- **Path:** `/data/data/com.example.ethio_connect/shared_prefs/FlutterSecureStorage`
- **Encryption:** ✅ EncryptedSharedPreferences (AES-256)
- **Keys:**
  - `flutter.access_token`
  - `flutter.refresh_token`
  - `flutter.user_data`

### iOS:
- **Path:** Keychain Services
- **Encryption:** ✅ Native iOS Keychain (Hardware-backed)
- **Keys:** Same as Android

---

## 🧪 Testing Token Refresh

### Scenario 1: Access Token Expires
```
1. Make API call → 401
2. Auto-refresh triggered
3. New access token saved
4. Request retried
5. ✅ Success
```

### Scenario 2: Refresh Token Expires
```
1. Make API call → 401
2. Auto-refresh triggered
3. Refresh token invalid → 401
4. Clear all auth data
5. ❌ User logged out
6. Redirect to login
```

---

## 🔑 Token Lifecycle

```
Login/Register
    ↓
Save tokens to Secure Storage
    ↓
Use access token for requests (15-60 min lifespan)
    ↓
Access token expires
    ↓
Auto-refresh with refresh token (7-30 day lifespan)
    ↓
Save new access token
    ↓
Continue using app
    ↓
(Eventually) Refresh token expires
    ↓
Auto-logout → Clear storage
    ↓
User must login again
```

---

## 🚨 Error Handling

### When Refresh Token is Invalid (401 in Postman):

**Reason:** Refresh token has expired or been invalidated

**Solution:**
1. App automatically calls `clearAuth()`
2. Deletes all tokens from Secure Storage
3. User is logged out
4. Redirected to login screen
5. User must login again to get new tokens

**No manual intervention needed!** ✅

---

## 🎯 Summary

| Feature | Status |
|---------|--------|
| **Encrypted Storage** | ✅ AES-256 / Keychain |
| **Auto Token Refresh** | ✅ On 401 errors |
| **Circular Refresh Prevention** | ✅ Separate Dio instance |
| **Refresh Token Rotation** | ✅ Saves new refresh token |
| **Auto Logout on Expired** | ✅ Clears auth on 401/403 |
| **Request Retry** | ✅ After successful refresh |
| **Logging** | ✅ Detailed debug logs |

---

**Your tokens are securely stored and automatically refreshed! 🔐**
