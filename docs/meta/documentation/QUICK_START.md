# ZeroTrace XDR - Quick Start Guide

## 🚀 Cross-Platform Development Environment

ZeroTrace projesi artık **işletim sisteminden tamamen bağımsız** bir geliştirme ortamı sunuyor. Tüm geliştirme araçları sanal ortamlarda çalışıyor ve host sisteminizi kirletmiyor.

## 📋 Gereksinimler

### Minimum Gereksinimler
- **Docker Desktop** (önerilen) veya **Docker Engine + Docker Compose**
- **Git**
- **Make** (opsiyonel, kolaylık için)

### Desteklenen Platformlar
- ✅ **macOS** (Intel ve Apple Silicon)
- ✅ **Linux** (Ubuntu, Debian, RHEL, Arch, etc.)
- ✅ **Windows** (WSL2, Git Bash, veya PowerShell)

## 🎯 Hızlı Başlangıç

### Yöntem 1: Tek Komutla Kurulum (Önerilen)
```bash
# Repository'yi klonlayın
git clone <repository-url>
cd ZeroTrace

# Otomatik kurulum
make setup
# veya
./dev setup
```

### Yöntem 2: Manuel Kurulum
```bash
# Container tabanlı kurulum (önerilen)
./scripts/setup.sh --container

# Yerel kurulum (Docker yoksa)
./scripts/setup.sh --local
```

## 🛠️ Geliştirme Komutları

### Temel Komutlar
```bash
# Geliştirme ortamını başlat
make start
# veya
./dev start

# Geliştirme shell'i aç
make shell
# veya
./dev shell

# Tüm bileşenleri build et
make build
# veya
./dev build

# Testleri çalıştır
make test
# veya
./dev test
```

### Detaylı Komutlar
```bash
# Sadece C++ bileşenlerini build et
./dev build cpp

# Sadece Python bileşenlerini build et
./dev build python

# Unit testleri çalıştır
./dev test tests/unit/

# Code linting
./dev lint

# Code formatting
./dev format

# Güvenlik taraması
./dev security

# Build artifact'lerini temizle
./dev clean
```

## 🐳 Container vs Local Development

### Container Development (Önerilen)
- ✅ **Platform bağımsız**: Tüm platformlarda aynı environment
- ✅ **Host sistemi kirletmez**: Tüm bağımlılıklar container'da
- ✅ **Tutarlı**: Tüm geliştirici aynı environment'ı kullanır
- ✅ **Kolay kurulum**: Docker yeterli

### Local Development (Fallback)
- ⚠️ Platform bağımlı
- ⚠️ Host sistemde C++ kütüphaneleri gerekir
- ✅ Daha hızlı startup
- ✅ Docker gerektirmez

## 🔧 VS Code Integration

### Dev Containers (Önerilen)
1. **Dev Containers** extension'ı yükleyin
2. Command Palette'i açın (`Ctrl+Shift+P` / `Cmd+Shift+P`)
3. **Dev Containers: Reopen in Container** seçin
4. Container içinde development başlayın

### Local Development
1. Virtual environment'ı aktif edin:
   ```bash
   # macOS/Linux
   source .venv/bin/activate
   
   # Windows
   .venv\Scripts\activate
   ```

## 📊 Environment Status

Environment durumunu kontrol etmek için:
```bash
# Detaylı durum bilgisi
./dev status

# Environment kontrolü
./dev check
```

## 🔄 Environment Management

```bash
# Environment'ı başlat
./dev start

# Environment'ı durdur
./dev stop

# Environment'ı sıfırla (dikkat: destructive!)
./dev reset

# Logları görüntüle
./dev logs
```

## 🎯 VS Code Setup

Proje ile birlikte gelen VS Code konfigürasyonu:
- ✅ Python linting ve formatting
- ✅ C++ development tools
- ✅ Integrated debugging
- ✅ Docker integration
- ✅ Git integration

## 🚨 Troubleshooting

### Docker Issues
```bash
# Docker durumunu kontrol et
docker info

# Container'ları yeniden başlat
./dev stop
./dev start

# Container'ları sil ve yeniden oluştur
./dev reset
./dev setup
```

### Permission Issues (Linux/macOS)
```bash
# Script'leri executable yap
chmod +x dev scripts/*.sh

# User ID mapping (Linux)
export USER_UID=$(id -u)
export USER_GID=$(id -g)
```

### Windows Issues
```bash
# WSL2 kullanın (önerilen)
# veya Git Bash kullanın
# PowerShell için .ps1 script'leri eklenebilir
```

## 📚 Available Commands

### Environment Management
- `./dev setup` - Development environment kurulumu
- `./dev start` - Environment'ı başlat
- `./dev stop` - Environment'ı durdur
- `./dev shell` - Development shell aç
- `./dev status` - Environment durumu
- `./dev reset` - Environment'ı sıfırla

### Development
- `./dev build [target]` - Build (cpp|python|all)
- `./dev test [pattern]` - Test çalıştır
- `./dev lint` - Code linting
- `./dev format` - Code formatting
- `./dev security` - Güvenlik taraması
- `./dev clean` - Build artifacts temizle

### Services
- `./dev services` - Tüm servisleri başlat
- `./dev db` - Sadece database başlat
- `./dev queue` - Sadece message queue başlat
- `./dev logs` - Container logları

## 🎉 Next Steps

1. **Setup completed**: `./dev setup`
2. **Start development**: `./dev start && ./dev shell`
3. **Build project**: `./dev build`
4. **Run tests**: `./dev test`
5. **Start coding**: VS Code ile container'a bağlan

## 💡 Pro Tips

- `make` komutları da kullanılabilir: `make setup`, `make build`, etc.
- VS Code Dev Containers extension ile seamless development
- `./dev help` ile tüm komutları görün
- Container development önerilen yöntemdir
- Local development sadece Docker yoksa kullanın

## 🆘 Yardım

```bash
# Tüm komutları görün
./dev help

# Makefile yardımı
make help

# Environment kontrolü
./dev check
```

---

**Not**: Bu kurulum tamamen cross-platform ve containerized'dır. Host sisteminize herhangi bir C++ kütüphanesi yüklemenize gerek yoktur.
