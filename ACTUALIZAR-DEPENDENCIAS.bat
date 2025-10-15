@echo off
echo ====================================
echo JPUNS-Claude 3.0 - Actualizador
echo ====================================
echo.

echo [1/4] Actualizando dependencias del backend...
cd backend
pip install -r requirements.txt --upgrade
if %errorlevel% neq 0 (
    echo ERROR: Falló la actualización del backend
    pause
    exit /b 1
)
echo ✅ Backend actualizado correctamente
echo.

echo [2/4] Verificando compatibilidad del backend...
python -m pip check
if %errorlevel% neq 0 (
    echo ADVERTENCIA: Problemas de compatibilidad en el backend
)
echo.

echo [3/4] Actualizando dependencias del frontend...
cd ..\frontend
rmdir /s /q node_modules 2>nul
del package-lock.json 2>nul
npm install
if %errorlevel% neq 0 (
    echo ERROR: Falló la actualización del frontend
    pause
    exit /b 1
)
echo ✅ Frontend actualizado correctamente
echo.

echo [4/4] Verificando seguridad del frontend...
npm audit --audit-level=moderate
echo.

echo ====================================
echo ✅ ACTUALIZACIÓN COMPLETADA
echo ====================================
echo.
echo Se han actualizado todas las dependencias
echo del proyecto JPUNS-Claude 3.0
echo.
pause