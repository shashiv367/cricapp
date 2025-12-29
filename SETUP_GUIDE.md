# Cricapp Setup Guide

Complete setup instructions for both backend and frontend.

## Prerequisites

- Node.js (v16 or higher)
- Flutter SDK (latest stable)
- Supabase account with project created

---

## Backend Setup

### 1. Navigate to backend directory
```bash
cd backend
```

### 2. Install dependencies
```bash
npm install
```

### 3. Create `.env` file
Create a `.env` file in the `backend` directory with your Supabase credentials:

```env
PORT=4000

SUPABASE_URL=https://prxfvwqortyeflsuahkj.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByeGZ2d3FvcnR5ZWZsc3VhaGtqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NjUwMjE2MCwiZXhwIjoyMDgyMDc4MTYwfQ.DvXT6BUHy0MvULaJccKBsjtM0RUbEU7FOnPlM7lbJdg
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByeGZ2d3FvcnR5ZWZsc3VhaGtqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1MDIxNjAsImV4cCI6MjA4MjA3ODE2MH0.DSNQPasRPBWjgO2PsxvO7Vanyd_Grm50L_JCv3NuC_A
SUPABASE_JWT_SECRET=G7XkHlHkvShKJXluEmjMVdIkTH8LUdwpbA0v1GCJXWRe+t0oGhNdKii2mqWR2TnpkzZD7hLxtmguyAq+XzC02g==
```

### 4. Set up Supabase Database Tables

**Option A: Quick Setup (Recommended)**
- Open Supabase SQL Editor
- Copy and paste the entire contents of `backend/database/schema.sql`
- Click Run

**Option B: Manual Setup**
Run these SQL commands in your Supabase SQL Editor:

```sql
-- Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  username TEXT,
  phone TEXT,
  role TEXT CHECK (role IN ('user', 'player', 'umpire')) DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Teams table
CREATE TABLE IF NOT EXISTS teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Locations table
CREATE TABLE IF NOT EXISTS locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Matches table
CREATE TABLE IF NOT EXISTS matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_a UUID REFERENCES teams(id),
  team_b UUID REFERENCES teams(id),
  venue UUID REFERENCES locations(id),
  overs INTEGER DEFAULT 20,
  status TEXT DEFAULT 'live',
  created_by UUID REFERENCES auth.users(id),
  start_date TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Match scores table
CREATE TABLE IF NOT EXISTS match_score (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  team_a_score INTEGER DEFAULT 0,
  team_a_wkts INTEGER DEFAULT 0,
  team_a_overs DECIMAL DEFAULT 0,
  team_b_score INTEGER DEFAULT 0,
  team_b_wkts INTEGER DEFAULT 0,
  team_b_overs DECIMAL DEFAULT 0,
  target INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Match player stats table
CREATE TABLE IF NOT EXISTS match_player_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  team_id UUID REFERENCES teams(id),
  player_id UUID REFERENCES profiles(id),
  player_name TEXT,
  runs INTEGER DEFAULT 0,
  balls INTEGER DEFAULT 0,
  fours INTEGER DEFAULT 0,
  sixes INTEGER DEFAULT 0,
  wickets INTEGER DEFAULT 0,
  overs DECIMAL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_score ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_player_stats ENABLE ROW LEVEL SECURITY;

-- RLS Policies (basic - adjust as needed)
CREATE POLICY "Users can view all profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Anyone can view teams" ON teams FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create teams" ON teams FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Anyone can view locations" ON locations FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create locations" ON locations FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Anyone can view matches" ON matches FOR SELECT USING (true);
CREATE POLICY "Umpires can create matches" ON matches FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'umpire')
);

CREATE POLICY "Anyone can view match scores" ON match_score FOR SELECT USING (true);
CREATE POLICY "Umpires can update match scores" ON match_score FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'umpire')
);

CREATE POLICY "Anyone can view player stats" ON match_player_stats FOR SELECT USING (true);
CREATE POLICY "Umpires can manage player stats" ON match_player_stats FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'umpire')
);
```

### 5. Start the backend server
```bash
npm run dev
```

The backend will run on `http://localhost:4000`

---

## Frontend Setup

### 1. Navigate to frontend directory
```bash
cd frontend
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Update API Service Base URL

Edit `frontend/lib/services/api_service.dart` and update the `baseUrl`:

- **For Android Emulator**: `http://10.0.2.2:4000/api`
- **For iOS Simulator**: `http://localhost:4000/api`
- **For Physical Device**: `http://<your-computer-ip>:4000/api` (e.g., `http://192.168.1.100:4000/api`)

### 4. Run the Flutter app
```bash
flutter run --dart-define=SUPABASE_URL=https://prxfvwqortyeflsuahkj.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByeGZ2d3FvcnR5ZWZsc3VhaGtqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1MDIxNjAsImV4cCI6MjA4MjA3ODE2MH0.DSNQPasRPBWjgO2PsxvO7Vanyd_Grm50L_JCv3NuC_A
```

Or create a script/alias for easier running.

---

## Features Implemented

### ✅ Authentication & Roles
- Signup with role selection (User, Player, Umpire)
- Login with email/password
- Profile management
- Role-based access control

### ✅ Umpire Dashboard
- Create matches with team selection
- Location management (select existing or create new)
- Live score updates (runs, wickets, overs)
- Player stats management
- Auto-calculation of run rate, strike rate, economy

### ✅ Player Dashboard
- View personal stats (batting & bowling)
- Update profile (name, email, mobile)
- See aggregated statistics across all matches

### ✅ User Dashboard
- Browse all matches (like Cricbuzz)
- View live scores and scoreboards
- Filter matches by status
- Detailed match scoreboard with player stats

---

## API Documentation

See `backend/API_DOCUMENTATION.md` for complete API reference.

---

## Troubleshooting

### Backend won't start
- Check that `.env` file exists and has correct values
- Ensure port 4000 is not in use
- Verify Supabase credentials are correct

### Frontend can't connect to backend
- Check backend is running on correct port
- Verify `baseUrl` in `api_service.dart` matches your setup
- For physical devices, ensure phone and computer are on same network
- Check firewall settings

### Database errors
- Ensure all SQL tables are created in Supabase
- Check RLS policies are set up correctly
- Verify service role key has proper permissions

---

## Next Steps

1. Add more validation and error handling
2. Implement real-time updates using Supabase Realtime
3. Add image uploads for player profiles
4. Implement match scheduling and notifications
5. Add team management features
6. Enhance statistics and analytics

