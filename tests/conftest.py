"""
ZeroTrace Test Configuration

Test categories:
- unit: Fast, isolated tests
- integration: Tests with external dependencies
- e2e: End-to-end system tests
"""

import asyncio
import os
import tempfile
from pathlib import Path

import pytest


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def temp_dir():
    """Create a temporary directory for tests."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        yield Path(tmp_dir)


@pytest.fixture
def mock_env():
    """Mock environment variables for testing."""
    original_env = os.environ.copy()
    test_env = {
        "POSTGRES_HOST": "localhost",
        "POSTGRES_PORT": "5432",
        "POSTGRES_DB": "zerotrace_test",
        "POSTGRES_USER": "test_user",
        "POSTGRES_PASSWORD": "test_password",
        "RABBITMQ_HOST": "localhost",
        "RABBITMQ_PORT": "5672",
        "RABBITMQ_USER": "test_user",
        "RABBITMQ_PASSWORD": "test_password",
        "LOG_LEVEL": "DEBUG",
        "DEV_MODE": "true",
    }

    os.environ.update(test_env)
    yield test_env

    # Restore original environment
    os.environ.clear()
    os.environ.update(original_env)


@pytest.fixture
def sample_hash():
    """Sample malware hash for testing."""
    return "d41d8cd98f00b204e9800998ecf8427e"


@pytest.fixture
def sample_file_content():
    """Sample file content for YARA testing."""
    return b"This is a test file with some content for YARA scanning."


@pytest.fixture
def yara_rule_basic():
    """Basic YARA rule for testing."""
    return """
rule TestRule
{
    meta:
        description = "Test rule for unit testing"
        author = "ZeroTrace Test"

    strings:
        $test_string = "test file"

    condition:
        $test_string
}
"""
