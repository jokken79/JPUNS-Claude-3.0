@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Verificar Docker

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                VERIFICACIÓN DE DOCKER DESKTOP                  ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Rutas posibles de Docker
set "DOCKER_PATHS[0]=C:\Program Files\Docker\Docker\resources\bin\docker.exe"
set "DOCKER_PATHS[1]=C:\Program Files\Docker\Docker\Docker Desktop.exe"
set "DOCKER_PATHS[2]=%ProgramFiles%\Docker\Docker\resources\bin\docker.exe"

:: Buscar Docker en PATH
docker --version >nul 2>&1
if !errorlevel! EQU 0 (
    echo ✅ Docker encontrado en PATH
    for /f "tokens=3" %%a in ('docker --version') do echo    Versión: %%a
    set "DOCKER_CMD=docker"
    goto :found
)

:: Buscar Docker en rutas específicas
for /L %%i in (0,1,2) do (
    if exist "!DOCKER_PATHS[%%i]!" (
        echo ✅ Docker encontrado en: !DOCKER_PATHS[%%i]!
        for /f "tokens=3" %%a in ('"!DOCKER_PATHS[%%i]!" --version') do echo    Versión: %%a
        set "DOCKER_CMD="!DOCKER_PATHS[%%i]!""
        goto :found
    )
)

echo ❌ Docker no encontrado
echo.
echo Por favor instala Docker Desktop desde:
echo https://www.docker.com/products/docker-desktop
pause
exit /b 1

:found
echo.
echo 🔄 Verificando Docker Compose...
!DOCKER_CMD! compose version >nul 2>&1
if !errorlevel! EQU 0 (
    for /f "tokens=4" %%a in ('!DOCKER_CMD! compose version') do echo ✅ Docker Compose: %%a
) else (
    echo ❌ Docker Compose no disponible
    pause
    exit /b 1
)

echo.
echo 🔄 Verificando servicios...
!DOCKER_CMD! compose ps

echo.
echo ✅ Verificación completada
echo.
echo Docker Command: !DOCKER_CMD!
echo.
pause