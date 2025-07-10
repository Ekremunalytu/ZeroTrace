"""
Basic tests for ZeroTrace platform
"""

import sys
from pathlib import Path

import pytest


def test_python_version():
    """Test that we're running Python 3.9+"""
    assert sys.version_info >= (3, 9), (
        f"Python 3.9+ required, got {sys.version_info}"
    )


def test_imports():
    """Test that core modules can be imported"""
    try:
        import fastapi  # noqa: F401
        import pydantic  # noqa: F401
        import pytest  # noqa: F401
        import requests  # noqa: F401
        import sqlalchemy  # noqa: F401
        import uvicorn  # noqa: F401

        assert True
    except ImportError as e:
        pytest.fail(f"Failed to import required module: {e}")


def test_project_structure():
    """Test that basic project structure exists"""
    project_root = Path(__file__).parent.parent

    # Check essential directories
    essential_dirs = [
        "src", "build", "tests", "tools", "docs"
    ]

    for dir_name in essential_dirs:
        dir_path = project_root / dir_name
        assert dir_path.exists(), (
            f"Essential directory missing: {dir_name}"
        )


def test_configuration_files():
    """Test that configuration files exist"""
    project_root = Path(__file__).parent.parent

    config_files = [
        "build/python/pyproject.toml",
        "build/python/requirements.txt", 
        "build/docker/docker-compose.yml",
        "CMakeLists.txt",
        "Makefile",
    ]

    for file_name in config_files:
        file_path = project_root / file_name
        assert file_path.exists(), (
            f"Configuration file missing: {file_name}"
        )


def test_docker_compose_validity():
    """Test that docker-compose.yml is valid"""
    project_root = Path(__file__).parent.parent
    compose_file = project_root / "build/docker/docker-compose.yml"

    assert compose_file.exists()
    content = compose_file.read_text()

    # Basic validation
    assert "services:" in content
    assert "devcontainer:" in content
    assert "postgres:" in content
    assert "rabbitmq:" in content


if __name__ == "__main__":
    pytest.main([__file__])
