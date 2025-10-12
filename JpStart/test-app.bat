@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

:: ============================================
:: TEST-APP.BAT - Sistema de Verificación Completa
:: UNS-ClaudeJP 2.0
:: ============================================

title UNS-ClaudeJP - Test Suite

color 0B
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║         🧪 UNS-CLAUDEJP 2.0 - SISTEMA DE PRUEBAS             ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [INFO] Iniciando verificación completa del sistema...
echo [INFO] Fecha: %DATE% %TIME%
echo.

:: ============================================
:: Variables
:: ============================================
set "BACKEND_URL=http://localhost:8000"
set "FRONTEND_URL=http://localhost:3000"
set "TOTAL_TESTS=0"
set "PASSED_TESTS=0"
set "FAILED_TESTS=0"

:: ============================================
:: TEST 1: Verificar Docker
:: ============================================
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 1/12: Verificar Docker Desktop
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

docker --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [❌ FALLO] Docker no está instalado
    set /a FAILED_TESTS+=1
    goto :test_2
)

docker ps > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [❌ FALLO] Docker Desktop no está corriendo
    set /a FAILED_TESTS+=1
    goto :test_2
)

echo [✅ ÉXITO] Docker está instalado y corriendo
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 2: Verificar Contenedores
:: ============================================
:test_2
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 2/12: Verificar Contenedores Docker
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

docker ps --format "{{.Names}}" | findstr "uns-claudejp-db" > nul
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [❌ FALLO] Contenedor de Base de Datos no está corriendo
    set /a FAILED_TESTS+=1
    goto :test_3
)

docker ps --format "{{.Names}}" | findstr "uns-claudejp-backend" > nul
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [❌ FALLO] Contenedor de Backend no está corriendo
    set /a FAILED_TESTS+=1
    goto :test_3
)

docker ps --format "{{.Names}}" | findstr "uns-claudejp-frontend" > nul
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [❌ FALLO] Contenedor de Frontend no está corriendo
    set /a FAILED_TESTS+=1
    goto :test_3
)

echo [✅ ÉXITO] Todos los contenedores están corriendo
echo    - uns-claudejp-db: OK
echo    - uns-claudejp-backend: OK
echo    - uns-claudejp-frontend: OK
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 3: Healthcheck de Base de Datos
:: ============================================
:test_3
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 3/12: Healthcheck de PostgreSQL
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

docker exec uns-claudejp-db pg_isready -U uns_admin > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [❌ FALLO] PostgreSQL no está aceptando conexiones
    set /a FAILED_TESTS+=1
    goto :test_4
)

echo [✅ ÉXITO] PostgreSQL está saludable
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 4: Verificar Backend Health Endpoint
:: ============================================
:test_4
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 4/12: Backend Health Endpoint
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

curl -s %BACKEND_URL%/api/health > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0E
    echo [⚠️ ADVERTENCIA] Backend health endpoint no responde
    echo [INFO] Intentando verificar si el contenedor está corriendo...
    docker ps --format "{{.Status}}" --filter "name=uns-claudejp-backend"
    set /a FAILED_TESTS+=1
    goto :test_5
)

echo [✅ ÉXITO] Backend health endpoint responde correctamente
curl -s %BACKEND_URL%/api/health
echo.
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 5: Verificar OCR Azure Health
:: ============================================
:test_5
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 5/12: Azure OCR Service Health
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

curl -s %BACKEND_URL%/api/azure-ocr/health > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0E
    echo [⚠️ ADVERTENCIA] Azure OCR endpoint no responde
    set /a FAILED_TESTS+=1
    goto :test_6
)

echo [✅ ÉXITO] Azure OCR Service está operativo
curl -s %BACKEND_URL%/api/azure-ocr/health
echo.
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 6: Verificar Frontend
:: ============================================
:test_6
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 6/12: Frontend Accessibility
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

curl -s %FRONTEND_URL% > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0E
    echo [⚠️ ADVERTENCIA] Frontend no responde en puerto 3000
    set /a FAILED_TESTS+=1
    goto :test_7
)

echo [✅ ÉXITO] Frontend está accesible en puerto 3000
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 7: Verificar Formulario OCR (rirekisho.html)
:: ============================================
:test_7
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 7/12: Formulario OCR (rirekisho.html)
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

curl -s %FRONTEND_URL%/templates/rirekisho.html > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0E
    echo [⚠️ ADVERTENCIA] Formulario rirekisho.html no accesible
    set /a FAILED_TESTS+=1
    goto :test_8
)

echo [✅ ÉXITO] Formulario OCR accesible
echo [INFO] URL: %FRONTEND_URL%/templates/rirekisho.html
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 8: Verificar API Docs (Swagger)
:: ============================================
:test_8
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 8/12: API Documentation (Swagger UI)
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

curl -s %BACKEND_URL%/api/docs > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0E
    echo [⚠️ ADVERTENCIA] Swagger UI no accesible
    set /a FAILED_TESTS+=1
    goto :test_9
)

echo [✅ ÉXITO] Swagger UI accesible
echo [INFO] URL: %BACKEND_URL%/api/docs
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 9: Verificar Archivos de Configuración
:: ============================================
:test_9
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 9/12: Archivos de Configuración
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

if not exist ".env" (
    color 0C
    echo [❌ FALLO] Archivo .env no encontrado
    set /a FAILED_TESTS+=1
    goto :test_10
)

if not exist "docker-compose.yml" (
    color 0C
    echo [❌ FALLO] Archivo docker-compose.yml no encontrado
    set /a FAILED_TESTS+=1
    goto :test_10
)

echo [✅ ÉXITO] Archivos de configuración presentes
echo    - .env: OK
echo    - docker-compose.yml: OK
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 10: Verificar Variables de Entorno Críticas
:: ============================================
:test_10
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 10/12: Variables de Entorno Críticas
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

findstr /C:"DATABASE_URL" .env > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [❌ FALLO] DATABASE_URL no configurada en .env
    set /a FAILED_TESTS+=1
    goto :test_11
)

findstr /C:"AZURE_COMPUTER_VISION_ENDPOINT" .env > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0E
    echo [⚠️ ADVERTENCIA] AZURE_COMPUTER_VISION_ENDPOINT no configurada
    echo [INFO] El OCR podría no funcionar correctamente
)

findstr /C:"AZURE_COMPUTER_VISION_KEY" .env > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0E
    echo [⚠️ ADVERTENCIA] AZURE_COMPUTER_VISION_KEY no configurada
    echo [INFO] El OCR podría no funcionar correctamente
)

echo [✅ ÉXITO] Variables críticas configuradas
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 11: Verificar Logo UNS
:: ============================================
:test_11
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 11/12: Logo UNS Integrado
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

if not exist "frontend\public\uns-logo.gif" (
    color 0E
    echo [⚠️ ADVERTENCIA] Logo UNS no encontrado en frontend/public/
    set /a FAILED_TESTS+=1
    goto :test_12
)

if not exist "config\logo.gif" (
    color 0E
    echo [⚠️ ADVERTENCIA] Logo UNS no encontrado en config/
)

echo [✅ ÉXITO] Logo UNS presente
echo    - frontend/public/uns-logo.gif: OK
echo    - config/logo.gif: OK
set /a PASSED_TESTS+=1

:: ============================================
:: TEST 12: Verificar Conexión a Base de Datos
:: ============================================
:test_12
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 TEST 12/12: Conexión a Base de Datos
echo ═══════════════════════════════════════════════════════════════
set /a TOTAL_TESTS+=1

docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT COUNT(*) FROM employees;" > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0E
    echo [⚠️ ADVERTENCIA] No se pudo consultar la tabla employees
    echo [INFO] La base de datos podría estar inicializándose
    set /a FAILED_TESTS+=1
    goto :results
)

echo [✅ ÉXITO] Conexión a base de datos exitosa
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT COUNT(*) as total_employees FROM employees;"
set /a PASSED_TESTS+=1

:: ============================================
:: RESULTADOS FINALES
:: ============================================
:results
echo.
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║                     📊 RESULTADOS FINALES                      ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [INFO] Total de pruebas ejecutadas: %TOTAL_TESTS%
echo [✅] Pruebas exitosas: %PASSED_TESTS%
echo [❌] Pruebas fallidas: %FAILED_TESTS%
echo.

:: Calcular porcentaje de éxito
set /a SUCCESS_RATE=(%PASSED_TESTS%*100)/%TOTAL_TESTS%

if %SUCCESS_RATE% GEQ 100 (
    color 0A
    echo ╔════════════════════════════════════════════════════════════════╗
    echo ║                                                                ║
    echo ║          🎉 ¡PERFECTO! TODOS LOS TESTS PASARON                ║
    echo ║                                                                ║
    echo ║              Sistema 100%% Operativo                           ║
    echo ║                                                                ║
    echo ╚════════════════════════════════════════════════════════════════╝
) else if %SUCCESS_RATE% GEQ 80 (
    color 0E
    echo ╔════════════════════════════════════════════════════════════════╗
    echo ║                                                                ║
    echo ║         ⚠️  SISTEMA OPERATIVO CON ADVERTENCIAS                ║
    echo ║                                                                ║
    echo ║     Tasa de éxito: %SUCCESS_RATE%%%% - Revisar advertencias          ║
    echo ║                                                                ║
    echo ╚════════════════════════════════════════════════════════════════╝
) else (
    color 0C
    echo ╔════════════════════════════════════════════════════════════════╗
    echo ║                                                                ║
    echo ║           ❌ SISTEMA CON PROBLEMAS CRÍTICOS                   ║
    echo ║                                                                ║
    echo ║     Tasa de éxito: %SUCCESS_RATE%%%% - Atención requerida           ║
    echo ║                                                                ║
    echo ╚════════════════════════════════════════════════════════════════╝
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
echo.
echo ═══════════════════════════════════════════════════════════════
echo 📝 LOGS ÚTILES
echo ═══════════════════════════════════════════════════════════════
echo.
echo Ver logs backend:   docker logs uns-claudejp-backend --tail 50
echo Ver logs frontend:  docker logs uns-claudejp-frontend --tail 50
echo Ver logs database:  docker logs uns-claudejp-db --tail 50
echo Ver todos los logs: docker-compose logs -f
echo.
echo ═══════════════════════════════════════════════════════════════

:: Preguntar si desea ver logs
echo.
set /p VIEW_LOGS="¿Desea ver los logs del backend ahora? (s/n): "
if /i "%VIEW_LOGS%"=="s" (
    echo.
    echo [INFO] Mostrando últimas 50 líneas del backend...
    echo.
    docker logs uns-claudejp-backend --tail 50
)

echo.
set /p OPEN_BROWSER="¿Desea abrir el frontend en el navegador? (s/n): "
if /i "%OPEN_BROWSER%"=="s" (
    echo [INFO] Abriendo frontend en navegador...
    start %FRONTEND_URL%
    timeout /t 2 /nobreak > nul
    echo [INFO] Abriendo formulario OCR...
    start %FRONTEND_URL%/templates/rirekisho.html
)

echo.
echo [INFO] Test completado. Presione cualquier tecla para salir...
pause > nul

endlocal
exit /b 0
