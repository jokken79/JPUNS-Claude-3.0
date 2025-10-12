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
        echo.
        echo Por favor instala Docker Desktop desde:
        echo https://www.docker.com/products/docker-desktop
        pause
        exit /b 1
    )
)

:: Verificar si ya está corriendo
echo [1/4] Verificando estado actual...
%DOCKER_COMPOSE_CMD% ps | findstr "uns-claudejp" >nul 2>&1
if %errorlevel% EQU 0 (
    echo    ⚠ Los contenedores ya están corriendo
    echo.
    choice /C SN /M "¿Deseas reiniciar los servicios? (S=Sí, N=No)"
    if errorlevel 2 goto :check_services
    if errorlevel 1 (
        echo.
        echo    Deteniendo servicios...
        %DOCKER_COMPOSE_CMD% down
        timeout /t 3 /nobreak >nul
    )
)

:: Iniciar servicios
echo.
echo [2/4] Iniciando servicios...
echo    Base de datos (PostgreSQL)
echo    Backend API (FastAPI)
echo    Frontend (React)
echo.
%DOCKER_COMPOSE_CMD% up -d

if errorlevel 1 (
    echo.
    echo ❌ Error al iniciar los servicios
    echo.
    echo Verifica:
    echo 1. Docker Desktop está corriendo
    echo 2. Los puertos 3000, 5432 y 8000 están libres
    echo 3. Hay suficiente espacio en disco
    echo.
    pause
    exit /b 1
)

:: Esperar a que los servicios estén listos
:check_services
echo.
echo [3/4] Esperando a que los servicios estén listos...
echo    Este proceso puede tomar 30-60 segundos...
echo.

:: Esperar base de datos
echo    [■□□□] Iniciando base de datos...
timeout /t 10 /nobreak >nul

echo    [■■□□] Base de datos iniciando...
timeout /t 10 /nobreak >nul

:: Verificar backend
echo    [■■■□] Verificando backend...
timeout /t 10 /nobreak >nul

set RETRY=0
:check_backend
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    set /a RETRY+=1
    if !RETRY! LSS 6 (
        timeout /t 5 /nobreak >nul
        goto :check_backend
    ) else (
        echo    ⚠ Backend tardando en iniciar, pero puede que esté funcionando...
    )
) else (
    echo    [■■■■] ✅ Backend respondiendo!
)

:: Verificar frontend
timeout /t 5 /nobreak >nul
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Frontend aún compilando (esto es normal)...
) else (
    echo    ✅ Frontend listo!
)

:: Mostrar estado
echo.
echo [4/4] Estado de los servicios:
%DOCKER_COMPOSE_CMD% ps

:: Mensaje final
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  🎉 SISTEMA INICIADO 🎉                        ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo 🌐 URLs de Acceso:
echo    Frontend:  http://localhost:3000
echo    Backend:   http://localhost:8000
echo    API Docs:  http://localhost:8000/api/docs
echo.
echo 👤 Credenciales de Login:
echo    Usuario:   admin
echo    Password:  admin123
echo.
echo 📝 Notas:
echo    - El frontend puede tardar 1-2 minutos en compilar completamente
echo    - Si no abre automáticamente, espera un momento y reintenta
echo    - Para detener: ejecuta STOP.bat
echo    - Para ver logs: ejecuta LOGS.bat
echo.
echo ══════════════════════════════════════════════════════════════════
echo.

:: Preguntar si abrir navegador
choice /C SN /M "¿Abrir en el navegador ahora? (S=Sí, N=No)"
if errorlevel 2 goto :end
if errorlevel 1 (
    echo.
    echo Abriendo navegador...
    start http://localhost:3000
)

:end
echo.
echo ¡Listo! Presiona cualquier tecla para salir...
pause >nul
