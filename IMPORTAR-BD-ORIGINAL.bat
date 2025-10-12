@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Importar Base de Datos Original

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║         UNS-CLAUDEJP - IMPORTAR BASE DE DATOS ORIGINAL         ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar Docker Compose
set "DOCKER_COMPOSE_CMD="
docker compose version >nul 2>&1
if %errorlevel% EQU 0 (
    set "DOCKER_COMPOSE_CMD=docker compose"
) else (
    docker-compose version >nul 2>&1
    if %errorlevel% EQU 0 (
        set "DOCKER_COMPOSE_CMD=docker-compose"
    ) else (
        echo ❌ Docker Compose no está instalado
        pause
        exit /b 1
    )
)

echo ══════════════════════════════════════════════════════════════════
echo   ¿DÓNDE ESTÁ TU BASE DE DATOS ORIGINAL?
echo ══════════════════════════════════════════════════════════════════
echo.
echo Selecciona el origen de tus datos:
echo.
echo [1] Tengo un archivo .sql (backup de PostgreSQL)
echo [2] Tengo un archivo .csv o Excel con datos
echo [3] Tengo otra base de datos PostgreSQL corriendo
echo [4] Quiero conectarme a una BD externa
echo [0] Cancelar
echo.

choice /C 12340 /M "Elige una opción"

if errorlevel 5 goto :cancelled
if errorlevel 4 goto :external_db
if errorlevel 3 goto :other_postgres
if errorlevel 2 goto :csv_import
if errorlevel 1 goto :sql_import

:sql_import
echo.
echo ══════════════════════════════════════════════════════════════════
echo   IMPORTAR DESDE ARCHIVO .SQL
echo ══════════════════════════════════════════════════════════════════
echo.
echo Paso 1: Coloca tu archivo .sql en la carpeta:
echo         d:\JPUNS-Claude-3.0\base-datos\
echo.
echo Ejemplo: d:\JPUNS-Claude-3.0\base-datos\mi_backup.sql
echo.
pause

echo.
echo Archivos .sql encontrados en base-datos/:
echo.
dir /b base-datos\*.sql 2>nul

echo.
set /p SQL_FILE="Ingresa el nombre del archivo (ejemplo: mi_backup.sql): "

if not exist "base-datos\%SQL_FILE%" (
    echo.
    echo ❌ Archivo no encontrado: base-datos\%SQL_FILE%
    echo.
    pause
    exit /b 1
)

echo.
echo ⚠ ADVERTENCIA: Esto reemplazará todos los datos actuales
echo.
choice /C SN /M "¿Estás seguro? (S=Sí, N=No)"
if errorlevel 2 goto :cancelled

echo.
echo [1/3] Verificando que la base de datos esté corriendo...
%DOCKER_COMPOSE_CMD% ps | findstr "uns-claudejp-db" | findstr "Up" >nul
if errorlevel 1 (
    echo    Base de datos no está corriendo. Iniciando...
    %DOCKER_COMPOSE_CMD% up -d db
    echo    Esperando 30 segundos...
    timeout /t 30 /nobreak >nul
)
echo    ✅ Base de datos corriendo

echo.
echo [2/3] Copiando archivo al contenedor...
docker cp "base-datos\%SQL_FILE%" uns-claudejp-db:/tmp/import.sql
echo    ✅ Archivo copiado

echo.
echo [3/3] Importando datos...
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -f /tmp/import.sql

if errorlevel 1 (
    echo.
    echo ❌ Error al importar datos
    echo.
    echo Posibles causas:
    echo 1. El archivo SQL tiene errores de sintaxis
    echo 2. Las tablas no coinciden con el esquema actual
    echo 3. Hay conflictos de claves únicas
    echo.
    echo Ver logs completos:
    echo   LOGS.bat ^> opción 4 (Base de datos)
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Datos importados correctamente
echo.
echo Reiniciando backend para refrescar conexiones...
%DOCKER_COMPOSE_CMD% restart backend

goto :success

:csv_import
echo.
echo ══════════════════════════════════════════════════════════════════
echo   IMPORTAR DESDE CSV/EXCEL
echo ══════════════════════════════════════════════════════════════════
echo.
echo Para importar desde CSV o Excel:
echo.
echo Opción 1 - Usar script Python:
echo   1. Coloca tus archivos .csv en: base-datos/csv/
echo   2. Ejecuta: python scripts/import_csv.py
echo.
echo Opción 2 - Convertir a SQL primero:
echo   1. Usa una herramienta para convertir CSV ^> SQL
echo   2. Luego ejecuta este script y elige opción [1]
echo.
echo Opción 3 - Importar manualmente por la interfaz:
echo   1. Abre http://localhost:3000
echo   2. Ve a cada sección (Empleados, Candidatos, etc.)
echo   3. Usa el botón "Importar" en cada página
echo.
pause
exit /b 0

:other_postgres
echo.
echo ══════════════════════════════════════════════════════════════════
echo   MIGRAR DESDE OTRA BASE DE DATOS POSTGRESQL
echo ══════════════════════════════════════════════════════════════════
echo.
echo Pasos para migrar:
echo.
echo 1. Haz backup de tu BD original:
echo    pg_dump -U usuario -d base_datos ^> backup.sql
echo.
echo 2. Copia el archivo backup.sql a:
echo    d:\JPUNS-Claude-3.0\base-datos\
echo.
echo 3. Vuelve a ejecutar este script y elige opción [1]
echo.
pause
exit /b 0

:external_db
echo.
echo ══════════════════════════════════════════════════════════════════
echo   CONECTAR A BASE DE DATOS EXTERNA
echo ══════════════════════════════════════════════════════════════════
echo.
echo Para usar una BD externa (no Docker):
echo.
echo 1. Edita: docker-compose.yml
echo.
echo 2. En la sección "backend", cambia DATABASE_URL:
echo.
echo    DATABASE_URL: postgresql://usuario:password@host:5432/database
echo.
echo 3. Comenta o elimina el servicio "db" del docker-compose.yml
echo.
echo 4. Reinicia: STOP.bat ^&^& START.bat
echo.
echo Ejemplo de configuración:
echo   Host: mi-servidor.com
echo   Puerto: 5432
echo   Usuario: uns_admin
echo   Password: tu_password
echo   Database: uns_claudejp
echo.
pause
exit /b 0

:success
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              ✅ IMPORTACIÓN COMPLETADA ✅                      ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Tus datos originales han sido importados exitosamente.
echo.
echo Próximos pasos:
echo 1. Verifica los datos: http://localhost:3000
echo 2. Si algo está mal, puedes restaurar desde backup
echo.
pause
exit /b 0

:cancelled
echo.
echo Importación cancelada.
echo.
pause
exit /b 0
