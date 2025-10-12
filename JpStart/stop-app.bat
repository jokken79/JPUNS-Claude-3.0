@echo off
setlocal

:: ==========================================
:: UNS-ClaudeJP 2.0 - Application Stopper
:: ==========================================
title UNS-ClaudeJP 2.0 - Stopping...

color 0E
echo.
echo  ╔═══════════════════════════════════════════════════╗
echo  ║                                                   ║
echo  ║         UNS-ClaudeJP 2.0 - Stop Application      ║
echo  ║                                                   ║
echo  ╚═══════════════════════════════════════════════════╝
echo.

:: ==========================================
:: Detect Docker Compose
:: ==========================================
echo [1/3] Detecting Docker Compose...
set "DOCKER_COMPOSE_CMD="
docker compose version >nul 2>&1
if %errorlevel% EQU 0 (
    set "DOCKER_COMPOSE_CMD=docker compose"
    echo       [OK] Docker Compose V2 detected
) else (
    docker-compose version >nul 2>&1
    if %errorlevel% EQU 0 (
        set "DOCKER_COMPOSE_CMD=docker-compose"
        echo       [OK] Docker Compose V1 detected
    ) else (
        color 0C
        echo       [ERROR] Docker Compose not installed!
        pause
        exit /b 1
    )
)
echo.

:: ==========================================
:: Check Container Status
:: ==========================================
echo [2/3] Checking running containers...
docker ps --filter "name=uns-claudejp" --format "table {{.Names}}\t{{.Status}}"
echo.

docker ps --filter "name=uns-claudejp" --format "{{.Names}}" | findstr "uns-claudejp" >nul
if errorlevel 1 (
    echo       [INFO] No running containers found
    echo.
    goto END
)

:: ==========================================
:: Stop Options
:: ==========================================
echo What would you like to do?
echo.
echo   1. Stop containers (keep data)
echo   2. Stop and remove containers (keep data)
echo   3. Stop, remove containers and volumes (DELETE ALL DATA!)
echo   4. Cancel
echo.
set /p STOP_CHOICE="Enter choice (1-4): "

if "%STOP_CHOICE%"=="1" goto STOP_ONLY
if "%STOP_CHOICE%"=="2" goto STOP_REMOVE
if "%STOP_CHOICE%"=="3" goto STOP_REMOVE_VOLUMES
if "%STOP_CHOICE%"=="4" goto CANCEL
goto INVALID_CHOICE

:STOP_ONLY
echo.
echo [3/3] Stopping containers...
call %DOCKER_COMPOSE_CMD% stop
if errorlevel 1 (
    color 0C
    echo       [ERROR] Failed to stop services
    pause
    exit /b 1
)
color 0A
echo       [OK] Containers stopped
echo.
echo       Containers are stopped but still exist.
echo       Data is preserved in Docker volumes.
echo       To start again: start-app.bat
goto END

:STOP_REMOVE
echo.
color 0E
set /p CONFIRM="Are you sure you want to remove containers? (Y/N): "
if /I not "%CONFIRM%"=="Y" goto CANCEL

echo.
echo [3/3] Stopping and removing containers...
call %DOCKER_COMPOSE_CMD% down
if errorlevel 1 (
    color 0C
    echo       [ERROR] Failed to remove containers
    pause
    exit /b 1
)
color 0A
echo       [OK] Containers removed
echo.
echo       Containers removed but data is preserved.
echo       Docker volumes still exist with your database.
echo       To start again: start-app.bat
goto END

:STOP_REMOVE_VOLUMES
echo.
color 0C
echo  ╔═══════════════════════════════════════════════════╗
echo  ║                   ⚠️  WARNING  ⚠️                  ║
echo  ║                                                   ║
echo  ║  This will DELETE ALL DATA including:            ║
echo  ║    • Database (employees, factories, users)      ║
echo  ║    • Uploaded files                              ║
echo  ║    • All configurations                          ║
echo  ║                                                   ║
echo  ║  This action CANNOT be undone!                   ║
echo  ╚═══════════════════════════════════════════════════╝
echo.
set /p CONFIRM1="Type 'DELETE' to confirm: "
if /I not "%CONFIRM1%"=="DELETE" goto CANCEL

set /p CONFIRM2="Are you absolutely sure? (Y/N): "
if /I not "%CONFIRM2%"=="Y" goto CANCEL

echo.
echo [3/3] Stopping containers and removing all data...
call %DOCKER_COMPOSE_CMD% down -v
if errorlevel 1 (
    color 0C
    echo       [ERROR] Failed to remove everything
    pause
    exit /b 1
)

:: Also remove uploaded files
if exist "uploads\*" (
    echo Removing uploaded files...
    del /q uploads\* 2>nul
)

color 0A
echo       [OK] Everything removed
echo.
echo       All containers and data have been deleted.
echo       Next start will be a fresh installation.
goto END

:CANCEL
echo.
color 0A
echo       [INFO] Operation cancelled
goto END

:INVALID_CHOICE
color 0C
echo.
echo       [ERROR] Invalid choice!
pause
exit /b 1

:END
echo.
echo  ╔═══════════════════════════════════════════════════╗
echo  ║                                                   ║
echo  ║              Operation Complete                   ║
echo  ║                                                   ║
echo  ╚═══════════════════════════════════════════════════╝
echo.
echo Useful commands:
echo   • View containers:  docker ps -a
echo   • View volumes:     docker volume ls
echo   • Start app:        start-app.bat
echo   • View logs:        docker-compose logs
echo.
endlocal
pause
