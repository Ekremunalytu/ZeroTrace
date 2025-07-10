#!/bin/bash
# ZeroTrace Cross-Platform Security Check Script
# Bu script sisteminizin güvenlik durumunu kontrol eder
# Hem container hem de local ortamlarda çalışır

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VENV_DIR=".venv"
CONTAINER_NAME="zerotrace-dev"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Linux*)     PLATFORM="linux";;
        Darwin*)    PLATFORM="macos";;
        CYGWIN*)    PLATFORM="windows";;
        MINGW*)     PLATFORM="windows";;
        MSYS*)      PLATFORM="windows";;
        *)          PLATFORM="unknown";;
    esac
}

# Check if we're running inside a container
is_container() {
    if [[ -f /.dockerenv ]] || [[ -n "${CONTAINER}" ]]; then
        return 0
    else
        return 1
    fi
}

# Cross-platform virtual environment activation
activate_venv() {
    if is_container; then
        # In container, Python packages are globally available
        return 0
    fi
    
    detect_platform
    
    if [[ "$PLATFORM" == "windows" ]]; then
        if [[ -f "$VENV_DIR/Scripts/activate" ]]; then
            source "$VENV_DIR/Scripts/activate"
        else
            log_error "Virtual environment not found. Run ./scripts/setup.sh first."
        fi
    else
        if [[ -f "$VENV_DIR/bin/activate" ]]; then
            source "$VENV_DIR/bin/activate"
        else
            log_error "Virtual environment not found. Run ./scripts/setup.sh first."
        fi
    fi
}

# Security checks
check_dependencies() {
    log_info "Checking Python dependencies for vulnerabilities..."
    
    # Activate virtual environment
    activate_venv
    
    # Install safety if not present
    if ! command -v safety >/dev/null 2>&1; then
        log_info "Installing safety for dependency checking..."
        pip install safety
    fi
    
    # Check for vulnerabilities
    if safety check; then
        log_success "No known vulnerabilities found in Python dependencies"
    else
        log_warning "Vulnerabilities found! Please update affected packages"
    fi
}

check_secrets() {
    log_info "Checking for hardcoded secrets..."
    
    # Activate virtual environment for detect-secrets
    activate_venv
    
    # Install detect-secrets if not present
    if ! command -v detect-secrets >/dev/null 2>&1; then
        log_info "Installing detect-secrets..."
        pip install detect-secrets
    fi
    
    # Check if secrets baseline exists
    if [ ! -f ".secrets.baseline" ]; then
        log_info "Creating secrets baseline..."
        detect-secrets scan --baseline .secrets.baseline
    fi
    
    # Scan for new secrets
    if detect-secrets scan --baseline .secrets.baseline --exclude-files '\.env\.example$'; then
        log_success "No new secrets detected"
    else
        log_warning "Potential secrets detected! Review and update baseline if needed"
    fi
}

check_docker_security() {
    log_info "Checking Docker configuration security..."
    
    # Check for latest tags
    if grep -q ":latest" docker-compose.yml; then
        log_warning "Found :latest tags in docker-compose.yml - consider pinning versions"
    else
        log_success "Docker images are properly version-pinned"
    fi
    
    # Check for exposed Docker socket
    if grep -q "/var/run/docker.sock" docker-compose.yml; then
        log_warning "Docker socket is exposed - this is OK for development but NOT for production"
    fi
}

check_production_readiness() {
    log_info "Checking production readiness..."
    
    # Check if production config exists
    if [ -f "configs/production/security.env" ]; then
        log_success "Production security config exists"
        
        # Check for default values
        if grep -q "CHANGE_THIS" configs/production/security.env; then
            log_error "Production config contains default values! Please update before deployment"
        else
            log_success "Production config appears to be customized"
        fi
    else
        log_warning "Production security config not found"
    fi
    
    # Check if production docker-compose exists
    if [ -f "docker-compose.prod.yml" ]; then
        log_success "Production Docker Compose configuration exists"
    else
        log_warning "Production Docker Compose configuration not found"
    fi
}

check_file_permissions() {
    log_info "Checking critical file permissions..."
    
    detect_platform
    
    # Check for executable scripts
    for script in scripts/*.sh infrastructure/docker/scripts/*; do
        if [ -f "$script" ] && [ ! -x "$script" ]; then
            log_warning "Script $script is not executable"
        fi
    done
    
    # Check for sensitive files - cross-platform file permissions check
    for file in configs/*/security.env .env; do
        if [ -f "$file" ]; then
            # Cross-platform permission check
            case $PLATFORM in
                macos|linux)
                    if command -v stat >/dev/null 2>&1; then
                        if [[ "$PLATFORM" == "macos" ]]; then
                            perms=$(stat -f "%A" "$file" 2>/dev/null || echo "unknown")
                        else
                            perms=$(stat -c "%a" "$file" 2>/dev/null || echo "unknown")
                        fi
                        
                        if [[ "$perms" != "600" ]] && [[ "$perms" != "644" ]] && [[ "$perms" != "unknown" ]]; then
                            log_warning "File $file has permissions $perms - consider restricting to 600"
                        fi
                    fi
                    ;;
                windows)
                    # On Windows, just check if file exists and warn about permissions
                    log_warning "File $file exists - ensure it has restricted permissions on Windows"
                    ;;
                *)
                    log_info "Cannot check permissions for $file on $PLATFORM platform"
                    ;;
            esac
        fi
    done
}

# Main execution
main() {
    log_info "🔒 ZeroTrace Security Check Starting..."
    echo ""
    
    check_dependencies
    echo ""
    
    check_secrets
    echo ""
    
    check_docker_security
    echo ""
    
    check_production_readiness
    echo ""
    
    check_file_permissions
    echo ""
    
    log_success "🔒 Security check completed!"
    echo ""
    echo "📋 Next steps for production deployment:"
    echo "1. Update all passwords in configs/production/security.env"
    echo "2. Generate proper SSL certificates"
    echo "3. Review and update CORS origins"
    echo "4. Set up proper backup procedures"
    echo "5. Configure monitoring and alerting"
}

main "$@"
