# 🧪 EthioConnect Verification System - Testing Guide

## Quick Test Scenarios

### Test 1: Happy Path - Verified Doctor Posts Medical Advice ✅

**Goal**: Verify complete flow from registration to posting

1. **Register as Dr. Sarah**
   ```dart
   // In your Flutter app or use Postman
   POST https://ethiouser.zewdbingo.com/api/auth/register
   {
     "username": "dr_sarah",
     "email": "sarah@hospital.com",
     "password": "SecurePass123!",
     "firstName": "Sarah",
     "lastName": "Johnson"
   }
   ```
   **Expected**: Get JWT token, save it

2. **Submit Doctor License Verification**
   - Navigate to `/verification/submit` in app
   - Select "Doctor License"
   - Upload medical license document
   - Add notes: "Board certified physician, 10 years experience"
   - Submit
   
   **Expected**: Verification created with status "pending"

3. **Admin Approves Verification** (Use Postman/Backend)
   ```http
   PUT https://ethiouser.zewdbingo.com/api/verifications/{verificationId}
   Authorization: Bearer ADMIN_TOKEN
   {
     "status": "approved",
     "notes": "Verified with medical board"
   }
   ```
   **Expected**: 
   - Verification status → "approved"
   - User gets "doctor" role automatically
   - verifiedAt timestamp set

4. **Check Verification Status**
   ```http
   GET https://ethiouser.zewdbingo.com/api/verifications/is-verified?type=doctor_license
   Authorization: Bearer SARAH_TOKEN
   ```
   **Expected Response**:
   ```json
   {
     "success": true,
     "data": {
       "isVerified": true,
       "hasRole": true,
       "hasVerification": true,
       "roleName": "doctor",
       "verifiedAt": "2024-01-15T14:30:00.000Z"
     }
   }
   ```

5. **Create Medical Post**
   - Navigate to `/posts/create` with category "medical"
   - App auto-checks verification → Shows ✅ Verified Doctor badge
   - Fill in post details:
     - Title: "5 Tips for Managing Diabetes"
     - Description: "As a physician, I recommend..."
     - Tags: diabetes, health, medical-advice
   - Submit
   
   **Expected**: 
   - Post created successfully
   - Shows success message
   - Returns to previous screen

6. **Verify Post Was Created**
   ```http
   GET https://ethiopost.unitybingo.com/api/posts/my
   Authorization: Bearer SARAH_TOKEN
   ```
   **Expected**: See newly created post with verification info

---

### Test 2: Unhappy Path - Unverified User Tries Medical Post ❌

**Goal**: Verify system blocks unverified users

1. **Register as John (Regular User)**
   ```http
   POST https://ethiouser.zewdbingo.com/api/auth/register
   {
     "username": "john_doe",
     "email": "john@example.com",
     "password": "Password123!",
     "firstName": "John",
     "lastName": "Doe"
   }
   ```

2. **Submit KYC Only** (Not Doctor License)
   - Navigate to `/verification/submit`
   - Select "KYC Verification"
   - Upload ID document
   - Submit
   
3. **Admin Approves KYC**
   ```http
   PUT https://ethiouser.zewdbingo.com/api/verifications/{verificationId}
   {
     "status": "approved"
   }
   ```
   **Expected**: User gets basic "user" role

4. **Try to Create Medical Post**
   - Navigate to `/posts/create` with category "medical"
   - App checks verification
   
   **Expected Behavior**:
   - ❌ Shows "Verification Required" dialog
   - Displays: "You need to be a verified medical professional..."
   - Shows status: Has Role: ❌, Has Verification: ❌
   - Offers "Get Verified" button

5. **If User Bypasses UI and Calls API Directly**
   ```http
   POST https://ethiopost.unitybingo.com/api/posts
   Authorization: Bearer JOHN_TOKEN
   {
     "category": "medical",
     "title": "My Health Tips",
     "content": "I think you should..."
   }
   ```
   
   **Expected Response**: 403 Forbidden
   ```json
   {
     "success": false,
     "message": "You are not verified to post in the medical category",
     "details": {
       "category": "medical",
       "requiredVerification": "doctor_license",
       "hasRole": false,
       "hasVerification": false,
       "reason": "User does not have required role 'doctor'...",
       "action": "Please verify your medical credentials..."
     }
   }
   ```

---

### Test 3: Verification Status Check Flow

**Test Frontend Verification Check**:

```dart
// In your Flutter app
final postService = PostService();

// Check if user can post in medical category
final result = await postService.checkCategoryAccess('medical');

if (result != null) {
  print('Is Verified: ${result.isVerified}');
  print('Has Role: ${result.hasRole}');
  print('Has Verification: ${result.hasVerification}');
  print('Role Name: ${result.roleName}');
  print('Verified At: ${result.verifiedAt}');
  print('Reason: ${result.reason}');
}
```

**Expected Outputs**:

**Verified Doctor**:
```
Is Verified: true
Has Role: true
Has Verification: true
Role Name: doctor
Verified At: 2024-01-15 14:30:00.000Z
Reason: null
```

**Unverified User**:
```
Is Verified: false
Has Role: false
Has Verification: false
Role Name: doctor
Verified At: null
Reason: User does not have required role 'doctor' and verification is not approved
```

---

### Test 4: Different Category Requirements

**Medical Category** (Requires doctor_license):
```dart
Navigator.pushNamed(
  context,
  '/posts/create',
  arguments: {
    'categoryName': 'medical',
    'categoryId': 'medical-category-uuid',
  },
);
```
**Expected**: Only verified doctors can post

**Education Category** (Requires teacher_cert):
```dart
Navigator.pushNamed(
  context,
  '/posts/create',
  arguments: {
    'categoryName': 'education',
    'categoryId': 'education-category-uuid',
  },
);
```
**Expected**: Only verified teachers can post

**Jobs Category** (Requires business_license):
```dart
Navigator.pushNamed(
  context,
  '/posts/create',
  arguments: {
    'categoryName': 'jobs',
    'categoryId': 'jobs-category-uuid',
  },
);
```
**Expected**: Only verified businesses can post

**General Category** (Requires KYC):
```dart
Navigator.pushNamed(
  context,
  '/posts/create',
  arguments: {
    'categoryName': 'general',
    'categoryId': 'general-category-uuid',
  },
);
```
**Expected**: Anyone with KYC can post

---

## Manual UI Testing

### Screen 1: Verification Center (`/verification/center`)
- [ ] Shows list of my verifications
- [ ] Shows current status (pending/approved/rejected)
- [ ] Shows submitted date
- [ ] Shows document URL (if any)
- [ ] Shows "Submit New Verification" button
- [ ] Displays my current roles

### Screen 2: Submit Verification (`/verification/submit`)
- [ ] Shows verification type selector
- [ ] Each type has icon and description
- [ ] Can upload document (image/PDF)
- [ ] Shows selected file name
- [ ] Can add optional notes
- [ ] Submit button enabled only when file selected
- [ ] Shows loading indicator during submission
- [ ] Shows success message after submission
- [ ] Navigates back after success

### Screen 3: Create Post (`/posts/create`)

**When Verified**:
- [ ] Shows verification badge in app bar
- [ ] Form is accessible
- [ ] Can select category (or pre-selected)
- [ ] Can enter title and description
- [ ] Can enter price (optional)
- [ ] Can select region and city
- [ ] Can enter tags
- [ ] Submit button creates post
- [ ] Shows success message
- [ ] Navigates back after creation

**When NOT Verified**:
- [ ] Shows lock icon
- [ ] Shows "Verification Required" message
- [ ] Shows category-specific requirements
- [ ] Shows current status (role/verification)
- [ ] "Get Verified" button navigates to `/verification/submit`
- [ ] "Go Back" button navigates back

### Screen 4: Verification History (`/profile/verifications`)
- [ ] Shows all my verification requests
- [ ] Shows status with color coding
- [ ] Shows dates and notes
- [ ] Can view document (if uploaded)

---

## API Testing with Postman

Import your collection: `EthioConnect Post Service - Complete API v2.postman_collection.json`

### Test Suite 1: Verification Endpoints

1. **Register User**
   - Endpoint: POST `/api/auth/register`
   - Save token to environment variable

2. **Get My Verifications**
   - Endpoint: GET `/api/verifications`
   - Use saved token
   - Should return empty array initially

3. **Submit Verification**
   - Endpoint: POST `/api/verifications`
   - Upload document file
   - Add type and notes
   - Should return verification with "pending" status

4. **Check Is Verified** (Before Approval)
   - Endpoint: GET `/api/verifications/is-verified?type=doctor_license`
   - Should return `isVerified: false`

5. **Admin Approves** (Use admin token)
   - Endpoint: PUT `/api/verifications/{id}`
   - Set status to "approved"
   - Should auto-assign role

6. **Check Is Verified** (After Approval)
   - Endpoint: GET `/api/verifications/is-verified?type=doctor_license`
   - Should return `isVerified: true`

### Test Suite 2: Post Creation

1. **Create Post in General Category** (KYC only)
   - Should succeed with basic verification

2. **Create Post in Medical Category** (Not Verified)
   - Should return 403 Forbidden

3. **Create Post in Medical Category** (After Verification)
   - Should succeed
   - Post should have verification info

4. **Get My Posts**
   - Should show created posts
   - Verified posts should show `verifiedWith` field

---

## Common Issues & Solutions

### Issue 1: "Failed to check verification"
**Cause**: User Service not responding or token invalid  
**Solution**: 
- Verify User Service is running: https://ethiouser.zewdbingo.com
- Check JWT token is valid
- Re-login if needed

### Issue 2: "403 Forbidden" when creating post
**Cause**: User not verified for category  
**Solution**:
- Check verification status: GET `/api/verifications/is-verified?type={type}`
- Ensure admin has approved verification
- Ensure user has correct role

### Issue 3: Verification shows "pending" forever
**Cause**: Admin hasn't approved yet  
**Solution**:
- Use Postman to approve manually
- Check verification ID is correct
- Use admin token

### Issue 4: Category check shows "not found in verification map"
**Cause**: Category name not in CategoryVerificationMap  
**Solution**:
- Check spelling of category name
- Add category to map in `category_verification_map.dart`
- Use exact category names: 'medical', 'education', 'jobs', 'general'

### Issue 5: JWT token expired
**Symptoms**: 401 Unauthorized  
**Solution**:
- Re-login to get new token
- Check token expiry time
- Implement token refresh if needed

---

## Performance Testing

Test with multiple users:
1. Create 10 users
2. Submit verifications for each
3. Approve half of them
4. Try creating posts from all users
5. Verify only approved users succeed

**Expected**:
- Fast response times (<500ms)
- No race conditions
- Correct verification checks for all users
- Proper error handling

---

## Debug Mode

Enable detailed logging in your Flutter app:

```dart
// Already configured in your services
AppLogger.info('🔍 Checking verification...');
AppLogger.success('✅ Verification passed!');
AppLogger.error('❌ Verification failed');
AppLogger.warning('⚠️ Warning message');
AppLogger.celebrate('🎉 Success!');
```

Check console for detailed logs during testing.

---

## Final Checklist

Before going to production:

### Backend
- [ ] User Service deployed and accessible
- [ ] Post Service deployed and accessible
- [ ] Database properly configured
- [ ] Admin credentials secured
- [ ] JWT secret properly set
- [ ] CORS configured correctly

### Frontend
- [ ] All screens accessible
- [ ] All routes configured
- [ ] API endpoints correct
- [ ] Error handling in place
- [ ] Loading states work
- [ ] Success/error messages clear

### Integration
- [ ] User can register and login
- [ ] User can submit verification
- [ ] Admin can approve verification
- [ ] Verification check works
- [ ] Post creation enforces verification
- [ ] Error messages are helpful
- [ ] Navigation flows smoothly

### Security
- [ ] JWT authentication working
- [ ] Tokens stored securely
- [ ] API calls use HTTPS
- [ ] Sensitive data not logged
- [ ] Admin endpoints protected

---

**Status**: ✅ Ready for Testing  
**Next Step**: Run through Test 1 (Happy Path) completely

🎯 **Start testing now and verify everything works end-to-end!**
