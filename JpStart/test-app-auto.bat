@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

:: ============================================
:: TEST-APP-AUTO.BAT - Verificación Automática
:: UNS-ClaudeJP 2.0 (Sin interacción del usuario)
:: ============================================

title UNS-ClaudeJP - Test Suite (Auto)

:: Crear archivo de reporte
set "REPORT_FILE=test-report-%DATE:~-4,4%%DATE:~-10,2%%DATE:~-7,2%-%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.txt"
set "REPORT_FILE=%REPORT_FILE: =0%"

color 0B
echo ╔════════════════════════════════════════════════════════════════╗ > "%REPORT_FILE%"
echo ║         🧪 UNS-CLAUDEJP 2.0 - REPORTE DE PRUEBAS              ║ >> "%REPORT_FILE%"
echo ╚════════════════════════════════════════════════════════════════╝ >> "%REPORT_FILE%"
echo Fecha: %DATE% %TIME% >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║         🧪 UNS-CLAUDEJP 2.0 - SISTEMA DE PRUEBAS              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [INFO] Iniciando verificación automática del sistema...
echo.

set "BACKEND_URL=http://localhost:8000"
set "FRONTEND_URL=http://localhost:3000"
set "TOTAL_TESTS=0"
set "PASSED_TESTS=0"
set "FAILED_TESTS=0"

:: ============================================
:: TEST 1: Docker
:: ============================================
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 1/12: Verificar Docker Desktop
echo ═══════════════════════════════════════════════════════════════
echo TEST 1: Verificar Docker Desktop >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

docker --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [❌ FALLO] Docker no está instalado
    echo [FALLO] Docker no está instalado >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    docker ps > nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo [❌ FALLO] Docker Desktop no está corriendo
        echo [FALLO] Docker Desktop no está corriendo >> "%REPORT_FILE%"
        set /a FAILED_TESTS+=1
    ) else (
        echo [✅ ÉXITO] Docker está instalado y corriendo
        echo [ÉXITO] Docker operativo >> "%REPORT_FILE%"
        set /a PASSED_TESTS+=1
    )
)

:: ============================================
:: TEST 2: Contenedores
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 2/12: Verificar Contenedores Docker
echo ═══════════════════════════════════════════════════════════════
echo TEST 2: Verificar Contenedores Docker >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

set "CONTAINERS_OK=1"
docker ps --format "{{.Names}}" | findstr "uns-claudejp-db" > nul || set "CONTAINERS_OK=0"
docker ps --format "{{.Names}}" | findstr "uns-claudejp-backend" > nul || set "CONTAINERS_OK=0"
docker ps --format "{{.Names}}" | findstr "uns-claudejp-frontend" > nul || set "CONTAINERS_OK=0"

if %CONTAINERS_OK%==0 (
    echo [❌ FALLO] Algunos contenedores no están corriendo
    echo [FALLO] Contenedores no corriendo >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Todos los contenedores están corriendo
    echo [ÉXITO] Contenedores: DB, Backend, Frontend OK >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 3: PostgreSQL
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 3/12: Healthcheck de PostgreSQL
echo ═══════════════════════════════════════════════════════════════
echo TEST 3: Healthcheck de PostgreSQL >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

docker exec uns-claudejp-db pg_isready -U uns_admin > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [❌ FALLO] PostgreSQL no está aceptando conexiones
    echo [FALLO] PostgreSQL no responde >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] PostgreSQL está saludable
    echo [ÉXITO] PostgreSQL saludable >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 4: Backend Health
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 4/12: Backend Health Endpoint
echo ═══════════════════════════════════════════════════════════════
echo TEST 4: Backend Health Endpoint >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

curl -s -o nul -w "%%{http_code}" %BACKEND_URL%/api/health | findstr "200" > nul
if %ERRORLEVEL% NEQ 0 (
    echo [❌ FALLO] Backend health endpoint no responde
    echo [FALLO] Backend health no responde >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Backend health endpoint responde correctamente
    echo [ÉXITO] Backend health OK >> "%REPORT_FILE%"
    curl -s %BACKEND_URL%/api/health >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 5: Azure OCR
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 5/12: Azure OCR Service Health
echo ═══════════════════════════════════════════════════════════════
echo TEST 5: Azure OCR Service Health >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

curl -s -o nul -w "%%{http_code}" %BACKEND_URL%/api/azure-ocr/health | findstr "200" > nul
if %ERRORLEVEL% NEQ 0 (
    echo [❌ FALLO] Azure OCR endpoint no responde
    echo [FALLO] Azure OCR no responde >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Azure OCR Service está operativo
    echo [ÉXITO] Azure OCR operativo >> "%REPORT_FILE%"
    curl -s %BACKEND_URL%/api/azure-ocr/health >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 6: Frontend
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 6/12: Frontend Accessibility
echo ═══════════════════════════════════════════════════════════════
echo TEST 6: Frontend Accessibility >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

curl -s -o nul -w "%%{http_code}" %FRONTEND_URL% | findstr "200" > nul
if %ERRORLEVEL% NEQ 0 (
    echo [❌ FALLO] Frontend no responde en puerto 3000
    echo [FALLO] Frontend no accesible >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Frontend está accesible en puerto 3000
    echo [ÉXITO] Frontend accesible >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 7: rirekisho.html
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 7/12: Formulario OCR (rirekisho.html)
echo ═══════════════════════════════════════════════════════════════
echo TEST 7: Formulario OCR >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

curl -s -o nul -w "%%{http_code}" %FRONTEND_URL%/templates/rirekisho.html | findstr "200" > nul
if %ERRORLEVEL% NEQ 0 (
    echo [❌ FALLO] Formulario rirekisho.html no accesible
    echo [FALLO] rirekisho.html no accesible >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Formulario OCR accesible
    echo [ÉXITO] rirekisho.html accesible >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 8: Swagger UI
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 8/12: API Documentation (Swagger UI)
echo ═══════════════════════════════════════════════════════════════
echo TEST 8: API Documentation >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

curl -s -o nul -w "%%{http_code}" %BACKEND_URL%/api/docs | findstr "200" > nul
if %ERRORLEVEL% NEQ 0 (
    echo [❌ FALLO] Swagger UI no accesible
    echo [FALLO] Swagger UI no accesible >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Swagger UI accesible
    echo [ÉXITO] Swagger UI accesible >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 9: Archivos Config
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 9/12: Archivos de Configuración
echo ═══════════════════════════════════════════════════════════════
echo TEST 9: Archivos de Configuración >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

if not exist ".env" (
    echo [❌ FALLO] Archivo .env no encontrado
    echo [FALLO] .env no encontrado >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else if not exist "docker-compose.yml" (
    echo [❌ FALLO] Archivo docker-compose.yml no encontrado
    echo [FALLO] docker-compose.yml no encontrado >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Archivos de configuración presentes
    echo [ÉXITO] .env y docker-compose.yml presentes >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 10: Variables de Entorno
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 10/12: Variables de Entorno Críticas
echo ═══════════════════════════════════════════════════════════════
echo TEST 10: Variables de Entorno >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

findstr /C:"DATABASE_URL" .env > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [❌ FALLO] DATABASE_URL no configurada
    echo [FALLO] DATABASE_URL no configurada >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Variables críticas configuradas
    echo [ÉXITO] DATABASE_URL configurada >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 11: Logo UNS
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 11/12: Logo UNS Integrado
echo ═══════════════════════════════════════════════════════════════
echo TEST 11: Logo UNS >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

if not exist "frontend\public\uns-logo.gif" (
    echo [❌ FALLO] Logo UNS no encontrado
    echo [FALLO] Logo UNS no encontrado >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Logo UNS presente
    echo [ÉXITO] Logo UNS presente >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: TEST 12: Conexión BD
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 12/12: Conexión a Base de Datos
echo ═══════════════════════════════════════════════════════════════
echo TEST 12: Conexión a Base de Datos >> "%REPORT_FILE%"
set /a TOTAL_TESTS+=1

docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT COUNT(*) FROM employees;" > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [❌ FALLO] No se pudo consultar la tabla employees
    echo [FALLO] Query a BD falló >> "%REPORT_FILE%"
    set /a FAILED_TESTS+=1
) else (
    echo [✅ ÉXITO] Conexión a base de datos exitosa
    echo [ÉXITO] Conexión BD exitosa >> "%REPORT_FILE%"
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT COUNT(*) as total_employees FROM employees;" >> "%REPORT_FILE%"
    set /a PASSED_TESTS+=1
)

:: ============================================
:: RESULTADOS
:: ============================================
echo.
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                     📊 RESULTADOS FINALES                      ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo. >> "%REPORT_FILE%"
echo ════════════════════════════════════════════════════════════════ >> "%REPORT_FILE%"
echo RESULTADOS FINALES >> "%REPORT_FILE%"
echo ════════════════════════════════════════════════════════════════ >> "%REPORT_FILE%"

echo [INFO] Total de pruebas ejecutadas: %TOTAL_TESTS%
echo [✅] Pruebas exitosas: %PASSED_TESTS%
echo [❌] Pruebas fallidas: %FAILED_TESTS%

echo Total de pruebas: %TOTAL_TESTS% >> "%REPORT_FILE%"
echo Pruebas exitosas: %PASSED_TESTS% >> "%REPORT_FILE%"
echo Pruebas fallidas: %FAILED_TESTS% >> "%REPORT_FILE%"

set /a SUCCESS_RATE=(%PASSED_TESTS%*100)/%TOTAL_TESTS%
echo Tasa de éxito: %SUCCESS_RATE%%% >> "%REPORT_FILE%"

echo.
if %SUCCESS_RATE% GEQ 100 (
    color 0A
    echo ╔════════════════════════════════════════════════════════════════╗
    echo ║          🎉 ¡PERFECTO! TODOS LOS TESTS PASARON                ║
    echo ║              Sistema 100%% Operativo                           ║
    echo ╚════════════════════════════════════════════════════════════════╝
    echo ESTADO: PERFECTO - Sistema 100%% Operativo >> "%REPORT_FILE%"
) else if %SUCCESS_RATE% GEQ 80 (
    color 0E
    echo ╔════════════════════════════════════════════════════════════════╗
    echo ║         ⚠️  SISTEMA OPERATIVO CON ADVERTENCIAS                ║
    echo ║     Tasa de éxito: %SUCCESS_RATE%%%% - Revisar advertencias          ║
    echo ╚════════════════════════════════════════════════════════════════╝
    echo ESTADO: OPERATIVO CON ADVERTENCIAS (%SUCCESS_RATE%%%%) >> "%REPORT_FILE%"
) else (
    color 0C
    echo ╔════════════════════════════════════════════════════════════════╗
    echo ║           ❌ SISTEMA CON PROBLEMAS CRÍTICOS                   ║
    echo ║     Tasa de éxito: %SUCCESS_RATE%%%% - Atención requerida           ║
    echo ╚════════════════════════════════════════════════════════════════╝
    echo ESTADO: PROBLEMAS CRÍTICOS (%SUCCESS_RATE%%%%) >> "%REPORT_FILE%"
)

echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔗 URLs DE ACCESO
echo ═══════════════════════════════════════════════════════════════
echo.
echo Frontend:      %FRONTEND_URL%
echo Backend API:   %BACKEND_URL%/api
echo API Docs:      %BACKEND_URL%/api/docs
echo Formulario:    %FRONTEND_URL%/templates/rirekisho.html

echo. >> "%REPORT_FILE%"
echo URLs: >> "%REPORT_FILE%"
echo Frontend: %FRONTEND_URL% >> "%REPORT_FILE%"
echo Backend: %BACKEND_URL%/api >> "%REPORT_FILE%"
echo API Docs: %BACKEND_URL%/api/docs >> "%REPORT_FILE%"

echo.
echo [INFO] Reporte guardado en: %REPORT_FILE%
echo.
echo Presione cualquier tecla para salir...
pause > nul

endlocal
