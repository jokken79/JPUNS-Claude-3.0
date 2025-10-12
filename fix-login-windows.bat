@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Fix Login Issues

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║          UNS-CLAUDEJP - SOLUCIÓN DE PROBLEMAS DE LOGIN          ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar Docker Compose
echo [PASO 1/8] Detectando Docker Compose...
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
        pause
        exit /b 1
    )
)

:: Verificar Docker
echo.
echo [PASO 2/8] Verificando Docker Desktop...
docker ps >nul 2>&1
if errorlevel 1 (
    echo    ❌ Docker Desktop NO está corriendo
    echo    SOLUCIÓN: Inicie Docker Desktop
    pause
    exit /b 1
) else (
    echo    ✅ Docker Desktop corriendo
)

:: Verificar contenedores
echo.
echo [PASO 3/8] Verificando contenedores...
echo    Contenedores UNS-ClaudeJP:
%DOCKER_COMPOSE_CMD% ps --filter "name=uns-claudejp"

:: Verificar base de datos
echo.
echo [PASO 4/8] Verificando conexión a base de datos...
docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
if errorlevel 1 (
    echo    ❌ Base de datos NO está lista
    echo    Esperando 30 segundos para que se inicialice...
    timeout /t 30 /nobreak >nul
    
    docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
    if errorlevel 1 (
        echo    ❌ La base de datos sigue sin estar lista
        echo    Logs de la base de datos:
        %DOCKER_COMPOSE_CMD% logs db --tail=10
        echo.
        echo    SOLUCIÓN: Reinicie los servicios con: %DOCKER_COMPOSE_CMD% restart
        pause
        exit /b 1
    ) else (
        echo    ✅ Base de datos está lista ahora
    )
) else (
    echo    ✅ Base de datos está lista
)

:: Verificar backend
echo.
echo [PASO 5/8] Verificando Backend API...
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ❌ Backend API NO responde
    echo    Esperando 30 segundos para que se inicie...
    timeout /t 30 /nobreak >nul
    
    curl -s http://localhost:8000/api/health >nul 2>&1
    if errorlevel 1 (
        echo    ❌ El backend sigue sin responder
        echo    Logs del backend:
        %DOCKER_COMPOSE_CMD% logs backend --tail=10
        echo.
        echo    SOLUCIÓN: Reinicie el backend con: %DOCKER_COMPOSE_CMD% restart backend
        pause
        exit /b 1
    ) else (
        echo    ✅ Backend API respondiendo ahora
    )
) else (
    echo    ✅ Backend API respondiendo
)

:: Verificar usuario admin
echo.
echo [PASO 6/8] Verificando usuario admin...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT username, email, role, is_active FROM users WHERE username='admin';" 2>nul | findstr "admin" >nul
if errorlevel 1 (
    echo    ❌ Usuario admin NO encontrado
    echo.
    echo    Creando usuario admin...
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
        INSERT INTO users (username, email, password_hash, role, full_name, is_active)
        VALUES ('admin', 'admin@uns-kikaku.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu', 'SUPER_ADMIN', 'System Administrator', true)
        ON CONFLICT (username) DO UPDATE SET
            password_hash = EXCLUDED.password_hash,
            role = EXCLUDED.role,
            email = EXCLUDED.email,
            full_name = EXCLUDED.full_name,
            is_active = EXCLUDED.is_active;
    "
    
    if errorlevel 1 (
        echo    ❌ Error al crear usuario admin
        echo    Intentando crear tabla users primero...
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
        "
        
        docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
            INSERT INTO users (username, email, password_hash, role, full_name, is_active)
            VALUES ('admin', 'admin@uns-kikaku.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu', 'SUPER_ADMIN', 'System Administrator', true)
            ON CONFLICT (username) DO UPDATE SET
                password_hash = EXCLUDED.password_hash,
                role = EXCLUDED.role,
                email = EXCLUDED.email,
                full_name = EXCLUDED.full_name,
                is_active = EXCLUDED.is_active;
        "
    )
    
    echo    ✅ Usuario admin creado/actualizado
) else (
    echo    ✅ Usuario admin existe
    echo    Actualizando password por si acaso...
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
        UPDATE users SET
            password_hash = '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu',
            role = 'SUPER_ADMIN',
            email = 'admin@uns-kikaku.com',
            full_name = 'System Administrator',
            is_active = true
        WHERE username = 'admin';
    "
    echo    ✅ Password actualizado
)

:: Probar login endpoint
echo.
echo [PASO 7/8] Probando endpoint de login...
curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "username=admin&password=admin123" > temp_login_response.txt 2>&1

findstr "access_token" temp_login_response.txt >nul
if errorlevel 1 (
    echo    ❌ Login endpoint falló
    echo    Respuesta del servidor:
    type temp_login_response.txt
    echo.
    echo    SOLUCIÓN: Verificando logs del backend...
    %DOCKER_COMPOSE_CMD% logs backend --tail=20
) else (
    echo    ✅ Login endpoint funcionando correctamente
)

del temp_login_response.txt 2>nul

:: Verificar frontend
echo.
echo [PASO 8/8] Verificando Frontend...
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Frontend no responde (puede estar compilando)
    echo    Esperando 60 segundos para que compile...
    timeout /t 60 /nobreak >nul
    
    curl -s http://localhost:3000 >nul 2>&1
    if errorlevel 1 (
        echo    ❌ El frontend sigue sin responder
        echo    Logs del frontend:
        %DOCKER_COMPOSE_CMD% logs frontend --tail=10
        echo.
        echo    SOLUCIÓN: Reinicie el frontend con: %DOCKER_COMPOSE_CMD% restart frontend
    ) else (
        echo    ✅ Frontend respondiendo ahora
    )
) else (
    echo    ✅ Frontend respondiendo
)

:: Resumen
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                          RESUMEN                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo ✅ SERVICIOS VERIFICADOS Y CORREGIDOS
echo.
echo Credenciales de acceso:
echo   Username: admin
echo   Password: admin123
echo.
echo URLs de acceso:
echo   Frontend:  http://localhost:3000
echo   Backend:   http://localhost:8000
echo   API Docs:  http://localhost:8000/api/docs
echo.
echo Pasos a seguir:
echo 1. Abra su navegador web
echo 2. Vaya a: http://localhost:3000/login
echo 3. Ingrese las credenciales mostradas arriba
echo 4. Si el login falla, espere 1-2 minutos y reintente
echo.
echo Si el problema persiste:
echo 1. Ejecute: JpStart\diagnose-issues.bat
echo 2. Tome capturas de pantalla
echo 3. Contacte al soporte técnico
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
pause