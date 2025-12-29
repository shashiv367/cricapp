# Quick Fix: Backend Connection Timeout Error

## The Problem
You're seeing: **"Connection timeout: Backend did not respond"**

This happens because the **backend server is not running**.

## The Solution

### Step 1: Start the Backend Server

Open a **new terminal/command prompt** and run:

```bash
cd backend
npm run dev
```

You should see output like:
```
Cricapp backend listening on port 4000 (development)
🔵 [BACKEND] Server accessible at http://0.0.0.0:4000
🔵 [BACKEND] Local access: http://localhost:4000
```

### Step 2: Keep the Backend Running

**IMPORTANT:** Keep this terminal window open! The backend server needs to keep running for your app to work.

### Step 3: Test the Connection

Once the backend is running, test it:

1. **From your computer's browser:**
   ```
   http://localhost:4000/api/health
   ```
   Should show: `{"status":"ok","service":"cricapp-backend",...}`

2. **From your phone's browser (must be on same WiFi):**
   ```
   http://10.137.196.199:4000/api/health
   ```
   Should show the same JSON response

3. **From your Flutter app:**
   - Try signup/login again
   - The connection timeout error should be gone

---

## If You Still Get Connection Errors

### Check 1: Is Backend Actually Running?
```bash
# In a new terminal
netstat -ano | findstr :4000
```
If you see output, the backend is running. If empty, it's not running.

### Check 2: Windows Firewall
If your phone can't connect but your computer can:

1. Open **Windows Defender Firewall**
2. Click **Advanced Settings**
3. Click **Inbound Rules** → **New Rule**
4. Select **Port** → Next
5. Select **TCP**, enter port **4000** → Next
6. Select **Allow the connection** → Next
7. Check all profiles → Next
8. Name it "Cricapp Backend" → Finish

### Check 3: IP Address
Make sure the IP in `frontend/lib/services/api_service.dart` matches your computer's current IP:

```bash
# Find your IP address
ipconfig
```
Look for "IPv4 Address" under your active network adapter (usually 192.168.x.x or 10.x.x.x)

Update line 16 in `frontend/lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP_HERE:4000/api';
```

### Check 4: Same WiFi Network
- Your computer and phone **MUST** be on the same WiFi network
- Some routers have "AP Isolation" which blocks device-to-device communication
- Try connecting both devices to the same WiFi network

---

## Quick Start Commands

```bash
# Start backend (in backend folder)
cd backend
npm run dev

# In another terminal, test connection
curl http://localhost:4000/api/health

# Check if port is open
netstat -ano | findstr :4000
```

---

## Summary

✅ **Fix:** Start the backend server with `cd backend && npm run dev`
✅ **Keep it running:** Don't close the terminal window
✅ **Test:** Visit `http://localhost:4000/api/health` in browser
✅ **If phone can't connect:** Check Windows Firewall and IP address

