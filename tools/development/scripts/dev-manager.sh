#!/bin/bash
# ZeroTrace Development Environment Manager
# Cross-platform development environment management script
#
# This script provides a unified interface for development operations
# and automatically detects the best environment (container vs local).

# Get script directory and change to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
CONTAINER_NAME="zerotrace-dev"
COMPOSE_FILE="build/docker/docker-compose.yml"
VENV_DIR=".venv"
ENV_DIR="tools/development/environment"

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     🛡️  ZeroTrace XDR                      ║"
    echo "║                Development Environment Manager               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() {
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

# Show environment status
show_status() {
    echo ""
    print_info "Environment Status:"
    echo "=================="
    
    # Docker status
    if check_docker; then
        print_success "Docker is available and running"
        
        if check_dev_container; then
            print_success "Development container is running"
            
            # Show container stats
            echo ""
            print_info "Container Information:"
            docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        else
            print_warning "Development container is not running"
        fi
    else
        print_warning "Docker is not available or not running"
    fi
    
    # Local environment status
    echo ""
    print_info "Local Environment:"
    if [[ -d "$VENV_DIR" ]]; then
        print_success "Virtual environment exists at $VENV_DIR"
        
        if [[ -n "$VIRTUAL_ENV" ]]; then
            if [[ "$VIRTUAL_ENV" == *"$VENV_DIR"* ]]; then
                print_success "Correct virtual environment is active"
            else
                print_warning "Different virtual environment is active: $VIRTUAL_ENV"
            fi
        else
            print_warning "Virtual environment is not active"
        fi
    else
        print_warning "Virtual environment not found"
    fi
}

# Execute command in best available environment
execute_command() {
    local cmd="$1"
    local description="$2"
    
    print_info "$description"
    
    if check_dev_container; then
        print_info "Executing in container..."
        docker exec -it "$CONTAINER_NAME" bash -c "cd /workspace && $cmd"
    elif [[ -d "$VENV_DIR" ]]; then
        print_info "Executing in local environment..."
        
        # Activate virtual environment and run command
        if [[ -f "$VENV_DIR/bin/activate" ]]; then
            source "$VENV_DIR/bin/activate"
        elif [[ -f "$VENV_DIR/Scripts/activate" ]]; then
            source "$VENV_DIR/Scripts/activate"
        fi
        
        eval "$cmd"
    else
        print_error "No suitable environment found. Run 'dev setup' first."
        exit 1
    fi
}

# Show help
show_help() {
    echo "ZeroTrace Development Environment Manager"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Environment Commands:"
    echo "  setup [--container|--local]  Set up development environment"
    echo "  status                       Show environment status"
    echo "  start                        Start development container"
    echo "  stop                         Stop development container"
    echo "  shell                        Open shell in best available environment"
    echo "  logs                         Show container logs"
    echo ""
    echo "Development Commands:"
    echo "  build [target]               Build project (cpp|python|all)"
    echo "  test [pattern]               Run tests"
    echo "  lint                         Run code linting"
    echo "  format                       Format code"
    echo "  security                     Run security checks"
    echo "  clean                        Clean build artifacts"
    echo ""
    echo "Service Commands:"
    echo "  services                     Start all services (DB, RabbitMQ, Redis)"
    echo "  db                           Start only database"
    echo "  queue                        Start only message queue"
    echo ""
    echo "Utility Commands:"
    echo "  check                        Check environment setup"
    echo "  reset                        Reset entire environment"
    echo "  help                         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 setup                     # Auto-detect best setup method"
    echo "  $0 setup --container         # Force container setup"
    echo "  $0 build python              # Build Python components"
    echo "  $0 test tests/unit/          # Run unit tests"
    echo "  $0 shell                     # Open development shell"
}

# Main command handling
main() {
    case "${1:-help}" in
        setup)
            shift
            ./tools/build-scripts/setup.sh "$@"
            ;;
        status)
            show_status
            ;;
        start)
            print_info "Starting development container..."
            if command -v docker-compose &> /dev/null; then
                docker-compose -f "$COMPOSE_FILE" up -d devcontainer postgres rabbitmq redis
            else
                docker compose -f "$COMPOSE_FILE" up -d devcontainer postgres rabbitmq redis
            fi
            print_success "Development environment started"
            ;;
        stop)
            print_info "Stopping development container..."
            if command -v docker-compose &> /dev/null; then
                docker-compose -f "$COMPOSE_FILE" down
            else
                docker compose -f "$COMPOSE_FILE" down
            fi
            print_success "Development environment stopped"
            ;;
        shell)
            if check_dev_container; then
                print_info "Opening shell in container..."
                docker exec -it "$CONTAINER_NAME" bash
            else
                print_info "Opening shell in local environment..."
                if [[ -f "$VENV_DIR/bin/activate" ]]; then
                    bash --init-file <(echo "source $VENV_DIR/bin/activate; echo 'Virtual environment activated'")
                elif [[ -f "$VENV_DIR/Scripts/activate" ]]; then
                    # Windows Git Bash / WSL
                    bash --init-file <(echo "source $VENV_DIR/Scripts/activate; echo 'Virtual environment activated'")
                else
                    print_error "No virtual environment found. Run 'dev setup' first."
                    exit 1
                fi
            fi
            ;;
        build)
            shift
            ./tools/build-scripts/build.sh "$@"
            ;;
        test)
            shift
            pattern="${1:-}"
            if [[ -n "$pattern" ]]; then
                execute_command "python3 -m pytest $pattern -v" "Running tests: $pattern"
            else
                execute_command "python3 -m pytest tests/ -v" "Running all tests"
            fi
            ;;
        lint)
            execute_command "python3 -m flake8 services/ tests/" "Running code linting"
            ;;
        format)
            execute_command "python3 -m black services/ tests/ && python3 -m isort services/ tests/" "Formatting code"
            ;;
        security)
            ./tools/build-scripts/security-check.sh
            ;;
        clean)
            ./tools/build-scripts/build.sh clean
            ;;
        services)
            print_info "Starting all services..."
            if command -v docker-compose &> /dev/null; then
                docker-compose -f "$COMPOSE_FILE" up -d postgres rabbitmq redis
            else
                docker compose -f "$COMPOSE_FILE" up -d postgres rabbitmq redis
            fi
            print_success "All services started"
            ;;
        db)
            print_info "Starting database..."
            if command -v docker-compose &> /dev/null; then
                docker-compose -f "$COMPOSE_FILE" up -d postgres
            else
                docker compose -f "$COMPOSE_FILE" up -d postgres
            fi
            print_success "Database started"
            ;;
        queue)
            print_info "Starting message queue..."
            if command -v docker-compose &> /dev/null; then
                docker-compose -f "$COMPOSE_FILE" up -d rabbitmq
            else
                docker compose -f "$COMPOSE_FILE" up -d rabbitmq
            fi
            print_success "Message queue started"
            ;;
        logs)
            if check_dev_container; then
                docker logs -f "$CONTAINER_NAME"
            else
                print_error "Container is not running"
                exit 1
            fi
            ;;
        check)
            ./tools/build-scripts/check_env.sh
            ;;
        reset)
            print_warning "This will destroy all containers and local environment!"
            read -p "Are you sure? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_info "Resetting environment..."
                if command -v docker-compose &> /dev/null; then
                    docker-compose -f "$COMPOSE_FILE" down -v
                else
                    docker compose -f "$COMPOSE_FILE" down -v
                fi
                rm -rf "$VENV_DIR" build/ .pytest_cache/ __pycache__/
                print_success "Environment reset completed"
            else
                print_info "Reset cancelled"
            fi
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            print_banner
            show_status
            echo ""
            echo "Run '$0 help' for available commands"
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Run '$0 help' for available commands"
            exit 1
            ;;
    esac
}

# Show banner and run main function
if [[ "${1:-}" != "help" ]] && [[ "${1:-}" != "--help" ]] && [[ "${1:-}" != "-h" ]]; then
    print_banner
fi

main "$@"
