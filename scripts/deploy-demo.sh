#!/bin/bash

# SuiteCRM Banking Demo - Quick Deploy Script
# Deploys demo to Railway with one command

set -e

echo "🚀 SuiteCRM Banking Demo Deployment"
echo "===================================="
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "Installing Railway CLI..."
    npm install -g @railway/cli
fi

# Check if logged in
if ! railway whoami &> /dev/null; then
    echo "Please login to Railway:"
    railway login
fi

# Create new project or use existing
echo ""
echo "Setting up Railway project..."
read -p "Project name (suitecrm-banking-demo): " project_name
project_name=${project_name:-suitecrm-banking-demo}

# Initialize project
railway init -n "$project_name"

# Add MySQL database
echo "Adding MySQL database..."
railway add mysql

# Set environment variables
echo "Configuring environment..."
cat > .env.railway << EOF
DEMO_MODE=true
AUTO_RESET=hourly
SHOW_DEMO_BANNER=true
ADMIN_USER=admin
ADMIN_PASSWORD=demo123
SITE_URL=\${{RAILWAY_STATIC_URL}}
DATABASE_URL=\${{MYSQL_URL}}
COBOL_API_URL=http://cobol-api.railway.internal:3000
EOF

railway env:set $(cat .env.railway | xargs)

# Deploy
echo ""
echo "Deploying to Railway..."
railway up

# Get deployment URL
echo ""
echo "Waiting for deployment..."
sleep 10
deployment_url=$(railway open --url)

echo ""
echo "✅ Deployment Complete!"
echo "======================="
echo ""
echo "🌐 Demo URL: $deployment_url"
echo "👤 Login: admin / demo123"
echo ""
echo "📊 Railway Dashboard: https://railway.app/dashboard"
echo ""
echo "Next steps:"
echo "1. Visit your demo: $deployment_url"
echo "2. Custom domain: railway domain"
echo "3. View logs: railway logs"
echo "4. Open shell: railway shell"
echo ""
echo "To add this to your GitHub repo:"
echo "1. Add deploy button to README:"
echo '   [![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https://github.com/yourusername/suitecrm-banking)'
echo ""

# Create GitHub deploy button config
cat > railway.toml << EOF
[deploy]
repository = "https://github.com/yourusername/suitecrm-banking"
branch = "main"

[[services]]
name = "suitecrm"
dockerfile = "Dockerfile"

[[services]]  
name = "cobol-api"
dockerfile = "Dockerfile.cobol"

[[databases]]
name = "mysql"
EOF

echo "Deploy configuration saved to railway.toml"
echo "Commit this file to enable one-click deploys from GitHub"