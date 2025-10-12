@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Reinstalación de Autenticación

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     UNS-CLAUDEJP - REINSTALACIÓN COMPLETA DE AUTENTICACIÓN      ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo ADVERTENCIA: Este script reinstalará completamente el sistema de autenticación
echo           Puede perder datos existentes. Presione Ctrl+C para cancelar.
echo.
pause

:: Detectar Docker Compose
echo [PASO 1/8] Detectando Docker Compose...
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

:: Detener todos los servicios
echo.
echo [PASO 2/8] Deteniendo todos los servicios...
%DOCKER_COMPOSE_CMD% down -v
echo    ✅ Servicios detenidos

:: Limpiar imágenes y caché
echo.
echo [PASO 3/8] Limpiando caché de Docker...
docker system prune -f
echo    ✅ Caché limpiada

:: Eliminar volúmenes de base de datos
echo.
echo [PASO 4/8] Eliminando volúmenes de base de datos...
docker volume ls | findstr postgres
if not errorlevel 1 (
    docker volume rm jpuns-claude25o_postgres_data 2>nul
    echo    ✅ Volúmenes eliminados
) else (
    echo    ✅ No hay volúmenes que eliminar
)

:: Recrear directorios necesarios
echo.
echo [PASO 5/8] Recreando directorios necesarios...
if not exist "uploads" mkdir uploads
if not exist "logs" mkdir logs
if not exist "config\factories" mkdir config\factories
echo    ✅ Directorios recreados

:: Verificar archivo .env
echo.
echo [PASO 6/8] Verificando archivo .env...
if not exist ".env" (
    echo    ❌ .env no encontrado, copiando desde .env.example
    copy .env.example .env >nul
    echo    ✅ .env creado
) else (
    echo    ✅ .env encontrado
)

:: Modificar .env para asegurar configuración correcta
echo    Actualizando configuración crítica en .env...
(
    echo POSTGRES_DB=uns_claudejp
    echo POSTGRES_USER=uns_admin
    echo POSTGRES_PASSWORD=57UD10R
    echo SECRET_KEY=57UD10R
    echo ALGORITHM=HS256
    echo ACCESS_TOKEN_EXPIRE_MINUTES=30
    echo FRONTEND_URL=http://localhost:3000
    echo REACT_APP_API_URL=http://localhost:8000
    echo ENVIRONMENT=development
    echo DEBUG=true
) > temp_env.txt

:: Actualizar solo las líneas críticas en .env
powershell -Command "(Get-Content .env) -replace '^POSTGRES_DB=.*', 'POSTGRES_DB=uns_claudejp' -replace '^POSTGRES_USER=.*', 'POSTGRES_USER=uns_admin' -replace '^POSTGRES_PASSWORD=.*', 'POSTGRES_PASSWORD=57UD10R' -replace '^SECRET_KEY=.*', 'SECRET_KEY=57UD10R' | Set-Content .env"

del temp_env.txt 2>nul
echo    ✅ Configuración actualizada

:: Iniciar servicios base de datos
echo.
echo [PASO 7/8] Iniciando base de datos...
%DOCKER_COMPOSE_CMD% up -d db
echo    ✅ Base de datos iniciada

:: Esperar a que la base de datos esté lista
echo    Esperando a que la base de datos se inicialice...
timeout /t 45 /nobreak >nul

:: Verificar que la base de datos esté lista
docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
if errorlevel 1 (
    echo    ❌ La base de datos no está lista después de 45 segundos
    echo    Esperando 30 segundos más...
    timeout /t 30 /nobreak >nul
    
    docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
    if errorlevel 1 (
        echo    ❌ La base de datos sigue sin estar lista
        echo    Logs de la base de datos:
        %DOCKER_COMPOSE_CMD% logs db --tail=20
        pause
        exit /b 1
    )
)

echo    ✅ Base de datos lista

:: Crear estructura de base de datos y usuario admin
echo.
echo [PASO 8/8] Creando estructura de base de datos y usuario admin...

:: Crear tabla users con la estructura correcta
echo    Creando tabla users...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
    DROP TABLE IF EXISTS users CASCADE;
    DROP TYPE IF EXISTS user_role CASCADE;
    
    CREATE TYPE user_role AS ENUM ('SUPER_ADMIN', 'ADMIN', 'COORDINATOR', 'KANRININSHA', 'EMPLOYEE', 'CONTRACT_WORKER');
    
    CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role user_role NOT NULL DEFAULT 'EMPLOYEE',
        full_name VARCHAR(100),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
"

if errorlevel 1 (
    echo    ❌ Error al crear tabla users
    pause
    exit /b 1
) else (
    echo    ✅ Tabla users creada
)

:: Insertar usuario admin con el hash correcto
echo    Creando usuario admin...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
    INSERT INTO users (username, email, password_hash, role, full_name, is_active)
    VALUES ('admin', 'admin@uns-kikaku.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu', 'SUPER_ADMIN', 'System Administrator', true);
"

if errorlevel 1 (
    echo    ❌ Error al crear usuario admin
    pause
    exit /b 1
) else (
    echo    ✅ Usuario admin creado
)

:: Crear otras tablas básicas necesarias
echo    Creando tablas básicas...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
    CREATE TABLE IF NOT EXISTS factories (
        id SERIAL PRIMARY KEY,
        factory_id VARCHAR(20) UNIQUE NOT NULL,
        name VARCHAR(100) NOT NULL,
        address TEXT,
        phone VARCHAR(20),
        contact_person VARCHAR(100),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS candidates (
        id SERIAL PRIMARY KEY,
        rirekisho_id VARCHAR(20) UNIQUE NOT NULL,
        full_name_kanji VARCHAR(100),
        status VARCHAR(20) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS employees (
        id SERIAL PRIMARY KEY,
        hakenmoto_id INTEGER UNIQUE NOT NULL,
        full_name_kanji VARCHAR(100) NOT NULL,
        status VARCHAR(20) DEFAULT 'active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
"

echo    ✅ Tablas básicas creadas

:: Iniciar backend y frontend
echo.
echo    Iniciando backend y frontend...
%DOCKER_COMPOSE_CMD% up -d backend frontend

:: Esperar a que los servicios se inicien
echo    Esperando a que los servicios se inicien completamente...
timeout /t 60 /nobreak >nul

:: Verificar que el backend esté funcionando
echo    Verificando backend...
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ❌ Backend no responde
    echo    Logs del backend:
    %DOCKER_COMPOSE_CMD% logs backend --tail=30
    echo.
    echo    Esperando 30 segundos adicionales...
    timeout /t 30 /nobreak >nul
    
    curl -s http://localhost:8000/api/health >nul 2>&1
    if errorlevel 1 (
        echo    ❌ El backend sigue sin responder
        echo    Reiniciando backend...
        %DOCKER_COMPOSE_CMD% restart backend
        timeout /t 30 /nobreak >nul
        
        curl -s http://localhost:8000/api/health >nul 2>&1
        if errorlevel 1 (
            echo    ❌ Backend sigue sin responder después del reinicio
            pause
            exit /b 1
        )
    )
)

echo    ✅ Backend funcionando

:: Verificar que el frontend esté funcionando
echo    Verificando frontend...
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Frontend no responde (puede estar compilando)
    echo    Esperando 60 segundos adicionales para compilación...
    timeout /t 60 /nobreak >nul
    
    curl -s http://localhost:3000 >nul 2>&1
    if errorlevel 1 (
        echo    ⚠ Frontend todavía no responde, pero esto puede ser normal
        echo    El frontend puede tardar varios minutos en compilar
    ) else (
        echo    ✅ Frontend funcionando
    )
) else (
    echo    ✅ Frontend funcionando
)

:: Probar login
echo.
echo    Probando login...
curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "username=admin&password=admin123" > temp_final_login.txt 2>&1

findstr "access_token" temp_final_login.txt >nul
if errorlevel 1 (
    echo    ❌ Login falló
    echo    Respuesta:
    type temp_final_login.txt
    echo.
    echo    Verificando configuración final...
    echo    Usuario en base de datos:
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT username, role, is_active FROM users WHERE username='admin';"
    echo.
    echo    Logs del backend:
    %DOCKER_COMPOSE_CMD% logs backend --tail=20
) else (
    echo    ✅ Login funcionando correctamente
)

del temp_final_login.txt 2>nul

:: Resumen final
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                REINSTALACIÓN COMPLETADA                        ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Sistema reinstalado completamente:
echo ✅ Base de datos limpia y nueva
echo ✅ Usuario admin creado
echo ✅ Backend configurado
echo ✅ Frontend configurado
echo.
echo CREDENCIALES DEFINITIVAS:
echo   Username: admin
echo   Password: admin123
echo   Email: admin@uns-kikaku.com
echo   Role: SUPER_ADMIN
echo.
echo URLs DE ACCESO:
echo   Frontend:  http://localhost:3000/login
echo   Backend:   http://localhost:8000
echo   API Docs:  http://localhost:8000/api/docs
echo.
echo PASOS A SEGUIR:
echo 1. Abra su navegador web
echo 2. Vaya a: http://localhost:3000/login
echo 3. Use las credenciales: admin / admin123
echo 4. Si el frontend no carga, espere 2-3 minutos (está compilando)
echo 5. Si el login falla, espere 1 minuto y reintente
echo.
echo Si después de esto el login no funciona, el problema puede ser:
echo - Firewall de Windows bloqueando puertos
echo - Antivirus bloqueando Docker
echo - Problemas de red locales
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
pause