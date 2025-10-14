@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Restaurar Después de Actualización Docker

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            RESTAURAR DESPUÉS DE ACTUALIZACIÓN                  ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Buscar directorios de backup
echo 📁 Buscando backups disponibles...
echo.

for /d %%d in (backup-docker-*) do (
    echo   📦 %%d
)

echo.
set /p "BACKUP_DIR=Introduce el nombre del backup a restaurar: "

if not exist "%BACKUP_DIR%" (
    echo ❌ Backup no encontrado: %BACKUP_DIR%
    pause
    exit /b 1
)

echo.
echo 🔄 Restaurando desde: %BACKUP_DIR%
echo.

:: Detener servicios actuales
echo 🛑 Deteniendo servicios...
docker compose down >nul 2>&1

:: Restaurar base de datos
if exist "%BACKUP_DIR%\database-backup.sql" (
    echo 🗄️ Restaurando base de datos...
    
    :: Iniciar solo la base de datos
    docker compose up -d db
    timeout /t 30 >nul
    
    :: Restaurar datos
    docker compose exec -T db psql -U uns_admin -d uns_claudejp < "%BACKUP_DIR%\database-backup.sql" >nul 2>&1
    
    echo ✅ Base de datos restaurada
) else (
    echo ⚠️ No hay backup de base de datos
)

:: Reconstruir imágenes
echo 🔨 Reconstruyendo imágenes...
docker compose build --no-cache

:: Iniciar servicios
echo 🚀 Iniciando servicios...
docker compose up -d

echo.
echo ✅ Restauración completada
echo.
echo 🌐 Verificar en:
echo   Frontend: http://localhost:3000
echo   Backend:  http://localhost:8000
echo.
pause