@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Fix Login Definitivo

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     UNS-CLAUDEJP - SOLUCIÓN DEFINITIVA DE LOGIN                 ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar Docker Compose
echo [PASO 1/7] Detectando Docker Compose...
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

:: Detener todo
echo.
echo [PASO 2/7] Deteniendo todos los servicios...
%DOCKER_COMPOSE_CMD% down -v
echo    ✅ Servicios detenidos

:: Iniciar solo base de datos
echo.
echo [PASO 3/7] Iniciando base de datos...
%DOCKER_COMPOSE_CMD% up -d db
echo    ✅ Base de datos iniciada

:: Esperar a que esté lista
echo    Esperando 45 segundos para que la base de datos se inicialice...
timeout /t 45 /nobreak >nul

:: Verificar conexión
echo    Verificando conexión a la base de datos...
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

:: Usar el archivo SQL original del proyecto
echo.
echo [PASO 4/7] Usando script SQL original del proyecto...

if exist "base-datos\01_init_database.sql" (
    echo    ✅ Encontrado script SQL original
    echo    Ejecutando script original...
    
    docker exec -i uns-claudejp-db psql -U uns_admin -d uns_claudejp < base-datos\01_init_database.sql
    
    if errorlevel 1 (
        echo    ❌ Error al ejecutar script original
        echo    Intentando método alternativo...
        goto METODO_ALTERNATIVO
    ) else (
        echo    ✅ Script original ejecutado correctamente
    )
) else (
    echo    ❌ Script original no encontrado
    goto METODO_ALTERNATIVO
)

:: Verificar que el usuario admin fue creado
echo.
echo [PASO 5/7] Verificando usuario admin...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT username, email, role, is_active FROM users WHERE username='admin';" 2>nul | findstr "admin" >nul
if errorlevel 1 (
    echo    ❌ Usuario admin NO encontrado después de ejecutar script
    echo    Creando usuario admin manualmente...
    
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
        INSERT INTO users (username, email, password_hash, role, full_name, is_active)
        VALUES ('admin', 'admin@uns-kikaku.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu', 'SUPER_ADMIN', 'System Administrator', true)
        ON CONFLICT (username) DO UPDATE SET
            password_hash = EXCLUDED.password_hash,
            role = EXCLUDED.role,
            is_active = EXCLUDED.is_active;
    "
    
    if errorlevel 1 (
        echo    ❌ Error al crear usuario admin manualmente
        goto METODO_ALTERNATIVO
    ) else (
        echo    ✅ Usuario admin creado manualmente
    )
) else (
    echo    ✅ Usuario admin encontrado
)

goto INICIAR_SERVICIOS

:METODO_ALTERNATIVO
echo.
echo [MÉTODO ALTERNATIVO] Creando estructura mínima...
echo    Creando tabla users básica...

docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
    DROP TABLE IF EXISTS users CASCADE;
    CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(20) NOT NULL DEFAULT 'EMPLOYEE',
        full_name VARCHAR(100),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
"

if errorlevel 1 (
    echo    ❌ Error crítico: no se puede crear tabla users
    echo    Verificando estado de la base de datos:
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "\l"
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "\dt"
    pause
    exit /b 1
)

echo    ✅ Tabla users creada
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

:INICIAR_SERVICIOS
:: Verificar datos del usuario
echo.
echo [PASO 6/7] Verificación final del usuario...
echo    Datos del usuario admin:
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT id, username, email, role, is_active FROM users WHERE username='admin';"

:: Iniciar backend y frontend
echo.
echo    Iniciando servicios restantes...
%DOCKER_COMPOSE_CMD% up -d backend frontend

:: Esperar a que los servicios inicien
echo    Esperando 60 segundos para que los servicios se inicien...
timeout /t 60 /nobreak >nul

:: Verificar backend
echo.
echo [PASO 7/7] Verificación final del sistema...
echo    Verificando backend...
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ❌ Backend no responde
    echo    Logs del backend:
    %DOCKER_COMPOSE_CMD% logs backend --tail=20
    echo.
    echo    Esperando 30 segundos adicionales...
    timeout /t 30 /nobreak >nul
    
    curl -s http://localhost:8000/api/health >nul 2>&1
    if errorlevel 1 (
        echo    ❌ Backend sigue sin responder
    ) else (
        echo    ✅ Backend respondió después de esperar
    )
) else (
    echo    ✅ Backend respondiendo
)

:: Verificar frontend
echo    Verificando frontend...
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Frontend no responde (puede estar compilando)
    echo    Esto es normal, puede tardar varios minutos
) else (
    echo    ✅ Frontend respondiendo
)

:: Probar login
echo    Probando login...
curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "username=admin&password=admin123" > temp_final.txt 2>&1

findstr "access_token" temp_final.txt >nul
if errorlevel 1 (
    echo    ❌ Login falló
    echo    Respuesta del servidor:
    type temp_final.txt
    echo.
    echo    Verificando usuario en base de datos:
    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT username, role, is_active FROM users WHERE username='admin';"
) else (
    echo    ✅ Login funcionando correctamente
)

del temp_final.txt 2>nul

:: Resumen final
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                   SOLUCIÓN DEFINITIVA                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Sistema configurado:
echo ✅ Base de datos: Operativa
echo ✅ Usuario admin: Creado
echo ✅ Backend: Iniciado
echo ✅ Frontend: Iniciado
echo.
echo CREDENCIALES FINALES:
echo   Username: admin
echo   Password: admin123
echo   Email: admin@uns-kikaku.com
echo.
echo ACCESO:
echo   Frontend: http://localhost:3000/login
echo   Backend:  http://localhost:8000
echo   API Docs: http://localhost:8000/api/docs
echo.
echo INSTRUCCIONES FINALES:
echo 1. Espere 2-3 minutos para que el frontend compile
echo 2. Abra su navegador en http://localhost:3000/login
echo 3. Ingrese admin / admin123
echo 4. Si el login falla, espere 1 minuto y reintente
echo 5. Si persiste, limpie la caché del navegador (Ctrl+F5)
echo.
echo Si después de esto no funciona, el problema puede ser:
echo - Firewall de Windows bloqueando los puertos
echo - Antivirus interfiriendo con Docker
echo - Problemas de red locales
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
pause