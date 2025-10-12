@echo off
echo ==========================================
echo UNS-ClaudeJP - Reparacion de Base de Datos
echo ==========================================
echo.

echo OPCION 1: Reparar sin borrar datos (ejecutar migraciones)
echo OPCION 2: Borrar y recrear base de datos (datos se pierden)
echo.
set /p OPCION="Elige una opcion (1 o 2): "

if "%OPCION%"=="1" goto OPCION1
if "%OPCION%"=="2" goto OPCION2
echo Opcion invalida
pause
exit /b 1

:OPCION1
echo.
echo ==========================================
echo OPCION 1: Ejecutando migraciones...
echo ==========================================
echo.

echo Ejecutando migracion consolidada...
docker exec -i uns-claudejp-db psql -U uns_admin -d uns_claudejp < database\migrations\006_consolidado_todas_columnas.sql

echo.
echo Reiniciando contenedor importer...
docker compose restart importer

echo.
echo Esperando a que termine la importacion...
timeout /t 10 /nobreak >nul

echo.
echo Mostrando logs del importador:
docker logs uns-claudejp-importer --tail 50

echo.
echo ==========================================
echo Reparacion completada (Opcion 1)!
echo ==========================================
echo.
echo Las columnas faltantes han sido agregadas.
echo Tus datos NO fueron eliminados.
echo.
pause
exit /b 0

:OPCION2
echo.
echo ==========================================
echo OPCION 2: Recreando base de datos...
echo ==========================================
echo.
echo ADVERTENCIA: Todos los datos se perderan!
set /p CONFIRMAR="Estas seguro? (SI/NO): "

if /I not "%CONFIRMAR%"=="SI" (
    echo Operacion cancelada.
    pause
    exit /b 0
)

echo.
echo Deteniendo contenedores...
docker compose stop

echo.
echo Eliminando volumen de base de datos...
docker volume rm jpuns-claude25o_postgres_data

echo.
echo Reiniciando servicios...
docker compose up -d --build

echo.
echo Esperando a que los servicios esten listos...
timeout /t 30 /nobreak >nul

echo.
echo Verificando importacion...
docker logs uns-claudejp-importer --tail 50

echo.
echo ==========================================
echo Reparacion completada (Opcion 2)!
echo ==========================================
echo.
echo La base de datos ha sido recreada con el esquema correcto.
echo Todos los datos fueron eliminados - la BD esta limpia.
echo.
pause
exit /b 0
