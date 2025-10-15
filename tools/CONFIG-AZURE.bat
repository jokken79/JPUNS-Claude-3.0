@echo off
echo ============================================
echo JPUNS-CLAUDE 3.0 - CONFIGURAR AZURE OCR
echo ============================================
echo.
echo Este script te ayudará a configurar las credenciales
echo de Azure Computer Vision para el OCR.
echo.
echo Si no tienes una cuenta de Azure, puedes:
echo 1. Crear una cuenta gratuita en Azure
echo 2. Crear un recurso de Computer Vision
echo 3. Obtener la clave y el endpoint
echo.
echo Más información: https://docs.microsoft.com/es-es/azure/cognitive-services/computer-vision/
echo.

set /p azure_endpoint="Introduce tu Azure Computer Vision Endpoint (ej: https://your-resource.cognitiveservices.azure.com/): "
set /p azure_key="Introduce tu Azure Computer Vision Key: "

echo.
Escribiendo configuración en backend/.env...

(
echo # Azure Computer Vision OCR Configuration
echo AZURE_COMPUTER_VISION_ENDPOINT=%azure_endpoint%
echo AZURE_COMPUTER_VISION_KEY=%azure_key%
echo AZURE_COMPUTER_VISION_API_VERSION=2023-02-01-preview
) > backend/.env

echo.
echo ¡Configuración guardada correctamente!
echo.
echo Ahora reinicia el backend para aplicar los cambios:
echo docker-compose restart backend
echo.
pause