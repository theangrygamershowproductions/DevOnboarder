#!/bin/bash

# DevOnboarder AAR UI Stack Integration Setup
# Integrates AAR UI as a service in the DevOnboarder Docker stack

set -e  # Exit on any error

echo "DEPLOY Setting up DevOnboarder AAR UI Stack Integration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pyproject.toml" ] || [ ! -d "app/aar-ui" ]; then
    print_error "Please run this script from the DevOnboarder root directory"
    exit 1
fi

print_status "Installing AAR UI dependencies..."

# Install AAR UI dependencies
cd app/aar-ui
npm install
cd ../..

print_success "Dependencies installed"

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p docs/AAR/data
mkdir -p docs/AAR/reports
mkdir -p logs

print_success "Directories created"

# Install core AAR system dependencies if needed
print_status "Ensuring core AAR system dependencies..."
npm install

print_success "Core dependencies verified"

# Test the system
print_status "Testing AAR system..."
npm run aar:full-test

print_success "AAR system tests passed"

# Build the Docker image
print_status "Building AAR UI Docker image..."
npm run aar:stack:build

print_success "Docker image built successfully"

# Check if networks exist
print_status "Verifying Docker networks..."
if ! docker network ls | grep -q "devonboarder_edge_tier"; then
    print_warning "DevOnboarder networks not found. Creating them..."
    docker network create devonboarder_edge_tier || true
    docker network create devonboarder_api_tier || true
    docker network create devonboarder_auth_tier || true
    docker network create devonboarder_data_tier || true
fi

print_success "Docker networks verified"

print_status "Setup complete! SYMBOL"
echo
echo "SYMBOL Stack Commands:"
echo "  npm run aar:stack:up          # Start AAR UI service in stack"
echo "  npm run aar:stack:down        # Stop AAR UI service"
echo "  npm run aar:stack:logs        # View service logs"
echo "  npm run aar:stack:build       # Rebuild Docker image"
echo "  npm run aar:stack:prod        # Start with production config"
echo
echo "SYMBOL Stack URLs (after starting):"
echo "  AAR UI:       https://aar.theangrygamershow.com (production)"
echo "  AAR UI:       http://localhost (development via Traefik)"
echo "  Traefik:      http://localhost:8090 (dashboard)"
echo
echo "SYMBOL Docker Commands:"
echo "  docker compose -f docker-compose.dev.yaml up -d    # Start full stack"
echo "  docker compose -f docker-compose.dev.yaml ps       # Check services"
echo "  docker compose -f docker-compose.dev.yaml down     # Stop stack"
echo
echo "SYMBOL Usage:"
echo "  1. Run 'npm run aar:stack:up' to start the AAR UI service"
echo "  2. Access via Traefik at configured domain"
echo "  3. Create AARs via React form or GitHub Issues"
echo "  4. All AARs automatically validated and rendered"
echo "  5. Reports available at /reports/ endpoint"
echo
print_success "AAR UI integrated into DevOnboarder stack! DEPLOY"
