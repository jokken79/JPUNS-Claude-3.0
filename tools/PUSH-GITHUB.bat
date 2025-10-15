@echo off
echo ====================================
echo JPUNS-Claude 3.0 - Push to GitHub
echo ====================================
echo.

echo [1/4] Verificando estado del repositorio...
git status
echo.

echo [2/4] Agregando todos los cambios...
git add .
if %errorlevel% neq 0 (
    echo ERROR: No se pudieron agregar los cambios
    pause
    exit /b 1
)
echo ✅ Cambios agregados correctamente
echo.

echo [3/4] Creando commit...
set /p commit_msg="Ingrese mensaje del commit (o presione Enter para usar mensaje por defecto): "
if "%commit_msg%"=="" (
    set commit_msg=Actualización automática del sistema JPUNS-Claude 3.0
)
git commit -m "%commit_msg%"
if %errorlevel% neq 0 (
    echo ADVERTENCIA: No hay cambios para commitear o ocurrió un error
)
echo.

echo [4/4] Enviando cambios a GitHub...
git push origin main
if %errorlevel% neq 0 (
    echo ERROR: No se pudo hacer push a GitHub
    echo Verifique su conexión a internet y permisos del repositorio
    pause
    exit /b 1
)
echo.

echo ====================================
echo ✅ PUSH COMPLETADO EXITOSAMENTE
echo ====================================
echo.
echo Los cambios han sido enviados a:
echo https://github.com/jokken79/JPUNS-Claude-3.0
echo.
pause