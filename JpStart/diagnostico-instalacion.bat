@echo off
setlocal
title UNS-ClaudeJP - Diagnóstico de Instalación

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║          DIAGNÓSTICO COMPLETO DE INSTALACIÓN                    ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Verificar marcador de instalación
echo [1/10] Verificando marcador de instalación...
if exist ".install_complete" (
    echo [OK] Marcador de instalación existe - Ya se instaló antes
    set "INSTALADO_ANTES=SI"
) else (
    echo [INFO] No hay marcador - Primera instalación o instalación incompleta
    set "INSTALADO_ANTES=NO"
)
echo.

REM Verificar archivo .env
echo [2/10] Verificando archivo .env...
if exist ".env" (
    echo [OK] Archivo .env existe
    set "ENV_EXISTE=SI"
) else (
    echo [ERROR] No existe archivo .env - Debe crearlo desde .env.example
    set "ENV_EXISTE=NO"
)
echo.

REM Verificar Docker
echo [3/10] Verificando Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker no está instalado
    set "DOCKER_OK=NO"
    goto :docker_error
)
echo [OK] Docker está instalado
set "DOCKER_OK=SI"

REM Verificar Docker running
echo [4/10] Verificando si Docker está corriendo...
docker ps >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker no está corriendo - Inicia Docker Desktop
    set "DOCKER_RUNNING=NO"
) else (
    echo [OK] Docker está corriendo
    set "DOCKER_RUNNING=SI"
)
echo.

:docker_error

REM Verificar Docker Compose
echo [5/10] Verificando Docker Compose...
docker compose version >nul 2>&1
if %errorlevel% EQU 0 (
    echo [OK] Docker Compose V2 está disponible
    set "COMPOSE_OK=SI"
    set "COMPOSE_CMD=docker compose"
) else (
    docker-compose version >nul 2>&1
    if %errorlevel% EQU 0 (
        echo [OK] Docker Compose V1 está disponible
        set "COMPOSE_OK=SI"
        set "COMPOSE_CMD=docker-compose"
    ) else (
        echo [ERROR] Docker Compose no está disponible
        set "COMPOSE_OK=NO"
    )
)
echo.

REM Verificar contenedores
echo [6/10] Verificando contenedores UNS-ClaudeJP...
docker ps --format "table {{.Names}}" | findstr "uns-claudejp" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [OK] Contenedores UNS-ClaudeJP están corriendo
    set "CONTAINERS_RUNNING=SI"
) else (
    echo [INFO] No hay contenedores UNS-ClaudeJP corriendo
    set "CONTAINERS_RUNNING=NO"
)
echo.

REM Verificar volúmenes
echo [7/10] Verificando volúmenes de datos...
docker volume ls | findstr "uns-claudejp" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [OK] Volúmenes de datos existen
    set "VOLUMES_EXIST=SI"
) else (
    echo [INFO] No hay volúmenes de datos
    set "VOLUMES_EXIST=NO"
)
echo.

REM Verificar archivos de configuración
echo [8/10] Verificando archivos de configuración...
if exist "docker-compose.yml" (
    echo [OK] docker-compose.yml existe
) else (
    echo [ERROR] No existe docker-compose.yml
)

if exist ".env.example" (
    echo [OK] .env.example existe
) else (
    echo [ERROR] No existe .env.example
)
echo.

REM Verificar puertos
echo [9/10] Verificando puertos en uso...
netstat -an | findstr ":3000" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [INFO] Puerto 3000 está en uso (Frontend)
    set "PORT3000_USED=SI"
) else (
    echo [INFO] Puerto 3000 está libre
    set "PORT3000_USED=NO"
)

netstat -an | findstr ":8000" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [INFO] Puerto 8000 está en uso (Backend)
    set "PORT8000_USED=SI"
) else (
    echo [INFO] Puerto 8000 está libre
    set "PORT8000_USED=NO"
)

netstat -an | findstr ":5432" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [INFO] Puerto 5432 está en uso (Base de datos)
    set "PORT5432_USED=SI"
) else (
    echo [INFO] Puerto 5432 está libre
    set "PORT5432_USED=NO"
)
echo.

REM Verificar servicios web
echo [10/10] Verificando servicios web...
curl -s http://localhost:8000/api/health >nul 2>&1
if %errorlevel% EQU 0 (
    echo [OK] Backend API responde correctamente
    set "API_OK=SI"
) else (
    echo [WARNING] Backend API no responde
    set "API_OK=NO"
)

curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% EQU 0 (
    echo [OK] Frontend responde correctamente
    set "FRONTEND_OK=SI"
) else (
    echo [WARNING] Frontend no responde
    set "FRONTEND_OK=NO"
)
echo.

REM Resumen y recomendaciones
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                     RESUMEN Y RECOMENDACIONES                  ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

if "%DOCKER_OK%"=="NO" (
    echo ❌ DOCKER NO INSTALADO
    echo    Solución: Instala Docker Desktop desde https://www.docker.com
    echo.
)

if "%DOCKER_RUNNING%"=="NO" (
    echo ❌ DOCKER NO ESTÁ CORRIENDO
    echo    Solución: Inicia Docker Desktop y espera que esté listo
    echo.
)

if "%COMPOSE_OK%"=="NO" (
    echo ❌ DOCKER COMPOSE NO DISPONIBLE
    echo    Solución: Instala o actualiza Docker Desktop
    echo.
)

if "%ENV_EXISTE%"=="NO" (
    echo ❌ ARCHIVO .ENV NO EXISTE
    echo    Solución: Ejecuta install-windows-v2.bat para crearlo
    echo.
)

if "%CONTAINERS_RUNNING%"=="NO" (
    if "%DOCKER_OK%"=="SI" (
        echo ❌ CONTENEDORES NO CORREN
        echo    Solución: Ejecuta start-app.bat o install-windows-v2.bat
        echo.
    )
)

if "%API_OK%"=="NO" (
    if "%CONTAINERS_RUNNING%"=="SI" (
        echo ⚠️  BACKEND NO RESPONDE
        echo    Solución: Espera 2-3 minutos para inicialización de BD
        echo    O revisa logs con: docker logs uns-claudejp-backend-1
        echo.
    )
)

if "%FRONTEND_OK%"=="NO" (
    if "%CONTAINERS_RUNNING%"=="SI" (
        echo ⚠️  FRONTEND NO RESPONDE
        echo    Solución: Revisa logs con: docker logs uns-claudejp-frontend-1
        echo.
    )
)

REM Estado general
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                         ESTADO GENERAL                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

if "%DOCKER_OK%"=="SI" (
    if "%DOCKER_RUNNING%"=="SI" (
        if "%CONTAINERS_RUNNING%"=="SI" (
            if "%API_OK%"=="SI" (
                if "%FRONTEND_OK%"=="SI" (
                    echo ✅ APLICACIÓN FUNCIONANDO CORRECTAMENTE
                    echo    Puedes acceder a: http://localhost:3000
                ) else (
                    echo ⚠️  APLICACIÓN PARCIALMENTE FUNCIONAL
                    echo    El backend funciona pero el frontend no
                )
            ) else (
                echo ⚠️  APLICACIÓN INICIANDO
                echo    Los contenedores corren pero el API aún no responde
                echo    Espera 2-3 minutos para inicialización completa
            )
        ) else (
            echo ❌ APLICACIÓN DETENIDA
            echo    Docker funciona pero los contenedores no están corriendo
        )
    ) else (
        echo ❌ DOCKER DETENIDO
        echo    Docker está instalado pero no está corriendo
    )
) else (
    echo ❌ DOCKER NO DISPONIBLE
    echo    Debes instalar Docker Desktop primero
)

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                      ACCIONES SUGERIDAS                         ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

if "%INSTALADO_ANTES%"=="NO" (
    echo 📋 PARA PRIMERA INSTALACIÓN:
    echo    1. Ejecuta: install-windows-v2.bat
    echo    2. Elige opción 1 (Instalación Fresh)
    echo    3. Espera 3-5 minutos
    echo.
) else (
    echo 📋 PARA REINSTALAR/ACTUALIZAR:
    echo    1. Ejecuta: install-windows-v2.bat
    echo    2. Elige opción 1 (Fresh) o 2 (Actualizar)
    echo.
)

echo 📋 PARA INICIAR/DETENER:
echo    - Iniciar: start-app.bat
echo    - Detener: stop-app.bat
echo    - Diagnosticar: diagnose-issues.bat
echo.

echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  VER LOGS EN TIEMPO REAL                         ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Para ver todos los logs: docker-compose logs -f
echo Para ver solo backend: docker-compose logs -f backend
echo Para ver solo frontend: docker-compose logs -f frontend
echo Para ver solo base de datos: docker-compose logs -f db
echo.

pause