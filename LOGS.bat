@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Ver Logs

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            UNS-CLAUDEJP - SISTEMA DE GESTIÓN                    ║
echo ║                       VER LOGS                                  ║
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

echo Selecciona qué logs ver:
echo.
echo [1] Todos los servicios
echo [2] Backend (FastAPI)
echo [3] Frontend (React)
echo [4] Base de Datos (PostgreSQL)
echo [5] Logs en tiempo real (seguir)
echo [0] Salir
echo.

choice /C 123450 /M "Elige una opción"

if errorlevel 6 goto :end
if errorlevel 5 (
    echo.
    echo Mostrando logs en tiempo real... (Ctrl+C para salir)
    echo.
    %DOCKER_COMPOSE_CMD% logs -f
    goto :end
)
if errorlevel 4 (
    echo.
    echo === LOGS DE BASE DE DATOS ===
    %DOCKER_COMPOSE_CMD% logs db --tail=100
    goto :menu
)
if errorlevel 3 (
    echo.
    echo === LOGS DE FRONTEND ===
    %DOCKER_COMPOSE_CMD% logs frontend --tail=100
    goto :menu
)
if errorlevel 2 (
    echo.
    echo === LOGS DE BACKEND ===
    %DOCKER_COMPOSE_CMD% logs backend --tail=100
    goto :menu
)
if errorlevel 1 (
    echo.
    echo === LOGS DE TODOS LOS SERVICIOS ===
    %DOCKER_COMPOSE_CMD% logs --tail=50
    goto :menu
)

:menu
echo.
echo.
choice /C SN /M "¿Ver más logs? (S=Sí, N=No)"
if errorlevel 2 goto :end
if errorlevel 1 (
    cls
    goto :start
)

:end
echo.
pause
