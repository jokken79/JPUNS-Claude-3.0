@echo off
setlocal

echo ==========================================
echo UNS-ClaudeJP 2.0 - Windows Installation v2.0
echo ==========================================
echo.

REM Check if this is the first installation
set "FIRST_INSTALL=true"
set "INSTALL_MARKER=.install_complete"

REM Check for installation markers
if exist "%INSTALL_MARKER%" (
    set "FIRST_INSTALL=false"
    echo [INFO] Instalación previa detectada.
    echo.
)

if exist ".env" (
    set "FIRST_INSTALL=false"
    echo [INFO] Archivo .env ya existe.
    echo.
)

REM Check if Docker containers are already running
docker ps --format "table {{.Names}}" | findstr "uns-claudejp" >nul 2>&1
if %errorlevel% EQU 0 (
    set "FIRST_INSTALL=false"
    echo [INFO] Contenedores UNS-ClaudeJP ya están corriendo.
    echo.
)

if "%FIRST_INSTALL%"=="true" (
    echo [PRIMERA INSTALACIÓN] Esta parece ser una instalación por primera vez.
    echo.
) else (
    echo [REINSTALACIÓN] Esta parece ser una reinstalación o actualización.
    echo.
)

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
        echo Please install Docker Desktop or enable Docker Compose V2.
        pause
        exit /b 1
    )
)

:: Verificar Docker
echo Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed!
    echo Please install Docker Desktop from:
    echo https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo [OK] Docker is installed
echo.

:: Verificar estado de Docker
echo Checking Docker status...
docker ps >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running!
    echo Please start Docker Desktop.
    pause
    exit /b 1
)
echo [OK] Docker is running
echo.

:: Opciones de instalación
echo ==========================================
echo OPCIONES DE INSTALACIÓN
echo ==========================================
echo.
if "%FIRST_INSTALL%"=="true" (
    echo [PRIMERA INSTALACIÓN] Se recomienda la opción 1 para primera vez
    echo.
)
echo 1. Instalación Fresh (recomendado para primera vez)
echo    - Elimina containers y volúmenes anteriores
echo    - Descarga imágenes actualizadas
echo    - Crea base de datos desde cero
echo.
echo 2. Actualización forzada
echo    - Elimina containers pero mantiene datos
echo    - Fuerza descarga de imágenes nuevas
echo    - Ejecuta migraciones necesarias
echo.
echo 3. Reparación de base de datos
echo    - Solo ejecuta migraciones pendientes
echo    - Mantiene todos los datos
echo.
echo 4. Salir
echo.

set /p INSTALL_TYPE="Elija una opción (1-4): "

if "%INSTALL_TYPE%"=="1" goto FRESH_INSTALL
if "%INSTALL_TYPE%"=="2" goto FORCED_UPDATE
if "%INSTALL_TYPE%"=="3" goto DATABASE_REPAIR
if "%INSTALL_TYPE%"=="4" goto EXIT
echo Opción inválida
pause
exit /b 1

:FRESH_INSTALL
echo.
echo ==========================================
echo INSTALACIÓN FRESH - LIMPIEZA COMPLETA
echo ==========================================
echo.

:: Detener y eliminar todo
echo [1/6] Deteniendo y eliminando containers anteriores...
call %DOCKER_COMPOSE_CMD% down -v >nul 2>&1

:: Eliminar imágenes antiguas para forzar descarga
echo [2/6] Eliminando imágenes antiguas...
docker image prune -f >nul 2>&1
docker system prune -f >nul 2>&1

:: Crear directorios
echo [3/6] Creating directories...
if not exist "uploads" mkdir uploads
if not exist "logs" mkdir logs
if not exist "config\factories" mkdir config\factories
echo [OK] Directories created

:: Verificar .env
echo [4/6] Checking .env file...
if not exist ".env" (
    if "%FIRST_INSTALL%"=="true" (
        echo [PRIMERA INSTALACIÓN] Creando archivo .env desde plantilla...
    ) else (
        echo Creating .env file...
    )
    copy .env.example .env >nul
    echo.
    echo [IMPORTANTE] Por favor edita el archivo .env:
    echo   1. Cambia DB_PASSWORD
    echo   2. Cambia SECRET_KEY
    echo   3. Configura email (opcional)
    echo.
    echo ¿Quieres editar .env ahora? (S/N)
    set /p EDIT_ENV=
    if /I "%EDIT_ENV%"=="S" (
        notepad .env
    )
) else (
    if "%FIRST_INSTALL%"=="true" (
        echo [PRIMERA INSTALACIÓN] Archivo .env ya existe, omitiendo creación.
    )
)
echo.

:: Descargar imágenes actualizadas
echo [5/6] Downloading latest images (force refresh)...
call %DOCKER_COMPOSE_CMD% pull --ignore-pull-failures
if errorlevel 1 (
    echo [WARNING] Could not pull some images. Continuing with local cache.
)

:: Construir y levantar
echo [6/6] Building and starting services...
call %DOCKER_COMPOSE_CMD% up -d --build --force-recreate
if errorlevel 1 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)
echo [OK] Build complete

:: Esperar a que la base de datos esté completamente saludable
if "%FIRST_INSTALL%"=="true" (
    echo [PRIMERA INSTALACIÓN] Esperando que la base de datos esté completamente saludable...
    echo Esto puede tomar 2-3 minutos en la primera instalación.
    timeout /t 30 /nobreak >nul
) else (
    echo [WAITING] Waiting for database to be fully healthy...
    timeout /t 20 /nobreak >nul
)

:: Verificar estado de salud de la base de datos
echo [CHECKING] Verifying database health...
for /l %%i in (1,1,10) do (
    call %DOCKER_COMPOSE_CMD% inspect uns-claudejp-db --format='{{.State.Health.Status}}' 2>nul | findstr -i "healthy" >nul
    if !errorlevel! equ 0 (
        echo [OK] Database is healthy
        goto HEALTHY_CHECK_COMPLETE
    )
    echo [WAITING] Database still initializing... (attempt %%i/10)
    timeout /t 5 /nobreak >nul
)
echo [WARNING] Database may still be initializing. Check logs if issues persist.
:HEALTHY_CHECK_COMPLETE
goto POST_INSTALL

:FORCED_UPDATE
echo.
echo ==========================================
echo ACTUALIZACIÓN FORZADA
echo ==========================================
echo.

:: Detener containers pero mantener volúmenes
echo [1/5] Stopping containers...
call %DOCKER_COMPOSE_CMD% down >nul 2>&1

:: Crear directorios
echo [2/5] Creating directories...
if not exist "uploads" mkdir uploads
if not exist "logs" mkdir logs
if not exist "config\factories" mkdir config\factories

:: Forzar descarga de imágenes
echo [3/5] Forcing image update...
call %DOCKER_COMPOSE_CMD% pull --ignore-pull-failures

:: Levantar con reconstrucción
echo [4/5] Rebuilding and starting...
call %DOCKER_COMPOSE_CMD% up -d --build --force-recreate
if errorlevel 1 (
    echo [ERROR] Update failed
    pause
    exit /b 1
)

:: Esperar y ejecutar migraciones
echo [5/5] Running database migrations...
timeout /t 10 /nobreak >nul
call %DOCKER_COMPOSE_CMD% exec -T db psql -U uns_admin -d uns_claudejp -f /docker-entrypoint-initdb.d/006_consolidado_todas_columnas.sql >nul 2>&1
echo [OK] Migrations executed
goto POST_INSTALL

:DATABASE_REPAIR
echo.
echo ==========================================
echo REPARACIÓN DE BASE DE DATOS
echo ==========================================
echo.

:: Verificar si los containers están corriendo
echo [1/3] Checking containers...
%DOCKER_COMPOSE_CMD% ps >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No containers running. Please start the app first.
    pause
    exit /b 1
)

:: Ejecutar migración consolidada
echo [2/3] Running consolidated migration...
call %DOCKER_COMPOSE_CMD% exec -T db psql -U uns_admin -d uns_claudejp -f /docker-entrypoint-initdb.d/006_consolidado_todas_columnas.sql
if errorlevel 1 (
    echo [ERROR] Migration failed
    pause
    exit /b 1
)

:: Reiniciar importer si es necesario
echo [3/3] Restarting data importer...
call %DOCKER_COMPOSE_CMD% restart importer >nul 2>&1
echo [OK] Database repaired
goto POST_INSTALL

:POST_INSTALL
echo.
echo Waiting for services to initialize...
timeout /t 30 /nobreak >nul

:: Verificar salud de los servicios
echo.
echo Checking service health...
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Backend not responding yet. This is normal on first startup.
    echo The database might still be initializing. Please wait a few minutes.
    echo.
    echo Checking database logs...
    call %DOCKER_COMPOSE_CMD% logs db --tail=10
    echo.
    echo Checking backend logs...
    call %DOCKER_COMPOSE_CMD% logs backend --tail=10
) else (
    echo [OK] Backend is responding
)
echo.

:: Obtener IP local
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set LOCAL_IP=%%a
    goto found_ip
)
:found_ip
set LOCAL_IP=%LOCAL_IP:~1%

:: Crear marcador de instalación
echo. > "%INSTALL_MARKER%"
echo [INFO] Marcador de instalación creado.

:: Mostrar resumen
echo ==========================================
if "%FIRST_INSTALL%"=="true" (
    echo ¡Primera Instalación Completada!
) else (
    echo ¡Instalación/Actualización Completada!
)
echo ==========================================
echo.

if "%FIRST_INSTALL%"=="true" (
    echo [NOTAS IMPORTANTES PRIMERA INSTALACIÓN]:
    echo  - La base de datos se está inicializando en segundo plano
    echo  - El primer inicio de sesión puede tardar 2-3 minutos
    echo  - Se han creado las credenciales por defecto
    echo.
    echo Credenciales por defecto:
    echo   - Usuario: admin
    echo   - Contraseña: admin123
    echo   [¡IMPORTANTE!] Cambia la contraseña después del primer login!
    echo.
) else (
    echo ¡Aplicación actualizada exitosamente!
    echo.
)

echo Acceder a la aplicación:
echo   - Frontend: http://localhost:3000
echo   - Backend API: http://localhost:8000
echo   - API Docs: http://localhost:8000/api/docs
echo.
echo Acceso desde red:
echo   - Frontend: http://%LOCAL_IP%:3000
echo   - Backend: http://%LOCAL_IP%:8000
echo.
echo Comandos útiles:
echo   - Inicio rápido: start-app.bat
echo   - Detener rápido: stop-app.bat
echo   - Ver estado: check-services.bat
echo   - Ver logs: %DOCKER_COMPOSE_CMD% logs -f
echo   - Detener: %DOCKER_COMPOSE_CMD% stop
echo   - Iniciar: %DOCKER_COMPOSE_CMD% start
echo   - Reiniciar: %DOCKER_COMPOSE_CMD% restart
echo   - Eliminar: %DOCKER_COMPOSE_CMD% down
echo.
echo Solución de problemas:
echo   - Si el backend no responde, espera 2-3 minutos para inicialización de BD
echo   - Revisa logs con: %DOCKER_COMPOSE_CMD% logs
echo   - Para problemas de base de datos, ejecuta: fix-database.bat
echo.

:: Preguntar si abrir navegador
echo ¿Abrir aplicación en el navegador? (S/N)
set /p OPEN_BROWSER=
if /I "%OPEN_BROWSER%"=="S" (
    start http://localhost:3000
    start http://localhost:8000/api/docs
)
echo.
goto END

:EXIT
echo Installation cancelled.
goto END

:END
endlocal
pause
