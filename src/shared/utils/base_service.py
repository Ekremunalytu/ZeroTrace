"""
Base classes for ZeroTrace services
Provides common functionality for all services
"""

import logging
import asyncio
import signal
import sys
from abc import ABC, abstractmethod
from typing import Optional, Dict, Any
import json
import os
from datetime import datetime


class BaseService(ABC):
    """Base class for all ZeroTrace services"""
    
    def __init__(self, service_name: str, version: str = "1.0.0"):
        self.service_name = service_name
        self.version = version
        self.logger = self._setup_logging()
        self.is_running = False
        
        # Setup signal handlers
        signal.signal(signal.SIGINT, self._signal_handler)
        signal.signal(signal.SIGTERM, self._signal_handler)
    
    def _setup_logging(self) -> logging.Logger:
        """Setup structured logging"""
        logger = logging.getLogger(self.service_name)
        logger.setLevel(logging.INFO)
        
        if not logger.handlers:
            handler = logging.StreamHandler(sys.stdout)
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)
        
        return logger
    
    def _signal_handler(self, signum, frame):
        """Handle shutdown signals gracefully"""
        self.logger.info(f"Received signal {signum}, shutting down...")
        self.is_running = False
    
    @abstractmethod
    async def start(self):
        """Start the service"""
        pass
    
    @abstractmethod
    async def stop(self):
        """Stop the service"""
        pass
    
    async def run(self):
        """Main service loop"""
        self.logger.info(f"Starting {self.service_name} v{self.version}")
        self.is_running = True
        
        try:
            await self.start()
            
            # Keep service running
            while self.is_running:
                await asyncio.sleep(1)
                
        except Exception as e:
            self.logger.error(f"Service error: {e}")
        finally:
            await self.stop()
            self.logger.info(f"{self.service_name} stopped")


class BaseCollector(BaseService):
    """Base class for data collectors"""
    
    def __init__(self, service_name: str, version: str = "1.0.0"):
        super().__init__(service_name, version)
        self.hostname = os.uname().nodename
    
    @abstractmethod
    async def collect_data(self) -> Dict[str, Any]:
        """Collect data from the system"""
        pass
    
    @abstractmethod
    async def publish_event(self, event_data: Dict[str, Any]):
        """Publish event to message queue"""
        pass


class BaseAnalyzer(BaseService):
    """Base class for data analyzers"""
    
    def __init__(self, service_name: str, version: str = "1.0.0"):
        super().__init__(service_name, version)
    
    @abstractmethod
    async def analyze_event(self, event: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Analyze an event and return alert if threat detected"""
        pass
    
    @abstractmethod
    async def consume_events(self):
        """Consume events from message queue"""
        pass


# Health check utilities
class HealthCheck:
    """Health check functionality for services"""
    
    @staticmethod
    def get_health_status(service_name: str, additional_checks: Dict[str, bool] = None) -> Dict[str, Any]:
        """Get health status of a service"""
        status = {
            "service": service_name,
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "checks": {
                "service_running": True
            }
        }
        
        if additional_checks:
            status["checks"].update(additional_checks)
            if not all(additional_checks.values()):
                status["status"] = "unhealthy"
        
        return status


# Configuration management
class Config:
    """Configuration management for services"""
    
    @staticmethod
    def get_env(key: str, default: Any = None) -> Any:
        """Get environment variable with default"""
        return os.getenv(key, default)
    
    @staticmethod
    def get_database_url() -> str:
        """Get database connection URL"""
        host = Config.get_env("POSTGRES_HOST", "localhost")
        port = Config.get_env("POSTGRES_PORT", "5432")
        db = Config.get_env("POSTGRES_DB", "zerotrace")
        user = Config.get_env("POSTGRES_USER", "zerotrace")
        password = Config.get_env("POSTGRES_PASSWORD", "zerotrace_dev_pass")
        
        return f"postgresql://{user}:{password}@{host}:{port}/{db}"
    
    @staticmethod
    def get_rabbitmq_url() -> str:
        """Get RabbitMQ connection URL"""
        host = Config.get_env("RABBITMQ_HOST", "localhost")
        port = Config.get_env("RABBITMQ_PORT", "5672")
        user = Config.get_env("RABBITMQ_USER", "zerotrace")
        password = Config.get_env("RABBITMQ_PASSWORD", "zerotrace_dev_pass")
        vhost = Config.get_env("RABBITMQ_VHOST", "/")
        
        return f"amqp://{user}:{password}@{host}:{port}{vhost}"
