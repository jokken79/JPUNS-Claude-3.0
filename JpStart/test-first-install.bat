@echo off
echo ==========================================
echo Testing First Installation Detection
echo ==========================================
echo.

REM Check if install marker exists
if exist ".install_complete" (
    echo [RESULT] Installation marker exists - NOT first install
) else (
    echo [RESULT] No installation marker - FIRST install
)

REM Check if .env exists
if exist ".env" (
    echo [RESULT] .env file exists - NOT first install
) else (
    echo [RESULT] No .env file - FIRST install
)

REM Check if containers are running
docker ps --format "table {{.Names}}" | findstr "uns-claudejp" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [RESULT] UNS-ClaudeJP containers running - NOT first install
) else (
    echo [RESULT] No UNS-ClaudeJP containers running - FIRST install
)

REM Check database volume
docker volume ls | findstr "uns-claudejp_db_data" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [RESULT] Database volume exists - NOT first install
) else (
    echo [RESULT] No database volume - FIRST install
)

echo.
echo To simulate a fresh installation, delete:
echo   - .install_complete (if exists)
echo   - .env (if exists)
echo   - Stop and remove containers
echo   - Remove database volume: docker volume rm uns-claudejp_db_data
echo.
pause