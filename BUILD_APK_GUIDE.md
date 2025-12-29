# Build APK - Step by Step Guide

## ✅ Yes, It Will Work!

Your APK will work with Render.com backend as long as:
1. ✅ Backend URL is correctly set in `api_service.dart` (already done!)
2. ✅ Backend is deployed and running on Render.com
3. ✅ Phone has internet connection

---

## Step 1: Verify Backend URL is Correct

The URL should be: `https://ballista-4d2o.onrender.com/api`

✅ I've already updated it for you!

---

## Step 2: Build APK

### Option A: Debug APK (For Testing)

```bash
cd frontend
flutter build apk --debug
```

**Output location:**
`frontend/build/app/outputs/flutter-apk/app-debug.apk`

### Option B: Release APK (For Distribution) ⭐ RECOMMENDED

```bash
cd frontend
flutter build apk --release
```

**Output location:**
`frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## Step 3: Install APK on Your Phone

### Method 1: USB Transfer
1. Connect phone to computer via USB
2. Copy `app-release.apk` to your phone
3. On phone: Settings → Security → Enable "Install from Unknown Sources"
4. Tap the APK file to install

### Method 2: Email/Cloud
1. Upload APK to Google Drive/Dropbox
2. Send link to your phone
3. Download and install

### Method 3: Direct Install via ADB
```bash
flutter install
```
(This installs directly if phone is connected)

---

## Step 4: Test the App

1. **Open the app** on your phone
2. **Try to sign up/login**
3. **Check if it connects** to Render.com backend
4. **Verify all features work**

---

## Important Notes

### ✅ Backend URL Configuration

Your app is now configured to use:
```
https://ballista-4d2o.onrender.com/api
```

This means:
- ✅ Works from anywhere (no need for same WiFi)
- ✅ Works on any network (mobile data, WiFi, etc.)
- ✅ Publicly accessible
- ✅ HTTPS secure connection

### ⚠️ Render.com Free Tier Limitations

- **Spins down after 15 minutes** of inactivity
- **First request after spin-down** may take 30-60 seconds (cold start)
- **This is normal** - subsequent requests will be fast

### 🔧 If Backend Seems Slow

The first request after inactivity is slow due to Render's free tier. This is expected behavior.

---

## Quick Build Command

**For release APK:**
```bash
cd frontend
flutter build apk --release
```

**For debug APK (faster, larger file):**
```bash
cd frontend
flutter build apk --debug
```

---

## Troubleshooting

### "Backend connection failed"

1. **Check backend is running:**
   - Visit: `https://ballista-4d2o.onrender.com/api/health`
   - Should see: `{"status":"ok",...}`

2. **Check phone has internet:**
   - Try browsing any website
   - Make sure WiFi/mobile data is on

3. **First request slow:**
   - Wait 30-60 seconds (cold start)
   - Try again - should be faster

### "App won't install"

- Enable "Install from Unknown Sources" in phone settings
- Check if APK file is corrupted (rebuild if needed)

---

## Summary

✅ **Your APK will work perfectly with Render.com backend!**

Just run:
```bash
cd frontend
flutter build apk --release
```

Then install `app-release.apk` on your phone!

