@echo off
setlocal enabledelayedexpansion

title UNS-ClaudeJP 2.0 - Starting...

echo.
echo ==================================================
echo          UNS-ClaudeJP 2.0 - Quick Start          
echo      人材管理インテリジェンスプラットフォーム       
echo ==================================================
echo.

:: Check Docker
echo [1/5] Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker not installed
    pause
    exit /b 1
)
echo       [OK] Docker installed

:: Check Docker daemon
echo [2/5] Checking Docker daemon...
docker ps >nul 2>&1
if errorlevel 1 (
    echo WARNING: Docker daemon not running
    echo Starting Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo Please wait for Docker to start and try again...
    pause
    exit /b 1
)
echo       [OK] Docker daemon is running

:: Check configuration
echo [3/5] Checking configuration...
if not exist ".env" (
    echo ERROR: .env file not found
    pause
    exit /b 1
)
if not exist "docker-compose.yml" (
    echo ERROR: docker-compose.yml not found
    pause
    exit /b 1
)
echo       [OK] Configuration files found

:: Create directories
echo [4/5] Preparing directories...
if not exist "uploads" mkdir uploads
if not exist "logs" mkdir logs
if not exist "config" mkdir config
echo       [OK] Directories ready

:: Start services
echo [5/5] Starting services...
docker compose up -d --build
if errorlevel 1 (
    echo ERROR: Failed to start services
    echo Checking logs...
    docker compose logs
    pause
    exit /b 1
)

echo.
echo SUCCESS: UNS-ClaudeJP 2.0 is starting!
echo.
echo URLs:
echo   Frontend:  http://localhost:3000
echo   Backend:   http://localhost:8000
echo   API Docs:  http://localhost:8000/api/docs
echo.
echo Default credentials:
echo   Username: admin
echo   Password: admin123
echo.

echo Waiting for services to be ready...
echo This usually takes 30-60 seconds...
echo.

:: Wait for services
set /a count=0
:WAIT_LOOP
if %count% GEQ 12 goto TIMEOUT_CHECK
ping 127.0.0.1 -n 6 >nul
set /a count+=1

:: Check backend health
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo [%count%/12] Backend starting...
    goto WAIT_LOOP
)

echo.
echo [OK] Backend is ready!

:: Check frontend
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo [INFO] Frontend still starting (this is normal)
) else (
    echo [OK] Frontend is ready!
)

echo.
echo Container status:
docker compose ps
echo.

set /p OPEN_BROWSER="Open application in browser? (Y/N): "
if /I "%OPEN_BROWSER%"=="Y" (
    echo Opening browser...
    start http://localhost:3000
    ping 127.0.0.1 -n 3 >nul
    start http://localhost:8000/api/docs
)

echo.
echo Press any key to exit...
pause >nul
goto END

:TIMEOUT_CHECK
echo.
echo [WARNING] Services are taking longer than expected to start.
echo You can still try accessing:
echo   - Frontend: http://localhost:3000
echo   - Backend:  http://localhost:8000
echo.
echo Check status with: docker compose logs
echo.
pause

:END
endlocal