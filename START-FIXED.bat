@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Iniciar Sistema

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            UNS-CLAUDEJP - SISTEMA DE GESTIÓN                    ║
echo ║                     INICIAR APLICACIÓN                          ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Configurar rutas de Docker
set "DOCKER_PATH=C:\Program Files\Docker\Docker\resources\bin\docker.exe"
set "DOCKER_COMPOSE_CMD="

:: Verificar Docker con ruta completa
echo 🔍 Verificando Docker...
if exist "%DOCKER_PATH%" (
    echo ✅ Docker encontrado en: %DOCKER_PATH%
    
    :: Probar Docker Compose
    "%DOCKER_PATH%" compose version >nul 2>&1
    if !errorlevel! EQU 0 (
        set "DOCKER_COMPOSE_CMD="%DOCKER_PATH%" compose"
        echo ✅ Docker Compose está disponible
    ) else (
        echo ❌ Docker Compose no funciona
        pause
        exit /b 1
    )
) else (
    echo ❌ Docker no encontrado en la ubicación esperada
    echo.
    echo Por favor verifica que Docker Desktop esté instalado en:
    echo C:\Program Files\Docker\Docker\resources\bin\docker.exe
    echo.
    echo O instala Docker Desktop desde:
    echo https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo.
echo 🚀 Iniciando servicios...
echo.

:: Cambiar al directorio del proyecto
cd /d "%~dp0"

:: Detener servicios existentes
echo 📛 Deteniendo servicios existentes...
%DOCKER_COMPOSE_CMD% down --remove-orphans >nul 2>&1

:: Iniciar servicios
echo 🔥 Iniciando servicios con Docker Compose...
%DOCKER_COMPOSE_CMD% up -d --build

if !errorlevel! EQU 0 (
    echo.
    echo ╔════════════════════════════════════════════════════════════════╗
    echo ║                     ✅ SISTEMA INICIADO                         ║
    echo ╚════════════════════════════════════════════════════════════════╝
    echo.
    echo 🌐 Aplicación disponible en:
    echo    Frontend: http://localhost:3000
    echo    Backend:  http://localhost:8000
    echo.
    echo 📊 Para ver logs: LOGS.bat
    echo 🛑 Para detener:  STOP.bat
    echo.
) else (
    echo.
    echo ❌ Error al iniciar los servicios
    echo 📋 Ejecuta LOGS.bat para ver más detalles
    echo.
)

echo Presiona cualquier tecla para continuar...
pause >nul