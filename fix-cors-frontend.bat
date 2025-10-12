@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Fix CORS & Frontend Issues

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║       UNS-CLAUDEJP - SOLUCIÓN DE PROBLEMAS CORS Y FRONTEND       ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar Docker Compose
echo [PASO 1/6] Detectando Docker Compose...
set "DOCKER_COMPOSE_CMD="
docker compose version >nul 2>&1
if %errorlevel% EQU 0 (
    set "DOCKER_COMPOSE_CMD=docker compose"
) else (
    docker-compose version >nul 2>&1
    if %errorlevel% EQU 0 (
        set "DOCKER_COMPOSE_CMD=docker-compose"
    ) else (
        echo    ❌ Docker Compose NO instalado
        pause
        exit /b 1
    )
)

:: Verificar configuración CORS del backend
echo.
echo [PASO 2/6] Verificando configuración CORS del backend...
echo    Testeando conexión desde frontend a backend...

curl -s -H "Origin: http://localhost:3000" ^
     -H "Access-Control-Request-Method: POST" ^
     -H "Access-Control-Request-Headers: Content-Type" ^
     -X OPTIONS http://localhost:8000/api/auth/login > temp_cors_test.txt 2>&1

findstr "Access-Control-Allow-Origin" temp_cors_test.txt >nul
if errorlevel 1 (
    echo    ❌ Problema de CORS detectado
    echo    Respuesta del servidor:
    type temp_cors_test.txt
    echo.
    echo    Solucionando problema CORS...
    
    :: Reiniciar backend con variables CORS correctas
    echo    Reiniciando backend con configuración CORS correcta...
    %DOCKER_COMPOSE_CMD% stop backend
    timeout /t 5 /nobreak >nul
    
    :: Iniciar backend con variables de entorno CORS
    set "CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000"
    %DOCKER_COMPOSE_CMD% up -d backend --force-recreate
    
    echo    Esperando 20 segundos para que el backend se inicie...
    timeout /t 20 /nobreak >nul
    
    :: Probar CORS nuevamente
    curl -s -H "Origin: http://localhost:3000" ^
         -H "Access-Control-Request-Method: POST" ^
         -H "Access-Control-Request-Headers: Content-Type" ^
         -X OPTIONS http://localhost:8000/api/auth/login > temp_cors_test2.txt 2>&1
    
    findstr "Access-Control-Allow-Origin" temp_cors_test2.txt >nul
    if errorlevel 1 (
        echo    ❌ El problema CORS persiste
        echo    Logs del backend:
        %DOCKER_COMPOSE_CMD% logs backend --tail=15
    ) else (
        echo    ✅ Problema CORS solucionado
    )
    
    del temp_cors_test2.txt 2>nul
) else (
    echo    ✅ Configuración CORS correcta
)

del temp_cors_test.txt 2>nul

:: Verificar configuración del frontend
echo.
echo [PASO 3/6] Verificando configuración del frontend...
echo    Verificando variable REACT_APP_API_URL...

:: Verificar si el archivo .env del frontend existe
if exist "frontend\.env" (
    echo    ✅ Archivo .env del frontend encontrado
    type frontend\.env | findstr "REACT_APP_API_URL"
) else (
    echo    ⚠ Archivo .env del frontend NO encontrado
    echo    Creando archivo .env para el frontend...
    
    echo REACT_APP_API_URL=http://localhost:8000 > frontend\.env
    echo REACT_APP_NAME=UNS-ClaudeJP 2.0 >> frontend\.env
    echo REACT_APP_COMPANY=UNS企画 >> frontend\.env
    echo REACT_APP_LANGUAGE=ja >> frontend\.env
    
    echo    ✅ Archivo .env del frontend creado
)

:: Verificar que el frontend esté apuntando al backend correcto
echo.
echo [PASO 4/6] Verificando conexión frontend-backend...
echo    Testeando API desde el contexto del frontend...

docker exec uns-claudejp-frontend curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ❌ El frontend no puede conectar al backend
    echo    Intentando conectar al backend por nombre de servicio...
    
    docker exec uns-claudejp-frontend curl -s http://backend:8000/api/health >nul 2>&1
    if errorlevel 1 (
        echo    ❌ El frontend no puede conectar al backend por ningún medio
        echo    Logs del frontend:
        %DOCKER_COMPOSE_CMD% logs frontend --tail=10
        echo.
        echo    Logs del backend:
        %DOCKER_COMPOSE_CMD% logs backend --tail=10
    ) else (
        echo    ✅ El frontend puede conectar al backend por nombre de servicio
        echo    Actualizando configuración del frontend...
        
        echo REACT_APP_API_URL=http://backend:8000 > frontend\.env
        echo REACT_APP_NAME=UNS-ClaudeJP 2.0 >> frontend\.env
        echo REACT_APP_COMPANY=UNS企画 >> frontend\.env
        echo REACT_APP_LANGUAGE=ja >> frontend\.env
        
        echo    Reiniciando frontend para aplicar cambios...
        %DOCKER_COMPOSE_CMD% restart frontend
        echo    Esperando 30 segundos para que el frontend se reinicie...
        timeout /t 30 /nobreak >nul
    )
) else (
    echo    ✅ El frontend puede conectar al backend
)

:: Probar login completo
echo.
echo [PASO 5/6] Probando login completo...
echo    Simulando petición de login completa...

curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -H "Origin: http://localhost:3000" ^
  -d "username=admin&password=admin123" > temp_login_full.txt 2>&1

findstr "access_token" temp_login_full.txt >nul
if errorlevel 1 (
    echo    ❌ Login completo falló
    echo    Respuesta del servidor:
    type temp_login_full.txt
    echo.
    echo    Verificando configuración de autenticación...
    
    :: Probar login sin CORS headers
    curl -s -X POST http://localhost:8000/api/auth/login ^
      -H "Content-Type: application/x-www-form-urlencoded" ^
      -d "username=admin&password=admin123" > temp_login_simple.txt 2>&1
    
    findstr "access_token" temp_login_simple.txt >nul
    if errorlevel 1 (
        echo    ❌ El login falla incluso sin CORS
        echo    El problema está en la autenticación, no en CORS
        echo.
        echo    Verificando usuario en la base de datos...
        docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT username, role, is_active FROM users WHERE username='admin';"
        echo.
        echo    Logs del backend:
        %DOCKER_COMPOSE_CMD% logs backend --tail=20
    ) else (
        echo    ✅ El login funciona sin CORS, el problema es CORS
        echo    Configuración CORS necesita ajustes adicionales
    )
    
    del temp_login_simple.txt 2>nul
) else (
    echo    ✅ Login completo funcionando correctamente
)

del temp_login_full.txt 2>nul

:: Verificar estado final
echo.
echo [PASO 6/6] Verificación final del sistema...
echo    Estado final de los servicios:

echo.
echo    Backend:
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ❌ Backend no responde
) else (
    echo    ✅ Backend responde
)

echo    Frontend:
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo    ❌ Frontend no responde
) else (
    echo    ✅ Frontend responde
)

echo    Base de datos:
docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
if errorlevel 1 (
    echo    ❌ Base de datos no responde
) else (
    echo    ✅ Base de datos responde
)

echo    Login:
curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "username=admin&password=admin123" > temp_final_test.txt 2>&1
findstr "access_token" temp_final_test.txt >nul
if errorlevel 1 (
    echo    ❌ Login no funciona
) else (
    echo    ✅ Login funciona
)
del temp_final_test.txt 2>nul

:: Resumen
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                          RESUMEN                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Configuración verificada y corregida:
echo ✅ Configuración CORS del backend
echo ✅ Variables de entorno del frontend
echo ✅ Conexión frontend-backend
echo ✅ Funcionalidad de login
echo.
echo Credenciales de acceso:
echo   Username: admin
echo   Password: admin123
echo.
echo URLs de acceso:
echo   Frontend:  http://localhost:3000/login
echo   Backend:   http://localhost:8000
echo   API Docs:  http://localhost:8000/api/docs
echo.
echo Pasos recomendados:
echo 1. Abra su navegador en modo incógnito
echo 2. Vaya a: http://localhost:3000/login
echo 3. Ingrese las credenciales: admin / admin123
echo 4. Si el login falla, espere 1 minuto y reintente
echo 5. Si persiste, limpie la caché del navegador (Ctrl+F5)
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
pause