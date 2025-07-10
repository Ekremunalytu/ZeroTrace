#!/bin/bash
#
# check_env.sh: Cross-platform environment verification for ZeroTrace project.
# This script verifies that the development environment is properly set up.
# Works with both container and local virtual environments.

set -e

# Configuration
VENV_DIR=".venv"
CONTAINER_NAME="zerotrace-dev"

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

# Get the absolute path of the project root
get_project_root() {
    if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
        PROJECT_ROOT=$(git rev-parse --show-toplevel)
    else
        # Fallback: assume script is in scripts/ subdirectory
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    fi
}

# Check container environment
check_container_env() {
    echo "✅ Running inside development container"
    
    # Check if workspace is mounted
    if [[ -d "/workspace" ]] && [[ -f "/workspace/pyproject.toml" ]]; then
        echo "✅ Workspace is properly mounted"
    else
        echo "❌ ERROR: Workspace not properly mounted" >&2
        exit 1
    fi
    
    # Check if Python is available
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        echo "✅ Python $PYTHON_VERSION is available"
    else
        echo "❌ ERROR: Python not found in container" >&2
        exit 1
    fi
    
    # Check if required packages are installed
    if python3 -c "import fastapi, pydantic, sqlalchemy" 2>/dev/null; then
        echo "✅ Core Python dependencies are installed"
    else
        echo "⚠️  WARNING: Some Python dependencies may be missing" >&2
        echo "Run: pip install -r requirements.txt" >&2
    fi
    
    return 0
}

# Check local virtual environment
check_local_env() {
    echo "ℹ️  Checking local virtual environment..."
    
    detect_platform
    get_project_root
    
    # Define expected virtual environment path
    EXPECTED_VENV_PATH="$PROJECT_ROOT/$VENV_DIR"
    
    # Platform-specific virtual environment check
    if [[ "$PLATFORM" == "windows" ]]; then
        ACTIVATE_SCRIPT="$EXPECTED_VENV_PATH/Scripts/activate"
        PYTHON_EXECUTABLE="$EXPECTED_VENV_PATH/Scripts/python.exe"
    else
        ACTIVATE_SCRIPT="$EXPECTED_VENV_PATH/bin/activate"
        PYTHON_EXECUTABLE="$EXPECTED_VENV_PATH/bin/python"
    fi
    
    # Check if virtual environment exists
    if [[ ! -d "$EXPECTED_VENV_PATH" ]]; then
        echo "❌ ERROR: Virtual environment not found at $EXPECTED_VENV_PATH" >&2
        echo "Please run ./tools/build-scripts/setup.sh to create the development environment." >&2
        exit 1
    fi
    
    # Check if virtual environment is active
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Normalize paths for comparison
        if command -v realpath >/dev/null 2>&1; then
            CURRENT_VENV=$(realpath "$VIRTUAL_ENV")
            EXPECTED_VENV=$(realpath "$EXPECTED_VENV_PATH")
        else
            # Fallback for systems without realpath
            CURRENT_VENV="$VIRTUAL_ENV"
            EXPECTED_VENV="$EXPECTED_VENV_PATH"
        fi
        
        if [[ "$CURRENT_VENV" == "$EXPECTED_VENV" ]]; then
            echo "✅ Correct virtual environment is active"
        else
            echo "❌ ERROR: Wrong virtual environment is active" >&2
            echo "Expected: $EXPECTED_VENV_PATH" >&2
            echo "Current:  $VIRTUAL_ENV" >&2
            echo "Please activate the correct virtual environment:" >&2
            if [[ "$PLATFORM" == "windows" ]]; then
                echo "  $VENV_DIR\\Scripts\\activate" >&2
            else
                echo "  source $VENV_DIR/bin/activate" >&2
            fi
            exit 1
        fi
    else
        echo "❌ ERROR: No virtual environment is active" >&2
        echo "Please activate the project's virtual environment:" >&2
        if [[ "$PLATFORM" == "windows" ]]; then
            echo "  $VENV_DIR\\Scripts\\activate" >&2
        else
            echo "  source $VENV_DIR/bin/activate" >&2
        fi
        exit 1
    fi
    
    # Check Python version and packages
    if [[ -x "$PYTHON_EXECUTABLE" ]]; then
        PYTHON_VERSION=$("$PYTHON_EXECUTABLE" -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        echo "✅ Python $PYTHON_VERSION is available in virtual environment"
        
        # Check if required packages are installed
        if "$PYTHON_EXECUTABLE" -c "import fastapi, pydantic, sqlalchemy" 2>/dev/null; then
            echo "✅ Core Python dependencies are installed"
        else
            echo "⚠️  WARNING: Some Python dependencies may be missing" >&2
            echo "Run: pip install -r requirements.txt" >&2
        fi
    else
        echo "❌ ERROR: Python executable not found in virtual environment" >&2
        exit 1
    fi
    
    return 0
}

# Main execution
main() {
    echo "🔍 ZeroTrace Environment Check"
    echo "============================="
    
    if is_container; then
        check_container_env
    else
        check_local_env
    fi
    
    echo ""
    echo "✅ Environment check completed successfully!"
    
    return 0
}

main "$@"
