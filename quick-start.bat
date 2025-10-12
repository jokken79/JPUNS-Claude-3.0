@echo off
cls
echo ========================================
echo   JPUNS-CLAUDE 3.0 - INICIO RAPIDO
echo ========================================
echo.
echo Iniciando servicios...
echo.

docker-compose up -d

echo.
echo Esperando servicios...
timeout /t 30 /nobreak > nul

echo.
echo ========================================
echo   SERVICIOS INICIADOS
echo ========================================
echo.
echo Frontend: http://localhost:3000
echo Backend:  http://localhost:8000
echo API Docs: http://localhost:8000/api/docs
echo.
echo Usuario: admin@uns-kikaku.com
echo Pass: admin123
echo.
pause
