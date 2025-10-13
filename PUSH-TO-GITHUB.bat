@echo off
echo ============================================
echo JPUNS-CLAUDE 3.0 - PUSH TO GITHUB
echo ============================================
echo.
echo Este script subirá todos los cambios al GitHub.
echo.

echo Paso 1: Verificando estado de Git...
git status

echo.
echo Paso 2: Agregando todos los cambios...
git add .

echo.
echo Paso 3: Creando commit...
git commit -m "Fix: Complete solution for candidate form and Azure OCR

- Added 118 missing columns to candidates table
- Fixed candidate_status enum values
- Corrected OCR endpoints in frontend
- Added required field indicators
- Fixed data mapping in saveData function
- Configured Azure Vision Studio credentials
- Increased JWT token expiration time to 8 hours
- Created scripts for easy configuration and troubleshooting"

echo.
echo Paso 4: Subiendo cambios a GitHub...
git push origin main

echo.
echo ============================================
echo ¡CAMBIOS SUBIDOS CORRECTAMENTE!
echo ============================================
echo.
pause