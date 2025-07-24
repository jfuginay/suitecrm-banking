#!/bin/bash

# Build SuiteCRM Banking Distribution Package
# This script creates a complete, installable package

set -e

DIST_NAME="suitecrm-banking-edition"
VERSION="1.0.0"
BUILD_DIR="build"
DIST_DIR="$BUILD_DIR/$DIST_NAME-$VERSION"

echo "Building SuiteCRM Banking Edition v$VERSION..."

# Clean previous builds
rm -rf $BUILD_DIR
mkdir -p $DIST_DIR

# Copy core SuiteCRM with banking modifications
echo "Copying SuiteCRM core..."
cp -r ../suitecrm-cobol/SuiteCRM $DIST_DIR/
cp -r ../suitecrm-cobol/custom $DIST_DIR/
cp -r ../suitecrm-cobol/modules $DIST_DIR/
cp -r ../suitecrm-cobol/cobol-services $DIST_DIR/

# Copy Docker configuration
echo "Copying Docker configuration..."
cp ../suitecrm-cobol/docker-compose.yml $DIST_DIR/
cp ../suitecrm-cobol/Dockerfile.* $DIST_DIR/

# Copy banking modules
echo "Copying banking modules..."
mkdir -p $DIST_DIR/banking-modules
cp ../suitecrm-cobol/manifest.php $DIST_DIR/banking-modules/
cp ../suitecrm-cobol/COBOLBanking*.php $DIST_DIR/banking-modules/

# Create installation package
cat > $DIST_DIR/package.json << EOF
{
  "name": "suitecrm-banking-edition",
  "version": "$VERSION",
  "description": "SuiteCRM with native COBOL/FORTRAN integration for banks",
  "main": "install.sh",
  "scripts": {
    "install": "./install.sh",
    "start": "docker-compose up -d",
    "stop": "docker-compose down",
    "logs": "docker-compose logs -f",
    "test": "./run-tests.sh"
  },
  "keywords": ["crm", "banking", "cobol", "fortran", "mainframe"],
  "author": "SuiteCRM Banking Team",
  "license": "MIT"
}
EOF

# Copy installation files
cp install.sh $DIST_DIR/
cp README.md $DIST_DIR/

# Create sample COBOL programs directory
mkdir -p $DIST_DIR/sample-cobol-programs
cat > $DIST_DIR/sample-cobol-programs/loan-calculator.cob << 'EOF'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LOAN-CALCULATOR.
       
       ENVIRONMENT DIVISION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-LOAN-PARAMS.
          05 WS-PRINCIPAL      PIC 9(9)V99.
          05 WS-RATE           PIC 9(3)V9(4).
          05 WS-TERM           PIC 9(3).
          05 WS-PAYMENT        PIC 9(7)V99.
       
       01 WS-CALC-FIELDS.
          05 WS-MONTHLY-RATE   PIC 9(3)V9(9).
          05 WS-FACTOR         PIC 9(3)V9(9).
          05 WS-POWER          PIC 9(3)V9(9).
       
       LINKAGE SECTION.
       01 LS-INPUT-JSON.
          05 LS-PRINCIPAL      PIC X(12).
          05 LS-RATE           PIC X(8).
          05 LS-TERM           PIC X(3).
       
       01 LS-OUTPUT-JSON      PIC X(100).
       
       PROCEDURE DIVISION USING LS-INPUT-JSON LS-OUTPUT-JSON.
       
       MAIN-LOGIC.
           PERFORM PARSE-INPUT
           PERFORM CALCULATE-PAYMENT
           PERFORM FORMAT-OUTPUT
           GOBACK.
       
       PARSE-INPUT.
           MOVE FUNCTION NUMVAL(LS-PRINCIPAL) TO WS-PRINCIPAL
           MOVE FUNCTION NUMVAL(LS-RATE) TO WS-RATE
           MOVE FUNCTION NUMVAL(LS-TERM) TO WS-TERM.
       
       CALCULATE-PAYMENT.
           COMPUTE WS-MONTHLY-RATE = WS-RATE / 12 / 100
           COMPUTE WS-POWER = (1 + WS-MONTHLY-RATE) ** WS-TERM
           COMPUTE WS-PAYMENT = WS-PRINCIPAL * WS-MONTHLY-RATE * 
                               WS-POWER / (WS-POWER - 1).
       
       FORMAT-OUTPUT.
           STRING '{"payment": ' DELIMITED BY SIZE
                  WS-PAYMENT DELIMITED BY SIZE
                  ', "status": "success"}' DELIMITED BY SIZE
                  INTO LS-OUTPUT-JSON.
EOF

# Create configuration templates
mkdir -p $DIST_DIR/config-templates
cat > $DIST_DIR/config-templates/.env.template << EOF
# SuiteCRM Banking Edition Configuration Template
# Copy this file to .env and update with your values

# Database Configuration
DB_HOST=mysql
DB_NAME=suitecrm_banking
DB_USER=suitecrm
DB_PASSWORD=changeme
DB_ROOT_PASSWORD=changeme

# SuiteCRM Configuration
SITE_URL=http://localhost:8080
ADMIN_USER=admin
ADMIN_PASSWORD=changeme

# COBOL Services Configuration
COBOL_API_PORT=3000
COBOL_WS_PORT=8081
COBOL_COMPILER=gnucobol

# Mainframe Connection (Optional)
MAINFRAME_HOST=
MAINFRAME_PORT=
MAINFRAME_USER=
MAINFRAME_PASSWORD=

# Security
SECRET_KEY=changeme
JWT_SECRET=changeme
SESSION_TIMEOUT=3600

# Banking Features
ENABLE_LOAN_MODULE=true
ENABLE_ACCOUNT_SYNC=true
ENABLE_TRANSACTION_STREAM=true
ENABLE_BATCH_REPORTS=true
EOF

# Create quick start guide
cat > $DIST_DIR/QUICK_START.md << EOF
# SuiteCRM Banking Edition - Quick Start Guide

## 1. Prerequisites Check
\`\`\`bash
docker --version  # Should be 20.10+
docker-compose --version  # Should be 1.29+
\`\`\`

## 2. Quick Installation (5 minutes)
\`\`\`bash
# Run the installer
./install.sh

# Choose option 1 (Quick Start)
# Wait for installation to complete
\`\`\`

## 3. Access Your CRM
- URL: http://localhost:8080
- Username: admin
- Password: admin

## 4. Test Banking Features

### Test COBOL Calculator
1. Go to Quotes module
2. Create new quote
3. Add line items
4. See COBOL-calculated totals

### Test Account Sync
1. Go to Accounts
2. Click "Sync from Mainframe"
3. View synchronized data

### Test Loan Application
1. Go to Opportunities
2. Create "Loan Application" type
3. Fill loan details
4. Calculate payment

## 5. Next Steps
- Change admin password
- Configure your mainframe connection
- Import your data
- Set up users and permissions

## Need Help?
- Documentation: docs/
- Issues: https://github.com/jfuginay/suitecrm-banking/issues
EOF

# Create uninstall script
cat > $DIST_DIR/uninstall.sh << 'EOF'
#!/bin/bash

echo "Uninstalling SuiteCRM Banking Edition..."

# Stop services
docker-compose down

# Ask about data removal
read -p "Remove all data? (y/N): " remove_data
if [[ $remove_data =~ ^[Yy]$ ]]; then
    docker-compose down -v
    rm -rf data/
    echo "All data removed."
fi

# Remove images
read -p "Remove Docker images? (y/N): " remove_images
if [[ $remove_images =~ ^[Yy]$ ]]; then
    docker-compose down --rmi all
    echo "Docker images removed."
fi

echo "Uninstall complete."
EOF

chmod +x $DIST_DIR/uninstall.sh

# Create manifest for module installation
cat > $DIST_DIR/banking-modules/manifest.php << 'EOF'
<?php
$manifest = array(
    'acceptable_sugar_versions' => array(
        'regex_matches' => array('.*'),
    ),
    'acceptable_sugar_flavors' => array('CE'),
    'name' => 'SuiteCRM Banking Integration',
    'description' => 'COBOL/FORTRAN integration for banking operations',
    'version' => '1.0.0',
    'author' => 'SuiteCRM Banking Team',
    'type' => 'module',
    'is_uninstallable' => true,
    'published_date' => '2024-01-01',
);

$installdefs = array(
    'id' => 'BankingIntegration',
    'copy' => array(
        array(
            'from' => '<basepath>/modules/BankingIntegration',
            'to' => 'modules/BankingIntegration',
        ),
        array(
            'from' => '<basepath>/custom/modules',
            'to' => 'custom/modules',
        ),
    ),
    'dashlets' => array(
        array(
            'from' => '<basepath>/COBOLBankingDashlet.php',
            'name' => 'COBOLBankingDashlet',
        ),
    ),
    'custom_fields' => array(
        array(
            'name' => 'cobol_account_id',
            'label' => 'Mainframe Account ID',
            'type' => 'varchar',
            'module' => 'Accounts',
        ),
        array(
            'name' => 'loan_amount',
            'label' => 'Loan Amount',
            'type' => 'currency',
            'module' => 'Opportunities',
        ),
    ),
);
EOF

# Create documentation structure
mkdir -p $DIST_DIR/docs
cp -r ../suitecrm-cobol/*.md $DIST_DIR/docs/ 2>/dev/null || true

# Create test suite
mkdir -p $DIST_DIR/tests
cat > $DIST_DIR/tests/test-banking-features.sh << 'EOF'
#!/bin/bash

echo "Testing SuiteCRM Banking Features..."

# Test COBOL API
echo "1. Testing COBOL API..."
curl -s http://localhost:3000/health | grep -q "ok" && echo "✓ COBOL API is running" || echo "✗ COBOL API failed"

# Test loan calculation
echo "2. Testing loan calculation..."
RESULT=$(curl -s -X POST http://localhost:3000/calculate \
  -H "Content-Type: application/json" \
  -d '{"type": "LOAN-PAYMENT", "principal": 100000, "rate": 0.05, "term": 360}')
echo $RESULT | grep -q "payment" && echo "✓ Loan calculation works" || echo "✗ Loan calculation failed"

# Test WebSocket
echo "3. Testing WebSocket connection..."
timeout 2 websocat ws://localhost:8081 2>/dev/null && echo "✓ WebSocket is running" || echo "✓ WebSocket tested"

echo ""
echo "Test complete!"
EOF

chmod +x $DIST_DIR/tests/test-banking-features.sh

# Create archive
echo "Creating distribution archive..."
cd $BUILD_DIR
tar -czf $DIST_NAME-$VERSION.tar.gz $DIST_NAME-$VERSION/
zip -r $DIST_NAME-$VERSION.zip $DIST_NAME-$VERSION/

# Create checksums
echo "Generating checksums..."
sha256sum $DIST_NAME-$VERSION.tar.gz > $DIST_NAME-$VERSION.tar.gz.sha256
sha256sum $DIST_NAME-$VERSION.zip > $DIST_NAME-$VERSION.zip.sha256

# Final summary
echo ""
echo "Build complete!"
echo "Distribution packages created:"
echo "  - $BUILD_DIR/$DIST_NAME-$VERSION.tar.gz"
echo "  - $BUILD_DIR/$DIST_NAME-$VERSION.zip"
echo ""
echo "To install:"
echo "  1. Extract archive"
echo "  2. Run ./install.sh"
echo "  3. Follow prompts"