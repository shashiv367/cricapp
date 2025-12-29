# Backend Deployment Guide

## Option 1: Render.com (Recommended - Easiest)

### Step 1: Prepare Your Code
1. Make sure your `backend/package.json` has a `start` script (already done ✅)
2. Your server should use `process.env.PORT` (already configured ✅)

### Step 2: Push to GitHub
```bash
# If not already done, initialize git and push
cd D:\Shashi\cricapp
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-github-repo-url>
git push -u origin main
```

### Step 3: Deploy on Render
1. Go to https://render.com
2. Sign up with GitHub
3. Click **"New +"** → **"Web Service"**
4. Connect your GitHub repository
5. Configure:
   - **Name**: `cricapp-backend`
   - **Root Directory**: `backend` (important!)
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free

6. **Add Environment Variables** (click "Advanced"):
   ```
   NODE_ENV=production
   PORT=10000
   SUPABASE_URL=your_supabase_url
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   SUPABASE_ANON_KEY=your_anon_key
   SUPABASE_JWT_SECRET=your_jwt_secret
   ```

7. Click **"Create Web Service"**
8. Wait for deployment (5-10 minutes)
9. Your backend will be available at: `https://cricapp-backend.onrender.com`

### Step 4: Update Frontend
Update `frontend/lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://cricapp-backend.onrender.com/api';
```

---

## Option 2: Railway.app

### Step 1: Push to GitHub (same as above)

### Step 2: Deploy on Railway
1. Go to https://railway.app
2. Sign up with GitHub
3. Click **"New Project"** → **"Deploy from GitHub repo"**
4. Select your repository
5. Railway will auto-detect Node.js
6. Set **Root Directory** to `backend`
7. Add environment variables (same as Render)
8. Deploy

Your backend will be at: `https://your-app-name.up.railway.app`

---

## Option 3: Fly.io

### Step 1: Install Fly CLI
```bash
# Windows (PowerShell)
iwr https://fly.io/install.ps1 -useb | iex
```

### Step 2: Login
```bash
fly auth login
```

### Step 3: Initialize
```bash
cd backend
fly launch
```

### Step 4: Deploy
```bash
fly deploy
```

---

## After Deployment

1. **Update Frontend API URL**:
   - Open `frontend/lib/services/api_service.dart`
   - Change `baseUrl` to your deployed backend URL
   - Example: `https://cricapp-backend.onrender.com/api`

2. **Test**:
   - Open your deployed backend URL + `/api/health` in browser
   - Should see: `{"status":"ok","service":"cricapp-backend",...}`

3. **Rebuild Flutter App**:
   ```bash
   cd frontend
   flutter clean
   flutter run
   ```

---

## Important Notes

- **Free tiers may spin down** after inactivity (Render spins down after 15 min)
- **First request may be slow** (cold start)
- **HTTPS is included** (no need for certificates)
- **Environment variables** are secure (not visible in code)

---

## Quick Start (Render.com)

1. Push code to GitHub
2. Go to render.com → New Web Service
3. Connect GitHub repo
4. Set Root Directory: `backend`
5. Add environment variables
6. Deploy
7. Update frontend `baseUrl` to your Render URL
8. Done! ✅



