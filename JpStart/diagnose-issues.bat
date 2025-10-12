@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul

title UNS-ClaudeJP 2.5 - Full Diagnostic Tool

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║           UNS-CLAUDEJP 2.5 - DIAGNÓSTICO COMPLETO              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar Docker Compose
echo [PASO 1/10] Detectando Docker Compose...
set "DOCKER_COMPOSE_CMD="
docker compose version >nul 2>&1
if %errorlevel% EQU 0 (
    set "DOCKER_COMPOSE_CMD=docker compose"
    echo    ✅ Docker Compose V2 detectado
) else (
    docker-compose version >nul 2>&1
    if %errorlevel% EQU 0 (
        set "DOCKER_COMPOSE_CMD=docker-compose"
        echo    ✅ Docker Compose V1 detectado
    ) else (
        echo    ❌ Docker Compose NO instalado
        echo    SOLUCIÓN: Instale Docker Desktop desde https://www.docker.com/products/docker-desktop
        goto END_DIAGNOSIS
    )
)

:: Verificar Docker
echo.
echo [PASO 2/10] Verificando Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo    ❌ Docker NO instalado
    echo    SOLUCIÓN: Instale Docker Desktop
    goto END_DIAGNOSIS
) else (
    for /f "tokens=*" %%i in ('docker --version') do echo    ✅ %%i
)

:: Verificar Docker daemon
echo.
echo [PASO 3/10] Verificando Docker daemon...
docker ps >nul 2>&1
if errorlevel 1 (
    echo    ❌ Docker daemon NO está corriendo
    echo    SOLUCIÓN: Inicie Docker Desktop
    goto END_DIAGNOSIS
) else (
    echo    ✅ Docker daemon corriendo
)

:: Verificar archivos de configuración
echo.
echo [PASO 4/10] Verificando archivos de configuración...

if exist ".env" (
    echo    ✅ .env encontrado
) else (
    echo    ❌ .env NO encontrado
    echo    SOLUCIÓN: Copie .env.example a .env y configure las variables
)

if exist "docker-compose.yml" (
    echo    ✅ docker-compose.yml encontrado
) else (
    echo    ❌ docker-compose.yml NO encontrado
    echo    SOLUCIÓN: Asegúrese de estar en el directorio correcto del proyecto
)

if exist "config" (
    echo    ✅ Directorio config encontrado
) else (
    echo    ❌ Directorio config NO encontrado
    echo    SOLUCIÓN: Cree el directorio config
)

if exist "config\factories_index.json" (
    echo    ✅ factories_index.json encontrado
) else (
    echo    ❌ factories_index.json NO encontrado
    echo    SOLUCIÓN: Asegúrese de que el archivo de configuración de fábricas exista
)

if exist "config\employee_master.xlsm" (
    echo    ✅ employee_master.xlsm encontrado
) else (
    echo    ❌ employee_master.xlsm NO encontrado
    echo    SOLUCIÓN: Coloque el archivo maestro de empleados en config/
)

:: Verificar containers
echo.
echo [PASO 5/10] Verificando estado de containers...
echo    Containers UNS-ClaudeJP:
docker ps --filter "name=uns-claudejp" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

:: Verificar volúmenes
echo.
echo [PASO 6/10] Verificando volúmenes de Docker...
echo    Volúmenes relacionados:
docker volume ls --filter "name=postgres" --format "table {{.Name}}\t{{.Driver}}"

:: Verificar redes
echo.
echo [PASO 7/10] Verificando redes de Docker...
echo    Redes relacionadas:
docker network ls --filter "name=uns" --format "table {{.Name}}\t{{.Driver}}"

:: Verificar base de datos
echo.
echo [PASO 8/10] Verificando conexión a base de datos...
docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
if errorlevel 1 (
    echo    ❌ Base de datos NO está lista
    echo    Verificando logs de la base de datos...
    echo    ──────────────────────────────────────
    call %DOCKER_COMPOSE_CMD% logs db --tail=20
    echo    ──────────────────────────────────────
    echo    SOLUCIONES POSIBLES:
    echo    1. Espere unos minutos para que la base de datos se inicialice
    echo    2. Verifique que no haya conflictos de puerto (5432)
    echo    3. Reinicie con: docker compose restart db
) else (
    echo    ✅ Base de datos está lista
    
    :: Verificar tablas
    echo    Verificando tablas de la base de datos...
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "\dt" 2>nul | findstr "employees" >nul
    if errorlevel 1 (
        echo    ⚠ Tabla employees NO encontrada
        echo    SOLUCIÓN: Ejecute las migraciones iniciales
    ) else (
        echo    ✅ Tabla employees encontrada
        
        :: Verificar columnas específicas
        echo    Verificando columnas críticas...
        docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "\d employees" 2>nul | findstr "current_hire_date" >nul
        if errorlevel 1 (
            echo    ❌ Columna current_hire_date NO encontrada
            echo    SOLUCIÓN: Ejecute fix-database.bat o la migración 006_consolidado_todas_columnas.sql
        ) else (
            echo    ✅ Columnas críticas encontradas
        )
    )
)

:: Verificar backend
echo.
echo [PASO 9/10] Verificando Backend API...
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ❌ Backend API NO responde
    echo    Verificando logs del backend...
    echo    ──────────────────────────────────────
    call %DOCKER_COMPOSE_CMD% logs backend --tail=20
    echo    ──────────────────────────────────────
    echo    SOLUCIONES POSIBLES:
    echo    1. Espere 1-2 minutos para que el backend se inicie completamente
    echo    2. Verifique que no haya conflictos de puerto (8000)
    echo    3. Reinicie con: docker compose restart backend
    echo    4. Verifique que la base de datos esté funcionando correctamente
) else (
    echo    ✅ Backend API respondiendo
    
    :: Probar endpoint específico
    echo    Testeando endpoint de login...
    curl -s -X POST http://localhost:8000/api/auth/login -H "Content-Type: application/x-www-form-urlencoded" -d "username=admin&password=admin123" >nul 2>&1
    if errorlevel 1 (
        echo    ⚠ Endpoint de login no responde correctamente
    ) else (
        echo    ✅ Endpoint de login funcionando
    )
)

:: Verificar frontend
echo.
echo [PASO 10/10] Verificando Frontend...
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Frontend no responde (puede estar compilando)
    echo    Verificando logs del frontend...
    echo    ──────────────────────────────────────
    call %DOCKER_COMPOSE_CMD% logs frontend --tail=15
    echo    ──────────────────────────────────────
    echo    NOTA: Es normal que el frontend tarde varios minutos en compilar
    echo    SOLUCIÓN: Espere 2-5 minutos y verifique nuevamente
) else (
    echo    ✅ Frontend respondiendo
)

:: Verificar usuario admin
echo.
echo [VERIFICACIÓN EXTRA] Usuario admin en base de datos...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT username, email, role, is_active FROM users WHERE username='admin';" 2>nul | findstr "admin" >nul
if errorlevel 1 (
    echo    ❌ Usuario admin NO encontrado
    echo    SOLUCIÓN: Ejecute la migración inicial o recreate admin user
) else (
    echo    ✅ Usuario admin existe
    echo    Datos del usuario:
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT username, email, role, is_active FROM users WHERE username='admin';" 2>nul
)

:: Verificar uso de recursos
echo.
echo [VERIFICACIÓN DE RECURSOS] Uso de Docker...
echo    Uso de disco:
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}"

echo    Uso de memoria por container:
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.CPUPerc}}" --filter "name=uns-claudejp"

:: Resumen y recomendaciones
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                          RESUMEN                               ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Obtener IP local
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set LOCAL_IP=%%a
    goto found_ip
)
:found_ip
set LOCAL_IP=%LOCAL_IP:~1%

echo URLs de acceso:
echo   Frontend:  http://localhost:3000
echo   Backend:   http://localhost:8000
echo   API Docs:  http://localhost:8000/api/docs
echo   Acceso red: http://%LOCAL_IP%:3000
echo.

echo Credenciales:
echo   Username: admin
echo   Password: admin123
echo.

:: Comandos útiles
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                    COMANDOS ÚTILES                              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Para problemas comunes:
echo   • Reiniciar todo:          %DOCKER_COMPOSE_CMD% restart
echo   • Ver logs en vivo:        %DOCKER_COMPOSE_CMD% logs -f
echo   • Ver logs específicos:    %DOCKER_COMPOSE_CMD% logs [db|backend|frontend]
echo   • Detener todo:            %DOCKER_COMPOSE_CMD% down
echo   • Limpiar Docker:          docker system prune -a
echo.
echo Para reparación:
echo   • Reparar BD:              fix-database.bat
echo   • Actualización forzada:   force-update.bat
echo   • Instalación nueva:       install-windows-v2.bat
echo   • Inicio rápido:           start-app.bat
echo.

goto END_DIAGNOSIS

:END_DIAGNOSIS
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  DIAGNÓSTICO COMPLETADO                        ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Si los problemas persisten, por favor:
echo 1. Tome capturas de pantalla de este diagnóstico
echo 2. Guarde los logs: %DOCKER_COMPOSE_CMD% logs > logs.txt
echo 3. Contacte al soporte técnico
echo.
pause