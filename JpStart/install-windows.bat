@echo off
setlocal

echo ==========================================
echo UNS-ClaudeJP 2.0 - Windows Installation
echo ==========================================
echo.

REM Check if this is the first installation
set "FIRST_INSTALL=true"
set "INSTALL_MARKER=.install_complete"

REM Check for installation markers
if exist "%INSTALL_MARKER%" (
    set "FIRST_INSTALL=false"
    echo [INFO] Previous installation detected.
    echo.
)

if exist ".env" (
    set "FIRST_INSTALL=false"
    echo [INFO] .env file already exists.
    echo.
)

REM Check if Docker containers are already running
docker ps --format "table {{.Names}}" | findstr "uns-claudejp" >nul 2>&1
if %errorlevel% EQU 0 (
    set "FIRST_INSTALL=false"
    echo [INFO] UNS-ClaudeJP containers are already running.
    echo.
)

if "%FIRST_INSTALL%"=="true" (
    echo [FIRST INSTALL] This appears to be a first-time installation.
    echo.
) else (
    echo [REINSTALLATION] This appears to be a reinstallation or update.
    echo.
)

echo Detecting Docker Compose...
set "DOCKER_COMPOSE_CMD="
docker compose version >nul 2>&1
if %errorlevel% EQU 0 (
    set "DOCKER_COMPOSE_CMD=docker compose"
) else (
    docker-compose version >nul 2>&1
    if %errorlevel% EQU 0 (
        set "DOCKER_COMPOSE_CMD=docker-compose"
    ) else (
        echo [ERROR] Docker Compose is not installed!
        echo Please install Docker Desktop or enable Docker Compose V2.
        pause
        exit /b 1
    )
)

echo Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed!
    echo Please install Docker Desktop from:
    echo https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo [OK] Docker is installed
echo.

echo Checking Docker status...
docker ps >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running!
    echo Please start Docker Desktop.
    pause
    exit /b 1
)
echo [OK] Docker is running
echo.

echo Creating directories...
if not exist "uploads" mkdir uploads
if not exist "logs" mkdir logs
if not exist "config\factories" mkdir config\factories
echo [OK] Directories created
echo.

echo Checking .env file...
if not exist ".env" (
    if "%FIRST_INSTALL%"=="true" (
        echo [FIRST INSTALL] Creating .env file from template...
    ) else (
        echo Creating .env file...
    )
    copy .env.example .env >nul
    echo.
    echo [IMPORTANT] Please edit .env file:
    echo   1. Change DB_PASSWORD
    echo   2. Change SECRET_KEY
    echo   3. Configure email (optional)
    echo.
    echo Do you want to edit .env now? (Y/N)
    set /p EDIT_ENV=
    if /I "%EDIT_ENV%"=="Y" (
        notepad .env
    )
) else (
    if "%FIRST_INSTALL%"=="true" (
        echo [FIRST INSTALL] .env file already exists, skipping creation.
    )
)
echo.

if "%FIRST_INSTALL%"=="true" (
    echo [FIRST INSTALL] Pulling latest container images (this may take a moment)...
) else (
    echo Pulling latest container images (this may take a moment)...
)
call %DOCKER_COMPOSE_CMD% pull
if errorlevel 1 (
    echo [WARNING] Could not pull updated images. Continuing with local cache.
)
echo.

REM Check if database volume exists
docker volume ls | findstr "uns-claudejp_db_data" >nul 2>&1
if %errorlevel% EQU 0 (
    set "DB_EXISTS=true"
) else (
    set "DB_EXISTS=false"
)

if "%FIRST_INSTALL%"=="true" (
    echo [FIRST INSTALL] Building Docker images for first time...
    if "%DB_EXISTS%"=="false" (
        echo [FIRST INSTALL] New database will be created.
    )
) else (
    echo Building Docker images...
)
call %DOCKER_COMPOSE_CMD% up -d --build
if errorlevel 1 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)
echo [OK] Build complete
echo.

if "%FIRST_INSTALL%"=="true" (
    if "%DB_EXISTS%"=="false" (
        echo [FIRST INSTALL] Initializing new database (this may take 2-3 minutes)...
        timeout /t 45 /nobreak >nul
    ) else (
        echo [FIRST INSTALL] Waiting for services to initialize...
        timeout /t 30 /nobreak >nul
    )
) else (
    echo Waiting for services to initialize...
    timeout /t 20 /nobreak >nul
)
echo.

echo Checking service health...
curl -s http://localhost:8000/ >nul 2>&1
if errorlevel 1 (
    if "%FIRST_INSTALL%"=="true" (
        if "%DB_EXISTS%"=="false" (
            echo [FIRST INSTALL] Backend not responding yet. Database is still initializing.
            echo This is NORMAL for first installation. Please wait 2-3 minutes.
            echo You can check progress with: docker logs uns-claudejp_db_1
        ) else (
            echo [FIRST INSTALL] Backend not responding yet. This is normal on first startup.
            echo The database might still be initializing. Please wait a few minutes.
        )
    ) else (
        echo [WARNING] Backend not responding yet.
    )
)
echo.

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set LOCAL_IP=%%a
    goto found_ip
)
:found_ip
set LOCAL_IP=%LOCAL_IP:~1%

echo ==========================================
if "%FIRST_INSTALL%"=="true" (
    echo First-Time Installation Complete!
) else (
    echo Installation/Update Complete!
)
echo ==========================================
echo.

if "%FIRST_INSTALL%"=="true" (
    echo [FIRST INSTALL IMPORTANT NOTES]:
    echo  - Database is being initialized in the background
    echo  - First login may take up to 2-3 minutes
    echo  - Default credentials have been created
    echo.
    echo Default credentials:
    echo   - Username: admin
    echo   - Password: admin123
    echo   [IMPORTANT] Change password after first login!
    echo.
) else (
    echo Application updated successfully!
    echo.
)

echo Access the application:
echo   - Frontend: http://localhost:3000
echo   - Backend API: http://localhost:8000
echo   - API Docs: http://localhost:8000/api/docs
echo.
echo Network access:
echo   - Frontend: http://%LOCAL_IP%:3000
echo   - Backend: http://%LOCAL_IP%:8000
echo.
echo Useful commands:
echo   - Quick start: start-app.bat
echo   - Quick stop: stop-app.bat
echo   - View logs: %DOCKER_COMPOSE_CMD% logs -f
echo   - Stop: %DOCKER_COMPOSE_CMD% stop
echo   - Start: %DOCKER_COMPOSE_CMD% start
echo   - Restart: %DOCKER_COMPOSE_CMD% restart
echo   - Remove: %DOCKER_COMPOSE_CMD% down
echo.

REM Create installation marker
echo. > "%INSTALL_MARKER%"
echo [INFO] Installation marker created.

echo Open application in browser? (Y/N)
set /p OPEN_BROWSER=
if /I "%OPEN_BROWSER%"=="Y" (
    start http://localhost:3000
    start http://localhost:8000/api/docs
)
echo.
endlocal
pause
