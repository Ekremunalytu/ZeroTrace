"""
Service Discovery and Configuration Management for ZeroTrace
Centralized configuration and service discovery
"""

import os
import json
from typing import Dict, Any, Optional
from dataclasses import dataclass
from urllib.parse import urlparse


@dataclass
class ServiceConfig:
    """Service configuration container"""
    host: str
    port: int
    protocol: str = "http"
    
    @property
    def url(self) -> str:
        return f"{self.protocol}://{self.host}:{self.port}"


class ServiceRegistry:
    """Service registry for microservices discovery"""
    
    def __init__(self):
        self._services: Dict[str, ServiceConfig] = {}
        self._load_from_environment()
    
    def _load_from_environment(self):
        """Load service configurations from environment variables"""
        
        # Database service
        self._services["postgres"] = ServiceConfig(
            host=os.getenv("POSTGRES_HOST", "localhost"),
            port=int(os.getenv("POSTGRES_PORT", "5432")),
            protocol="postgresql"
        )
        
        # Message broker
        self._services["rabbitmq"] = ServiceConfig(
            host=os.getenv("RABBITMQ_HOST", "localhost"),
            port=int(os.getenv("RABBITMQ_PORT", "5672")),
            protocol="amqp"
        )
        
        # Cache service
        self._services["redis"] = ServiceConfig(
            host=os.getenv("REDIS_HOST", "localhost"),
            port=int(os.getenv("REDIS_PORT", "6379")),
            protocol="redis"
        )
        
        # API service
        self._services["api"] = ServiceConfig(
            host=os.getenv("API_HOST", "localhost"),
            port=int(os.getenv("API_PORT", "8000")),
            protocol="http"
        )
        
        # UI service
        self._services["ui"] = ServiceConfig(
            host=os.getenv("UI_HOST", "localhost"),
            port=int(os.getenv("UI_PORT", "3000")),
            protocol="http"
        )
    
    def get_service(self, service_name: str) -> Optional[ServiceConfig]:
        """Get service configuration by name"""
        return self._services.get(service_name)
    
    def get_database_url(self) -> str:
        """Get complete database connection URL"""
        db_config = self.get_service("postgres")
        if not db_config:
            raise ValueError("Database service not configured")
        
        user = os.getenv("POSTGRES_USER", "zerotrace")
        password = os.getenv("POSTGRES_PASSWORD", "zerotrace_dev_pass")
        database = os.getenv("POSTGRES_DB", "zerotrace")
        
        return f"postgresql://{user}:{password}@{db_config.host}:{db_config.port}/{database}"
    
    def get_rabbitmq_url(self) -> str:
        """Get complete RabbitMQ connection URL"""
        mq_config = self.get_service("rabbitmq")
        if not mq_config:
            raise ValueError("RabbitMQ service not configured")
        
        user = os.getenv("RABBITMQ_USER", "zerotrace")
        password = os.getenv("RABBITMQ_PASSWORD", "zerotrace_dev_pass")
        vhost = os.getenv("RABBITMQ_VHOST", "/")
        
        return f"amqp://{user}:{password}@{mq_config.host}:{mq_config.port}{vhost}"
    
    def get_redis_url(self) -> str:
        """Get complete Redis connection URL"""
        redis_config = self.get_service("redis")
        if not redis_config:
            raise ValueError("Redis service not configured")
        
        return f"redis://{redis_config.host}:{redis_config.port}/0"
    
    def health_check_all(self) -> Dict[str, bool]:
        """Check health of all registered services"""
        health_status = {}
        
        for service_name, config in self._services.items():
            try:
                # This would normally include actual health checks
                # For now, just check if config exists
                health_status[service_name] = config is not None
            except Exception:
                health_status[service_name] = False
        
        return health_status
    
    def list_services(self) -> Dict[str, Dict[str, Any]]:
        """List all registered services with their configurations"""
        return {
            name: {
                "host": config.host,
                "port": config.port,
                "protocol": config.protocol,
                "url": config.url
            }
            for name, config in self._services.items()
        }


# Global service registry instance
service_registry = ServiceRegistry()


# Convenience functions
def get_database_url() -> str:
    """Get database connection URL"""
    return service_registry.get_database_url()


def get_rabbitmq_url() -> str:
    """Get RabbitMQ connection URL"""
    return service_registry.get_rabbitmq_url()


def get_redis_url() -> str:
    """Get Redis connection URL"""
    return service_registry.get_redis_url()


def get_service_url(service_name: str) -> Optional[str]:
    """Get service URL by name"""
    config = service_registry.get_service(service_name)
    return config.url if config else None


def is_development_mode() -> bool:
    """Check if running in development mode"""
    return os.getenv("DEV_MODE", "false").lower() == "true"


def get_log_level() -> str:
    """Get logging level from environment"""
    return os.getenv("LOG_LEVEL", "INFO").upper()


# Message Queue Topic Constants
class Topics:
    """RabbitMQ topic constants"""
    
    # Raw events from collectors
    EVENTS_RAW_PROCESSES = "events.raw.processes"
    EVENTS_RAW_NETWORK = "events.raw.network"
    EVENTS_RAW_FILESYSTEM = "events.raw.filesystem"
    EVENTS_RAW_PERSISTENCE = "events.raw.persistence"
    
    # Alerts from analyzers
    ALERTS_HIGH_IOC = "alerts.high.ioc_match"
    ALERTS_MEDIUM_YARA = "alerts.medium.yara_match"
    ALERTS_LOW_ANOMALY = "alerts.low.behavior"
    ALERTS_CRITICAL_DECEPTION = "alerts.critical.deception"
    
    # Action requests
    ACTIONS_KILL_PROCESS = "actions.request.kill_process"
    ACTIONS_ISOLATE_HOST = "actions.request.isolate_host"
    ACTIONS_GET_FILE = "actions.request.get_file"
    ACTIONS_COLLECT_FORENSICS = "actions.request.collect_forensics"
    
    # Incidents
    INCIDENTS_CRITICAL = "incidents.critical"


# Exchange and routing configuration
class ExchangeConfig:
    """RabbitMQ exchange configuration"""
    
    EVENTS_EXCHANGE = "zerotrace.events"
    ALERTS_EXCHANGE = "zerotrace.alerts"
    ACTIONS_EXCHANGE = "zerotrace.actions"
    INCIDENTS_EXCHANGE = "zerotrace.incidents"
