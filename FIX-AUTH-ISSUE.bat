@echo off
echo ============================================
echo JPUNS-CLAUDE 3.0 - FIX AUTHENTICATION ISSUE
echo ============================================
echo.
echo Este script solucionará el problema de autenticación
echo que impide guardar candidatos.
echo.

echo Paso 1: Reiniciando servicios...
docker-compose restart frontend backend

echo.
echo Paso 2: Esperando que los servicios se inicien...
timeout /t 15 /nobreak > nul

echo.
echo Paso 3: Verificando estado de los servicios...
docker ps --filter "name=uns-claudejp"

echo.
echo ============================================
echo SOLUCIÓN COMPLETA
echo ============================================
echo.
echo 1. El tiempo de expiración del token se ha aumentado a 8 horas
echo 2. Los servicios se han reiniciado
echo 3. Ahora intenta lo siguiente:
echo.
echo    a) Abre el navegador en modo incógnito
echo    b) Inicia sesión con:
echo       - Usuario: admin
echo       - Contraseña: 57UD10R
echo    c) Intenta guardar un candidato
echo.
echo Si el problema persiste, ejecuta:
echo docker logs uns-claudejp-backend --tail=50
echo.
pause