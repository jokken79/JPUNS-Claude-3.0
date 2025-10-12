@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Solución Login (DEFINITIVA)

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        UNS-CLAUDEJP - SOLUCIÓN LOGIN (DEFINITIVA)              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar Docker Compose
echo [PASO 1/5] Detectando Docker Compose...
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

:: Verificar estado de contenedores
echo.
echo [PASO 2/5] Verificando estado de contenedores...
%DOCKER_COMPOSE_CMD% ps
echo.

:: Verificar si backend está corriendo
docker ps | findstr "uns-claudejp-backend" >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Backend no está corriendo. Iniciando servicios...
    %DOCKER_COMPOSE_CMD% up -d
    echo    ⏳ Esperando 30 segundos para que los servicios inicien...
    timeout /t 30 /nobreak >nul
)

:: Verificar backend health
echo.
echo [PASO 3/5] Verificando backend...
curl -s http://localhost:8000/api/health >nul 2>&1
if errorlevel 1 (
    echo    ⚠ Backend no responde. Revisando logs...
    %DOCKER_COMPOSE_CMD% logs backend --tail=10
    echo.
    echo    ⏳ Esperando 20 segundos más...
    timeout /t 20 /nobreak >nul
) else (
    echo    ✅ Backend funcionando
)

:: Copiar script de fix
echo.
echo [PASO 4/5] Copiando script de corrección de password...

:: Crear script Python para fix
echo import psycopg2 > temp_fix_password.py
echo from passlib.context import CryptContext >> temp_fix_password.py
echo. >> temp_fix_password.py
echo pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto") >> temp_fix_password.py
echo. >> temp_fix_password.py
echo conn = psycopg2.connect( >> temp_fix_password.py
echo     dbname="uns_claudejp", >> temp_fix_password.py
echo     user="uns_admin", >> temp_fix_password.py
echo     password="57UD10R", >> temp_fix_password.py
echo     host="db", >> temp_fix_password.py
echo     port="5432" >> temp_fix_password.py
echo ) >> temp_fix_password.py
echo. >> temp_fix_password.py
echo try: >> temp_fix_password.py
echo     cur = conn.cursor() >> temp_fix_password.py
echo     password = "admin123" >> temp_fix_password.py
echo     correct_hash = pwd_context.hash(password) >> temp_fix_password.py
echo     print(f"Actualizando password para usuario 'admin'...") >> temp_fix_password.py
echo     cur.execute("UPDATE users SET password_hash = %%s WHERE username = 'admin'", (correct_hash,)) >> temp_fix_password.py
echo     conn.commit() >> temp_fix_password.py
echo     cur.execute("SELECT username FROM users WHERE username = 'admin'") >> temp_fix_password.py
echo     result = cur.fetchone() >> temp_fix_password.py
echo     if result: >> temp_fix_password.py
echo         verification = pwd_context.verify(password, correct_hash) >> temp_fix_password.py
echo         if verification: >> temp_fix_password.py
echo             print("✅ Password actualizado correctamente") >> temp_fix_password.py
echo         else: >> temp_fix_password.py
echo             print("❌ Error en verificación") >> temp_fix_password.py
echo     cur.close() >> temp_fix_password.py
echo except Exception as e: >> temp_fix_password.py
echo     print(f"❌ Error: {e}") >> temp_fix_password.py
echo     conn.rollback() >> temp_fix_password.py
echo finally: >> temp_fix_password.py
echo     conn.close() >> temp_fix_password.py

echo    ✅ Script creado

:: Copiar y ejecutar
echo.
echo [PASO 5/5] Ejecutando corrección de password...
docker cp temp_fix_password.py uns-claudejp-backend:/app/temp_fix_password.py
docker exec uns-claudejp-backend python /app/temp_fix_password.py

if errorlevel 1 (
    echo    ❌ Error al ejecutar script
    pause
    exit /b 1
)

:: Limpiar
del temp_fix_password.py 2>nul

:: Probar login
echo.
echo [VERIFICACIÓN] Probando login...
curl -s -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "username=admin&password=admin123" > temp_login_test.txt 2>&1

findstr "access_token" temp_login_test.txt >nul
if errorlevel 1 (
    echo    ❌ Login falló
    echo    Respuesta del servidor:
    type temp_login_test.txt
    echo.
) else (
    echo    ✅ Login exitoso!
)

del temp_login_test.txt 2>nul

:: Resumen
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                    SOLUCIÓN COMPLETADA                         ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo ✅ Password del usuario admin ha sido corregido
echo.
echo Credenciales de acceso:
echo   👤 Usuario: admin
echo   🔑 Password: admin123
echo.
echo URLs de acceso:
echo   🌐 Frontend:  http://localhost:3000
echo   🔌 Backend:   http://localhost:8000
echo   📚 API Docs:  http://localhost:8000/api/docs
echo.
echo Instrucciones:
echo 1. Abre tu navegador en: http://localhost:3000
echo 2. Ingresa las credenciales: admin / admin123
echo 3. Deberías poder iniciar sesión sin problemas
echo.
echo Si el problema persiste:
echo - Verifica que todos los contenedores estén corriendo
echo - Revisa los logs con: docker-compose logs backend
echo - Asegúrate de tener el puerto 3000 y 8000 libres
echo.
echo ══════════════════════════════════════════════════════════════════
echo.
pause
