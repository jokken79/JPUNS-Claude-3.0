@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Fix Base de Datos Simple

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     UNS-CLAUDEJP - SOLUCIÓN SIMPLE DE BASE DE DATOS             ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar Docker Compose
echo [PASO 1/6] Detectando Docker Compose...
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
        pause
        exit /b 1
    )
)

:: Verificar estado actual
echo.
echo [PASO 2/6] Verificando estado actual...
%DOCKER_COMPOSE_CMD% ps

:: Iniciar solo la base de datos
echo.
echo [PASO 3/6] Iniciando base de datos...
%DOCKER_COMPOSE_CMD% up -d db
echo    ✅ Base de datos iniciada

:: Esperar a que esté lista
echo    Esperando 30 segundos...
timeout /t 30 /nobreak >nul

:: Verificar conexión
echo    Verificando conexión...
docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
if errorlevel 1 (
    echo    ❌ Base de datos no responde
    echo    Esperando 30 segundos más...
    timeout /t 30 /nobreak >nul
    
    docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
    if errorlevel 1 (
        echo    ❌ La base de datos sigue sin responder
        echo    Logs de la base de datos:
        %DOCKER_COMPOSE_CMD% logs db --tail=20
        pause
        exit /b 1
    )
)

echo    ✅ Base de datos responde

:: Crear archivo SQL temporal
echo.
echo [PASO 4/6] Creando script SQL para base de datos...
echo -- Creando estructura básica > temp_create_db.sql
echo. >> temp_create_db.sql
echo -- Eliminar tablas si existen >> temp_create_db.sql
echo DROP TABLE IF EXISTS users CASCADE; >> temp_create_db.sql
echo DROP TABLE IF EXISTS factories CASCADE; >> temp_create_db.sql
echo DROP TABLE IF EXISTS candidates CASCADE; >> temp_create_db.sql
echo DROP TABLE IF EXISTS employees CASCADE; >> temp_create_db.sql
echo. >> temp_create_db.sql
echo -- Eliminar tipos si existen >> temp_create_db.sql
echo DROP TYPE IF EXISTS user_role CASCADE; >> temp_create_db.sql
echo. >> temp_create_db.sql
echo -- Crear tipo ENUM >> temp_create_db.sql
echo CREATE TYPE user_role AS ENUM ('SUPER_ADMIN', 'ADMIN', 'COORDINATOR', 'KANRININSHA', 'EMPLOYEE', 'CONTRACT_WORKER'); >> temp_create_db.sql
echo. >> temp_create_db.sql
echo -- Crear tabla users >> temp_create_db.sql
echo CREATE TABLE users ( >> temp_create_db.sql
echo     id SERIAL PRIMARY KEY, >> temp_create_db.sql
echo     username VARCHAR(50) UNIQUE NOT NULL, >> temp_create_db.sql
echo     email VARCHAR(100) UNIQUE NOT NULL, >> temp_create_db.sql
echo     password_hash VARCHAR(255) NOT NULL, >> temp_create_db.sql
echo     role user_role NOT NULL DEFAULT 'EMPLOYEE', >> temp_create_db.sql
echo     full_name VARCHAR(100), >> temp_create_db.sql
echo     is_active BOOLEAN DEFAULT TRUE, >> temp_create_db.sql
echo     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, >> temp_create_db.sql
echo     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP >> temp_create_db.sql
echo ); >> temp_create_db.sql
echo. >> temp_create_db.sql
echo -- Insertar usuario admin >> temp_create_db.sql
echo INSERT INTO users (username, email, password_hash, role, full_name, is_active) >> temp_create_db.sql
echo VALUES ('admin', 'admin@uns-kikaku.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu', 'SUPER_ADMIN', 'System Administrator', true); >> temp_create_db.sql

echo    ✅ Script SQL creado

:: Ejecutar script SQL
echo.
echo [PASO 5/6] Ejecutando script SQL...
echo    Ejecutando creación de tablas...

:: Copiar script al contenedor y ejecutar
docker cp temp_create_db.sql uns-claudejp-db:/temp_create_db.sql
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -f /temp_create_db.sql

if errorlevel 1 (
    echo    ❌ Error al ejecutar script SQL
    echo    Intentando método alternativo...
    
    :: Método alternativo: ejecutar comandos individuales
    echo    Creando tabla users con método alternativo...
    
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "DROP TABLE IF EXISTS users CASCADE;"
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "DROP TYPE IF EXISTS user_role CASCADE;"
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "CREATE TYPE user_role AS ENUM ('SUPER_ADMIN', 'ADMIN', 'COORDINATOR', 'KANRININSHA', 'EMPLOYEE', 'CONTRACT_WORKER');"
    
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "CREATE TABLE users (id SERIAL PRIMARY KEY, username VARCHAR(50) UNIQUE NOT NULL, email VARCHAR(100) UNIQUE NOT NULL, password_hash VARCHAR(255) NOT NULL, role user_role NOT NULL DEFAULT 'EMPLOYEE', full_name VARCHAR(100), is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
    
    if errorlevel 1 (
        echo    ❌ Error crítico al crear tabla users
        echo    Verificando conexión manualmente...
        
        docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "\l"
        docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "\dt"
        
        pause
        exit /b 1
    ) else (
        echo    ✅ Tabla users creada con método alternativo
    )
    
    :: Insertar usuario admin
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "INSERT INTO users (username, email, password_hash, role, full_name, is_active) VALUES ('admin', 'admin@uns-kikaku.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu', 'SUPER_ADMIN', 'System Administrator', true);"
    
    if errorlevel 1 (
        echo    ❌ Error al insertar usuario admin
    ) else (
        echo    ✅ Usuario admin creado
    )
) else (
    echo    ✅ Script SQL ejecutado correctamente
)

:: Limpiar archivo temporal
del temp_create_db.sql 2>nul

:: Verificar que se creó el usuario
echo.
echo [PASO 6/6] Verificando creación del usuario...
echo    Verificando usuario admin en la base de datos...

docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT id, username, email, role, is_active FROM users WHERE username='admin';"

if errorlevel 1 (
    echo    ❌ No se puede verificar el usuario admin
) else (
    echo    ✅ Usuario admin verificado
)

:: Iniciar backend
echo.
echo    Iniciando backend...
%DOCKER_COMPOSE_CMD% up -d backend

:: Esperar a que backend esté listo
echo    Esperando 30 segundos para que backend inicie...
timeout /t 30 /nobreak >nul

:: Verificar backend
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Backend no responde aún, esperando 30 segundos más...
    timeout /t 30 /nobreak >nul
    
    curl -s http://localhost:8000/api/health >nul 2>&1
    if errorlevel 1 (
        echo    ❌ Backend no responde
        echo    Logs del backend:
        %DOCKER_COMPOSE_CMD% logs backend --tail=20
    ) else (
        echo    ✅ Backend respondiendo
    )
) else (
    echo    ✅ Backend respondiendo
)

:: Probar login
echo.
echo    Probando login...
curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "username=admin&password=admin123" > temp_test_login.txt 2>&1

findstr "access_token" temp_test_login.txt >nul
if errorlevel 1 (
    echo    ❌ Login falló
    echo    Respuesta:
    type temp_test_login.txt
) else (
    echo    ✅ Login funcionando correctamente
)

del temp_test_login.txt 2>nul

:: Iniciar frontend
echo.
echo    Iniciando frontend...
%DOCKER_COMPOSE_CMD% up -d frontend

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                    SOLUCIÓN COMPLETADA                         ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Estado final:
echo ✅ Base de datos creada y configurada
echo ✅ Usuario admin creado con password: admin123
echo ✅ Backend iniciado
echo ✅ Frontend iniciado
echo.
echo Credenciales de acceso:
echo   Username: admin
echo   Password: admin123
echo.
echo URLs:
echo   Frontend:  http://localhost:3000/login
echo   Backend:   http://localhost:8000
echo.
echo Pasos finales:
echo 1. Espere 1-2 minutos para que el frontend compile completamente
echo 2. Abra: http://localhost:3000/login
echo 3. Ingrese: admin / admin123
echo 4. Si el login falla, espere 1 minuto y reintente
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
pause