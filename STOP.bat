@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Detener Sistema

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            UNS-CLAUDEJP - SISTEMA DE GESTIÓN                    ║
echo ║                    DETENER APLICACIÓN                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar Docker Compose
set "DOCKER_COMPOSE_CMD="
docker compose version >nul 2>&1
if %errorlevel% EQU 0 (
    set "DOCKER_COMPOSE_CMD=docker compose"
) else (
    docker-compose version >nul 2>&1
    if %errorlevel% EQU 0 (
        set "DOCKER_COMPOSE_CMD=docker-compose"
    ) else (
        echo ❌ Docker Compose no está instalado
        pause
        exit /b 1
    )
)

echo [1/2] Deteniendo todos los servicios...
%DOCKER_COMPOSE_CMD% down

if errorlevel 1 (
    echo.
    echo ❌ Error al detener los servicios
    pause
    exit /b 1
)

echo.
echo [2/2] Verificando estado...
%DOCKER_COMPOSE_CMD% ps

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  ✅ SISTEMA DETENIDO ✅                        ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Todos los servicios han sido detenidos correctamente.
echo.
echo Para iniciar nuevamente: ejecuta START.bat
echo.
pause
