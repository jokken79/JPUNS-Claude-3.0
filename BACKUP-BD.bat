@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Backup Base de Datos

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║           UNS-CLAUDEJP - BACKUP BASE DE DATOS                  ║
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

echo [1/4] Verificando que la base de datos esté corriendo...
%DOCKER_COMPOSE_CMD% ps | findstr "uns-claudejp-db" | findstr "Up" >nul
if errorlevel 1 (
    echo    ❌ La base de datos NO está corriendo
    echo.
    echo    Inicia el sistema primero: START.bat
    echo.
    pause
    exit /b 1
)
echo    ✅ Base de datos corriendo

:: Crear carpeta de backups si no existe
if not exist "backups" mkdir backups

:: Generar nombre de archivo con fecha y hora
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set BACKUP_DATE=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%_%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%
set BACKUP_FILE=backups\backup_%BACKUP_DATE%.sql

echo.
echo [2/4] Creando backup...
echo    Archivo: %BACKUP_FILE%
echo.

:: Hacer backup usando pg_dump
docker exec uns-claudejp-db pg_dump -U uns_admin uns_claudejp > "%BACKUP_FILE%"

if errorlevel 1 (
    echo.
    echo ❌ Error al crear backup
    pause
    exit /b 1
)

echo    ✅ Backup creado

:: Verificar tamaño del archivo
echo.
echo [3/4] Verificando backup...
for %%A in ("%BACKUP_FILE%") do set SIZE=%%~zA

if %SIZE% LSS 1000 (
    echo    ⚠ ADVERTENCIA: El archivo es muy pequeño (%SIZE% bytes)
    echo    Es posible que el backup esté vacío o incompleto
) else (
    echo    ✅ Tamaño del backup: %SIZE% bytes
)

:: Comprimir backup (opcional)
echo.
echo [4/4] ¿Deseas comprimir el backup?
choice /C SN /M "(S=Sí, N=No)"

if errorlevel 2 goto :no_compress
if errorlevel 1 (
    echo.
    echo    Comprimiendo...

    :: Intentar usar tar (viene con Git Bash en Windows)
    tar -czf "%BACKUP_FILE%.tar.gz" "%BACKUP_FILE%" 2>nul

    if errorlevel 1 (
        echo    ⚠ No se pudo comprimir (tar no disponible)
        echo    El backup sin comprimir está en: %BACKUP_FILE%
    ) else (
        echo    ✅ Backup comprimido: %BACKUP_FILE%.tar.gz

        choice /C SN /M "¿Eliminar archivo .sql sin comprimir? (S=Sí, N=No)"
        if errorlevel 1 (
            del "%BACKUP_FILE%"
            echo    ✅ Archivo .sql eliminado (solo queda el .tar.gz)
        )
    )
)

:no_compress

:: Mostrar lista de backups
echo.
echo ══════════════════════════════════════════════════════════════════
echo   BACKUPS DISPONIBLES
echo ══════════════════════════════════════════════════════════════════
echo.
dir /b backups\*.sql backups\*.tar.gz 2>nul

:: Calcular espacio total
echo.
echo Espacio total usado por backups:
for /f "tokens=3" %%a in ('dir /s backups ^| findstr "bytes"') do set TOTAL=%%a
echo %TOTAL% bytes

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              ✅ BACKUP COMPLETADO ✅                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo 📁 Ubicación: %BACKUP_FILE%
echo.
echo 💡 Para restaurar este backup:
echo    1. Ejecuta: IMPORTAR-BD-ORIGINAL.bat
echo    2. Elige opción [1] (archivo .sql)
echo    3. Selecciona: %BACKUP_FILE%
echo.
echo 📋 Recomendaciones:
echo    - Haz backups regularmente (diario, semanal, mensual)
echo    - Guarda copias en otra ubicación (USB, nube)
echo    - Prueba restaurar backups ocasionalmente
echo.
pause
