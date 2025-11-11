# 📱 App Drawer Guide

## ✨ **Features**

The `AppDrawer` provides a beautiful side menu with:

### **🎨 Header**
- User avatar (first letter of username/email)
- Username/email display
- Verification badge (if verified)
- Beautiful gradient background

### **📋 Menu Items**

#### **For Logged In Users:**
1. **Profile** - View user profile
2. **Verification Center** - Manage verifications
3. **Settings** - App settings
4. **Dark Mode Toggle** - Switch themes
5. **Language Selector** - Choose from 5 languages
   - English
   - አማርኛ (Amharic)
   - Oromoo (Oromo)
   - Soomaali (Somali)
   - ትግርኛ (Tigrinya)
6. **Help & Support** - Get help
7. **About** - App information
8. **Logout** - Sign out (with confirmation)

#### **For Guest Users:**
1. **Settings**
2. **Dark Mode Toggle**
3. **Language Selector**
4. **Help & Support**
5. **About**
6. **Login** - Sign in to account

---

## 🎯 **How to Use**

### **Opening the Drawer**

The drawer can be opened in three ways:

1. **Tap the hamburger icon** (☰) in the app bar (top-left)
2. **Swipe from the left edge** of the screen
3. **Programmatically**: `Scaffold.of(context).openDrawer()`

### **Closing the Drawer**

- Tap outside the drawer
- Swipe back to the left
- Tap any menu item (closes automatically)

---

## 🔧 **Implementation**

### **Add to Any Screen**

```dart
import '../../widgets/app_drawer.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ✅ Add this line!
      appBar: AppBar(title: Text('My Screen')),
      body: Center(child: Text('Content')),
    );
  }
}
```

### **Already Added To:**
- ✅ `LandingScreen` - Main landing page

---

## 🎨 **Customization**

### **Change Theme**
The drawer automatically adapts to your app theme:
- Light mode: Bright colors
- Dark mode: Dark colors

Toggle dark mode directly from the drawer!

### **Language**
Select from 5 supported languages:
- Changes apply immediately
- Shows checkmark for current language
- All UI text updates automatically

---

## 🔐 **User States**

### **Guest User (Not Logged In)**
```
╔════════════════════════╗
║    Guest User          ║
║    Not logged in       ║
╠════════════════════════╣
║ ⚙️  Settings           ║
║ 🌙 Dark Mode          ║
║ 🌍 Language           ║
║ ❓ Help & Support     ║
║ ℹ️  About              ║
║ ➜  Login              ║
╚════════════════════════╝
```

### **Logged In User**
```
╔════════════════════════╗
║    [J]                 ║ ← Avatar
║    JohnDoe            ║
║    john@email.com      ║
║    ✅ Verified         ║
╠════════════════════════╣
║ 👤 Profile            ║
║ ✓  Verification Center║
║ ⚙️  Settings           ║
║ 🌙 Dark Mode          ║
║ 🌍 Language           ║
║ ❓ Help & Support     ║
║ ℹ️  About              ║
║ 🚪 Logout             ║
╚════════════════════════╝
```

---

## 🎯 **User Experience Features**

### **Smart User Display**
- Shows username if available
- Falls back to email prefix if no username
- Shows 'Guest' if not logged in
- Avatar shows first letter of name/email

### **Logout Confirmation**
- Shows confirmation dialog before logout
- Red button for danger action
- Success message after logout
- Automatically closes drawer

### **Language Change**
- Instant language switch
- Shows success message
- Highlights selected language
- Check icon for current language

### **Dark Mode**
- Toggle switch for easy access
- Shows current state (Enabled/Disabled)
- Changes apply immediately
- Icon changes (🌙/☀️)

---

## 📱 **Responsive Design**

- Adapts to different screen sizes
- Smooth animations
- Gradient header background
- Material Design 3 compliance
- Touch-friendly tap targets

---

## 🔔 **Notifications**

The drawer shows notifications for actions:
- ✅ "Logged out successfully" (green)
- ✅ "Language changed to [Language]" (default)
- Uses SnackBar for non-intrusive feedback

---

## 🚀 **Future Enhancements**

Potential features to add:
- [ ] Notifications menu item
- [ ] Favorites/Bookmarks
- [ ] App version update check
- [ ] Privacy policy link
- [ ] Terms of service
- [ ] Share app option
- [ ] Rate app
- [ ] Dark mode schedule (auto)

---

## 🐛 **Troubleshooting**

### **Drawer Not Showing**

Make sure:
1. `drawer: const AppDrawer()` is added to `Scaffold`
2. You're not overriding the `leading` in `AppBar`
3. Hot restart after adding the drawer

### **Hamburger Icon Not Appearing**

The icon appears automatically when:
- `Scaffold` has a `drawer` parameter
- `AppBar` doesn't have a custom `leading` widget

If you have a custom `AppBar`, manually add:
```dart
leading: IconButton(
  icon: Icon(Icons.menu),
  onPressed: () {
    Scaffold.of(context).openDrawer();
  },
),
```

### **User Data Not Showing**

- Drawer loads user data on `initState`
- If user logs in/out, the drawer updates automatically
- Check that `AuthService` is working correctly

---

## 💡 **Pro Tips**

1. **Quick Theme Toggle**: Users can quickly switch between light/dark mode from the drawer
2. **Language Learning**: Great for users who want to practice different Ethiopian languages
3. **One-Tap Logout**: Quick access to sign out when needed
4. **Verification Status**: Users can see their verification status at a glance

---

**Your beautiful drawer menu is ready! 🎉**

Users can now easily access settings, change language, toggle theme, and manage their account from the convenient side menu!
