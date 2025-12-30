# Profile Picture and Team Name Setup Guide

This guide explains how to set up profile picture uploads and team name functionality for the player dashboard.

## Database Setup

1. **Run the SQL migration:**
   - Open your Supabase SQL Editor
   - Run the SQL from `backend/database/add_profile_fields.sql`:
   ```sql
   ALTER TABLE profiles 
   ADD COLUMN IF NOT EXISTS profile_picture_url TEXT,
   ADD COLUMN IF NOT EXISTS team_name TEXT;
   ```

2. **Create Supabase Storage Bucket:**
   - Go to Supabase Dashboard → Storage
   - Create a new bucket named `avatars`
   - Set it to **Public** (or configure RLS policies for authenticated users)
   - Enable file uploads

3. **Storage Policies (if using RLS):**
   - Allow authenticated users to upload: `INSERT` policy for `avatars` bucket
   - Allow public read: `SELECT` policy for `avatars` bucket

## Frontend Setup

1. **Install dependencies:**
   ```bash
   cd frontend
   flutter pub get.
   ```

2. **Permissions (Android):**
   Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.CAMERA"/>
   ```

   For Android 13+:
   ```xml
   <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
   ```

3. **Permissions (iOS):**
   Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photo library to upload profile pictures</string>
   <key>NSCameraUsageDescription</key>
   <string>We need access to your camera to take profile pictures</string>
   ```

## Features Implemented

### Profile Picture
- ✅ Click on profile picture to upload new image
- ✅ Images stored in Supabase Storage `avatars` bucket
- ✅ Profile picture URL stored in database
- ✅ Display uploaded image or fallback to initials
- ✅ Loading indicator during upload

### Team Name
- ✅ Input field in Profile tab
- ✅ Stored in database `profiles.team_name` field
- ✅ Displayed in dashboard header
- ✅ Can be edited and saved

## Usage

1. **Upload Profile Picture:**
   - Navigate to Player Dashboard
   - Tap on the profile picture in the header
   - Select an image from gallery
   - Image uploads automatically

2. **Set Team Name:**
   - Go to Profile tab
   - Enter team name in the "Team Name" field
   - Click "Save Changes"
   - Team name appears in the dashboard header

## API Changes

The backend API endpoint `PUT /api/auth/profile` now accepts:
- `profilePictureUrl` (optional): URL of the uploaded profile picture
- `teamName` (optional): Player's team name

## Notes

- Profile pictures are automatically compressed (max 512x512, 85% quality)
- Image format: JPEG
- File naming: `{userId}_{timestamp}.jpg`
- Old profile pictures are overwritten when a new one is uploaded (upsert mode)

