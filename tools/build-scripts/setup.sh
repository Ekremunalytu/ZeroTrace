#!/bin/bash
#
# setup.sh: Cross-platform development environment setup for ZeroTrace project.
#
# This script provides a platform-independent way to set up the development environment:
# - Prioritizes Docker container development (recommended)
# - Falls back to local virtual environment if Docker is not available
# - Works on Linux, macOS, and Windows (with WSL/Git Bash)
#
# Usage:
#   ./scripts/setup.sh                 # Auto-detect best method
#   ./scripts/setup.sh --container     # Force container setup
#   ./scripts/setup.sh --local         # Force local setup

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
PYTHON_CMD="python3"
MIN_PYTHON_VERSION="3.11"
VENV_DIR=".venv"
CONTAINER_NAME="zerotrace-dev"
COMPOSE_FILE="build/docker/docker-compose.yml"

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

# --- Helper Functions ---
print_info() {
    echo "ℹ️  $1"
}

print_success() {
    echo "✅ $1"
}

print_error() {
    echo "❌ ERROR: $1" >&2
    exit 1
}

print_warning() {
    echo "⚠️  WARNING: $1"
}

# Cross-platform virtual environment activation
activate_venv() {
    if [[ "$PLATFORM" == "windows" ]]; then
        if [[ -f "$VENV_DIR/Scripts/activate" ]]; then
            source "$VENV_DIR/Scripts/activate"
        else
            print_error "Virtual environment not found at $VENV_DIR/Scripts/activate"
        fi
    else
        if [[ -f "$VENV_DIR/bin/activate" ]]; then
            source "$VENV_DIR/bin/activate"
        else
            print_error "Virtual environment not found at $VENV_DIR/bin/activate"
        fi
    fi
}

# Check if Docker is available and running
check_docker() {
    if command -v docker &> /dev/null; then
        if docker info &> /dev/null; then
            return 0
        else
            print_warning "Docker is installed but not running"
            return 1
        fi
    else
        return 1
    fi
}

# Check if Docker Compose is available
check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        return 0
    elif docker compose version &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Container-based setup (recommended)
setup_container() {
    print_info "Setting up container-based development environment..."
    
    if ! check_docker; then
        print_error "Docker is not available. Please install Docker Desktop or Docker Engine."
    fi
    
    if ! check_docker_compose; then
        print_error "Docker Compose is not available. Please install Docker Compose."
    fi
    
    print_info "Building development container..."
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$COMPOSE_FILE" build devcontainer
    else
        docker compose -f "$COMPOSE_FILE" build devcontainer
    fi
    
    print_info "Starting development environment..."
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$COMPOSE_FILE" up -d devcontainer postgres rabbitmq redis
    else
        docker compose -f "$COMPOSE_FILE" up -d devcontainer postgres rabbitmq redis
    fi
    
    print_success "Container environment is ready!"
    print_info "To enter the development container, run:"
    print_info "  docker exec -it $CONTAINER_NAME bash"
    print_info ""
    print_info "Or use VS Code with the Dev Containers extension:"
    print_info "  1. Install 'Dev Containers' extension"
    print_info "  2. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)"
    print_info "  3. Run 'Dev Containers: Attach to Running Container'"
    print_info "  4. Select '$CONTAINER_NAME'"
}

# Local virtual environment setup (fallback)
setup_local() {
    print_info "Setting up local virtual environment..."
    
    # 1. Check Python version
    print_info "Checking Python version..."
    if ! command -v $PYTHON_CMD &> /dev/null; then
        # Try alternative Python commands
        if command -v python &> /dev/null; then
            PYTHON_CMD="python"
        elif command -v py &> /dev/null; then
            PYTHON_CMD="py"
        else
            print_error "$PYTHON_CMD is not installed. Please install Python $MIN_PYTHON_VERSION or higher."
        fi
    fi

    PYTHON_VERSION=$($PYTHON_CMD -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if [[ "$PYTHON_VERSION" < "$MIN_PYTHON_VERSION" ]]; then
        print_error "Python version $PYTHON_VERSION is installed, but $MIN_PYTHON_VERSION or higher is required."
    fi
    print_success "Python version $PYTHON_VERSION is compatible."

    # 2. Create virtual environment
    if [ ! -d "$VENV_DIR" ]; then
        print_info "Creating Python virtual environment in '$VENV_DIR'..."
        $PYTHON_CMD -m venv "$VENV_DIR"
        print_success "Virtual environment created."
    else
        print_info "Virtual environment already exists."
    fi

    # 3. Activate virtual environment
    print_info "Activating virtual environment..."
    activate_venv
    print_success "Virtual environment activated."

    # 4. Upgrade pip
    print_info "Upgrading pip..."
    python -m pip install --upgrade pip
    print_success "pip is up to date."

    # 5. Install dependencies
    print_info "Installing dependencies from requirements.txt..."
    pip install -r requirements.txt
    print_success "Core dependencies installed."

    # 6. Install development dependencies
    print_info "Installing development dependencies..."
    pip install -e ".[dev]"
    print_success "Development dependencies installed."

    # 7. Install pre-commit hooks
    print_info "Installing pre-commit hooks..."
    pre-commit install
    print_success "Pre-commit hooks installed."

    print_success "🎉 Local development environment is ready!"
    print_info "To activate the virtual environment in your terminal:"
    if [[ "$PLATFORM" == "windows" ]]; then
        print_info "  $VENV_DIR\\Scripts\\activate"
    else
        print_info "  source $VENV_DIR/bin/activate"
    fi
}

# Main setup logic
main() {
    print_info "🚀 ZeroTrace Development Environment Setup"
    print_info "=========================================="
    
    detect_platform
    print_info "Detected platform: $PLATFORM"
    
    # Parse command line arguments
    FORCE_CONTAINER=false
    FORCE_LOCAL=false
    
    case "${1:-}" in
        --container|-c)
            FORCE_CONTAINER=true
            ;;
        --local|-l)
            FORCE_LOCAL=true
            ;;
        --help|-h)
            echo "Usage: $0 [--container|--local|--help]"
            echo ""
            echo "Options:"
            echo "  --container, -c  Force container-based setup"
            echo "  --local, -l      Force local virtual environment setup"
            echo "  --help, -h       Show this help message"
            echo ""
            echo "If no option is specified, the script will:"
            echo "1. Try container setup if Docker is available"
            echo "2. Fall back to local setup if Docker is not available"
            exit 0
            ;;
        "")
            # Auto-detect mode
            ;;
        *)
            print_error "Unknown option: $1. Use --help for usage information."
            ;;
    esac
    
    if [[ "$FORCE_CONTAINER" == "true" ]]; then
        setup_container
    elif [[ "$FORCE_LOCAL" == "true" ]]; then
        setup_local
    else
        # Auto-detect best setup method
        if check_docker && check_docker_compose; then
            print_info "Docker detected. Using container-based setup (recommended)."
            print_info "Use --local flag to force local setup instead."
            setup_container
        else
            print_info "Docker not available. Using local virtual environment setup."
            print_info "For better cross-platform compatibility, consider installing Docker."
            setup_local
        fi
    fi
    
    echo ""
    print_success "✨ Setup completed successfully!"
    echo ""
    print_info "📚 Next steps:"
    if [[ "$FORCE_CONTAINER" == "true" ]] || ([[ "$FORCE_LOCAL" != "true" ]] && check_docker && check_docker_compose); then
        print_info "  • Enter development container: docker exec -it $CONTAINER_NAME bash"
        print_info "  • Use VS Code Dev Containers extension for integrated development"
        print_info "  • Run tests: docker exec -it $CONTAINER_NAME pytest"
        print_info "  • Build project: docker exec -it $CONTAINER_NAME make"
    else
        print_info "  • Activate virtual environment and start coding!"
        print_info "  • Run tests: pytest"
        print_info "  • Build project: make"
    fi
}

main "$@"
