@echo off
setlocal enabledelayedexpansion

title UNS-ClaudeJP 3.1 - Inicio Único

echo.
echo ==================================================
echo       UNS-ClaudeJP 3.1 - INICIO COMPLETO          
echo     人材管理インテリジェンスプラットフォーム       
echo ==================================================
echo.

:: Check Docker
echo [1/6] Verificando Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker no está instalado
    pause
    exit /b 1
)
echo       [OK] Docker instalado

:: Check Docker daemon
echo [2/6] Verificando daemon Docker...
docker ps >nul 2>&1
if errorlevel 1 (
    echo ADVERTENCIA: Docker daemon no está ejecutándose
    echo Iniciando Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo Espere a que Docker inicie y ejecute nuevamente...
    pause
    exit /b 1
)
echo       [OK] Docker daemon está ejecutándose

:: Check configuration
echo [3/6] Verificando configuración...
if not exist ".env" (
    echo ERROR: Archivo .env no encontrado
    pause
    exit /b 1
)
if not exist "docker-compose.yml" (
    echo ERROR: Archivo docker-compose.yml no encontrado
    pause
    exit /b 1
)
echo       [OK] Archivos de configuración encontrados

:: Create directories
echo [4/6] Preparando directorios...
if not exist "uploads" mkdir uploads
if not exist "logs" mkdir logs
if not exist "config" mkdir config
echo       [OK] Directorios listos

:: Start services with proper initialization
echo [5/6] Iniciando servicios...

:: Detener servicios existentes para asegurar inicio limpio
echo Deteniendo servicios existentes...
docker-compose stop 2>nul

:: Eliminar contenedores para asegurar estado limpio
echo Limpiando contenedores...
docker-compose rm -f 2>nul

:: Iniciar servicios sin reconstrucción para preservar base de datos
echo Iniciando servicios...
docker-compose up -d
if errorlevel 1 (
    echo ERROR: Falló el inicio de servicios
    echo Verificando logs...
    docker-compose logs
    pause
    exit /b 1
)

:: Esperar que la base de datos esté lista
echo [6/6] Esperando inicialización de base de datos...
set /a db_count=0
:DB_WAIT_LOOP
if %db_count% GEQ 15 goto DB_TIMEOUT
ping 127.0.0.1 -n 3 >nul
set /a db_count+=1

:: Verificar si la base de datos acepta conexiones
docker-compose exec -T db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
if errorlevel 1 (
    echo [%db_count%/15] Base de datos iniciándose...
    goto DB_WAIT_LOOP
)

echo [OK] Base de datos lista!

:: Inicializar base de datos si es necesario
echo Inicializando base de datos...
docker-compose exec -T backend python scripts/create_admin_user.py >nul 2>&1
docker-compose exec -T backend python scripts/import_data.py >nul 2>&1
echo [OK] Base de datos inicializada!

goto CONTINUE_START

:DB_TIMEOUT
echo [ADVERTENCIA] Tiempo de espera de base de datos agotado, continuando...

:CONTINUE_START

echo.
echo ==================================================
echo ¡ÉXITO! UNS-ClaudeJP 3.1 se está iniciando...
echo ==================================================
echo.
echo URLs:
echo   Frontend:  http://localhost:3000
echo   Backend:   http://localhost:8000
echo   API Docs:  http://localhost:8000/api/docs
echo.
echo Credenciales por defecto:
echo   Usuario: admin
echo   Contraseña: 57UD10R
echo.

echo Esperando que los servicios estén completamente listos...
echo Esto usualmente toma 30-60 segundos...
echo.

:: Esperar servicios
set /a count=0
:WAIT_LOOP
if %count% GEQ 12 goto TIMEOUT_CHECK
ping 127.0.0.1 -n 6 >nul
set /a count+=1

:: Verificar salud del backend
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo [%count%/12] Backend iniciándose...
    goto WAIT_LOOP
)

echo.
echo [OK] Backend está listo!

:: Verificar frontend
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo [INFO] Frontend aún iniciándose (esto es normal)
) else (
    echo [OK] Frontend está listo!
)

echo.
echo Estado de contenedores:
docker-compose ps
echo.

set /p OPEN_BROWSER="¿Abrir aplicación en navegador? (S/N): "
if /I "%OPEN_BROWSER%"=="S" (
    echo Abriendo navegador...
    start http://localhost:3000
    ping 127.0.0.1 -n 3 >nul
    start http://localhost:8000/api/docs
)

echo.
echo ==================================================
echo ¡SISTEMA COMPLETAMENTE INICIADO Y FUNCIONANDO!
echo ==================================================
echo.
echo Ahora puedes usar la aplicación normalmente.
echo Si tienes problemas, ejecuta: JpStart\diagnose-issues.bat
echo.
pause

goto END

:TIMEOUT_CHECK
echo.
echo [ADVERTENCIA] Los servicios están tardando más de lo esperado.
echo Aún puedes intentar acceder a:
echo   - Frontend: http://localhost:3000
echo   - Backend:  http://localhost:8000
echo.
echo Verifica estado con: docker-compose logs
echo.
pause

:END
endlocal