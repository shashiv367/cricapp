# Frontend-Backend Connection & Database Storage Verification

## Summary

This document provides a comprehensive analysis of the frontend-backend connection and database storage for login/signup.

---

## 1. Frontend-Backend Connection Status

### ✅ Configuration is Correct

**Frontend API Configuration:**
- Base URL: `http://10.137.196.199:4000/api` (configured in `frontend/lib/services/api_service.dart`)
- This IP is for physical device connection (both devices must be on same WiFi network)

**Backend Configuration:**
- Port: `4000` (configured in `backend/src/config/index.js`)
- Server listens on `0.0.0.0` (accessible from network)
- Supabase credentials: ✅ **Configured** (verified in `.env` file)

### ⚠️ Backend Server Status

**Current Status: Backend server is NOT running**

The connection test timed out, indicating the backend server needs to be started.

### How to Start Backend Server

```bash
cd backend
npm run dev
```

Or for production:
```bash
cd backend
npm start
```

The server should start and display:
```
Cricapp backend listening on port 4000 (development)
🔵 [BACKEND] Server accessible at http://0.0.0.0:4000
🔵 [BACKEND] Local access: http://localhost:4000
```

### Testing Connection

Once the backend is running, test the connection:

1. **From browser/phone browser:**
   ```
   http://10.137.196.199:4000/api/health
   ```
   Should return:
   ```json
   {
     "status": "ok",
     "service": "cricapp-backend",
     "timestamp": "2025-12-23T..."
   }
   ```

2. **From frontend app:**
   - The app has built-in connection testing in `api_service.dart`
   - Signup/Login functions test connection before making requests

---

## 2. Database Storage Verification

### ✅ Database Storage Implementation

The signup and login process stores data correctly in Supabase:

#### **Signup Flow:**

1. **User Creation in Supabase Auth:**
   ```58:87:backend/src/controllers/authController.js
   console.log('🔵 [BACKEND] Creating profile in database...');
   // Create profile in profiles table
   const profileData = {
     id: authData.user.id,
     full_name: fullName || null,
     username: email,
     role,
     phone: phone || null,
   };
   console.log('🔵 [BACKEND] Profile data:', JSON.stringify(profileData, null, 2));

   // Use upsert to handle existing profiles (insert or update)
   console.log('🔵 [BACKEND] Upserting profile (insert or update if exists)...');
   const { error: profileError, data: profileDataResult } = await supabase
     .from('profiles')
     .upsert(profileData, {
       onConflict: 'id',
     })
     .select();

   if (profileError) {
     console.log('❌ [BACKEND] Profile upsert error:', JSON.stringify(profileError, null, 2));
     console.log('🔵 [BACKEND] Attempting to delete auth user...');
     // If profile creation fails, try to delete the auth user
     const deleteResult = await supabase.auth.admin.deleteUser(authData.user.id);
     console.log('🔵 [BACKEND] Delete user result:', deleteResult);
     throw profileError;
   }
   ```

2. **Data Stored:**
   - **In `auth.users` table (Supabase Auth):**
     - `id` (UUID)
     - `email`
     - `password` (hashed)
     - `user_metadata.role`
     - `user_metadata.full_name`
   
   - **In `profiles` table (Database):**
     - `id` (UUID, references auth.users.id)
     - `full_name` (TEXT)
     - `username` (TEXT, usually email)
     - `role` (TEXT: 'user', 'player', or 'umpire')
     - `phone` (TEXT, nullable)
     - `created_at` (TIMESTAMP)
     - `updated_at` (TIMESTAMP)

#### **Login Flow:**

1. **Authentication:**
   ```137:149:backend/src/controllers/authController.js
   // Authenticate with Supabase
   const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
     email,
     password,
   });

   if (authError) {
     console.log('❌ [BACKEND] Supabase Auth Error:', JSON.stringify(authError, null, 2));
     if (authError.message && authError.message.includes('Invalid login credentials')) {
       console.log('⚠️ [BACKEND] Invalid credentials');
       return res.status(401).json({ message: 'Invalid email or password' });
     }
     throw authError;
   }
   ```

2. **Profile Retrieval:**
   ```164:176:backend/src/controllers/authController.js
   // Get user profile with role
   const { data: profile, error: profileError } = await supabase
     .from('profiles')
     .select('role, full_name, phone, username')
     .eq('id', authData.user.id)
     .single();

   if (profileError) {
     console.log('⚠️ [BACKEND] Profile fetch error:', JSON.stringify(profileError, null, 2));
     console.log('⚠️ [BACKEND] Continuing with default role: user');
   } else {
     console.log('✅ [BACKEND] Profile fetched successfully');
     console.log('🔵 [BACKEND] Profile data:', JSON.stringify(profile, null, 2));
   }
   ```

### Database Schema

The database schema is defined in `backend/database/schema.sql`:

```8:16:backend/database/schema.sql
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  username TEXT,
  phone TEXT,
  role TEXT CHECK (role IN ('user', 'player', 'umpire')) DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### ✅ Verification Steps

To verify data is being stored:

1. **Check Supabase Dashboard:**
   - Go to your Supabase project dashboard
   - Navigate to **Authentication** → **Users** to see created users
   - Navigate to **Table Editor** → **profiles** to see profile data

2. **Check Backend Logs:**
   When you run signup/login, the backend logs will show:
   ```
   ✅ [BACKEND] User created in Supabase Auth
   ✅ [BACKEND] Profile created successfully
   ```

3. **Test API Endpoints:**
   ```bash
   # Signup
   curl -X POST http://10.137.196.199:4000/api/auth/signup \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "test123",
       "role": "user",
       "fullName": "Test User"
     }'
   
   # Login
   curl -X POST http://10.137.196.199:4000/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "test123"
     }'
   ```

---

## 3. Connection Troubleshooting

### Common Issues:

1. **Connection Timeout:**
   - **Cause:** Backend server not running
   - **Solution:** Start backend with `cd backend && npm run dev`

2. **Network Error:**
   - **Cause:** Devices not on same WiFi network
   - **Solution:** Ensure both computer and phone are on the same WiFi network

3. **IP Address Mismatch:**
   - **Cause:** Computer's IP address changed
   - **Solution:** 
     - Find current IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
     - Update `baseUrl` in `frontend/lib/services/api_service.dart`

4. **Firewall Blocking:**
   - **Cause:** Windows Firewall blocking port 4000
   - **Solution:** Allow port 4000 in Windows Firewall settings

---

## 4. Summary

### ✅ What's Working:
- ✅ Frontend API configuration is correct
- ✅ Backend configuration is correct (Supabase credentials set)
- ✅ Database schema is properly defined
- ✅ Signup/login code correctly stores data in both `auth.users` and `profiles` tables
- ✅ Code handles errors and logging properly

### ⚠️ What Needs Action:
- ⚠️ **Backend server needs to be started** (currently not running)
- ⚠️ Verify database tables exist in Supabase (run `schema.sql` if not done)

### Next Steps:
1. Start the backend server: `cd backend && npm run dev`
2. Test connection: Visit `http://10.137.196.199:4000/api/health` from browser/phone
3. Test signup from the Flutter app
4. Verify data in Supabase dashboard

---

## 5. Quick Verification Checklist

- [ ] Backend server is running (`npm run dev` in backend folder)
- [ ] Health endpoint accessible: `http://10.137.196.199:4000/api/health`
- [ ] Frontend can reach backend (test signup from app)
- [ ] Database tables exist (check Supabase dashboard)
- [ ] User data appears in `auth.users` table after signup
- [ ] Profile data appears in `profiles` table after signup

