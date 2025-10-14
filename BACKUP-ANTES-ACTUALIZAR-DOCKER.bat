@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

title UNS-ClaudeJP - Backup Antes de Actualizar Docker

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║            BACKUP ANTES DE ACTUALIZAR DOCKER                   ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Crear directorio de backup con fecha
set "BACKUP_DATE=%date:~6,4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%"
set "BACKUP_DATE=%BACKUP_DATE: =0%"
set "BACKUP_DIR=backup-docker-%BACKUP_DATE%"

echo 📁 Creando backup en: %BACKUP_DIR%
mkdir "%BACKUP_DIR%" 2>nul

echo.
echo 🔄 Haciendo backup de configuración Docker...

:: Backup de imágenes Docker
echo   📦 Listando imágenes Docker...
docker images > "%BACKUP_DIR%\docker-images.txt" 2>nul

:: Backup de contenedores
echo   🐳 Listando contenedores...
docker ps -a > "%BACKUP_DIR%\docker-containers.txt" 2>nul

:: Backup de volúmenes
echo   💾 Listando volúmenes...
docker volume ls > "%BACKUP_DIR%\docker-volumes.txt" 2>nul

:: Backup de redes
echo   🌐 Listando redes...
docker network ls > "%BACKUP_DIR%\docker-networks.txt" 2>nul

:: Backup de compose
echo   📋 Copiando docker-compose.yml...
copy "docker-compose.yml" "%BACKUP_DIR%\" >nul 2>&1

:: Backup de datos de volúmenes (solo PostgreSQL)
echo   🗄️ Haciendo backup de base de datos...
docker compose exec -T db pg_dumpall -U uns_admin > "%BACKUP_DIR%\database-backup.sql" 2>nul

echo.
echo ✅ Backup completado en: %BACKUP_DIR%
echo.
echo 📋 INSTRUCCIONES POST-ACTUALIZACIÓN:
echo.
echo 1. Después de actualizar Docker, ejecuta: VERIFICAR-DOCKER.bat
echo 2. Si hay problemas, ejecuta: RESTAURAR-DOCKER.bat
echo 3. Siempre prueba con: START.bat
echo.
echo 💡 RECORDATORIO:
echo - Guarda este backup hasta verificar que todo funciona
echo - Si Docker cambia mucho, puedes usar START-FIXED.bat
echo.
pause