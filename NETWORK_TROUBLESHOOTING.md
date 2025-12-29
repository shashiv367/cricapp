# Network Troubleshooting Guide

## Problem: App cannot connect to backend (Request timeout)

### Step 1: Test from Phone Browser
**This is the easiest way to verify connectivity:**

1. Open a web browser on your Android phone (Chrome, Firefox, etc.)
2. Navigate to: `http://192.168.1.4:4000/api/health`
3. You should see: `{"status":"ok","service":"cricapp-backend","timestamp":"..."}`

**If this works:** The network is fine, the issue is in the Flutter app.
**If this doesn't work:** Continue with the steps below.

### Step 2: Verify Both Devices on Same Network

1. On your computer, run: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
2. Note your computer's IP address (should be 192.168.1.4)
3. On your phone:
   - Go to Settings → WiFi → Tap on your connected network
   - Check the IP address range (should be 192.168.1.x)
   - If different, connect to the same WiFi network as your computer

### Step 3: Verify Backend is Running

1. On your computer, check if backend is running:
   ```bash
   netstat -an | findstr ":4000"
   ```
   Should show: `TCP    0.0.0.0:4000           0.0.0.0:0              LISTENING`

2. Test from your computer's browser:
   - Open: `http://localhost:4000/api/health`
   - Should show: `{"status":"ok","service":"cricapp-backend","timestamp":"..."}`

### Step 4: Check Windows Firewall

1. Run the firewall script: `backend\open-firewall.bat`
2. Or manually:
   - Windows Security → Firewall & network protection → Advanced settings
   - Inbound Rules → New Rule
   - Port → TCP → 4000 → Allow → Apply to all profiles → Name: "Cricapp Backend"

### Step 5: Check Router Firewall

Some routers block device-to-device communication:
1. Check router settings for "AP Isolation" or "Client Isolation"
2. Disable it if enabled
3. Some routers have "Guest Network" isolation - make sure you're not on a guest network

### Step 6: Try Different IP Address

If your computer has multiple network adapters:
1. Run `ipconfig` and check all IPv4 addresses
2. Try the IP address of your active WiFi adapter
3. Update `frontend/lib/services/api_service.dart` line 16 with the correct IP

### Step 7: Test with Ping

From your phone (if you have a terminal app or ADB):
```bash
ping 192.168.1.4
```
Should receive responses. If not, there's a network connectivity issue.

### Step 8: Check Antivirus/Firewall Software

Some antivirus software (Norton, McAfee, etc.) may block connections:
1. Temporarily disable antivirus firewall
2. Test again
3. If it works, add an exception for port 4000

### Common Issues:

1. **Phone on mobile data instead of WiFi**: Make sure WiFi is connected
2. **Computer on VPN**: VPN might change your IP address
3. **Router AP Isolation**: Prevents devices from talking to each other
4. **Multiple network adapters**: Using wrong IP address
5. **Windows Firewall**: Blocking incoming connections

### Quick Test Commands:

**On Windows (Command Prompt):**
```cmd
ipconfig | findstr IPv4
netstat -an | findstr ":4000"
```

**Test from phone browser:**
```
http://192.168.1.4:4000/api/health
```

If the browser test works but the app doesn't, the issue is in the Flutter app configuration (AndroidManifest.xml cleartext traffic, etc.).



