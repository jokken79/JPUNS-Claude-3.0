@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Service Health Check

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║         UNS-CLAUDEJP 2.5 - VERIFICACIÓN DE SERVICIOS          ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Check if Docker is running
echo [1/5] Verificando Docker Desktop...
docker ps >nul 2>&1
if errorlevel 1 (
    echo    ❌ Docker Desktop no está corriendo
    echo    Por favor inicia Docker Desktop y vuelve a intentar
    pause
    exit /b 1
)
echo    ✅ Docker Desktop corriendo

:: Check containers
echo.
echo [2/5] Verificando contenedores...
docker compose ps

:: Check database connection
echo.
echo [3/5] Verificando conexión a Base de Datos...
docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp >nul 2>&1
if errorlevel 1 (
    echo    ❌ Base de datos NO está lista
    echo    Verificando logs...
    docker compose logs db --tail=20
) else (
    echo    ✅ Base de datos está lista
)

:: Check backend health
echo.
echo [4/5] Verificando Backend API...
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ❌ Backend NO responde
    echo    Logs recientes del backend:
    docker compose logs backend --tail=20
) else (
    echo    ✅ Backend API funcionando

    :: Test login endpoint
    echo.
    echo    Testeando endpoint de login...
    curl -s -X POST http://localhost:8000/api/auth/login ^
      -H "Content-Type: application/x-www-form-urlencoded" ^
      -d "username=admin&password=admin123" >nul 2>&1

    if errorlevel 1 (
        echo    ❌ Login endpoint no responde
    ) else (
        echo    ✅ Login endpoint funcionando
    )
)

:: Check frontend
echo.
echo [5/5] Verificando Frontend...
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo    ⚠️  Frontend no responde (puede estar compilando)
    echo    Logs recientes del frontend:
    docker compose logs frontend --tail=15
) else (
    echo    ✅ Frontend funcionando
)

:: Check admin user in database
echo.
echo [EXTRA] Verificando usuario admin en BD...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp ^
  -c "SELECT username, email, role, is_active FROM users WHERE username='admin';" 2>&1 | findstr "admin"
if errorlevel 1 (
    echo    ❌ Usuario admin NO encontrado en la base de datos
    echo.
    echo    SOLUCIÓN: Ejecutar migración inicial
    echo    docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -f /docker-entrypoint-initdb.d/001_initial_schema.sql
) else (
    echo    ✅ Usuario admin existe en la base de datos
)

echo.
echo ══════════════════════════════════════════════════════════════════
echo.
echo Credenciales de Login:
echo   Username: admin
echo   Password: admin123
echo.
echo URLs:
echo   Frontend:  http://localhost:3000
echo   Backend:   http://localhost:8000
echo   API Docs:  http://localhost:8000/api/docs
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
pause
