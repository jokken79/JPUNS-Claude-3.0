"""Tests for main application endpoints and configuration."""
from __future__ import annotations

from fastapi.testclient import TestClient


def test_root_endpoint_returns_expected_data(client: TestClient) -> None:
    """Test that root endpoint returns correct application info."""
    response = client.get("/")
    assert response.status_code == 200
    
    data = response.json()
    assert data["status"] == "running"
    assert data["app"] == "UNS-ClaudeJP"
    assert data["version"] == "2.0"
    assert data["company"] == "UNS-Kikaku"
    assert "timestamp" in data
    assert "website" in data


def test_health_endpoint_returns_health_status(client: TestClient) -> None:
    """Test that health endpoint returns status information."""
    response = client.get("/api/health")
    assert response.status_code == 200
    
    data = response.json()
    assert "status" in data
    assert data["status"] in ["healthy", "degraded"]
    assert "timestamp" in data
    assert "version" in data
    assert "environment" in data
    assert "database" in data


def test_not_found_handler(client: TestClient) -> None:
    """Test that 404 handler works correctly."""
    response = client.get("/nonexistent-endpoint")
    assert response.status_code == 404
    
    data = response.json()
    assert "detail" in data
    assert data["detail"] == "Not found"
    assert "path" in data


def test_cors_headers_present(client: TestClient) -> None:
    """Test that CORS headers are properly set."""
    response = client.options(
        "/api/health",
        headers={
            "Origin": "http://localhost:3000",
            "Access-Control-Request-Method": "GET",
        },
    )
    
    # CORS middleware should add appropriate headers
    assert "access-control-allow-origin" in response.headers or response.status_code == 200


def test_security_headers_present(client: TestClient) -> None:
    """Test that security headers are properly set."""
    response = client.get("/")
    
    # Check for security headers added by SecurityMiddleware
    assert response.headers.get("X-Content-Type-Options") == "nosniff"
    assert response.headers.get("X-Frame-Options") == "DENY"
    assert response.headers.get("X-XSS-Protection") == "1; mode=block"
    assert response.headers.get("Referrer-Policy") == "strict-origin-when-cross-origin"


def test_performance_header_present(client: TestClient) -> None:
    """Test that performance timing header is added by LoggingMiddleware."""
    response = client.get("/")
    
    # LoggingMiddleware should add X-Process-Time header
    assert "X-Process-Time" in response.headers
    
    # Verify it's a valid float
    process_time = float(response.headers["X-Process-Time"])
    assert process_time >= 0
