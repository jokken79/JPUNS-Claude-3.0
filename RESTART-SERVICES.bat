@echo off
echo ============================================
echo JPUNS-CLAUDE 3.0 - RESTART SERVICES
echo ============================================
echo.
echo Este script reiniciará los servicios para solucionar
echo problemas de sesión y autenticación.
echo.

echo Deteniendo servicios...
docker-compose stop frontend backend

echo Iniciando servicios...
docker-compose start frontend backend

echo.
echo Esperando que los servicios se inicien completamente...
timeout /t 10 /nobreak > nul

echo.
echo ¡Servicios reiniciados!
echo.
echo Ahora intenta iniciar sesión nuevamente con:
echo Usuario: admin
echo Contraseña: 57UD10R
echo.
pause