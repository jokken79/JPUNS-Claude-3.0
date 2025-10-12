@echo off
cls
color 0A

echo ========================================
echo   RESET COMPLETO - JPUNS-CLAUDE 3.0
echo ========================================
echo.
echo Este script:
echo   1. Detendra todos los contenedores
echo   2. Eliminara volumenes de BD
echo   3. Reiniciara desde cero
echo   4. Verificara que TODO funcione
echo.
echo ATENCION: Se perderan todos los datos!
echo.
set /p CONFIRM="Estas seguro? (S/N): "

if /i not "%CONFIRM%"=="S" (
    echo.
    echo Cancelado por el usuario.
    pause
    exit /b 0
)

echo.
echo ========================================
echo   PASO 1: Deteniendo contenedores
echo ========================================
echo.

docker-compose down

echo.
echo ========================================
echo   PASO 2: Eliminando volumenes
echo ========================================
echo.

docker volume rm uns-claudejp-postgres-data 2>nul
docker volume prune -f

echo.
echo ========================================
echo   PASO 3: Limpiando imagenes antiguas
echo ========================================
echo.

docker-compose down --rmi local 2>nul

echo.
echo ========================================
echo   PASO 4: Reconstruyendo contenedores
echo ========================================
echo.

docker-compose build --no-cache

echo.
echo ========================================
echo   PASO 5: Iniciando servicios
echo ========================================
echo.

docker-compose up -d

echo.
echo ========================================
echo   PASO 6: Verificando servicios
echo ========================================
echo.

echo Esperando 40 segundos para que todo inicie...
timeout /t 40 /nobreak > nul

echo.
echo Verificando Base de Datos...
docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [ERROR] Base de datos no responde
    echo.
    echo Mostrando logs:
    docker logs uns-claudejp-db --tail 50
    echo.
    pause
    exit /b 1
)
echo [OK] Base de datos funcionando

echo.
echo Verificando Backend...
curl -s http://localhost:8000/api/health > nul
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [ERROR] Backend no responde
    echo.
    echo Mostrando logs:
    docker logs uns-claudejp-backend --tail 50
    echo.
    pause
    exit /b 1
)
echo [OK] Backend funcionando

echo.
echo Verificando Frontend...
curl -s http://localhost:3000 > nul
if %ERRORLEVEL% NEQ 0 (
    color 0E
    echo [WARNING] Frontend aun no responde (puede tomar mas tiempo)
) else (
    echo [OK] Frontend funcionando
)

echo.
echo ========================================
echo   PASO 7: Verificando datos en BD
echo ========================================
echo.

docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT COUNT(*) as users FROM users;" 2>nul
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT COUNT(*) as factories FROM factories;" 2>nul
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT COUNT(*) as candidates FROM candidates;" 2>nul
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT COUNT(*) as employees FROM employees;" 2>nul

echo.
echo ========================================
echo   RESET COMPLETADO
echo ========================================
echo.
color 0A
echo Todo listo! Puedes acceder a:
echo.
echo   Frontend: http://localhost:3000
echo   Backend:  http://localhost:8000
echo   API Docs: http://localhost:8000/api/docs
echo.
echo Credenciales:
echo   Usuario: admin@uns-kikaku.com
echo   Pass: admin123
echo.
echo Si Frontend no carga, espera 2-3 minutos mas.
echo.
pause
