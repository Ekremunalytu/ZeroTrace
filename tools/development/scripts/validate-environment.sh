#!/bin/bash
# ZeroTrace Environment Validation Script
# Validates that all development tools and dependencies are properly installed

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                ZeroTrace Environment Validation              ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

check_tool() {
    local tool=$1
    local required=$2
    local install_hint=$3

    if command -v "$tool" >/dev/null 2>&1; then
        version=$(${tool} --version 2>/dev/null | head -n1 || echo "unknown")
        echo -e "✅ ${GREEN}$tool${NC} - $version"
    else
        if [ "$required" = "true" ]; then
            echo -e "❌ ${RED}$tool${NC} - REQUIRED - $install_hint"
            ((ERRORS++))
        else
            echo -e "⚠️  ${YELLOW}$tool${NC} - OPTIONAL - $install_hint"
            ((WARNINGS++))
        fi
    fi
}

check_python_package() {
    local package=$1
    local required=$2

    if python3 -c "import $package" >/dev/null 2>&1; then
        version=$(python3 -c "import $package; print(getattr($package, '__version__', 'unknown'))" 2>/dev/null)
        echo -e "✅ ${GREEN}python:$package${NC} - $version"
    else
        if [ "$required" = "true" ]; then
            echo -e "❌ ${RED}python:$package${NC} - pip install $package"
            ((ERRORS++))
        else
            echo -e "⚠️  ${YELLOW}python:$package${NC} - pip install $package"
            ((WARNINGS++))
        fi
    fi
}

print_header

echo -e "${BLUE}🔧 System Tools${NC}"
check_tool "git" "true" "Install Git from https://git-scm.com/"
check_tool "docker" "true" "Install Docker from https://docker.com/"
check_tool "docker-compose" "true" "Install with: pip install docker-compose"
check_tool "make" "true" "Install build-essential (Linux) or Xcode tools (macOS)"
check_tool "cmake" "true" "Install from https://cmake.org/"
check_tool "python3" "true" "Install Python 3.9+ from https://python.org/"
check_tool "node" "false" "Install Node.js from https://nodejs.org/"
check_tool "curl" "true" "Usually pre-installed"
check_tool "wget" "false" "Install with package manager"

echo
echo -e "${BLUE}🔨 Build Tools${NC}"
check_tool "gcc" "true" "Install build-essential or Xcode tools"
check_tool "g++" "true" "Install build-essential or Xcode tools"
check_tool "clang" "false" "Install clang compiler"
check_tool "clang-format" "false" "Install clang-tools"

echo
echo -e "${BLUE}🐍 Python Environment${NC}"
# Check Python version
python_version=$(python3 --version 2>/dev/null | cut -d' ' -f2)
if [[ "$python_version" > "3.9" ]] || [[ "$python_version" == "3.9"* ]]; then
    echo -e "✅ ${GREEN}Python Version${NC} - $python_version"
else
    echo -e "❌ ${RED}Python Version${NC} - $python_version (Required: 3.9+)"
    ((ERRORS++))
fi

check_python_package "pip" "true"
check_python_package "venv" "true"
check_python_package "fastapi" "false"
check_python_package "pydantic" "false"
check_python_package "pytest" "false"

echo
echo -e "${BLUE}🔍 Quality Tools${NC}"
check_tool "pre-commit" "false" "pip install pre-commit"
check_tool "black" "false" "pip install black"
check_tool "flake8" "false" "pip install flake8"
check_tool "mypy" "false" "pip install mypy"
check_tool "bandit" "false" "pip install bandit"

echo
echo -e "${BLUE}📦 Container Status${NC}"
if docker info >/dev/null 2>&1; then
    echo -e "✅ ${GREEN}Docker Daemon${NC} - Running"

    # Check if our development image exists
    if docker images | grep -q "zerotrace.*dev"; then
        echo -e "✅ ${GREEN}ZeroTrace Dev Image${NC} - Built"
    else
        echo -e "⚠️  ${YELLOW}ZeroTrace Dev Image${NC} - Run 'make setup' to build"
        ((WARNINGS++))
    fi
else
    echo -e "❌ ${RED}Docker Daemon${NC} - Not running or not accessible"
    ((ERRORS++))
fi

echo
echo -e "${BLUE}📁 Project Structure${NC}"
required_dirs=("src" "build" "tests" "docs" "tools")
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "✅ ${GREEN}$dir/${NC} - Present"
    else
        echo -e "❌ ${RED}$dir/${NC} - Missing"
        ((ERRORS++))
    fi
done

required_files=("CMakeLists.txt" "Makefile" "pyproject.toml" ".gitignore")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "✅ ${GREEN}$file${NC} - Present"
    else
        echo -e "❌ ${RED}$file${NC} - Missing"
        ((ERRORS++))
    fi
done

echo
echo -e "${BLUE}📊 Summary${NC}"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "\n🎉 ${GREEN}Environment validation passed!${NC}"
    echo -e "Your development environment is ready for ZeroTrace development."

    if [ $WARNINGS -gt 0 ]; then
        echo -e "\n💡 Consider installing the optional tools above for the best development experience."
    fi

    echo -e "\n🚀 Next steps:"
    echo -e "  1. make setup     # Setup development environment"
    echo -e "  2. make start     # Start development services"
    echo -e "  3. make build     # Build all components"
    echo -e "  4. make test      # Run tests"

    exit 0
else
    echo -e "\n❌ ${RED}Environment validation failed!${NC}"
    echo -e "Please install the missing required tools before continuing."
    exit 1
fi
