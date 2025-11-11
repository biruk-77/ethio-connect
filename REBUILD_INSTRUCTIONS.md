# 🔧 REBUILD INSTRUCTIONS

## ❌ **Problem**
Your config file is correct:
```dart
'https://ethiocms.unitybingo.com'  ✅ ONE dot
```

But your compiled app has:
```
'https://ethiocms.unitybingo..com'  ❌ TWO dots (cached)
```

---

## ✅ **Solution: Full Clean & Rebuild**

### **Option 1: Use Batch Script (Fastest)**
```bash
# Double-click this file:
rebuild.bat
```

### **Option 2: Manual Steps**

1. **Stop your app**
   - Close emulator/device app
   - Stop any running Flutter processes

2. **Delete cache folders**
   ```bash
   # In project root
   rmdir /s /q build
   rmdir /s /q .dart_tool
   rmdir /s /q android\.gradle
   rmdir /s /q android\app\build
   ```

3. **Clean Flutter**
   ```bash
   flutter clean
   ```

4. **Get dependencies**
   ```bash
   flutter pub get
   ```

5. **Rebuild**
   ```bash
   flutter run
   ```

---

## 🔍 **Verify Fix**

After rebuild, check the logs for:
```
╔════════════════════════════════════════════════════════════
║  CONFIGURATION DEBUG
╠════════════════════════════════════════════════════════════
║  Base URL: https://ethiocms.unitybingo.com
║  Contains "unitybingo..": false          ← Should be false!
╚════════════════════════════════════════════════════════════
✅ Configuration looks correct!
```

And:
```
🔍 DEBUG - Full URL: https://ethiocms.unitybingo.com/...
                                           ↑
                                    Single dot only!
```

---

## 🚨 **Why This Happened**

Flutter compiles `const` values into the binary. Changes to const values require a **full rebuild**, not just hot reload or hot restart.

**Hot reload** ❌ - Doesn't update const values  
**Hot restart** ❌ - Doesn't update const values  
**Full rebuild** ✅ - Updates everything

---

## 📝 **After Rebuild**

The conversations endpoint should work:
```
GET https://ethiocms.unitybingo.com/api/v1/messages/conversations
Status: 200 ✅
```

---

**Last Updated**: Nov 10, 2025, 10:40 AM
