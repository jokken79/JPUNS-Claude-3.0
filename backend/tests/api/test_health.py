"""Tests for health endpoints."""
from __future__ import annotations

from fastapi.testclient import TestClient


def test_root_endpoint(client: TestClient) -> None:
    response = client.get("/")
    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "running"


def test_health_endpoint(client: TestClient) -> None:
    response = client.get("/api/health")
    assert response.status_code == 200
    payload = response.json()
    # Status can be "healthy" or "degraded" depending on DB availability
    assert payload["status"] in ["healthy", "degraded"]
    # Verify new fields are present
    assert "version" in payload
    assert "environment" in payload
    assert "database" in payload
