#!/bin/bash
# Health check script for development container

# Check if essential services are reachable
services_ok=0

# Check PostgreSQL
if pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER >/dev/null 2>&1; then
    echo "✅ PostgreSQL: OK"
    ((services_ok++))
else
    echo "❌ PostgreSQL: NOT REACHABLE"
fi

# Check RabbitMQ
if nc -z $RABBITMQ_HOST $RABBITMQ_PORT >/dev/null 2>&1; then
    echo "✅ RabbitMQ: OK"
    ((services_ok++))
else
    echo "❌ RabbitMQ: NOT REACHABLE"
fi

# Check Redis
if nc -z $REDIS_HOST $REDIS_PORT >/dev/null 2>&1; then
    echo "✅ Redis: OK"
    ((services_ok++))
else
    echo "❌ Redis: NOT REACHABLE"
fi

# Check workspace mount
if [ -d "/workspace" ] && [ "$(ls -A /workspace)" ]; then
    echo "✅ Workspace: MOUNTED"
    ((services_ok++))
else
    echo "❌ Workspace: NOT MOUNTED"
fi

# Return success if at least 3 services are OK
if [ $services_ok -ge 3 ]; then
    echo "🚀 Development environment is healthy ($services_ok/4 services OK)"
    exit 0
else
    echo "💥 Development environment has issues ($services_ok/4 services OK)"
    exit 1
fi
