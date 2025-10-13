@echo off
setlocal enabledelayedexpansion

echo.
echo ===================================
echo  CARGAR CONFIGURACIONES DE FÁBRICAS
echo ===================================
echo.
echo Este script cargará todas las configuraciones JSON de fábricas
echo desde la carpeta config/factories a la base de datos.
echo.

REM Verificar que Docker esté corriendo
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker no está funcionando o no se puede acceder.
    echo Por favor, asegúrate de que Docker Desktop está ejecutándose.
    goto :exit_error
)

REM Verificar que el contenedor backend esté corriendo
docker ps | findstr uns-claudejp-backend >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: El contenedor del backend no está en ejecución.
    echo Por favor, ejecuta START.bat primero.
    goto :exit_error
)

echo Opciones disponibles:
echo.
echo 1. Cargar solo fábricas nuevas
echo 2. Cargar/actualizar todas las fábricas
echo 3. Salir
echo.

:menu
set /P opcion=Selecciona una opción (1-3):

if "%opcion%"=="1" (
    echo.
    echo Cargando solo fábricas nuevas...
    echo.
    docker exec -it uns-claudejp-backend python /app/scripts/load_factories_from_json.py
    goto :exit_success
)

if "%opcion%"=="2" (
    echo.
    echo Cargando/actualizando todas las fábricas...
    echo.
    docker exec -it uns-claudejp-backend python /app/scripts/load_factories_from_json.py --all
    goto :exit_success
)

if "%opcion%"=="3" (
    echo.
    echo Operación cancelada.
    goto :exit_normal
)

echo.
echo Opción no válida, por favor selecciona 1, 2 o 3.
echo.
goto :menu

:exit_success
echo.
echo Proceso completado exitosamente.
echo.
pause
exit /b 0

:exit_normal
echo.
pause
exit /b 0

:exit_error
echo.
pause
exit /b 1