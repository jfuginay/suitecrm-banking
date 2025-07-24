#!/bin/bash

# SuiteCRM Banking Edition - Easy Installation Script
# This script sets up SuiteCRM with COBOL/FORTRAN banking integration

set -e

echo "=========================================="
echo "SuiteCRM Banking Edition Installer"
echo "=========================================="
echo ""

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo "ERROR: Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo "ERROR: Docker Compose is not installed. Please install Docker Compose first."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    echo "✓ Prerequisites check passed"
    echo ""
}

# Installation options
installation_menu() {
    echo "Select installation type:"
    echo "1) Quick Start (Docker) - Recommended"
    echo "2) Production Setup (with SSL)"
    echo "3) Development Setup (with hot reload)"
    echo "4) Custom Installation"
    echo ""
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1) quick_start_install ;;
        2) production_install ;;
        3) development_install ;;
        4) custom_install ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
}

# Quick start installation
quick_start_install() {
    echo ""
    echo "Starting Quick Start installation..."
    echo ""
    
    # Clone or copy the repository
    if [ ! -d "suitecrm-cobol" ]; then
        echo "Downloading SuiteCRM Banking Edition..."
        git clone https://github.com/jfuginay/suitecrm-cobol-banking.git suitecrm-cobol || {
            # Fallback to local copy if git fails
            echo "Git clone failed, using local copy..."
            cp -r ../suitecrm-cobol .
        }
    fi
    
    cd suitecrm-cobol
    
    # Create necessary directories
    mkdir -p data/mysql
    mkdir -p data/suitecrm
    mkdir -p logs
    
    # Set permissions
    echo "Setting permissions..."
    chmod -R 777 data logs
    
    # Create environment file
    create_env_file
    
    # Start services
    echo "Starting services..."
    docker-compose up -d
    
    # Wait for services to be ready
    echo "Waiting for services to start..."
    sleep 30
    
    # Run initial setup
    echo "Running initial setup..."
    docker-compose exec suitecrm php -r "include 'install.php';" || true
    
    echo ""
    echo "✓ Installation complete!"
    echo ""
    display_access_info
}

# Production installation
production_install() {
    echo ""
    echo "Starting Production installation..."
    echo ""
    
    # Get domain name
    read -p "Enter your domain name (e.g., crm.yourbank.com): " domain
    
    # Get SSL certificate paths
    read -p "Enter path to SSL certificate: " ssl_cert
    read -p "Enter path to SSL key: " ssl_key
    
    # Clone repository
    if [ ! -d "suitecrm-cobol" ]; then
        echo "Downloading SuiteCRM Banking Edition..."
        git clone https://github.com/jfuginay/suitecrm-cobol-banking.git suitecrm-cobol
    fi
    
    cd suitecrm-cobol
    
    # Create production docker-compose file
    create_production_compose "$domain" "$ssl_cert" "$ssl_key"
    
    # Create environment file
    create_env_file "production"
    
    # Start services
    echo "Starting services..."
    docker-compose -f docker-compose.prod.yml up -d
    
    echo ""
    echo "✓ Production installation complete!"
    echo ""
    echo "Access your CRM at: https://$domain"
}

# Development installation
development_install() {
    echo ""
    echo "Starting Development installation..."
    echo ""
    
    # Clone repository
    if [ ! -d "suitecrm-cobol" ]; then
        echo "Downloading SuiteCRM Banking Edition..."
        git clone https://github.com/jfuginay/suitecrm-cobol-banking.git suitecrm-cobol
    fi
    
    cd suitecrm-cobol
    
    # Create development docker-compose file
    create_development_compose
    
    # Install dependencies
    echo "Installing development dependencies..."
    cd cobol-services && npm install && cd ..
    
    # Create environment file
    create_env_file "development"
    
    # Start services
    echo "Starting services..."
    docker-compose -f docker-compose.dev.yml up -d
    
    echo ""
    echo "✓ Development installation complete!"
    echo ""
    display_access_info
}

# Custom installation
custom_install() {
    echo ""
    echo "Custom Installation"
    echo ""
    echo "This will guide you through a custom setup..."
    
    # Database selection
    echo "Select database:"
    echo "1) MySQL (recommended)"
    echo "2) PostgreSQL"
    echo "3) MariaDB"
    read -p "Enter choice (1-3): " db_choice
    
    # COBOL compiler selection
    echo ""
    echo "Select COBOL compiler:"
    echo "1) GnuCOBOL (recommended, free)"
    echo "2) Micro Focus COBOL"
    echo "3) IBM COBOL"
    read -p "Enter choice (1-3): " cobol_choice
    
    # Installation location
    echo ""
    read -p "Enter installation directory (default: /opt/suitecrm-banking): " install_dir
    install_dir=${install_dir:-/opt/suitecrm-banking}
    
    # Perform custom installation based on choices
    perform_custom_install "$db_choice" "$cobol_choice" "$install_dir"
}

# Create environment file
create_env_file() {
    local env_type=${1:-"development"}
    
    cat > .env << EOF
# SuiteCRM Banking Edition Configuration
ENVIRONMENT=$env_type

# Database Configuration
DB_HOST=mysql
DB_NAME=suitecrm_banking
DB_USER=suitecrm
DB_PASSWORD=$(openssl rand -base64 32)
DB_ROOT_PASSWORD=$(openssl rand -base64 32)

# SuiteCRM Configuration
SITE_URL=http://localhost:8080
ADMIN_USER=admin
ADMIN_PASSWORD=admin

# COBOL Services Configuration
COBOL_API_PORT=3000
COBOL_WS_PORT=8081

# Security Keys
SECRET_KEY=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)
EOF

    echo "✓ Environment file created"
}

# Create production docker-compose
create_production_compose() {
    local domain=$1
    local ssl_cert=$2
    local ssl_key=$3
    
    cat > docker-compose.prod.yml << EOF
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx-prod.conf:/etc/nginx/nginx.conf
      - $ssl_cert:/etc/nginx/ssl/cert.pem
      - $ssl_key:/etc/nginx/ssl/key.pem
      - suitecrm_data:/var/www/html
    depends_on:
      - suitecrm

  suitecrm:
    build:
      context: .
      dockerfile: Dockerfile.suitecrm
    volumes:
      - suitecrm_data:/var/www/html
    environment:
      - PRODUCTION=true
    depends_on:
      - mysql
      - cobol-api

  mysql:
    image: mysql:5.7
    volumes:
      - mysql_data:/var/lib/mysql
    env_file: .env

  cobol-api:
    build:
      context: .
      dockerfile: Dockerfile.cobol
    env_file: .env

volumes:
  suitecrm_data:
  mysql_data:
EOF
}

# Create development docker-compose
create_development_compose() {
    cat > docker-compose.dev.yml << EOF
version: '3.8'

services:
  suitecrm:
    build:
      context: .
      dockerfile: Dockerfile.suitecrm
    ports:
      - "8080:80"
    volumes:
      - ./SuiteCRM:/var/www/html
      - ./custom:/var/www/html/custom
    environment:
      - DEVELOPMENT=true
    depends_on:
      - mysql
      - cobol-api

  mysql:
    image: mysql:5.7
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    env_file: .env

  cobol-api:
    build:
      context: .
      dockerfile: Dockerfile.cobol
    ports:
      - "3000:3000"
    volumes:
      - ./cobol-services:/app
    command: npm run dev
    env_file: .env

  adminer:
    image: adminer
    ports:
      - "8081:8080"
    depends_on:
      - mysql

volumes:
  mysql_data:
EOF
}

# Display access information
display_access_info() {
    echo "=========================================="
    echo "Installation Complete!"
    echo "=========================================="
    echo ""
    echo "Access your SuiteCRM Banking Edition:"
    echo "- URL: http://localhost:8080"
    echo "- Username: admin"
    echo "- Password: admin"
    echo ""
    echo "COBOL API Service:"
    echo "- URL: http://localhost:3000"
    echo "- Health Check: http://localhost:3000/health"
    echo ""
    echo "Database Admin (development only):"
    echo "- URL: http://localhost:8081"
    echo ""
    echo "To stop services: docker-compose down"
    echo "To view logs: docker-compose logs -f"
    echo ""
    echo "Next steps:"
    echo "1. Change the admin password"
    echo "2. Configure your bank's COBOL mainframe connection"
    echo "3. Set up user accounts and permissions"
    echo "4. Import your customer data"
    echo ""
    echo "Documentation: https://github.com/jfuginay/suitecrm-cobol-banking/wiki"
}

# Main execution
main() {
    clear
    check_prerequisites
    installation_menu
}

# Run main function
main