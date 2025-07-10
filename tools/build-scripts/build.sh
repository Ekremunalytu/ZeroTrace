#!/bin/bash
# ZeroTrace Cross-Platform Build Script
# 
# This script provides a platform-independent build system that prioritizes
# container-based builds to ensure consistency across all environments.
# Falls back to local builds when containers are not available.

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
COMPOSE_FILE="docker-compose.yml"

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
    log_info "Detected platform: $PLATFORM"
}

# Check if we're running inside a container
is_container() {
    if [[ -f /.dockerenv ]] || [[ -n "${CONTAINER}" ]]; then
        return 0
    else
        return 1
    fi
}

# Check if Docker is available
check_docker() {
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if development container is running
check_dev_container() {
    if docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        return 0
    else
        return 1
    fi
}

# Container-based build (recommended)
build_in_container() {
    log_info "Building in container environment..."
    
    if ! check_docker; then
        log_error "Docker is not available. Please install Docker or use --local flag."
    fi
    
    # Start development container if not running
    if ! check_dev_container; then
        log_info "Starting development container..."
        if command -v docker-compose &> /dev/null; then
            docker-compose -f "$COMPOSE_FILE" up -d devcontainer
        else
            docker compose -f "$COMPOSE_FILE" up -d devcontainer
        fi
        
        # Wait for container to be ready
        log_info "Waiting for container to be ready..."
        sleep 5
    fi
    
    # Execute build commands in container
    case "${1:-all}" in
        cpp)
            log_info "Building C++ components in container..."
            docker exec "$CONTAINER_NAME" bash -c "cd /workspace && mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make -j\$(nproc)"
            ;;
        python)
            log_info "Installing Python dependencies in container..."
            docker exec "$CONTAINER_NAME" bash -c "cd /workspace && python3 -m pip install --upgrade pip && pip install -r build/python/requirements.txt"
            ;;
        test)
            log_info "Running tests in container..."
            docker exec "$CONTAINER_NAME" bash -c "cd /workspace && python -m pytest tests/ -v"
            ;;
        clean)
            log_info "Cleaning build artifacts in container..."
            docker exec "$CONTAINER_NAME" bash -c "cd /workspace && rm -rf build/ && find . -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null || true"
            ;;
        all)
            log_info "Full build in container..."
            docker exec "$CONTAINER_NAME" bash -c "
                cd /workspace &&
                python3 -m pip install --upgrade pip &&
                pip install -r build/python/requirements.txt &&
                mkdir -p build && cd build &&
                cmake .. -DCMAKE_BUILD_TYPE=Release &&
                make -j\$(nproc)
            "
            ;;
    esac
    
    log_success "Container build completed!"
}

# Cross-platform virtual environment activation
activate_venv() {
    if [[ "$PLATFORM" == "windows" ]]; then
        if [[ -f "$VENV_DIR/Scripts/activate" ]]; then
            source "$VENV_DIR/Scripts/activate"
        else
            log_error "Virtual environment not found. Run ./tools/build-scripts/setup.sh first."
        fi
    else
        if [[ -f "$VENV_DIR/bin/activate" ]]; then
            source "$VENV_DIR/bin/activate"
        else
            log_error "Virtual environment not found. Run ./tools/build-scripts/setup.sh first."
        fi
    fi
}

# Local build (fallback)
build_local() {
    log_info "Building in local environment..."
    log_warning "Local builds may have platform-specific dependencies!"
    log_warning "For consistent builds, consider using Docker containers."
    
    case "${1:-all}" in
        cpp)
            build_cpp_local
            ;;
        python)
            install_python_local
            ;;
        test)
            run_tests_local
            ;;
        clean)
            clean_local
            ;;
        all)
            install_python_local
            build_cpp_local
            log_success "Local build completed!"
            ;;
    esac
}

# Build C++ collectors locally
build_cpp_local() {
    log_info "Building C++ collectors locally..."
    log_warning "This requires C++ development tools to be installed on your system."
    
    # Check for basic build tools
    if ! command -v cmake >/dev/null 2>&1; then
        log_error "CMake not found. Please install CMake or use container build."
    fi
    
    if ! command -v make >/dev/null 2>&1 && ! command -v ninja >/dev/null 2>&1; then
        log_error "Build system (make/ninja) not found. Please install build tools or use container build."
    fi
    
    mkdir -p build
    cd build
    
    # Platform-specific CMake options
    CMAKE_OPTS=""
    case $PLATFORM in
        macos)
            # macOS specific options
            if [[ -d "/opt/homebrew/opt/openssl" ]]; then
                CMAKE_OPTS="-DOPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl"
            elif [[ -d "/usr/local/opt/openssl" ]]; then
                CMAKE_OPTS="-DOPENSSL_ROOT_DIR=/usr/local/opt/openssl"
            fi
            ;;
    esac
    
    cmake .. $CMAKE_OPTS -DCMAKE_BUILD_TYPE=Release
    
    # Use appropriate number of parallel jobs
    if command -v nproc >/dev/null 2>&1; then
        JOBS=$(nproc)
    elif command -v sysctl >/dev/null 2>&1; then
        JOBS=$(sysctl -n hw.ncpu)
    else
        JOBS=4
    fi
    
    make -j$JOBS
    cd ..
    log_success "C++ build completed"
}

# Install Python dependencies locally
install_python_local() {
    log_info "Installing Python dependencies locally..."
    
    # Check if Python 3 is available
    PYTHON_CMD="python3"
    if ! command -v python3 >/dev/null 2>&1; then
        if command -v python >/dev/null 2>&1; then
            PYTHON_CMD="python"
        elif command -v py >/dev/null 2>&1; then
            PYTHON_CMD="py"
        else
            log_error "Python 3 not found. Please install Python 3.11+ or use container build."
        fi
    fi
    
    # Activate virtual environment
    log_info "Activating virtual environment..."
    activate_venv
    
    # Upgrade pip and install dependencies
    python -m pip install --upgrade pip
    pip install -r build/python/requirements.txt
    
    log_success "Python dependencies installed"
}

# Run tests locally
run_tests_local() {
    log_info "Running tests locally..."
    
    # Activate virtual environment
    activate_venv
    
    # C++ tests
    if [ -f "build/tests" ]; then
        log_info "Running C++ tests..."
        ./build/tests
    fi
    
    # Python tests
    if [ -d "tests" ]; then
        log_info "Running Python tests..."
        python -m pytest tests/ -v
    fi
    
    log_success "Tests completed"
}

# Clean build artifacts
clean_local() {
    log_info "Cleaning build artifacts..."
    rm -rf build/
    find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    find . -name "*.pyc" -delete 2>/dev/null || true
    log_success "Cleanup completed"
}

# Main build function
main() {
    log_info "🔨 ZeroTrace Build Script Starting..."
    
    detect_platform
    
    # Parse arguments
    FORCE_CONTAINER=false
    FORCE_LOCAL=false
    BUILD_TARGET="all"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --container|-c)
                FORCE_CONTAINER=true
                shift
                ;;
            --local|-l)
                FORCE_LOCAL=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--container|--local] [target]"
                echo ""
                echo "Build targets:"
                echo "  all      - Full build (default)"
                echo "  cpp      - Build C++ components only"
                echo "  python   - Install Python dependencies only"
                echo "  test     - Run tests"
                echo "  clean    - Clean build artifacts"
                echo ""
                echo "Build modes:"
                echo "  --container, -c  Force container build (recommended)"
                echo "  --local, -l      Force local build"
                echo ""
                echo "If no mode is specified:"
                echo "  - Use container build if running inside container"
                echo "  - Use container build if Docker is available"
                echo "  - Fall back to local build otherwise"
                exit 0
                ;;
            cpp|python|test|clean|all)
                BUILD_TARGET="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1. Use --help for usage information."
                ;;
        esac
    done
    
    # Determine build method
    if [[ "$FORCE_CONTAINER" == "true" ]]; then
        build_in_container "$BUILD_TARGET"
    elif [[ "$FORCE_LOCAL" == "true" ]]; then
        build_local "$BUILD_TARGET"
    elif is_container; then
        log_info "Running inside container. Using container build commands."
        build_local "$BUILD_TARGET"  # Inside container, local commands work
    elif check_docker; then
        log_info "Docker detected. Using container build (recommended)."
        log_info "Use --local flag to force local build instead."
        build_in_container "$BUILD_TARGET"
    else
        log_info "Docker not available. Using local build."
        log_warning "For consistent builds, consider installing Docker."
        build_local "$BUILD_TARGET"
    fi
    
    echo ""
    log_success "✨ Build completed successfully!"
    
    # Show next steps based on build method
    if [[ "$FORCE_CONTAINER" == "true" ]] || ([[ "$FORCE_LOCAL" != "true" ]] && ! is_container && check_docker); then
        echo ""
        log_info "📚 Container environment commands:"
        log_info "  • Enter container: docker exec -it $CONTAINER_NAME bash"
        log_info "  • Run tests: docker exec -it $CONTAINER_NAME pytest"
        log_info "  • View logs: docker logs $CONTAINER_NAME"
    else
        echo ""
        log_info "📚 Local environment commands:"
        if [[ "$PLATFORM" == "windows" ]]; then
            log_info "  • Activate venv: $VENV_DIR\\Scripts\\activate"
        else
            log_info "  • Activate venv: source $VENV_DIR/bin/activate"
        fi
        log_info "  • Run tests: pytest"
        log_info "  • Clean build: $0 clean"
    fi
}

main "$@"
