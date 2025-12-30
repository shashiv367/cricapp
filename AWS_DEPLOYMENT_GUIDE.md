# AWS Free Tier Deployment Guide

## Option 1: AWS Elastic Beanstalk (Recommended - Easiest)

### Prerequisites
1. AWS Account (sign up at https://aws.amazon.com)
2. AWS CLI installed (optional, but recommended)
3. Your backend code ready

### Step 1: Prepare Your Backend

1. **Create a `.ebignore` file** in the `backend` folder:
```
node_modules/
.env
*.log
.DS_Store
```

2. **Create `Procfile`** in the `backend` folder:
```
web: node src/server.js
```

3. **Update `package.json`** to ensure start script exists (already done ✅):
```json
"scripts": {
  "start": "node src/server.js"
}
```

### Step 2: Install EB CLI (Optional but Recommended)

```bash
# Windows (using pip)
pip install awsebcli

# Or download installer from AWS
```

### Step 3: Deploy via AWS Console (Easiest Method)

1. **Go to AWS Console**: https://console.aws.amazon.com
2. **Navigate to Elastic Beanstalk**
3. **Click "Create Application"**
4. **Configure**:
   - Application name: `cricapp-backend`
   - Platform: `Node.js`
   - Platform version: Latest
   - Application code: Upload your code
5. **Upload your backend folder** (zip it first)
6. **Configure environment variables**:
   ```
   NODE_ENV=production
   PORT=8080
   SUPABASE_URL=your_supabase_url
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   SUPABASE_ANON_KEY=your_anon_key
   SUPABASE_JWT_SECRET=your_jwt_secret
   ```
7. **Create environment**
8. **Wait for deployment** (5-10 minutes)
9. **Get your URL**: `http://your-app.region.elasticbeanstalk.com`

### Step 4: Update Frontend

Update `frontend/lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-app.region.elasticbeanstalk.com/api';
```

---

## Option 2: AWS EC2 (More Control)

### Step 1: Launch EC2 Instance

1. Go to EC2 Console
2. Launch Instance
3. Choose: **Amazon Linux 2023** (free tier eligible)
4. Instance type: **t2.micro** (free tier)
5. Configure security group: Allow HTTP (port 80) and Custom TCP (port 4000)
6. Launch

### Step 2: Connect to EC2

```bash
# SSH into your instance
ssh -i your-key.pem ec2-user@your-ec2-ip
```

### Step 3: Install Node.js

```bash
# On EC2 instance
sudo dnf install -y nodejs npm
node --version
npm --version
```

### Step 4: Deploy Your Code

```bash
# Clone your repo or upload files
git clone your-repo-url
cd cricapp/backend

# Install dependencies
npm install

# Create .env file
nano .env
# Add your environment variables

# Install PM2 for process management
sudo npm install -g pm2

# Start your app
pm2 start src/server.js --name cricapp-backend
pm2 save
pm2 startup
```

### Step 5: Configure Security Group

- Allow inbound: Port 4000 from anywhere (0.0.0.0/0)
- Or use a reverse proxy (nginx) on port 80

---

## Option 3: AWS Lambda + API Gateway (Serverless)

**Note**: Requires code changes to work with Lambda

### Pros:
- Truly free (1M requests/month)
- Auto-scaling
- Pay only for what you use

### Cons:
- Need to refactor code for serverless
- Cold starts can be slow
- More complex setup

---

## Free Tier Limits

### Elastic Beanstalk:
- ✅ 750 hours/month free (12 months)
- ✅ 30 GB storage free
- ✅ 2 GB data transfer free

### EC2:
- ✅ 750 hours/month of t2.micro (12 months)
- ✅ 30 GB EBS storage free
- ✅ 2 GB data transfer free

### Lambda:
- ✅ 1 million requests/month free (forever)
- ✅ 400,000 GB-seconds compute time free

---

## Quick Start (Elastic Beanstalk - Recommended)

1. **Zip your backend folder**:
   ```bash
   cd backend
   # Exclude node_modules and .env
   zip -r ../backend-deploy.zip . -x "node_modules/*" ".env" "*.log"
   ```

2. **Go to AWS Console → Elastic Beanstalk**

3. **Create new application**:
   - Name: `cricapp-backend`
   - Platform: Node.js
   - Upload: `backend-deploy.zip`

4. **Add environment variables** (from your `.env` file)

5. **Deploy**

6. **Get your URL** and update frontend

---

## Important Notes

1. **Free tier is for 12 months** (new AWS accounts)
2. **After 12 months**, you'll pay for usage (but EC2 t2.micro is ~$8/month)
3. **Always set up billing alerts** to avoid unexpected charges
4. **Use environment variables** for secrets (never commit `.env`)
5. **HTTPS**: Elastic Beanstalk provides HTTPS automatically
6. **Custom domain**: Can be added later

---

## Cost After Free Tier

- **EC2 t2.micro**: ~$8-10/month
- **Elastic Beanstalk**: Free (only pay for EC2)
- **Lambda**: Pay per request (very cheap, ~$0.20 per million requests)

---

## Recommendation

**Start with Elastic Beanstalk** - it's the easiest and handles:
- Auto-scaling
- Load balancing
- Health monitoring
- HTTPS certificates
- Easy updates

Want me to help you set it up step by step?




