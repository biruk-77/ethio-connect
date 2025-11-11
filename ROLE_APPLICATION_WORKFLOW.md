# 🎯 Role Application & Verification Workflow

## ✅ **CORRECTED UNDERSTANDING!**

The **"What are you interested in?"** section is **NOT** for browsing content categories.  
It's for **APPLYING TO BECOME A VERIFIED PROFESSIONAL** in that role!

---

## 🔄 **The Correct Workflow**

### **1. Landing Page Shows Professional Roles**

Section header:
- **"Apply for Professional Roles"**
- Subtitle: "Become a verified professional"

Displays roles from API:
- 🩺 **Doctor**
- 👨‍🏫 **Teacher**
- 👔 **Employee**
- 💼 **Employer**
- 🏢 **Business**
- etc.

---

### **2. User Clicks on a Role (e.g., "Doctor")**

**Two scenarios:**

#### **A) Not Logged In:**
1. Show dialog: "Login Required"
2. Message: "You need to login to apply for professional roles and get verified."
3. Options: [Cancel] [Login]
4. If Login clicked → Navigate to `/auth/login`

#### **B) Logged In:**
1. Show confirmation dialog:
   - Title: "Apply for Doctor"
   - Message: "You are applying to become a verified Doctor."
   - Requirements:
     - ✓ Upload verification documents
     - ✓ Provide additional information
     - ✓ Wait for admin approval
   - Options: [Cancel] [Continue]

2. If Continue clicked:
   - Navigate to `/verification/submit`
   - Pass arguments:
     ```dart
     {
       'verificationType': 'doctor_license',
       'roleName': 'Doctor'
     }
     ```

---

### **3. Verification Submission Screen**

**Receives role information:**
- App bar title: **"Apply for Doctor"**
- Main title: **"Apply for Doctor Role"**
- Description: **"Upload required documents to become a verified Doctor"**

**Pre-selects verification type:**
- Role: `doctor` → Type: `doctor_license`
- Role: `teacher` → Type: `teacher_cert`
- Role: `business` → Type: `business_license`
- Role: `employer` → Type: `business_license`
- Role: `employee` → Type: `employer_cert`
- Others → Type: `other`

**User uploads:**
- Medical license (for doctor)
- Teaching certificate (for teacher)
- Business registration (for business/employer)
- Employment certificate (for employee)
- etc.

---

### **4. After Submission**

1. Verification goes to **Pending** status
2. User can check status in **Verification Center**
3. Admin reviews and approves/rejects
4. If approved → User gets the role assigned
5. User becomes a **Verified Doctor** (or whatever role)

---

## 📊 **Role to Verification Type Mapping**

| Role Name | Verification Type | Required Document |
|-----------|------------------|-------------------|
| Doctor | `doctor_license` | Medical license, registration |
| Teacher | `teacher_cert` | Teaching certificate |
| Business | `business_license` | Business registration |
| Employer | `business_license` | Company documents |
| Employee | `employer_cert` | Employment letter |
| Other | `other` | Relevant documents |

---

## 🎯 **Key Changes Made**

### **1. Landing Screen** (`landing_screen.dart`)

**Updated section header:**
```dart
'Apply for Professional Roles'
'Become a verified professional'
```

**Updated `_handleCategoryTap` method:**
- Check if user is logged in
- Show login dialog if not
- Show role application confirmation
- Navigate to verification with role arguments

### **2. Verification Submit Screen** (`submit_verification_screen.dart`)

**Added role argument handling:**
```dart
void didChangeDependencies() {
  final args = ModalRoute.of(context)?.settings.arguments;
  if (args != null) {
    _selectedType = args['verificationType'];
    _roleName = args['roleName'];
  }
}
```

**Dynamic titles:**
- App bar: "Apply for [Role]"
- Main title: "Apply for [Role] Role"
- Description: "Upload required documents to become a verified [Role]"

---

## 🚀 **Complete User Journey**

```
1. Open app → Landing page

2. See "Apply for Professional Roles" section
   Shows: Doctor, Teacher, Employee, Employer, Business

3. User clicks "Doctor" 🩺

4. If not logged in:
   → Show login dialog
   → Navigate to login
   → After login, return to landing

5. If logged in:
   → Show "Apply for Doctor" dialog
   → Explain requirements
   → Click "Continue"

6. Navigate to Verification Submit
   → Title: "Apply for Doctor"
   → Pre-selected: Doctor License
   → Upload medical license
   → Add notes (optional)
   → Submit

7. Verification created with status: Pending
   → User gets confirmation
   → Navigate back to landing

8. User can check status:
   → User menu → "Verification Center"
   → See "Doctor License" - Pending
   → Wait for admin approval

9. Admin approves:
   → Status changes to Approved
   → User gets Doctor role assigned
   → User is now a Verified Doctor! ✅
```

---

## 📱 **User Experience**

### **Benefits:**
1. **Clear Intent**: Users know they're applying for roles
2. **Login Prompt**: Prevents confusion, asks to login when needed
3. **Confirmation Dialog**: Explains what's required before starting
4. **Contextual UI**: Verification screen shows role name throughout
5. **Pre-selected Type**: Automatically picks correct verification type
6. **Professional**: Feels like a real application process

---

## 🔗 **API Integration**

### **Get Roles**
```http
GET /api/roles
```

Response:
```json
{
  "success": true,
  "data": {
    "roles": [
      {
        "id": "...",
        "name": "doctor",
        "createdAt": "...",
        "updatedAt": "..."
      }
    ]
  }
}
```

### **Submit Verification**
```http
POST /api/verifications
Content-Type: multipart/form-data

{
  "type": "doctor_license",
  "file": (binary),
  "notes": "..."
}
```

### **Get My Verifications**
```http
GET /api/verifications
```

### **Get My Profile**
```http
GET /api/profiles
```

Response includes verification status:
```json
{
  "profile": {
    "verificationStatus": "pending" | "approved" | "rejected" | "none"
  }
}
```

---

## 🎉 **Summary**

**OLD (WRONG):**
- "What are you interested in?" → Browse categories → See content

**NEW (CORRECT):**
- "Apply for Professional Roles" → Select role → Apply with documents → Get verified

**This is a professional verification and role application system, NOT a content browsing system!** 🚀

---

**Hot restart and try it!**

1. Click on a role
2. See the application dialog
3. Submit verification
4. Get verified as a professional! ✅
