# Hash Checker Service

Bu servis 800.000 malware hash'ini veritabanında saklayarak dosya hash'lerini kontrol eder.

## Özellikler
- PostgreSQL tabanlı hash database
- MD5, SHA1, SHA256 hash desteği
- RabbitMQ ile event-driven communication
- REST API endpoint'leri

## Teknolojiler
- Python 3.11+
- FastAPI/Flask
- PostgreSQL
- SQLAlchemy ORM
- Celery (background tasks)

## API Endpoints
- `POST /check-hash` - Hash kontrolü
- `GET /stats` - Database istatistikleri
- `GET /health` - Health check

## Configuration
Environment variables:
- `POSTGRES_HOST` - Database host
- `POSTGRES_DB` - Database name
- `RABBITMQ_URL` - Message broker URL
- `LOG_LEVEL` - Logging level
