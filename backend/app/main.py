"""FastAPI application entry point."""
from __future__ import annotations

from datetime import datetime
import os

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.core.database import init_db
from app.core.logging import app_logger
from app.core.middleware import ExceptionHandlerMiddleware, LoggingMiddleware, SecurityMiddleware

app = FastAPI(
    title=f"{settings.APP_NAME} API",
    description="""## UNS-ClaudeJP v2.0 - API de Gestión de Personal Temporal

### Características Principales
- **OCR Híbrido**: Gemini + Vision API + Tesseract con caché inteligente
- **Gestión de Personal**: Candidatos, empleados, fábricas y tarjetas de tiempo
- **Nóminas Automatizadas**: Cálculo según normativa laboral japonesa
- **Notificaciones**: Integración con Email y LINE
- **Monitoreo**: Endpoints de health check y métricas

### Autenticación
La API utiliza tokens JWT. Incluye el header: `Authorization: Bearer <token>`.

### Formato de Respuesta
Todas las respuestas retornan JSON estructurado con mensajes y códigos claros.
""",
    version=settings.APP_VERSION,
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json",
    contact={
        "name": "UNS-Kikaku Support",
        "email": "support@uns-kikaku.com",
        "url": settings.COMPANY_WEBSITE,
    },
    license_info={"name": "Proprietary"},
    servers=[
        {"url": "http://localhost:8000", "description": "Development"},
        {"url": "https://api.uns-kikaku.com", "description": "Production"},
    ],
)

# Middleware order matters: outermost first (processes response last)
# Exception handler should be outermost to catch all errors
app.add_middleware(ExceptionHandlerMiddleware)
app.add_middleware(LoggingMiddleware)
app.add_middleware(SecurityMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# TrustedHostMiddleware should use a list for production
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["*"] if settings.DEBUG else ["uns-kikaku.com", "*.uns-kikaku.com", "localhost"]
)

# Ensure required directories exist
try:
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    os.makedirs(os.path.dirname(settings.LOG_FILE), exist_ok=True)
    app_logger.info("Required directories created/verified")
except Exception as exc:
    app_logger.warning(f"Could not create directories: {exc}")

# Mount static files for uploads
try:
    if os.path.exists(settings.UPLOAD_DIR) and os.path.isdir(settings.UPLOAD_DIR):
        app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")
        app_logger.info(f"Mounted static files from {settings.UPLOAD_DIR}")
except Exception as exc:
    app_logger.warning(f"Could not mount static files: {exc}")


@app.on_event("startup")
async def on_startup() -> None:
    """Application startup event handler."""
    app_logger.info(
        "Starting application",
        app_name=settings.APP_NAME,
        version=settings.APP_VERSION,
        environment=settings.ENVIRONMENT,
        debug=settings.DEBUG,
    )
    
    # Initialize database tables
    try:
        init_db()
        app_logger.info("Database tables initialized successfully")
    except Exception as exc:  # pragma: no cover - database might be unavailable in tests
        app_logger.exception("Database initialization failed", error=str(exc))
        if not settings.DEBUG:
            # In production, we might want to fail fast
            app_logger.critical("Cannot start application without database")
            raise
    
    # Log configuration summary
    app_logger.info(
        "Application configuration",
        cors_origins=len(settings.BACKEND_CORS_ORIGINS),
        upload_dir=settings.UPLOAD_DIR,
        ocr_enabled=settings.OCR_ENABLED,
    )


@app.on_event("shutdown")
async def on_shutdown() -> None:
    app_logger.info("Shutting down application")


@app.get("/")
async def root() -> dict:
    return {
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "company": settings.COMPANY_NAME,
        "website": settings.COMPANY_WEBSITE,
        "status": "running",
        "timestamp": datetime.now().isoformat(),
    }


@app.get("/api/health")
async def health_check() -> dict:
    """Health check endpoint with database connectivity verification."""
    from sqlalchemy import text
    
    health_status = {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
    }
    
    # Check database connectivity
    try:
        from app.core.database import SessionLocal
        db = SessionLocal()
        try:
            # Simple query to check database is responsive
            db.execute(text("SELECT 1"))
            health_status["database"] = "connected"
        except Exception as db_exc:
            app_logger.error(f"Database health check failed: {db_exc}")
            health_status["database"] = "disconnected"
            health_status["status"] = "degraded"
        finally:
            db.close()
    except Exception as exc:
        app_logger.error(f"Database connection error: {exc}")
        health_status["database"] = "error"
        health_status["status"] = "degraded"
    
    return health_status


@app.exception_handler(404)
async def not_found_handler(request: Request, exc: Exception) -> JSONResponse:
    return JSONResponse(status_code=404, content={"detail": "Not found", "path": str(request.url)})


@app.exception_handler(500)
async def internal_error_handler(request: Request, exc: Exception) -> JSONResponse:
    app_logger.exception("Internal server error", path=request.url.path)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error", "message": str(exc) if settings.DEBUG else "An error occurred"},
    )


# Import and register API routers
# Note: Imports are after app initialization to avoid circular dependencies
try:
    from app.api import (  # noqa: E402  pylint: disable=wrong-import-position
        auth,
        candidates,
        azure_ocr,
        dashboard,
        employees,
        factories,
        import_export,
        monitoring,
        notifications,
        reports,
        requests,
        salary,
        timer_cards,
    )

    # Register all API routers
    app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
    app.include_router(candidates.router, prefix="/api/candidates", tags=["Candidates"])
    app.include_router(azure_ocr.router, prefix="/api/azure-ocr", tags=["Azure OCR"])
    app.include_router(employees.router, prefix="/api/employees", tags=["Employees"])
    app.include_router(factories.router, prefix="/api/factories", tags=["Factories"])
    app.include_router(timer_cards.router, prefix="/api/timer-cards", tags=["Timer Cards"])
    app.include_router(salary.router, prefix="/api/salary", tags=["Salary"])
    app.include_router(requests.router, prefix="/api/requests", tags=["Requests"])
    app.include_router(dashboard.router, prefix="/api/dashboard", tags=["Dashboard"])
    app.include_router(import_export.router, prefix="/api/import", tags=["Import/Export"])
    app.include_router(reports.router, prefix="/api/reports", tags=["Reports"])
    app.include_router(notifications.router, prefix="/api/notifications", tags=["Notifications"])
    app.include_router(monitoring.router, prefix="/api/monitoring", tags=["Monitoring"])
    
    app_logger.info("All API routers registered successfully")
except ImportError as exc:
    app_logger.exception("Failed to import API routers", error=str(exc))
    raise
except Exception as exc:
    app_logger.exception("Failed to register API routers", error=str(exc))
    raise


if __name__ == "__main__":  # pragma: no cover
    import uvicorn

    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=settings.DEBUG)
