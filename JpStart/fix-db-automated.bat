@echo off
echo ==========================================
echo UNS-ClaudeJP - Reparacion de Base de Datos
echo ==========================================
echo.
echo Ejecutando reparacion automatica (opcion 2 - borrar y recrear)...
echo.
timeout /t 2 /nobreak >nul

:: Opcion 2: Borrar y recrear base de datos
echo 2 | cmd.exe /c fix-database.bat
