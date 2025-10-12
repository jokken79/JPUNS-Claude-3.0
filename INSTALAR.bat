@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Instalación Inicial

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            UNS-CLAUDEJP - INSTALACIÓN INICIAL                   ║
echo ║                    PRIMERA VEZ EN WINDOWS                       ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Verificar si Docker está instalado
echo [1/5] Verificando Docker Desktop...
echo.

docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Desktop NO está instalado
    echo.
    echo ══════════════════════════════════════════════════════════════════
    echo   NECESITAS INSTALAR DOCKER DESKTOP PRIMERO
    echo ══════════════════════════════════════════════════════════════════
    echo.
    echo Pasos:
    echo.
    echo 1. Abre tu navegador
    echo 2. Ve a: https://www.docker.com/products/docker-desktop
    echo 3. Descarga "Docker Desktop for Windows"
    echo 4. Instala (siguiente, siguiente, finalizar)
    echo 5. Reinicia Windows
    echo 6. Abre Docker Desktop y espera que inicie
    echo 7. Vuelve a ejecutar este script
    echo.
    echo ══════════════════════════════════════════════════════════════════
    echo.

    choice /C SN /M "¿Quieres abrir la página de descarga ahora? (S=Sí, N=No)"
    if errorlevel 2 goto :end
    if errorlevel 1 (
        start https://www.docker.com/products/docker-desktop
        echo.
        echo Página abierta en tu navegador.
        echo Instala Docker Desktop y vuelve a ejecutar este script.
        echo.
    )
    goto :end
)

echo ✅ Docker instalado (versión:
docker --version
echo.

:: Verificar Docker Compose
echo [2/5] Verificando Docker Compose...
set "DOCKER_COMPOSE_CMD="
docker compose version >nul 2>&1
if %errorlevel% EQU 0 (
    set "DOCKER_COMPOSE_CMD=docker compose"
    echo ✅ Docker Compose V2 detectado
) else (
    docker-compose version >nul 2>&1
    if %errorlevel% EQU 0 (
        set "DOCKER_COMPOSE_CMD=docker-compose"
        echo ✅ Docker Compose V1 detectado
    ) else (
        echo ❌ Docker Compose NO detectado
        echo.
        echo Docker Compose debería venir con Docker Desktop.
        echo Asegúrate de que Docker Desktop esté corriendo.
        echo.
        pause
        exit /b 1
    )
)
echo.

:: Verificar que Docker Desktop esté corriendo
echo [3/5] Verificando que Docker Desktop esté corriendo...
docker ps >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Desktop NO está corriendo
    echo.
    echo Por favor:
    echo 1. Abre Docker Desktop (ícono de ballena en la barra de tareas)
    echo 2. Espera a que inicie completamente
    echo 3. Vuelve a ejecutar este script
    echo.
    pause
    exit /b 1
)
echo ✅ Docker Desktop está corriendo
echo.

:: Verificar puertos disponibles
echo [4/5] Verificando puertos disponibles...
echo.

set "PORTS_OK=1"

netstat -ano | findstr ":3000 " | findstr "LISTENING" >nul 2>&1
if %errorlevel% EQU 0 (
    echo ⚠ Puerto 3000 está ocupado
    set "PORTS_OK=0"
) else (
    echo ✅ Puerto 3000 disponible (Frontend)
)

netstat -ano | findstr ":8000 " | findstr "LISTENING" >nul 2>&1
if %errorlevel% EQU 0 (
    echo ⚠ Puerto 8000 está ocupado
    set "PORTS_OK=0"
) else (
    echo ✅ Puerto 8000 disponible (Backend)
)

netstat -ano | findstr ":5432 " | findstr "LISTENING" >nul 2>&1
if %errorlevel% EQU 0 (
    echo ⚠ Puerto 5432 está ocupado
    set "PORTS_OK=0"
) else (
    echo ✅ Puerto 5432 disponible (Base de datos)
)

echo.

if "%PORTS_OK%"=="0" (
    echo ⚠ ADVERTENCIA: Algunos puertos están ocupados
    echo.
    echo Opciones:
    echo 1. Cierra las aplicaciones que usan esos puertos
    echo 2. O continúa y puede que haya errores
    echo.
    choice /C CN /M "¿Deseas continuar de todos modos? (C=Continuar, N=No)"
    if errorlevel 2 (
        echo.
        echo Instalación cancelada.
        echo.
        echo Para ver qué proceso usa un puerto:
        echo   netstat -ano ^| findstr ":3000"
        echo.
        pause
        exit /b 1
    )
)

:: Descargar e instalar (build)
echo.
echo [5/5] Instalando UNS-ClaudeJP...
echo.
echo ⏳ Esta es la PRIMERA VEZ, tomará 5-10 minutos
echo    Docker necesita:
echo    - Descargar imágenes base (Python, Node, PostgreSQL)
echo    - Construir el Backend (FastAPI)
echo    - Construir el Frontend (React)
echo    - Crear volúmenes para la base de datos
echo    - Inicializar la base de datos con datos de prueba
echo.
echo    Por favor, ten paciencia... ☕
echo.

%DOCKER_COMPOSE_CMD% build --no-cache

if errorlevel 1 (
    echo.
    echo ❌ Error durante la construcción
    echo.
    echo Posibles causas:
    echo 1. Conexión a internet lenta o interrumpida
    echo 2. Docker Desktop sin suficiente memoria
    echo 3. Poco espacio en disco
    echo.
    echo Soluciones:
    echo 1. Verifica tu conexión a internet
    echo 2. Aumenta memoria para Docker Desktop (Settings ^> Resources)
    echo 3. Libera espacio en disco
    echo 4. Vuelve a ejecutar este script
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Construcción completada
echo.

:: Iniciar por primera vez
echo Iniciando servicios por primera vez...
%DOCKER_COMPOSE_CMD% up -d

if errorlevel 1 (
    echo.
    echo ❌ Error al iniciar los servicios
    echo.
    echo Ver logs para más detalles:
    echo   LOGS.bat
    echo.
    pause
    exit /b 1
)

echo.
echo Esperando a que los servicios estén listos...
echo Esto puede tomar 1-2 minutos...
echo.

timeout /t 60 /nobreak >nul

:: Verificar que todo esté corriendo
echo.
echo Estado de los servicios:
%DOCKER_COMPOSE_CMD% ps

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              ✅ INSTALACIÓN COMPLETADA ✅                      ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo 🎉 ¡UNS-ClaudeJP está instalado y corriendo!
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
echo 📝 Nota: El frontend puede tardar 1-2 minutos más en compilar
echo          Si ves "Loading..." espera un momento y recarga.
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
echo 💡 Próximos pasos:
echo.
echo 1. Para iniciar en el futuro:      START.bat
echo 2. Para detener:                   STOP.bat
echo 3. Para ver logs:                  LOGS.bat
echo 4. Para guía rápida:               GUIA_RAPIDA.md
echo 5. Para documentación completa:    README.md
echo.
echo ══════════════════════════════════════════════════════════════════
echo.

choice /C SN /M "¿Abrir en el navegador ahora? (S=Sí, N=No)"
if errorlevel 2 goto :end
if errorlevel 1 (
    echo.
    echo Abriendo navegador...
    start http://localhost:3000
)

:end
echo.
echo ¡Instalación finalizada!
echo.
pause
