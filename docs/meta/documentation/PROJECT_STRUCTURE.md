# ZeroTrace Project Structure

## 📁 Directory Organization

```
ZeroTrace/
├── 🏗️ infrastructure/          # Container orchestration & DevOps
│   ├── docker/                 # Docker-related files
│   │   ├── docker-compose.yml  # Main orchestration
│   │   ├── docker-compose.dev.yml
│   │   ├── docker-compose.prod.yml
│   │   └── dockerfiles/        # Service-specific Dockerfiles
│   └── scripts/                # Deployment & maintenance scripts
│
├── 🔧 services/                # Microservices
│   ├── collectors/             # Data Collection Layer
│   │   ├── process-collector/  # C++ process monitoring
│   │   ├── network-monitor/    # C++ network traffic analysis
│   │   └── system-info/        # Python system information
│   │
│   ├── analyzers/              # Analysis Layer
│   │   ├── hash-checker/       # Python hash database lookup
│   │   ├── yara-scanner/       # Python YARA rule engine
│   │   └── virustotal-checker/ # Python VirusTotal integration
│   │
│   ├── core/                   # Core Services
│   │   ├── data-processor/     # Event ingestion & correlation
│   │   └── message-broker/     # RabbitMQ wrapper service
│   │
│   ├── api/                    # REST API Service
│   └── ui/                     # Web Dashboard
│
├── 🗄️ data/                    # Persistent Data Storage
│   ├── databases/              # PostgreSQL data directory
│   ├── hash-db/               # 800K malware hash database
│   ├── yara-rules/            # YARA signature files
│   └── logs/                  # Application logs
│
├── ⚙️ configs/                 # Configuration Management
│   ├── development/           # Dev environment configs
│   ├── production/            # Prod environment configs
│   ├── testing/               # Test environment configs
│   └── shared/                # Common configurations
│
├── 🔗 shared/                  # Shared Libraries & Schemas
│   ├── data-schemas/          # Common data structures
│   ├── proto/                 # Protocol buffers (if needed)
│   └── utils/                 # Shared utilities
│
├── 🧪 tests/                   # Testing Framework
│   ├── integration/           # Integration tests
│   ├── e2e/                   # End-to-end tests
│   └── fixtures/              # Test data
│
├── 📚 docs/                    # Documentation
│   ├── api/                   # API documentation
│   ├── architecture/          # System design docs
│   └── deployment/            # Deployment guides
│
├── 🛠️ tools/                   # Development Tools
│   ├── monitoring/            # Health check tools
│   ├── security/              # Security analysis tools
│   └── scripts/               # Utility scripts
│
└── 📋 Root Files
    ├── docker-compose.yml     # Main orchestration file
    ├── .env.example          # Environment template
    ├── Makefile              # Build automation
    └── README.md             # Project overview
```

## 🐳 Container Architecture

### Infrastructure Containers
- **rabbitmq**: Message broker for service communication
- **postgres**: Primary database for events and analysis results
- **nginx**: Reverse proxy and load balancer

### Application Containers
- **process-collector**: Real-time process monitoring (C++)
- **network-monitor**: Network traffic analysis (C++)
- **hash-checker**: Malware hash lookup service (Python)
- **yara-scanner**: File signature scanning (Python)
- **virustotal-checker**: External threat intelligence (Python)
- **api-service**: REST API backend (Python/FastAPI)
- **ui-service**: Web dashboard frontend (React/Vue)

## 🔄 Data Flow

```
OS Events → Collectors → RabbitMQ → Analyzers → Database → API → UI
                                       ↓
                              Real-time Alerts
```

## 🚀 Quick Start

```bash
# Clone and setup
git clone <repo>
cd ZeroTrace

# Start infrastructure
docker-compose up -d

# Development mode
docker-compose -f docker-compose.dev.yml up

# View logs
docker-compose logs -f <service-name>
```

## 📝 Development Guidelines

1. **Service Independence**: Each service should be deployable independently
2. **Configuration**: Use environment variables for all configurations
3. **Logging**: Structured JSON logging for all services
4. **Health Checks**: Every service must have health check endpoint
5. **Testing**: Unit tests required for all core functionality

## 🔧 Environment Management

- **Development**: Local development with hot reload
- **Testing**: Automated testing environment
- **Production**: Optimized production deployment

Each environment has its own configuration in `configs/<env>/`
