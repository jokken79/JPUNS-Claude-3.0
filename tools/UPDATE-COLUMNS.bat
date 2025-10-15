@echo off
echo ============================================
echo JPUNS-CLAUDE 3.0 - ACTUALIZAR CANDIDATES
echo ============================================
echo.

echo Este script agregara todas las columnas faltantes
echo del formulario rirekisho a la tabla candidates.
echo.

pause

echo Conectando a la base de datos PostgreSQL...
echo.

docker exec -i uns-claudejp-db psql -U uns_admin -d uns_claudejp < base-datos/03_add_candidates_rirekisho_columns.sql

echo.
echo ============================================
echo Proceso completado
echo ============================================
echo.
echo La tabla candidates ahora tiene todas las columnas
echo necesarias para el formulario completo de rirekisho.
echo.
pause