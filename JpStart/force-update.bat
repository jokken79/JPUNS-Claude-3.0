@echo off
setlocal

echo ==========================================
echo UNS-ClaudeJP 2.0 - Force Update Tool
echo ==========================================
echo.
echo This tool will:
echo 1. Stop all containers
echo 2. Remove all containers and images
echo 3. Download latest versions
echo 4. Rebuild everything from scratch
echo 5. Preserve your database data
echo.

:: Detectar Docker Compose
echo Detecting Docker Compose...
set "DOCKER_COMPOSE_CMD="
docker compose version >nul 2>&1
if %errorlevel% EQU 0 (
    set "DOCKER_COMPOSE_CMD=docker compose"
) else (
    docker-compose version >nul 2>&1
    if %errorlevel% EQU 0 (
        set "DOCKER_COMPOSE_CMD=docker-compose"
    ) else (
        echo [ERROR] Docker Compose is not installed!
        pause
        exit /b 1
    )
)

:: Verificar Docker
echo Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed!
    pause
    exit /b 1
)

:: Verificar estado de Docker
echo Checking Docker status...
docker ps >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running!
    pause
    exit /b 1
)

:: Advertencia
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                        ⚠️  ADVERTENCIA  ⚠️                   ║
echo ╠══════════════════════════════════════════════════════════════╣
echo ║ Este proceso eliminará todos los containers e imágenes       ║
echo ║ pero PRESERVARÁ tus datos de la base de datos.              ║
echo ║                                                              ║
echo ║ El proceso tomará varios minutos.                          ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
set /p CONFIRM="¿Continuar con la actualización forzada? (S/N): "
if /I not "%CONFIRM%"=="S" (
    echo Operación cancelada.
    pause
    exit /b 0
)

:: Paso 1: Detener todos los containers
echo.
echo [1/8] Deteniendo todos los containers...
call %DOCKER_COMPOSE_CMD% down >nul 2>&1
echo    ✓ Containers detenidos

:: Paso 2: Eliminar containers huérfanos
echo [2/8] Eliminando containers huérfanos...
docker container prune -f >nul 2>&1
echo    ✓ Containers huérfanos eliminados

:: Paso 3: Eliminar imágenes no utilizadas
echo [3/8] Eliminando imágenes antiguas...
docker image prune -a -f >nul 2>&1
echo    ✓ Imágenes antiguas eliminadas

:: Paso 4: Limpiar sistema
echo [4/8] Limpiando sistema Docker...
docker system prune -f >nul 2>&1
echo    ✓ Sistema limpiado

:: Paso 5: Verificar archivos de configuración
echo [5/8] Verificando archivos de configuración...
if not exist ".env" (
    echo    ! Creando .env desde ejemplo...
    copy .env.example .env >nul
)
if not exist "uploads" mkdir uploads
if not exist "logs" mkdir logs
if not exist "config\factories" mkdir config\factories
echo    ✓ Configuración verificada

:: Paso 6: Forzar descarga de imágenes base
echo [6/8] Descargando imágenes base actualizadas...
docker pull postgres:15-alpine >nul 2>&1
docker pull python:3.11-slim >nul 2>&1
docker pull node:18-alpine >nul 2>&1
echo    ✓ Imágenes base descargadas

:: Paso 7: Construir y levantar con flags de forzado
echo [7/8] Reconstruyendo y levantando servicios...
call %DOCKER_COMPOSE_CMD% up -d --build --force-recreate --no-deps
if errorlevel 1 (
    echo [ERROR] Falló la construcción
    echo Mostrando logs de error...
    call %DOCKER_COMPOSE_CMD% logs
    pause
    exit /b 1
)
echo    ✓ Servicios reconstruidos

:: Paso 8: Verificar y ejecutar migraciones
echo [8/8] Verificando migraciones de base de datos...
timeout /t 15 /nobreak >nul

:: Esperar a que la base de datos esté lista
echo    Esperando a que la base de datos esté lista...
set /a count=0
:WAIT_DB
if %count% GEQ 12 goto DB_READY
ping 127.0.0.1 -n 6 >nul
set /a count+=1

call %DOCKER_COMPOSE_CMD% exec -T db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
if errorlevel 1 (
    echo    Intento %count%/12...
    goto WAIT_DB
)

:DB_READY
echo    ✓ Base de datos lista

:: Ejecutar migración consolidada
echo    Ejecutando migración consolidada...
call %DOCKER_COMPOSE_CMD% exec -T db psql -U uns_admin -d uns_claudejp -f /docker-entrypoint-initdb.d/006_consolidado_todas_columnas.sql >nul 2>&1
if errorlevel 1 (
    echo    ! La migración ya estaba aplicada o no fue necesaria
) else (
    echo    ✓ Migración ejecutada
)

:: Reiniciar importer para asegurar importación de datos
echo    Reiniciando importador de datos...
call %DOCKER_COMPOSE_CMD% restart importer >nul 2>&1

:: Esperar a que los servicios estén completamente listos
echo.
echo Esperando que los servicios se inicialicen completamente...
timeout /t 30 /nobreak >nul

:: Verificar salud de los servicios
echo.
echo Verificando salud de los servicios...

:: Backend
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Backend aún no responde (puede estar iniciando)
    echo    Esperando 30 segundos adicionales...
    timeout /t 30 /nobreak >nul
    
    curl -s http://localhost:8000/api/health >nul 2>&1
    if errorlevel 1 (
        echo    ❌ Backend no responde
        echo    Mostrando logs del backend:
        call %DOCKER_COMPOSE_CMD% logs backend --tail=20
        echo.
        echo    Si el problema persiste, ejecute: docker-compose logs backend
    ) else (
        echo    ✓ Backend respondiendo
    )
) else (
    echo    ✓ Backend respondiendo
)

:: Frontend
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Frontend aún no responde (puede estar compilando)
) else (
    echo    ✓ Frontend respondiendo
)

:: Mostrar estado final
echo.
echo ==========================================
echo ¡ACTUALIZACIÓN COMPLETADA!
echo ==========================================
echo.
echo Estado de los containers:
call %DOCKER_COMPOSE_CMD% ps
echo.

:: Obtener IP local
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set LOCAL_IP=%%a
    goto found_ip
)
:found_ip
set LOCAL_IP=%LOCAL_IP:~1%

echo URLs de acceso:
echo   - Frontend: http://localhost:3000
echo   - Backend:  http://localhost:8000
echo   - API Docs: http://localhost:8000/api/docs
echo.
echo Acceso desde red:
echo   - Frontend: http://%LOCAL_IP%:3000
echo   - Backend:  http://%LOCAL_IP%:8000
echo.

echo Credenciales por defecto:
echo   Username: admin
echo   Password: admin123
echo   ¡IMPORTANTE! Cambie la contraseña después del primer login
echo.

echo Si algo no funciona correctamente:
echo 1. Espere 2-3 minutos más para que todo se inicialice
echo 2. Verifique logs con: %DOCKER_COMPOSE_CMD% logs -f
echo 3. Ejecute check-services.bat para diagnóstico completo
echo 4. Para problemas de base de datos: fix-database.bat
echo.

set /p OPEN_BROWSER="¿Abrir aplicación en el navegador? (S/N): "
if /I "%OPEN_BROWSER%"=="S" (
    echo Abriendo navegador...
    start http://localhost:3000
    ping 127.0.0.1 -n 3 >nul
    start http://localhost:8000/api/docs
)

echo.
echo ¡Actualización forzada completada con éxito!
pause