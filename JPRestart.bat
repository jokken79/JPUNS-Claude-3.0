@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - JPRestart (Reinicio Inteligente)

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            UNS-CLAUDEJP - SISTEMA DE GESTIÓN                    ║
echo ║              JPRESTART - REINICIO INTELIGENTE                   ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Este script intentará reiniciar los servicios de manera inteligente
echo sin perder datos. Si hay problemas con la BD, la reiniciará.
echo.
echo ══════════════════════════════════════════════════════════════════
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

echo [1/6] Verificando estado de contenedores...
%DOCKER_COMPOSE_CMD% ps

echo.
echo [2/6] Deteniendo servicios frontend y backend...
%DOCKER_COMPOSE_CMD% stop frontend backend

echo.
echo [3/6] Verificando estado de la base de datos...
docker inspect uns-claudejp-db >nul 2>&1
if %errorlevel% NEQ 0 (
    echo ⚠️  Base de datos no existe, se creará...
    goto :rebuild_db
)

:: Verificar si la BD está saludable
for /f "tokens=*" %%i in ('docker inspect --format "{{.State.Health.Status}}" uns-claudejp-db 2^>nul') do set DB_HEALTH=%%i

if "%DB_HEALTH%"=="healthy" (
    echo ✅ Base de datos está saludable
    goto :start_services
) else if "%DB_HEALTH%"=="starting" (
    echo ⏳ Base de datos está iniciando, esperando...
    timeout /t 15 /nobreak >nul
    goto :start_services
) else (
    echo ⚠️  Base de datos no está saludable, reiniciándola...
    goto :rebuild_db
)

:rebuild_db
echo.
echo [4/6] Reiniciando base de datos...
%DOCKER_COMPOSE_CMD% stop db
%DOCKER_COMPOSE_CMD% rm -f db

echo.
echo Reconstruyendo contenedor de base de datos...
%DOCKER_COMPOSE_CMD% up -d db

echo.
echo Esperando que la base de datos esté lista (30 segundos)...
timeout /t 30 /nobreak >nul

:: Verificar si la BD arrancó correctamente
for /f "tokens=*" %%i in ('docker inspect --format "{{.State.Health.Status}}" uns-claudejp-db 2^>nul') do set DB_HEALTH_AFTER=%%i

if "%DB_HEALTH_AFTER%"=="healthy" (
    echo ✅ Base de datos reiniciada exitosamente
    goto :start_services
) else if "%DB_HEALTH_AFTER%"=="starting" (
    echo ⏳ Base de datos aún iniciando, esperando 15 segundos más...
    timeout /t 15 /nobreak >nul
    goto :start_services
) else (
    echo ❌ La base de datos sigue sin estar saludable
    echo.
    echo Mostrando logs de la base de datos:
    echo ══════════════════════════════════════════════════════════════════
    docker logs --tail 50 uns-claudejp-db
    echo ══════════════════════════════════════════════════════════════════
    echo.
    echo ⚠️  SOLUCIÓN: Si el problema persiste, ejecuta REINSTALAR.bat
    pause
    exit /b 1
)

:start_services
echo.
echo [5/6] Iniciando servicios frontend y backend...
%DOCKER_COMPOSE_CMD% start backend frontend

if errorlevel 1 (
    echo ❌ Error al iniciar los servicios
    echo Intentando iniciar todos los servicios desde cero...
    %DOCKER_COMPOSE_CMD% up -d
)

echo.
echo [6/6] Esperando que los servicios estén completamente listos...
timeout /t 15 /nobreak >nul

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            ✅ REINICIO COMPLETADO ✅                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Verificando estado de los servicios:
echo ══════════════════════════════════════════════════════════════════
%DOCKER_COMPOSE_CMD% ps
echo ══════════════════════════════════════════════════════════════════
echo.
echo 🌐 URLs de Acceso:
echo    Frontend:  http://localhost:3000
echo    Backend:   http://localhost:8000
echo    API Docs:  http://localhost:8000/api/docs
echo.
echo 👤 Credenciales de acceso:
echo    Usuario:   admin
echo    Password:  admin123
echo.
echo 💡 Notas importantes:
echo    - Si el frontend no carga, espera 1-2 minutos más
echo    - Si hay problemas de login, prueba con: 57UD10R
echo    - Si persisten problemas, ejecuta REINSTALAR.bat
echo.
pause
exit /b 0
