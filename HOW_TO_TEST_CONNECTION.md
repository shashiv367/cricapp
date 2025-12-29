# How to Check if Frontend and Backend are Connected

## Quick Test Methods

### Method 1: Test from Browser (Easiest)

1. **Make sure backend is running:**
   ```bash
   cd backend
   npm run dev
   ```

2. **Open browser on your phone/computer:**
   - Go to: `http://192.168.1.4:4000/api/health`
   
3. **Expected result:**
   ```json
   {
     "status": "ok",
     "service": "cricapp-backend",
     "timestamp": "2025-12-29T..."
   }
   ```

   ✅ **If you see this JSON** = Backend is reachable  
   ❌ **If you see "This site can't be reached"** = Connection issue

---

### Method 2: Test from Flutter App (Check Logs)

1. **Run your Flutter app**
2. **Try to sign up or log in**
3. **Check the console/logs:**

   Look for these messages in your console:

   **✅ Success messages:**
   ```
   ✅ [API] Connection test successful: 200
   ✅ [API] Signup successful
   ✅ [API] Login successful
   ```

   **❌ Error messages:**
   ```
   ❌ [API] Connection test failed
   ❌ [API] Network error
   Connection timeout
   ```

---

### Method 3: Test Using Flutter's Connection Test Function

Your Flutter app already has a connection test function. Add this to a button or run it:

**In your Flutter app, call:**
```dart
// Test connection
bool isConnected = await ApiService.testConnection();
if (isConnected) {
  print('✅ Backend is connected!');
} else {
  print('❌ Backend connection failed');
}
```

---

### Method 4: Test from Command Line (Terminal)

**On your computer:**
```bash
# Test localhost (should always work if backend is running)
curl http://localhost:4000/api/health

# Test from network IP (same as your phone would use)
curl http://192.168.1.4:4000/api/health
```

**Expected:** JSON response with status "ok"  
**If fails:** Connection or firewall issue

---

### Method 5: Check Backend Logs

1. **Look at your backend terminal** (where you ran `npm run dev`)

2. **When frontend tries to connect, you should see:**
   ```
   🔵 [BACKEND] ========== INCOMING REQUEST ==========
   🔵 [BACKEND] Method: GET
   🔵 [BACKEND] Path: /api/health
   ✅ [BACKEND] Response sent
   ```

3. **If you DON'T see these logs** = Frontend can't reach backend

---

### Method 6: Complete Signup/Login Test

**The ultimate test - try to sign up:**

1. **Start backend:** `cd backend && npm run dev`
2. **Run Flutter app**
3. **Fill signup form:**
   - Email: test@example.com
   - Password: test123
   - Role: user
   - Name: Test User
4. **Click Signup**

**✅ Success indicators:**
- No error message
- You see "Account created successfully"
- You're redirected to dashboard/login
- Backend logs show: `✅ [BACKEND] Signup completed successfully`

**❌ Failure indicators:**
- Error message: "Connection timeout"
- Error message: "Network error"
- Error message: "Cannot connect to backend"
- Backend logs show nothing (no incoming request)

---

## Troubleshooting Checklist

If connection is NOT working, check these in order:

1. **✅ Is backend running?**
   ```bash
   netstat -ano | findstr :4000
   ```
   Should show port 4000 is in use

2. **✅ Can you access from browser?**
   - Try: `http://localhost:4000/api/health` (from computer)
   - Try: `http://192.168.1.4:4000/api/health` (from phone)

3. **✅ Is firewall open?**
   ```bash
   netsh advfirewall firewall show rule name="Cricapp Backend Port 4000"
   ```
   Should show "Enabled: Yes"

4. **✅ Is IP address correct?**
   - Check: `ipconfig` (find your IPv4 Address)
   - Check: `frontend/lib/services/api_service.dart` line 16
   - They should match!

5. **✅ Are devices on same WiFi?**
   - Computer and phone must be on the same WiFi network

---

## Quick Connection Test Script

Save this as a test file and run it:

```dart
// test_connection.dart
import 'package:http/http.dart' as http;

Future<void> testConnection() async {
  const baseUrl = 'http://192.168.1.4:4000';
  
  try {
    print('🔵 Testing connection to $baseUrl/api/health...');
    final response = await http
        .get(Uri.parse('$baseUrl/api/health'))
        .timeout(const Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      print('✅ SUCCESS! Backend is connected!');
      print('Response: ${response.body}');
    } else {
      print('⚠️ Backend responded but with status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ FAILED! Cannot connect to backend');
    print('Error: $e');
    print('\nCheck:');
    print('1. Is backend running? (cd backend && npm run dev)');
    print('2. Is firewall open? (Run open-firewall.bat)');
    print('3. Is IP correct? (Check ipconfig)');
  }
}
```

---

## Summary: Quick Test

**Fastest way to test:**

1. **Browser test:** `http://192.168.1.4:4000/api/health` → Should show JSON
2. **Flutter app:** Try signup → Should work without errors
3. **Backend logs:** Should show incoming requests

**If all three work = ✅ Connected!**

