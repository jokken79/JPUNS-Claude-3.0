@echo off
REM UNS-ClaudeJP Frontend Cache Cleaner (Windows)
REM Este script limpia todo el cache y fuerza una recompilación completa

echo 🧹 UNS-ClaudeJP Frontend Cache Cleaner
echo ======================================

echo 📍 Paso 1: Deteniendo servicios...
docker-compose down

echo 📍 Paso 2: Eliminando contenedores e imágenes...
docker-compose rm -f frontend
docker rmi jpuns-claude25o-frontend 2>nul

echo 📍 Paso 3: Limpiando cache local...
if exist ".\frontend\node_modules\.cache" (
    rmdir /s /q ".\frontend\node_modules\.cache"
    echo ✅ Cache de node_modules eliminado
)

if exist ".\frontend\build" (
    rmdir /s /q ".\frontend\build"
    echo ✅ Directorio build eliminado
)

echo 📍 Paso 4: Reconstruyendo servicios...
docker-compose build --no-cache frontend

echo 📍 Paso 5: Iniciando servicios...
docker-compose up -d

echo 📍 Paso 6: Esperando que el frontend esté listo...
timeout /t 10 >nul

echo 🎉 ¡Listo! El frontend ha sido reconstruido completamente.
echo.
echo 🌐 Accede a la aplicación en:
echo    http://localhost:3000
echo.
echo 💡 Consejos para evitar problemas de cache:
echo    - Usa Ctrl+F5 para refrescar forzadamente
echo    - Abre en ventana privada/incógnito
echo    - Limpia cache del navegador en configuración
echo.
echo 🔗 URLs importantes:
echo    - Login: http://localhost:3000/login
echo    - Dashboard: http://localhost:3000/dashboard
echo    - Rirekisho: http://localhost:3000/rirekisho

pause