@echo off
title UNS-ClaudeJP - ¿Qué ejecutar?

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║          ¿QUÉ ARCHIVO .BAT DEBO EJECUTAR?                     ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Elige tu situación:
echo.
echo   1. PRIMERA VEZ que voy a instalar
echo   2. Ya lo tengo instalado pero funciona MAL
echo   3. Quiero ACTUALIZAR a la última versión
echo   4. La BASE DE DATOS tiene errores
echo   5. No sé qué pasa, quiero DIAGNOSTICAR
echo   6. Solo quiero INICIAR la aplicación
echo   7. Solo quiero DETENER la aplicación
echo.
set /p opcion="Elija una opción (1-7): "

if "%opcion%"=="1" goto PRIMERA_VEZ
if "%opcion%"=="2" goto FUNCIONA_MAL
if "%opcion%"=="3" goto ACTUALIZAR
if "%opcion%"=="4" goto BASE_DATOS
if "%opcion%"=="5" goto DIAGNOSTICAR
if "%opcion%"=="6" goto INICIAR
if "%opcion%"=="7" goto DETENER
echo Opción inválida
pause
exit /b 1

:PRIMERA_VEZ
echo.
echo ════════════════════════════════════════════════════════════
echo   EJECUTAR EN ESTE ORDEN:
echo ════════════════════════════════════════════════════════════
echo.
echo   1º) install-windows-v2.bat
echo       (Elige opción 1: Instalación Fresh)
echo.
echo   ESPERAR 3-5 minutos hasta que termine todo
echo.
echo   2º) Si algo sale mal, ejecuta: diagnose-issues.bat
echo.
echo ════════════════════════════════════════════════════════════
echo.
set /p confirm="¿Quieres ejecutar install-windows-v2.bat ahora? (S/N): "
if /I "%confirm%"=="S" (
    call install-windows-v2.bat
) else (
    echo.
    echo Recuerda ejecutar: install-windows-v2.bat
)
pause
exit /b 0

:FUNCIONA_MAL
echo.
echo ════════════════════════════════════════════════════════════
echo   EJECUTAR EN ESTE ORDEN:
echo ════════════════════════════════════════════════════════════
echo.
echo   1º) diagnose-issues.bat
echo       (Para saber qué está mal)
echo.
echo   2º) Después de ver el diagnóstico, elige:
echo       - Si es de versión: force-update.bat
echo       - Si es de base de datos: fix-database.bat
echo       - Si es grave: install-windows-v2.bat
echo.
echo ════════════════════════════════════════════════════════════
echo.
set /p confirm="¿Quieres ejecutar diagnose-issues.bat ahora? (S/N): "
if /I "%confirm%"=="S" (
    call diagnose-issues.bat
) else (
    echo.
    echo Recuerda ejecutar: diagnose-issues.bat
)
pause
exit /b 0

:ACTUALIZAR
echo.
echo ════════════════════════════════════════════════════════════
echo   EJECUTAR:
echo ════════════════════════════════════════════════════════════
echo.
echo   force-update.bat
echo.
echo   Esto descargará la última versión sin borrar tus datos
echo.
echo ════════════════════════════════════════════════════════════
echo.
set /p confirm="¿Quieres ejecutar force-update.bat ahora? (S/N): "
if /I "%confirm%"=="S" (
    call force-update.bat
) else (
    echo.
    echo Recuerda ejecutar: force-update.bat
)
pause
exit /b 0

:BASE_DATOS
echo.
echo ════════════════════════════════════════════════════════════
echo   EJECUTAR:
echo ════════════════════════════════════════════════════════════
echo.
echo   fix-database.bat
echo.
echo   Elige:
echo   - Opción 1: Reparar sin borrar datos (recomendado)
echo   - Opción 2: Borrar y recrear (pierdes datos)
echo.
echo ════════════════════════════════════════════════════════════
echo.
set /p confirm="¿Quieres ejecutar fix-database.bat ahora? (S/N): "
if /I "%confirm%"=="S" (
    call fix-database.bat
) else (
    echo.
    echo Recuerda ejecutar: fix-database.bat
)
pause
exit /b 0

:DIAGNOSTICAR
echo.
echo ════════════════════════════════════════════════════════════
echo   EJECUTAR:
echo ════════════════════════════════════════════════════════════
echo.
echo   diagnose-issues.bat
echo.
echo   Esto te dirá exactamente qué está fallando
echo.
echo ════════════════════════════════════════════════════════════
echo.
set /p confirm="¿Quieres ejecutar diagnose-issues.bat ahora? (S/N): "
if /I "%confirm%"=="S" (
    call diagnose-issues.bat
) else (
    echo.
    echo Recuerda ejecutar: diagnose-issues.bat
)
pause
exit /b 0

:INICIAR
echo.
echo ════════════════════════════════════════════════════════════
echo   EJECUTAR:
echo ════════════════════════════════════════════════════════════
echo.
echo   start-app.bat
echo.
echo   Para iniciar la aplicación rápidamente
echo.
echo ════════════════════════════════════════════════════════════
echo.
set /p confirm="¿Quieres ejecutar start-app.bat ahora? (S/N): "
if /I "%confirm%"=="S" (
    call start-app.bat
) else (
    echo.
    echo Recuerda ejecutar: start-app.bat
)
pause
exit /b 0

:DETENER
echo.
echo ════════════════════════════════════════════════════════════
echo   EJECUTAR:
echo ════════════════════════════════════════════════════════════
echo.
echo   stop-app.bat
echo.
echo   Para detener la aplicación
echo.
echo ════════════════════════════════════════════════════════════
echo.
set /p confirm="¿Quieres ejecutar stop-app.bat ahora? (S/N): "
if /I "%confirm%"=="S" (
    call stop-app.bat
) else (
    echo.
    echo Recuerda ejecutar: stop-app.bat
)
pause
exit /b 0