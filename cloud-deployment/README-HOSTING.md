# Hosting SuiteCRM Banking Edition Demo

## 🚀 Best Options for Demo Hosting

### 1. **Railway.app** (Recommended for Demos)
**Cost**: ~$5-20/month | **Setup Time**: 10 minutes

```bash
# One-click deploy with Railway
railway login
railway init
railway up

# Or use the deploy button in your README:
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https://github.com/yourusername/suitecrm-banking)
```

**Pros**: 
- One-click deploys
- Automatic SSL
- Built-in database
- Great for demos
- Easy custom domains

### 2. **Render.com** (Best Free Tier)
**Cost**: Free tier available | **Setup Time**: 15 minutes

Create `render.yaml`:
```yaml
services:
  - type: web
    name: suitecrm-banking
    env: docker
    dockerfilePath: ./Dockerfile.suitecrm
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: suitecrm-db
          property: connectionString
    
  - type: web
    name: cobol-api
    env: docker
    dockerfilePath: ./Dockerfile.cobol
    
databases:
  - name: suitecrm-db
    plan: free
```

### 3. **Fly.io** (Best Performance)
**Cost**: ~$5-10/month | **Setup Time**: 20 minutes

```bash
# Install flyctl and deploy
brew install flyctl
fly launch
fly deploy
```

### 4. **DigitalOcean App Platform**
**Cost**: $5-10/month | **Setup Time**: 15 minutes

**Deploy Button for README**:
```markdown
[![Deploy to DO](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/yourusername/suitecrm-banking)
```

### 5. **Heroku** (Most Popular)
**Cost**: $5-7/month | **Setup Time**: 20 minutes

Create `heroku.yml`:
```yaml
build:
  docker:
    web: Dockerfile.suitecrm
    worker: Dockerfile.cobol
run:
  web: apache2-foreground
  worker: node server.js
```

## 🎯 Quick Demo Setup (Using Railway)

### Step 1: Prepare Your Repository
```bash
cd suitecrm-banking-distribution

# Create deployment config
cat > railway.json << 'EOF'
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile.suitecrm"
  },
  "deploy": {
    "numReplicas": 1,
    "healthcheckPath": "/",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 3
  }
}
EOF

# Create demo-specific docker-compose
cat > docker-compose.demo.yml << 'EOF'
version: '3.8'
services:
  suitecrm:
    build: .
    environment:
      - DEMO_MODE=true
      - AUTO_LOGIN=true
      - RESET_INTERVAL=hourly
    ports:
      - "80:80"
EOF
```

### Step 2: Add Demo Features
```php
// Create demo-mode.php for auto-reset
<?php
// Auto-login for demo
if (getenv('DEMO_MODE') === 'true') {
    // Auto-login as demo user
    $_SESSION['authenticated_user_id'] = 'demo_user';
    
    // Reset data every hour
    if (shouldResetDemo()) {
        resetDemoData();
    }
    
    // Show demo banner
    echo '<div class="demo-banner">
        This is a demo instance. Data resets hourly.
        <a href="/demo-guide">View Demo Guide</a>
    </div>';
}
```

### Step 3: Deploy to Railway
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and initialize
railway login
railway init

# Deploy
railway up

# Get your URL
railway open
```

## 💡 Demo-Specific Features to Add

### 1. Guided Tour
```javascript
// Add to your demo
const tour = new Shepherd.Tour({
  useModalOverlay: true,
  defaultStepOptions: {
    cancelIcon: { enabled: true }
  }
});

tour.addStep({
  title: 'Welcome to SuiteCRM Banking',
  text: 'This demo shows COBOL integration for banks',
  attachTo: { element: '.navbar', on: 'bottom' },
  buttons: [{ text: 'Start Tour', action: tour.next }]
});
```

### 2. Sample Data Reset
```bash
#!/bin/bash
# reset-demo.sh - Run via cron
mysql -u root -p$DB_PASS suitecrm < demo-data.sql
redis-cli FLUSHALL
echo "Demo reset at $(date)" >> /var/log/demo-reset.log
```

### 3. Demo Credentials Display
```html
<!-- Add to login page -->
<div class="demo-credentials">
  <h3>Demo Accounts</h3>
  <ul>
    <li>Bank Manager: manager/demo123</li>
    <li>Loan Officer: loan/demo123</li>
    <li>Teller: teller/demo123</li>
  </ul>
  <button onclick="autoFillCredentials('manager')">
    Login as Manager
  </button>
</div>
```

## 🔧 One-Click Deploy Buttons

Add these to your README for instant deployment:

```markdown
## Try the Demo

Deploy your own instance:

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https://github.com/yourusername/suitecrm-banking)

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/yourusername/suitecrm-banking)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/yourusername/suitecrm-banking)

[![Deploy to DO](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/yourusername/suitecrm-banking)
```

## 📊 Recommended Demo Configuration

### For Best Demo Experience:
1. **Use Railway or Render** - Easiest setup
2. **Enable auto-login** - Remove friction
3. **Add guided tour** - Help users explore
4. **Reset hourly** - Keep data clean
5. **Pre-load sample data** - Show real scenarios

### Resource Requirements:
- **Minimum**: 512MB RAM, 1 CPU
- **Recommended**: 1GB RAM, 1 CPU
- **Database**: 1GB storage
- **Bandwidth**: ~10GB/month for demos

## 🎪 Demo Script Ideas

### Banking Scenarios to Showcase:
1. **Loan Application Process**
   - Customer applies online
   - COBOL calculates payment
   - Manager approves in CRM
   
2. **Account Synchronization**
   - View mainframe account
   - Update in CRM
   - See real-time sync

3. **Batch Report Generation**
   - Schedule regulatory report
   - COBOL processes data
   - Download formatted output

## 🚀 Quick Start with Railway (Complete Steps)

```bash
# 1. Fork the repository
# 2. Add these files to your fork:

# app.json (for Heroku-style deploys)
{
  "name": "SuiteCRM Banking Demo",
  "description": "CRM with COBOL integration for banks",
  "repository": "https://github.com/yourusername/suitecrm-banking",
  "keywords": ["crm", "banking", "cobol"],
  "stack": "container",
  "env": {
    "DEMO_MODE": {
      "description": "Enable demo mode",
      "value": "true"
    }
  }
}

# 3. Push to GitHub
git add .
git commit -m "Add cloud deployment configs"
git push

# 4. Deploy via Railway dashboard
# - Connect GitHub repo
# - Deploy
# - Add custom domain (optional)
```

## 💰 Cost Comparison

| Platform | Free Tier | Paid (Demo) | Paid (Production) |
|----------|-----------|-------------|-------------------|
| Railway | No | $5-20/mo | $20-100/mo |
| Render | Yes (limited) | $7-25/mo | $25-100/mo |
| Fly.io | Yes ($5 credit) | $5-15/mo | $15-50/mo |
| DigitalOcean | No | $5-20/mo | $20-100/mo |
| Heroku | No | $5-25/mo | $25-100/mo |

## 🎯 My Recommendation

For a public demo of SuiteCRM Banking:

1. **Use Railway** for the quickest setup
2. **Add demo mode** with auto-reset
3. **Include guided tour** for first-time users
4. **Pre-populate** with banking scenarios
5. **Add "Deploy Your Own" buttons** to README

This gives potential users a zero-friction way to try your banking CRM while making it easy for them to deploy their own instance when ready.