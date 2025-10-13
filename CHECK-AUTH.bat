@echo off
echo ============================================
echo JPUNS-CLAUDE 3.0 - CHECK AUTHENTICATION
echo ============================================
echo.
echo Este script verificará el estado de tu autenticación.
echo.

echo Abre la consola del navegador (F12) y ve a la pestaña "Network".
echo Intenta guardar un candidato y busca la solicitud "POST /api/candidates/".
echo Revisa los encabezados (Headers) para ver si hay un token "Authorization".
echo.

echo Si no hay token o aparece "null", necesitas iniciar sesión nuevamente.
echo.

pause