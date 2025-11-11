# 🎯 Role-Based Screens Structure

## 📁 6 New Folders Created in Landing Directory

```
lib/screens/landing/
├── jobs/          # 💼 Job Opportunities
├── products/      # 🛍️ Products & Marketplace
├── rentals/       # 🏠 Rentals & Real Estate
├── services/      # 🔧 Services Offered
├── matchmaking/   # 💑 Matchmaking & Dating
└── events/        # 🎉 Events & Activities
```

---

## 🚀 Each Screen Has:

### ✅ Features:
1. **Role-Specific Posts** - Only shows posts for that category
2. **Apply for Role Button** - FAB (Floating Action Button) if user doesn't have role
3. **Authentication Check** - Login prompt if not logged in
4. **Verification Flow** - Redirects to verification center to apply for role
5. **Create Post Button** - In app bar if user has verified role
6. **Grid/List View** - Display posts in appropriate format
7. **Post Details** - Modal bottom sheet with full post details
8. **Pull to Refresh** - Refresh posts list

---

## 📋 Role Requirements:

| Screen | Required Role | Apply Button Text |
|--------|--------------|------------------|
| **Jobs** | Employer / Business | "Become an Employer" |
| **Products** | Business / Seller | "Become a Seller" |
| **Rentals** | Landlord / Business | "Become a Landlord" |
| **Services** | Service Provider | "Become a Provider" |
| **Matchmaking** | Matchmaker / Verified | "Become a Matchmaker" |
| **Events** | Event Organizer | "Become an Organizer" |

---

## 🔄 User Flow:

### Not Logged In:
```
User clicks category → Opens role screen
    ↓
User clicks "Apply for Role" FAB
    ↓
Shows "Login Required" dialog
    ↓
Redirects to /auth/login
```

### Logged In but No Role:
```
User clicks category → Opens role screen
    ↓
User clicks "Apply for Role" FAB
    ↓
Shows "Apply for [Role]" dialog
    ↓
Redirects to /verification/center
```

### Has Role:
```
User clicks category → Opens role screen
    ↓
Can view posts + Create new post button in app bar
    ↓
Click "+" → Create post (coming soon)
```

---

## 🎨 Screen Layouts:

### Jobs Screen:
- **Layout:** ListView with cards
- **Shows:** Job title, company, location, salary
- **Icon:** 💼

### Products Screen:
- **Layout:** GridView (2 columns)
- **Shows:** Product image, name, price
- **Icon:** 🛍️

### Rentals Screen:
- **Layout:** ListView with large image cards
- **Shows:** Property image, price/month, location, bedrooms
- **Icon:** 🏠

### Services Screen:
- **Layout:** ListView with provider info
- **Shows:** Service name, provider, rating, price range
- **Icon:** 🔧

### Matchmaking Screen:
- **Layout:** GridView (profiles)
- **Shows:** Profile photo, age, interests
- **Icon:** 💑

### Events Screen:
- **Layout:** ListView with event cards
- **Shows:** Event image, date, time, location
- **Icon:** 🎉

---

## 🔗 Navigation:

All screens accessible from:
1. Landing page category grid
2. Direct routes: `/landing/jobs`, `/landing/products`, etc.

---

## ✅ Status:

- [x] Folder structure created
- [x] Jobs screen created
- [x] Products screen created
- [ ] Rentals screen (creating...)
- [ ] Services screen (creating...)
- [ ] Matchmaking screen (creating...)
- [ ] Events screen (creating...)
- [ ] Routes added to main.dart
- [ ] Landing page updated to navigate to screens

---

**Next Steps:** Create remaining 4 screens and wire up navigation!
