# YARA Scanner Service

OS-specific YARA rule'ları ile dosya tarama servisi.

## Özellikler
- 10K+ YARA rule desteği
- OS-based rule filtering (Windows/Linux/macOS)
- Real-time file scanning
- Rule compilation caching

## Teknolojiler
- Python 3.11+
- yara-python
- FastAPI
- Redis (rule caching)

## Rule Organization
```
data/yara-rules/
├── windows/
├── linux/
├── macos/
└── generic/
```

## Configuration
- `YARA_RULES_PATH` - YARA rules directory
- `TARGET_OS` - Target operating system
- `REDIS_URL` - Rule cache URL
