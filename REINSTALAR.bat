@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Reinstalar Sistema

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            UNS-CLAUDEJP - SISTEMA DE GESTIÓN                    ║
echo ║                  REINSTALAR SISTEMA                             ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo ⚠⚠⚠ ADVERTENCIA ⚠⚠⚠
echo.
echo Esta acción eliminará:
echo - Todos los contenedores
echo - Todos los volúmenes (BASE DE DATOS)
echo - Todas las imágenes construidas
echo.
echo Se reinstalará todo desde cero con datos de prueba.
echo.
echo ══════════════════════════════════════════════════════════════════
echo.

choice /C SN /M "¿Estás SEGURO que deseas continuar? (S=Sí, N=No)"
if errorlevel 2 goto :cancelled
if errorlevel 1 goto :continue

:continue

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

echo.
echo [1/5] Deteniendo servicios...
%DOCKER_COMPOSE_CMD% down -v

echo.
echo [2/5] Eliminando imágenes antiguas...
docker rmi jpuns-claude-30-backend jpuns-claude-30-frontend 2>nul

echo.
echo [3/5] Reconstruyendo imágenes...
%DOCKER_COMPOSE_CMD% build --no-cache

if errorlevel 1 (
    echo.
    echo ❌ Error al reconstruir las imágenes
    pause
    exit /b 1
)

echo.
echo [4/5] Iniciando servicios nuevos...
%DOCKER_COMPOSE_CMD% up -d

if errorlevel 1 (
    echo.
    echo ❌ Error al iniciar los servicios
    pause
    exit /b 1
)

echo.
echo [5/5] Esperando a que los servicios estén listos (60 segundos)...
timeout /t 60 /nobreak >nul

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            ✅ REINSTALACIÓN COMPLETADA ✅                      ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo El sistema ha sido reinstalado con éxito.
echo.
echo 🌐 URLs de Acceso:
echo    Frontend:  http://localhost:3000
echo    Backend:   http://localhost:8000
echo.
echo 👤 Credenciales:
echo    Usuario:   admin
echo    Password:  admin123
echo.
echo Nota: El frontend puede tardar unos minutos en compilar.
echo.
pause
exit /b 0

:cancelled
echo.
echo Reinstalación cancelada.
echo.
pause
exit /b 0
