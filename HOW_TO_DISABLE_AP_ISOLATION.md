# How to Disable AP Isolation / Client Isolation in Router

## What is AP Isolation?

**AP Isolation** (Access Point Isolation) or **Client Isolation** is a security feature that prevents devices on the same WiFi network from communicating with each other. This is useful for public WiFi, but it blocks your phone from connecting to your backend server!

---

## Step-by-Step Guide

### Step 1: Find Your Router's IP Address

**On Windows:**
1. Open Command Prompt (cmd)
2. Type: `ipconfig`
3. Look for **"Default Gateway"** - this is your router's IP address
   - Usually: `192.168.1.1` or `192.168.0.1` or `192.168.1.254`

**Example output:**
```
Default Gateway . . . . . . . . . : 192.168.1.1
```

---

### Step 2: Access Router Admin Panel

1. **Open a web browser** (Chrome, Edge, Firefox)
2. **Type the router IP address** in the address bar
   - Example: `http://192.168.1.1` or `http://192.168.0.1`
3. **Press Enter**

---

### Step 3: Login to Router

**Common default credentials:**
- Username: `admin` / Password: `admin`
- Username: `admin` / Password: `password`
- Username: `admin` / Password: (blank/empty)
- Username: `admin` / Password: `1234`

**If default doesn't work:**
- Check the router's sticker/label (usually on the back/bottom)
- Look for "Default Username" and "Default Password"
- Or check router manual

**Note:** If you changed the password, use your custom password.

---

### Step 4: Find AP Isolation Setting

The location varies by router brand. Here are common locations:

#### **For Most Routers (TP-Link, D-Link, Netgear, etc.):**

**Option A: Wireless Settings**
1. Look for **"Wireless"** or **"WiFi"** or **"Wireless Settings"** menu
2. Click on it
3. Look for **"Advanced"** or **"Advanced Settings"** tab
4. Find **"AP Isolation"**, **"Client Isolation"**, or **"AP Client Isolation"**
5. Make sure it's **DISABLED** or **OFF**

**Option B: Advanced Settings**
1. Look for **"Advanced"** or **"Advanced Settings"** menu
2. Navigate to **"Wireless"** or **"Wireless Settings"**
3. Find **"AP Isolation"** or **"Client Isolation"**
4. Set to **DISABLED** or **OFF**

**Option C: Security Settings**
1. Look for **"Security"** or **"Wireless Security"** menu
2. Scroll down to find **"AP Isolation"** or **"Client Isolation"**
3. Disable it

---

#### **For Specific Router Brands:**

##### **TP-Link Routers:**
1. Login → **"Advanced"** → **"Wireless"** → **"Wireless Settings"**
2. Find **"AP Isolation"** checkbox
3. **Uncheck** it (disable)

##### **Netgear Routers:**
1. Login → **"Advanced"** → **"Wireless Settings"**
2. Look for **"AP Isolation"** or **"Enable AP Isolation"**
3. Set to **OFF** or uncheck

##### **D-Link Routers:**
1. Login → **"Setup"** → **"Wireless Settings"** → **"Advanced"**
2. Find **"AP Isolation"** or **"Client Isolation"**
3. Set to **Disabled**

##### **Linksys Routers:**
1. Login → **"Wireless"** → **"Wireless Security"**
2. Find **"AP Isolation"**
3. Set to **Disabled**

##### **ASUS Routers:**
1. Login → **"Wireless"** → **"Professional"** tab
2. Find **"AP Isolation"**
3. Set to **Disabled**

##### **Huawei Routers:**
1. Login → **"Advanced"** → **"Wi-Fi Settings"** → **"More Wi-Fi Features"**
2. Find **"AP Isolation"** or **"Station Isolation"**
3. Set to **Off**

---

### Step 5: Save Settings

1. **Click "Save"** or **"Apply"** button
2. Router may restart (wait 1-2 minutes)
3. Your devices may disconnect from WiFi temporarily
4. Reconnect to WiFi if needed

---

### Step 6: Verify

After disabling AP Isolation:

1. **Test from phone browser:**
   - Go to: `http://192.168.1.4:4000/api/health`
   - Should now show JSON response

2. **Test from Flutter app:**
   - Try signup/login again
   - Should work now!

---

## Can't Find the Setting?

### Alternative 1: Search Router Interface

Most router admin panels have a **search function**:
1. Look for a **search box** or **magnifying glass icon**
2. Type: `isolation` or `AP isolation` or `client isolation`
3. It should highlight or take you to the setting

### Alternative 2: Check Router Manual

1. Look up your router model online
2. Search: `[Your Router Model] disable AP isolation`
3. Find specific instructions for your model

### Alternative 3: Router Mobile App

Many modern routers have mobile apps:
- TP-Link Tether
- Netgear Nighthawk
- D-Link Wi-Fi

Check the app for AP Isolation setting.

---

## Common Router Admin URLs

If you don't know your router IP, try these common ones:

- `http://192.168.1.1`
- `http://192.168.0.1`
- `http://192.168.1.254`
- `http://10.0.0.1`
- `http://192.168.2.1`

Or find it with `ipconfig` → "Default Gateway"

---

## Quick Reference: Setting Names to Look For

Different routers use different names:
- **AP Isolation**
- **Client Isolation**
- **AP Client Isolation**
- **Station Isolation**
- **Wireless Isolation**
- **Client-to-Client Blocking**
- **Inter-Station Blocking**

They all mean the same thing - **disable it!**

---

## Troubleshooting

### "I can't login to router"
- Try default credentials from router sticker
- Reset router if needed (hold reset button 10 seconds)
- Use default credentials after reset

### "I can't find the setting"
- Look in Wireless → Advanced Settings
- Check router manual online
- Try searching the admin panel

### "Setting is already disabled but still not working"
- Restart router (unplug 30 seconds, plug back in)
- Restart both phone and computer
- Try the connection test again

---

## Alternative: Use Mobile Hotspot (Quick Test)

If you can't access router settings or want to test quickly:

1. **Enable mobile hotspot** on your phone
2. **Connect computer** to phone's hotspot
3. **Get computer's IP** on hotspot: `ipconfig` (look for hotspot adapter IP)
4. **Update frontend** IP address
5. **Test connection**

This bypasses router AP Isolation completely for testing purposes.

---

## Summary

**Quick Steps:**
1. Find router IP: `ipconfig` → "Default Gateway"
2. Open browser: Go to router IP (e.g., `http://192.168.1.1`)
3. Login: Use default credentials (usually `admin/admin`)
4. Find setting: Wireless → Advanced → **AP Isolation**
5. Disable: Set to **OFF** or **Disabled**
6. Save: Click "Save" or "Apply"
7. Test: Try `http://192.168.1.4:4000/api/health` from phone browser

**If you can't find it:** Use mobile hotspot as a workaround, or search online for your specific router model + "disable AP isolation".

