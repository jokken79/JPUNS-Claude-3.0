@echo off
echo ============================================
echo JPUNS-CLAUDE 3.0 - FIX CANDIDATE STATUS ENUM
echo ============================================
echo.

echo Este script corregira los valores del enum candidate_status
echo de minusculas a mayusculas para que coincidan con el modelo.
echo.

pause

echo Corrigiendo el enum candidate_status...
echo.

docker exec -i uns-claudejp-db psql -U uns_admin -d uns_claudejp < base-datos/04_fix_candidate_status_enum.sql

echo.
echo ============================================
echo Proceso completado
echo ============================================
echo.
echo El enum candidate_status ahora usa valores en mayusculas:
echo PENDING, APPROVED, REJECTED, HIRED
echo.
pause