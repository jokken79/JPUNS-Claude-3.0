@echo off
setlocal enabledelayedexpansion

title UNS-ClaudeJP 2.0 - Debug Start

echo ==========================================
echo UNS-ClaudeJP 2.0 - Debug Launch
echo ==========================================
echo.

:: Check Docker
echo [1/4] Checking Docker...
docker --version
if errorlevel 1 (
    echo ERROR: Docker not installed
    pause
    exit /b 1
)
echo.

:: Check Docker Daemon
echo [2/4] Checking Docker daemon...
docker ps
if errorlevel 1 (
    echo ERROR: Docker daemon not running
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)
echo.

:: Check files
echo [3/4] Checking configuration files...
if not exist ".env" (
    echo ERROR: .env file not found
    echo Please copy .env.example to .env
    pause
    exit /b 1
)
if not exist "docker-compose.yml" (
    echo ERROR: docker-compose.yml not found
    pause
    exit /b 1
)
echo All required files found.
echo.

:: Start containers
echo [4/4] Starting containers...
docker compose up -d --build
if errorlevel 1 (
    echo ERROR: Failed to start containers
    echo Checking logs...
    docker compose logs
    pause
    exit /b 1
)

echo.
echo SUCCESS: Containers started
echo.
echo URLs:
echo Frontend: http://localhost:3000
echo Backend:  http://localhost:8000
echo API Docs: http://localhost:8000/api/docs
echo.

echo Checking container status...
docker compose ps
echo.

pause