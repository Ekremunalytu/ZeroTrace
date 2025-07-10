# 🛡️ ZeroTrace
**Modern Açık Kaynak XDR (Extended Detection and Response) Platformu**

> Real-time threat detection, analysis and response enterprise security solution

## 🚀 Quick Start

```bash
# Clone the repository
git clone <your-repo-url>
cd ZeroTrace

# Start development environment
./tools/development/scripts/dev-manager.sh start

# Initialize environment
make init

# Enter development container
make shell
```

That's it! Your complete development environment is ready.

## 🌐 Available Services

After running `make up`, these services will be available:

- **🌐 RabbitMQ Management**: http://localhost:15672 (zerotrace/zerotrace_dev_pass)
- **🗄️ pgAdmin**: http://localhost:5050 (admin@zerotrace.local/admin)  
- **🔧 API**: http://localhost:8000
- **🎨 UI**: http://localhost:3000

## 📋 Essential Commands

```bash
make up      # Start all services
make down    # Stop all services  
make init    # Initialize environment
make build   # Build C++ components
make test    # Run tests
make logs    # Watch logs
make shell   # Enter dev container
make clean   # Clean build files
make help    # Show all commands
```

## 🏗️ Project Architecture

ZeroTrace is built with a microservices architecture using Docker containers:

- **🎯 Services**: Modular microservices (`services/`)
- **🔧 Build System**: Multi-language build configs (`build-system/`)  
- **🛡️ Quality Assurance**: Security, testing, code quality (`quality-assurance/`)
- **💻 Workspace**: IDE configurations (`workspace/`)
- **⚡ Runtime**: Build outputs, cache, temp files (`runtime/`)
- **🚀 Development**: Environment & scripts (`development/`)
- **🏗️ Infrastructure**: Docker, deployment (`infrastructure/`)
- **🗄️ Data**: Persistent data storage (`data/`)
- **📚 Documentation**: All project docs (`docs/`, `project-files/`)

> **For detailed project structure**: `docs/project-organization/PROJE_YAPISI.md`

## 📋 Architecture Overview

```
OS Events → Collectors → RabbitMQ → Analyzers → Database → API → UI
                                      ↓
                             Real-time Alerts
```

**Core Services:**
- **Process Collector** (C++) - Real-time process monitoring
- **Network Monitor** (C++) - Network traffic analysis  
- **Hash Checker** (Python) - Malware hash lookup
- **YARA Scanner** (Python) - Signature-based detection
- **API Service** (Python/FastAPI) - REST API backend
- **UI Service** (React/Vue) - Web dashboard

- **Collectors**: C++ services for high-performance data collection
- **Analyzers**: Python services for threat detection and analysis  
- **API**: REST API for frontend communication
- **UI**: Web dashboard for monitoring and management

## 📁 Project Structure

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed information.

## 🛠️ Development

All development happens inside the development container which includes:
- C++ build tools (CMake, GCC, libraries)
- Python development environment  
- Node.js for UI development
- Database and message broker clients
- All necessary tools and dependencies

## 📚 Documentation

- [Project Structure](PROJECT_STRUCTURE.md) - Detailed directory layout
- [Development Guide](docs/development.md) - Development workflow
- [API Documentation](docs/api.md) - REST API reference
- [Architecture](docs/architecture.md) - System design overview
