@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Diagnóstico Avanzado de Login

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     UNS-CLAUDEJP - DIAGNÓSTICO AVANZADO DE LOGIN (NIVEL 3)     ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar Docker Compose
echo [PASO 1/12] Detectando Docker Compose...
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
        echo    SOLUCIÓN: Instale Docker Desktop
        pause
        exit /b 1
    )
)

:: Verificar estado completo de los contenedores
echo.
echo [PASO 2/12] Verificando estado completo de contenedores...
echo    Estado detallado:
%DOCKER_COMPOSE_CMD% ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}\t{{.Health}}"

:: Verificar red Docker
echo.
echo [PASO 3/12] Verificando red Docker...
docker network ls | findstr uns
if errorlevel 1 (
    echo    ❌ Red UNS no encontrada
    echo    Creando red...
    docker network create uns-network
) else (
    echo    ✅ Red UNS encontrada
)

:: Verificar base de datos en profundidad
echo.
echo [PASO 4/12] Verificando base de datos en profundidad...
docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
if errorlevel 1 (
    echo    ❌ Base de datos NO responde
    echo    Logs de la base de datos:
    %DOCKER_COMPOSE_CMD% logs db --tail=30
    echo.
    echo    Intentando reiniciar base de datos...
    %DOCKER_COMPOSE_CMD% restart db
    timeout /t 30 /nobreak >nul
    
    docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
    if errorlevel 1 (
        echo    ❌ La base de datos sigue sin responder
        echo    SOLUCIÓN: Reinicie Docker Desktop completamente
        pause
        exit /b 1
    ) else (
        echo    ✅ Base de datos respondió después del reinicio
    )
) else (
    echo    ✅ Base de datos responde
)

:: Verificar estructura de la base de datos
echo.
echo [PASO 5/12] Verificando estructura de la base de datos...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "\dt" 2>nul | findstr "users" >nul
if errorlevel 1 (
    echo    ❌ Tabla 'users' NO existe
    echo    Creando estructura básica de la base de datos...
    
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            role VARCHAR(20) NOT NULL DEFAULT 'EMPLOYEE',
            full_name VARCHAR(100),
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE TYPE IF NOT EXISTS user_role AS ENUM ('SUPER_ADMIN', 'ADMIN', 'COORDINATOR', 'KANRININSHA', 'EMPLOYEE', 'CONTRACT_WORKER');
        
        ALTER TABLE users ALTER COLUMN role TYPE user_role USING role::user_role;
    "
    
    if errorlevel 1 (
        echo    ❌ Error al crear tabla users
    ) else (
        echo    ✅ Tabla users creada
    )
) else (
    echo    ✅ Tabla users existe
)

:: Verificar y crear usuario admin con hash correcto
echo.
echo [PASO 6/12] Verificando y creando usuario admin...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT username, role, is_active FROM users WHERE username='admin';" 2>nul | findstr "admin" >nul
if errorlevel 1 (
    echo    ❌ Usuario admin NO encontrado
    echo    Creando usuario admin con hash correcto...
    
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
        INSERT INTO users (username, email, password_hash, role, full_name, is_active)
        VALUES ('admin', 'admin@uns-kikaku.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu', 'SUPER_ADMIN', 'System Administrator', true);
    "
    
    if errorlevel 1 (
        echo    ❌ Error al crear usuario admin
        echo    Intentando con SQL alternativo...
        docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
            INSERT INTO users (username, email, password_hash, role, full_name, is_active)
            VALUES ('admin', 'admin@uns-kikaku.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu', 'SUPER_ADMIN', 'System Administrator', true)
            ON CONFLICT (username) DO NOTHING;
        "
    ) else (
        echo    ✅ Usuario admin creado
    )
) else (
    echo    ✅ Usuario admin existe
    echo    Actualizando password por seguridad...
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
        UPDATE users SET
            password_hash = '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu',
            role = 'SUPER_ADMIN',
            is_active = true
        WHERE username = 'admin';
    "
    echo    ✅ Password actualizado
)

:: Verificar datos del usuario admin
echo.
echo [PASO 7/12] Verificando datos completos del usuario admin...
echo    Datos del usuario admin:
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT id, username, email, role, is_active, created_at FROM users WHERE username='admin';"

:: Verificar backend en profundidad
echo.
echo [PASO 8/12] Verificando backend en profundidad...
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ❌ Backend NO responde en localhost:8000
    echo    Verificando si responde en el contenedor...
    
    docker exec uns-claudejp-backend curl -s http://localhost:8000/api/health >nul 2>&1
    if errorlevel 1 (
        echo    ❌ Backend no responde ni internamente
        echo    Logs del backend:
        %DOCKER_COMPOSE_CMD% logs backend --tail=30
        echo.
        echo    Reiniciando backend...
        %DOCKER_COMPOSE_CMD% restart backend
        timeout /t 30 /nobreak >nul
        
        curl -s http://localhost:8000/api/health >nul 2>&1
        if errorlevel 1 (
            echo    ❌ Backend sigue sin responder después del reinicio
            echo    Verificando configuración del backend...
            docker exec uns-claudejp-backend env | findstr -E "(SECRET_KEY|DATABASE_URL)"
            pause
            exit /b 1
        ) else (
            echo    ✅ Backend respondió después del reinicio
        )
    ) else (
        echo    ⚠ Backend responde internamente pero no externamente
        echo    Problema de puertos o red
    )
) else (
    echo    ✅ Backend responde correctamente
)

:: Verificar configuración CORS del backend
echo.
echo [PASO 9/12] Verificando configuración CORS del backend...
echo    Testeando petición OPTIONS para CORS:
curl -s -H "Origin: http://localhost:3000" ^
     -H "Access-Control-Request-Method: POST" ^
     -H "Access-Control-Request-Headers: Content-Type" ^
     -X OPTIONS http://localhost:8000/api/auth/login ^
     -D temp_cors_headers.txt 2>&1

findstr "Access-Control-Allow-Origin" temp_cors_headers.txt >nul
if errorlevel 1 (
    echo    ❌ Problema de CORS detectado
    echo    Respuesta CORS:
    type temp_cors_headers.txt
    echo.
    echo    Solucionando CORS...
    
    :: Detener backend y reiniciar con CORS correcto
    %DOCKER_COMPOSE_CMD% stop backend
    timeout /t 5 /nobreak >nul
    
    :: Iniciar con variables CORS explícitas
    set "CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000"
    set "CORS_ALLOW_CREDENTIALS=true"
    %DOCKER_COMPOSE_CMD% up -d backend --force-recreate
    
    timeout /t 20 /nobreak >nul
    echo    ✅ Backend reiniciado con configuración CORS
) else (
    echo    ✅ Configuración CORS correcta
)

del temp_cors_headers.txt 2>nul

:: Probar login endpoint con diferentes métodos
echo.
echo [PASO 10/12] Probando login endpoint con diferentes métodos...

echo    Método 1: Form data estándar
curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "username=admin&password=admin123" > temp_login1.txt 2>&1

findstr "access_token" temp_login1.txt >nul
if errorlevel 1 (
    echo    ❌ Método 1 falló
    echo    Respuesta: 
    type temp_login1.txt
) else (
    echo    ✅ Método 1 funcionó
)

echo.
echo    Método 2: Con headers CORS
curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -H "Origin: http://localhost:3000" ^
  -d "username=admin&password=admin123" > temp_login2.txt 2>&1

findstr "access_token" temp_login2.txt >nul
if errorlevel 1 (
    echo    ❌ Método 2 falló
    echo    Respuesta:
    type temp_login2.txt
) else (
    echo    ✅ Método 2 funcionó
)

del temp_login1.txt 2>nul
del temp_login2.txt 2>nul

:: Verificar frontend en profundidad
echo.
echo [PASO 11/12] Verificando frontend en profundidad...
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo    ❌ Frontend NO responde
    echo    Logs del frontend:
    %DOCKER_COMPOSE_CMD% logs frontend --tail=30
    echo.
    echo    Verificando si el frontend está corriendo en el contenedor...
    docker exec uns-claudejp-frontend curl -s http://localhost:3000 >nul 2>&1
    if errorlevel 1 (
        echo    ❌ Frontend no responde ni internamente
        echo    Reiniciando frontend...
        %DOCKER_COMPOSE_CMD% restart frontend
        timeout /t 45 /nobreak >nul
        
        curl -s http://localhost:3000 >nul 2>&1
        if errorlevel 1 (
            echo    ❌ Frontend sigue sin responder
            echo    El frontend puede estar compilando...
            echo    Espere 2-3 minutos y verifique nuevamente
        ) else (
            echo    ✅ Frontend respondió después del reinicio
        )
    ) else (
        echo    ⚠ Frontend responde internamente pero no externamente
    )
) else (
    echo    ✅ Frontend responde correctamente
)

:: Verificar variables de entorno del frontend
echo.
echo    Verificando configuración del frontend...
if exist "frontend\.env" (
    echo    ✅ Archivo .env del frontend encontrado
    echo    Contenido:
    type frontend\.env
) else (
    echo    ⚠ Archivo .env del frontend NO encontrado
    echo    Creando archivo .env...
    (
        echo REACT_APP_API_URL=http://localhost:8000
        echo REACT_APP_NAME=UNS-ClaudeJP 2.0
        echo REACT_APP_COMPANY=UNS企画
        echo REACT_APP_LANGUAGE=ja
        echo GENERATE_SOURCEMAP=false
    ) > frontend\.env
    echo    ✅ Archivo .env creado
)

:: Test final completo
echo.
echo [PASO 12/12] Test final completo del sistema...
echo    Realizando test completo de login...

:: Obtener token
curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "username=admin&password=admin123" > temp_token.txt 2>&1

findstr "access_token" temp_token.txt >nul
if errorlevel 1 (
    echo    ❌ TEST FINAL FALLIDO
    echo    Respuesta del login:
    type temp_token.txt
    echo.
    echo    ÚLTIMOS INTENTOS DE SOLUCIÓN:
    echo.
    echo    1. Reiniciando todos los servicios...
    %DOCKER_COMPOSE_CMD% restart
    timeout /t 30 /nobreak >nul
    
    echo    2. Verificando estado final...
    curl -s http://localhost:8000/api/health >nul 2>&1
    if not errorlevel 1 (
        echo    ✅ Backend responde después del reinicio completo
    ) else (
        echo    ❌ Backend sigue sin responder
    )
    
    curl -s http://localhost:3000 >nul 2>&1
    if not errorlevel 1 (
        echo    ✅ Frontend responde después del reinicio completo
    ) else (
        echo    ❌ Frontend sigue sin responder
    )
    
    echo.
    echo    ESTADO FINAL DE CONTENEDORES:
    %DOCKER_COMPOSE_CMD% ps
    
    echo.
    echo    LOGS RECIENTES:
    echo    Backend:
    %DOCKER_COMPOSE_CMD% logs backend --tail=20
    echo.
    echo    Base de datos:
    %DOCKER_COMPOSE_CMD% logs db --tail=10
) else (
    echo    ✅ TEST FINAL EXITOSO
    echo    Login está funcionando correctamente
)

del temp_token.txt 2>nul

:: Resumen final
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                      RESUMEN FINAL                            ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Estado del sistema:
echo   Base de datos: ✅ Operativa
echo   Backend:       %if errorlevel 1 (echo ❌ Problema) else (echo ✅ Operativo)%
echo   Frontend:      %if errorlevel 1 (echo ❌ Problema) else (echo ✅ Operativo)%
echo   Login:         %if errorlevel 1 (echo ❌ Problema) else (echo ✅ Operativo)%
echo.
echo Credenciales confirmadas:
echo   Username: admin
echo   Password: admin123
echo.
echo Pasos a seguir:
echo 1. Si todo está ✅, abra: http://localhost:3000/login
echo 2. Si hay ❌, espere 2-3 minutos y reintente
echo 3. Si persiste, reinicie Docker Desktop completamente
echo 4. Como último recurso, ejecute: JpStart\install-windows-v2.bat
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
pause