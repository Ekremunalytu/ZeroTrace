"""
ZeroTrace Common Event Model
Standard event format for all collectors and analyzers
"""

from datetime import datetime
from typing import Optional, Dict, Any, Union
from pydantic import BaseModel, Field
from enum import Enum
import uuid


class EventType(str, Enum):
    PROCESS_CREATED = "process.created"
    PROCESS_TERMINATED = "process.terminated"
    NETWORK_CONNECTION_ESTABLISHED = "network.connection.established"
    NETWORK_CONNECTION_CLOSED = "network.connection.closed"
    FILE_CREATED = "file.created"
    FILE_MODIFIED = "file.modified"
    FILE_DELETED = "file.deleted"
    PERSISTENCE_REGISTRY_MODIFIED = "persistence.registry.modified"
    PERSISTENCE_STARTUP_CREATED = "persistence.startup.created"


class HashInfo(BaseModel):
    md5: Optional[str] = None
    sha1: Optional[str] = None
    sha256: Optional[str] = None


class SourceInfo(BaseModel):
    service: str = Field(..., description="Name of the collector service")
    version: str = Field(..., description="Version of the collector")
    hostname: str = Field(..., description="Hostname where collector runs")


class ProcessEventData(BaseModel):
    pid: int
    ppid: int
    process_name: str
    command_line: str
    executable_path: Optional[str] = None
    user: Optional[str] = None
    session_id: Optional[int] = None
    integrity_level: Optional[str] = None
    process_guid: Optional[str] = None
    hashes: Optional[HashInfo] = None


class NetworkEventData(BaseModel):
    protocol: str = Field(..., regex="^(TCP|UDP|ICMP)$")
    source_ip: str
    source_port: int = Field(..., ge=1, le=65535)
    destination_ip: str
    destination_port: int = Field(..., ge=1, le=65535)
    process_id: Optional[int] = None
    process_name: Optional[str] = None
    bytes_sent: Optional[int] = None
    bytes_received: Optional[int] = None
    connection_state: Optional[str] = None


class FileEventData(BaseModel):
    file_path: str
    action: str = Field(..., regex="^(created|modified|deleted|renamed)$")
    old_file_path: Optional[str] = None
    file_size: Optional[int] = None
    process_id: Optional[int] = None
    process_name: Optional[str] = None
    user: Optional[str] = None
    hashes: Optional[HashInfo] = None
    file_attributes: Optional[list[str]] = None


class PersistenceEventData(BaseModel):
    technique: str
    location: str
    value: str
    process_id: Optional[int] = None
    process_name: Optional[str] = None
    user: Optional[str] = None


class ZeroTraceEvent(BaseModel):
    """
    Standard event format for ZeroTrace platform
    All collectors must use this format
    """
    event_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    event_type: EventType
    source: SourceInfo
    hostname: str
    data: Union[
        ProcessEventData,
        NetworkEventData, 
        FileEventData,
        PersistenceEventData
    ]

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat() + 'Z'
        }


# Convenience functions for creating events
def create_process_event(
    source: SourceInfo,
    hostname: str,
    event_type: EventType,
    pid: int,
    ppid: int,
    process_name: str,
    command_line: str,
    **kwargs
) -> ZeroTraceEvent:
    """Create a standardized process event"""
    return ZeroTraceEvent(
        event_type=event_type,
        source=source,
        hostname=hostname,
        data=ProcessEventData(
            pid=pid,
            ppid=ppid,
            process_name=process_name,
            command_line=command_line,
            **kwargs
        )
    )


def create_network_event(
    source: SourceInfo,
    hostname: str,
    event_type: EventType,
    protocol: str,
    source_ip: str,
    source_port: int,
    destination_ip: str,
    destination_port: int,
    **kwargs
) -> ZeroTraceEvent:
    """Create a standardized network event"""
    return ZeroTraceEvent(
        event_type=event_type,
        source=source,
        hostname=hostname,
        data=NetworkEventData(
            protocol=protocol,
            source_ip=source_ip,
            source_port=source_port,
            destination_ip=destination_ip,
            destination_port=destination_port,
            **kwargs
        )
    )


def create_file_event(
    source: SourceInfo,
    hostname: str,
    event_type: EventType,
    file_path: str,
    action: str,
    **kwargs
) -> ZeroTraceEvent:
    """Create a standardized file event"""
    return ZeroTraceEvent(
        event_type=event_type,
        source=source,
        hostname=hostname,
        data=FileEventData(
            file_path=file_path,
            action=action,
            **kwargs
        )
    )
