"""Monitoring and health-check endpoints."""
from __future__ import annotations

import platform
import time
from typing import Any, Dict

from fastapi import APIRouter, HTTPException

from app.core.logging import app_logger
# OCR service removed - using Azure OCR service instead
# from app.services.ocr_service import ocr_service

router = APIRouter()


@router.get("/health", summary="Detailed health information")
async def detailed_health() -> Dict[str, Any]:
    try:
        # OCR service removed - using Azure OCR service instead
        started = None
        return {
            "status": "ok",
            "timestamp": time.time(),
            "system": {
                "platform": platform.platform(),
                "python": platform.python_version(),
            },
            "ocr": {
                # OCR service removed - using Azure OCR service instead
                "cache_entries": 0,
                "last_warmup": started,
            },
        }
    except Exception as exc:  # pragma: no cover - defensive
        app_logger.exception("Health endpoint failed")
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/metrics", summary="Application metrics")
async def metrics() -> Dict[str, Any]:
    # OCR service removed - using Azure OCR service instead
    stats = {"cache_entries": 0, "total_requests": 0}
    return {
        "ocr_total_requests": stats.get("total_requests"),
        "ocr_cache_hits": stats.get("cache_hits"),
        "ocr_cache_hit_rate": stats.get("cache_hit_rate"),
        "ocr_average_processing_time": stats.get("average_processing_time"),
    }


@router.delete("/cache", summary="Clear OCR cache")
async def clear_cache() -> Dict[str, Any]:
    # OCR service removed - using Azure OCR service instead
    result = {"success": True, "message": "Cache cleared successfully (Azure OCR doesn't use cache)"}
    return result
