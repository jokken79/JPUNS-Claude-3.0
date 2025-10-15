@echo off
echo Instalando dependencias para procesamiento de imagenes...
cd backend

pip install Pillow>=9.0.0
pip install numpy>=1.21.0

echo.
echo Dependencias instaladas correctamente!
echo.
echo Reinicia el backend para aplicar los cambios:
echo docker-compose restart backend
pause