# Testing Instructions

## Current Setup
- **Backend**: Running on `http://localhost:4000` (or `http://10.0.2.2:4000` from emulator)
- **Frontend API URL**: Currently set to `http://10.0.2.2:4000/api` (for Android emulator)

## Testing on Android Emulator

1. **Start an Android Emulator**:
   ```bash
   # Open Android Studio → Tools → Device Manager → Start an emulator
   # OR use command line if you have emulators configured
   ```

2. **Verify backend is running**:
   - Backend should be running on port 4000
   - Check: `netstat -an | findstr ":4000"`

3. **Run Flutter app on emulator**:
   ```bash
   cd frontend
   flutter run
   # Select the emulator when prompted
   ```

4. **Test signup**:
   - Open the app
   - Try signing up with a new email
   - Should work with `10.0.2.2:4000` (already configured)

## Testing on Physical Device (I2301)

If you want to test on your physical device instead:

1. **Update API URL** in `frontend/lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://10.137.196.199:4000/api'; // Your computer's IP
   ```

2. **Make sure both devices are on the same network** (or use mobile hotspot)

3. **Run Flutter app**:
   ```bash
   cd frontend
   flutter run
   # Select I2301 when prompted
   ```

## Quick Test Commands

**Test backend health from emulator/device**:
- From emulator browser: `http://10.0.2.2:4000/api/health`
- From physical device browser: `http://10.137.196.199:4000/api/health`

**Check backend logs**:
- Backend terminal should show incoming requests

## Current Status
✅ Backend is running
✅ API URL configured for emulator (`10.0.2.2:4000`)
✅ Signup duplicate key issue fixed (using upsert)

## Next Steps
1. Start Android emulator (if not using physical device)
2. Run `flutter run` in frontend folder
3. Test signup with a new email
4. Check backend logs for any errors



