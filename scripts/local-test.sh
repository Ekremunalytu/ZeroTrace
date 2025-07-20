#!/bin/bash

# ZeroTrace Local Test Script
# Bu script GitHub Actions CI/CD pipeline'ını local ortamda simüle eder

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Başlık fonksiyonu
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Cleanup function
cleanup() {
    print_header "Cleanup"
    docker-compose -f build/docker/docker-compose.yml down -v || true
    print_success "Cleanup completed"
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

print_header "ZeroTrace Local Testing Pipeline"

# Python version kontrolü
print_header "Environment Check"
python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
echo "Python version: $python_version"

if [[ ! "$python_version" =~ ^3\.(11|12) ]]; then
    print_warning "Python 3.11 veya 3.12 önerilir (mevcut: $python_version)"
fi

# Virtual environment oluştur
print_header "Virtual Environment Setup"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    print_success "Virtual environment oluşturuldu"
else
    print_success "Virtual environment mevcut"
fi

# Virtual environment'ı aktive et
source venv/bin/activate
print_success "Virtual environment aktive edildi"

# Dependencies yükle
print_header "Installing Dependencies"
pip install --upgrade pip
pip install -e ".[dev]" || {
    print_error "Dependencies yüklenemedi. requirements.txt dosyasını kontrol edin."
    # Fallback: temel paketleri yükle
    pip install pytest pytest-cov flake8 black isort mypy bandit safety
}
print_success "Dependencies yüklendi"

# Code Quality Checks
print_header "Code Quality Checks"

# Flake8 lint
echo "🔍 Flake8 linting..."
flake8 src/ tests/ --count --select=E9,F63,F7,F82 --show-source --statistics || print_warning "Flake8 critical errors bulundu"
flake8 src/ tests/ --count --exit-zero --max-complexity=10 --max-line-length=88 --statistics || print_warning "Flake8 style issues bulundu"
print_success "Flake8 tamamlandı"

# Black formatting check
echo "🎨 Black format kontrolü..."
if command -v black &> /dev/null; then
    black --check src/ tests/ || print_warning "Black formatting issues bulundu. 'black src/ tests/' ile düzeltebilirsiniz."
    print_success "Black kontrolü tamamlandı"
else
    print_warning "Black yüklü değil"
fi

# Isort check
echo "📦 Import sıralama kontrolü..."
if command -v isort &> /dev/null; then
    isort --check-only src/ tests/ || print_warning "Import sıralama issues bulundu. 'isort src/ tests/' ile düzeltebilirsiniz."
    print_success "Isort kontrolü tamamlandı"
else
    print_warning "Isort yüklü değil"
fi

# MyPy type checking
echo "🔍 MyPy type kontrolü..."
if command -v mypy &> /dev/null; then
    mypy src/ || print_warning "MyPy type errors bulundu"
    print_success "MyPy kontrolü tamamlandı"
else
    print_warning "MyPy yüklü değil"
fi

# Security check
echo "🔐 Bandit security kontrolü..."
if command -v bandit &> /dev/null; then
    bandit -r src/ || print_warning "Security issues bulundu"
    print_success "Bandit kontrolü tamamlandı"
else
    print_warning "Bandit yüklü değil"
fi

# Safety check
echo "🛡️ Safety dependency kontrolü..."
if command -v safety &> /dev/null; then
    safety check || print_warning "Vulnerable dependencies bulundu"
    print_success "Safety kontrolü tamamlandı"
else
    print_warning "Safety yüklü değil"
fi

# Docker Services Setup
print_header "Setting Up Test Services"

# Docker kontrolü
if ! command -v docker &> /dev/null; then
    print_error "Docker yüklü değil!"
    exit 1
fi

# Docker services başlat
echo "🐳 Docker services başlatılıyor..."
cd build/docker
docker-compose up -d postgres rabbitmq
cd ../..

# Services'in hazır olmasını bekle
echo "⏳ Services'in hazır olmasını bekleniyor..."
sleep 30

# Service durumlarını kontrol et
echo "📋 Service durumları:"
cd build/docker
docker-compose ps
cd ../..

# Environment variables ayarla
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_DB=zerotrace_test
export POSTGRES_USER=test_user
export POSTGRES_PASSWORD=test_password
export RABBITMQ_HOST=localhost
export RABBITMQ_PORT=5672
export RABBITMQ_USER=test_user
export RABBITMQ_PASSWORD=test_password

print_success "Test services hazır"

# Run Tests
print_header "Running Tests"

echo "🧪 Testler çalıştırılıyor..."
pytest --cov=src --cov-report=xml --cov-report=term-missing || {
    print_error "Testler başarısız!"
    exit 1
}
print_success "Tüm testler başarılı!"

# Coverage report
if [ -f "coverage.xml" ]; then
    echo "📊 Coverage raporu oluşturuldu: coverage.xml"
fi

# Docker Build Test (opsiyonel)
read -p "Docker build testi yapmak istiyor musunuz? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_header "Docker Build Test"

    echo "🏗️ Docker images build ediliyor..."
    cd build/docker
    docker-compose build

    echo "🧪 Docker services testi..."
    docker-compose up -d
    sleep 30
    docker-compose ps
    docker-compose down
    cd ../..

    print_success "Docker build testi tamamlandı"
fi

print_header "Test Pipeline Completed Successfully!"
print_success "Tüm testler başarıyla tamamlandı! 🎉"

# Virtual environment'dan çık
deactivate
