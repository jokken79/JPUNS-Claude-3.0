@echo off
echo Verificando e instalando PIL en el contenedor Docker...
echo.

echo Ejecutando en el contenedor backend:
docker-compose exec backend pip install Pillow>=9.0.0 numpy>=1.21.0

echo.
echo Reiniciando el backend...
docker-compose restart backend

echo.
echo Esperando a que el backend se inicie...
timeout /t 10

echo.
echo PIL instalado y backend reiniciado!
pause