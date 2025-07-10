# 📁 ZeroTrace - Ultra Modüler Proje Yapısı

## 🎯 Minimalist Ana Dizin

```
ZeroTrace/
├── 📋 README.md                  # Ana proje dokümantasyonu
├── 📄 LICENSE                    # Lisans dosyası  
├── 🔧 Makefile                   # Ana build proxy (build-system'e yönlendirir)
├── 🗂️ .gitignore                 # Git ignore kuralları
└── 📝 PROJE_YAPISI.md           # Bu dokümantasyon
```

## 🏗️ Modüler Klasör Yapısı

### 🔧 Build ve Konfigürasyon
```
build-system/
├── cmake/                       # CMake yapılandırmaları
│   └── CMakeLists.txt           # Ana CMake dosyası
├── make/                        # Make yapılandırmaları  
│   └── Makefile                 # Ana Makefile
└── python/                      # Python paket yapılandırması
    ├── pyproject.toml           # Modern Python projesi config
    ├── requirements.txt         # Bağımlılıklar
    └── setup.py                 # Kurulum scripti
```

### 🛡️ Kalite Güvence Sistemi
```
quality-assurance/
├── security/                    # Güvenlik araçları
│   └── .secrets.baseline        # Güvenlik baseline
├── code-quality/                # Kod kalitesi araçları
│   └── .pre-commit-config.yaml  # Pre-commit hooks
└── coverage/                    # Test coverage
    └── .coverage                # Coverage raporu
```

### 💻 Workspace ve IDE Ayarları
```
workspace/
├── vscode/                      # VS Code yapılandırması
│   └── zerotrace.code-workspace # VS Code workspace
├── devcontainer/               # Development Container
│   └── .devcontainer/          # DevContainer yapılandırması
└── jetbrains/                  # IntelliJ IDEA/CLion
    └── .idea/                  # IDE ayarları
```

### ⚡ Runtime ve Geçici Dosyalar
```
runtime/
├── build/                      # Build çıktıları
│   └── cmake-build/           # CMake build dosyaları
├── cache/                     # Cache dosyaları
│   ├── pytest/               # Pytest cache
│   └── python-package/       # Python package cache
├── temp/                      # Geçici dosyalar
│   └── tmp/                  # Temporary files
└── venv/                      # Virtual environments
    └── python/               # Python venv
```

### 🚀 Geliştirme Ortamı
```
development/
├── environment/               # Ortam değişkenleri
│   ├── .env                  # Geliştirme ortamı
│   ├── .env.example          # Örnek yapılandırma
│   └── .env.production       # Üretim ortamı
└── scripts/                  # Geliştirme scriptleri
    └── dev-manager.sh        # Ana geliştirme yöneticisi
```

### 🏗️ Altyapı ve DevOps
```
infrastructure/
├── docker/                   # Container yapılandırmaları
│   ├── docker-compose.yml    # Ana orkestrasyon
│   ├── docker-compose.prod.yml
│   ├── Dockerfile.dev
│   └── Dockerfile.prod
└── scripts/                  # Deployment scriptleri
```

### 🎯 Uygulama Servisleri
```
services/
├── collectors/               # Veri Toplama Katmanı
│   ├── process-collector/    # C++ process monitoring
│   ├── network-monitor/      # C++ network analysis
│   └── system-info/          # Python system info
├── analyzers/                # Analiz Katmanı
│   ├── hash-checker/         # Hash database lookup
│   ├── yara-scanner/         # YARA rule engine
│   ├── threat-analyzer/      # Threat analysis
│   └── virustotal-checker/   # VirusTotal integration
├── core/                     # Çekirdek Servisler
│   └── data-processor/       # Event processing
├── api/                      # REST API Service
└── ui/                       # Web Dashboard
```

### 🗄️ Veri ve Konfigürasyon
```
data/                         # Kalıcı veri depolama
configs/                      # Yapılandırma dosyaları
shared/                       # Paylaşılan kütüphaneler
tests/                        # Test framework
tools/                        # Geliştirme araçları
docs/                         # API dokümantasyonu
scripts/                      # Utility scriptleri
```

### 📝 Proje Dosyaları
```
project-files/
├── documentation/            # Detaylı dokümantasyon
├── diagrams/                # Proje diyagramları
└── build-configs/           # Eski build yapılandırmaları
```

## 🎨 Klasör Simgeleri ve Anlamları

- 🔧 **Build Sistemi**: Derleme ve paketleme araçları
- 🛡️ **Kalite Güvence**: Güvenlik, kod kalitesi, test coverage
- 💻 **Workspace**: IDE ve geliştirme ortamı ayarları
- ⚡ **Runtime**: Geçici dosyalar, cache, build çıktıları
- � **Development**: Geliştirme araçları ve environment
- 🏗️ **Infrastructure**: Container, deployment, DevOps
- 🎯 **Services**: Ana uygulama bileşenleri
- 🗄️ **Data**: Kalıcı veri ve konfigürasyon
- 📝 **Project**: Meta dosyalar ve dokümantasyon

## 🚀 Ultra Modüler Yapının Avantajları

### 1. � **Temiz Ana Dizin**
- Sadece 5 temel dosya ana dizinde
- Proje açıldığında ne yapacağı net
- Karışıklık sıfır seviyede

### 2. 🎯 **Amaç Bazlı Gruplama**
- Her klasör belirli bir amaca hizmet eder
- İlgili dosyalar birlikte tutuluyor
- Modüler genişletme kolaylığı

### 3. 🔄 **Sürdürülebilir Organizasyon**
- Yeni özellikler doğru yerlere eklenir
- Refactoring kolaylaşır
- Teknik borç azalır

### 4. 👥 **Ekip Dostu**
- Yeni geliştiriciler hızla adapte olur
- Dosya arama zamanı minimize
- Code review süreçleri hızlanır

### 5. 🔧 **Araç Entegrasyonu**
- IDE'ler daha iyi çalışır
- Build araçları optimize
- CI/CD pipeline'lar sadeleşir

## � Kullanım Örnekleri

### Ana komutlar (kök dizinden)
```bash
# Geliştirme ortamını başlat
make dev-setup

# Projeyi derle  
make build

# Testleri çalıştır
make test

# Tüm geçici dosyaları temizle
make clean-all
```

### Belirli modüllerde çalışma
```bash
# Build sistem ayarları
cd build-system/python
nano requirements.txt

# Güvenlik konfigürasyonu
cd quality-assurance/security  
nano .secrets.baseline

# Development ortamı
cd development/environment
nano .env

# Workspace ayarları
cd workspace/vscode
code zerotrace.code-workspace
```

---
*Bu ultra modüler yapı ile ZeroTrace projesi maksimum organizasyon ve minimum karışıklık seviyesine ulaşmıştır! 🎉*
