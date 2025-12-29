# Connection Troubleshooting - Phone Can't Reach Backend

## Current Status

✅ **Backend is running** (port 4000 is listening)  
✅ **Backend works from computer** (localhost and network IP both respond)  
❌ **Phone cannot connect** (getting "Network error: Cannot connect")

---

## Step-by-Step Fix

### Step 1: Test from Phone Browser (IMPORTANT!)

**This is the easiest test to see if it's a network issue:**

1. Open **Chrome browser** on your phone
2. Go to: `http://192.168.1.4:4000/api/health`
3. **What happens?**
   - ✅ **If you see JSON** (`{"status":"ok",...}`) = Network is fine, issue is in Flutter app
   - ❌ **If you see "This site can't be reached"** = Network/firewall issue

**If phone browser also fails, continue with Step 2-5 below.**

---

### Step 2: Verify Both Devices on Same WiFi

**On your phone:**
- Settings → Wi-Fi
- Note the WiFi network name

**On your computer:**
- Look at network icon in system tray
- Verify it's the **same WiFi network name**

**If different:** Connect both to the same WiFi network.

---

### Step 3: Double-Check Windows Firewall

The firewall rule exists, but let's verify it's working:

```bash
# Check if rule exists and is enabled
netsh advfirewall firewall show rule name="Cricapp Backend Port 4000" | findstr "Enabled"
```

**If it shows "Enabled: No"**, re-run the firewall script:

1. Go to `backend` folder
2. Right-click `open-firewall.bat`
3. Select **"Run as administrator"**
4. Click "Yes" when prompted

---

### Step 4: Check Router AP Isolation

**AP Isolation** prevents devices on the same WiFi from talking to each other.

**How to check/fix:**
1. Open router admin page (usually `192.168.1.1` or `192.168.0.1`)
2. Look for **"AP Isolation"** or **"Client Isolation"** setting
3. Make sure it's **DISABLED**
4. Save settings

**Can't access router?** Try using your phone's mobile hotspot temporarily to test.

---

### Step 5: Test with Different IP Binding

The backend is listening on `0.0.0.0:4000` which should work, but let's verify:

**Check backend logs:**
When you started backend with `npm run dev`, you should see:
```
🔵 [BACKEND] Server accessible at http://0.0.0.0:4000
🔵 [BACKEND] Local access: http://localhost:4000
🔵 [BACKEND] Network access: http://192.168.1.4:4000
```

If you don't see "Network access" line, the server might not be binding correctly.

---

### Step 6: Check Android Network Permissions

Your Flutter app needs internet permission. Check `frontend/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

This should already be there, but verify.

---

### Step 7: Try Different Network (Mobile Hotspot Test)

**Temporary test to isolate the issue:**

1. **Enable mobile hotspot** on your phone
2. **Connect your computer** to the phone's hotspot
3. **Find computer's IP** on the hotspot:
   ```bash
   ipconfig
   ```
   Look for the IP under the hotspot adapter (usually 192.168.43.x or similar)
4. **Update frontend** with new IP
5. **Test connection**

If this works, the issue is with your router's AP Isolation or network settings.

---

## Quick Diagnostic Checklist

Run these in order:

- [ ] **Backend running?** → `netstat -ano | findstr :4000` (should show port 4000)
- [ ] **Computer can reach backend?** → `curl http://localhost:4000/api/health` (should show JSON)
- [ ] **Network IP works from computer?** → `curl http://192.168.1.4:4000/api/health` (should show JSON)
- [ ] **Phone browser can reach?** → Open `http://192.168.1.4:4000/api/health` on phone (should show JSON)
- [ ] **Same WiFi network?** → Check WiFi name on both devices
- [ ] **Firewall open?** → `netsh advfirewall firewall show rule name="Cricapp Backend Port 4000"` (should show Enabled: Yes)
- [ ] **AP Isolation disabled?** → Check router settings

---

## Most Common Fix

**If phone browser ALSO can't connect:**

1. **Run firewall script again** (as administrator):
   ```bash
   cd backend
   # Right-click open-firewall.bat → Run as administrator
   ```

2. **Check router AP Isolation** - This is the #1 cause of this issue

3. **Try mobile hotspot** as a test (see Step 7 above)

---

## If Phone Browser WORKS but Flutter App Doesn't

This means network is fine, but there's an issue with the Flutter app:

1. **Restart Flutter app completely** (stop and start again)
2. **Check Flutter logs** for more detailed error
3. **Verify IP address** in `api_service.dart` is correct
4. **Try hot restart** (press `R` in Flutter terminal)

---

## Test Command Script

Save this as `test_connection.bat` and run it:

```batch
@echo off
echo ========================================
echo Testing Backend Connection
echo ========================================
echo.

echo [1/4] Checking if backend is running...
netstat -ano | findstr :4000 >nul
if %errorlevel% equ 0 (
    echo ✅ Backend is running on port 4000
) else (
    echo ❌ Backend is NOT running! Start it with: cd backend && npm run dev
    pause
    exit /b 1
)

echo.
echo [2/4] Testing localhost connection...
curl -s http://localhost:4000/api/health >nul
if %errorlevel% equ 0 (
    echo ✅ Localhost connection works
) else (
    echo ❌ Localhost connection failed
)

echo.
echo [3/4] Testing network IP connection...
curl -s http://192.168.1.4:4000/api/health >nul
if %errorlevel% equ 0 (
    echo ✅ Network IP connection works
) else (
    echo ❌ Network IP connection failed
)

echo.
echo [4/4] Checking firewall rule...
netsh advfirewall firewall show rule name="Cricapp Backend Port 4000" | findstr "Enabled.*Yes" >nul
if %errorlevel% equ 0 (
    echo ✅ Firewall rule is enabled
) else (
    echo ❌ Firewall rule not found or disabled
    echo    Run: cd backend && open-firewall.bat (as administrator)
)

echo.
echo ========================================
echo Test Complete!
echo ========================================
echo.
echo NEXT STEP: Try http://192.168.1.4:4000/api/health from your phone browser
echo.
pause
```

---

## Still Not Working?

If all above fails, try:

1. **Temporarily disable Windows Firewall** (just for testing)
2. **Check antivirus** - Some antivirus software has its own firewall
3. **Check Windows Network Profile** - Make sure your WiFi is set to "Private" not "Public"
4. **Restart both devices** (phone and computer)
5. **Restart router**

