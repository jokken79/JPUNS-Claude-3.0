@echo off
echo ============================================
echo JPUNS-CLAUDE 3.0 - TEST AZURE OCR
echo ============================================
echo.
echo Este script probará si las credenciales de Azure OCR
echo están configuradas correctamente.
echo.

docker exec uns-claudejp-backend python -c "
import os
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv('/app/.env')

# Verificar variables de entorno
azure_endpoint = os.getenv('AZURE_COMPUTER_VISION_ENDPOINT')
azure_key = os.getenv('AZURE_COMPUTER_VISION_KEY')

print(f'Azure Endpoint: {azure_endpoint}')
print(f'Azure Key: {azure_key[:10]}...' if azure_key else 'Azure Key: None')

if azure_endpoint and azure_key:
    print('✅ Las credenciales de Azure están configuradas correctamente')
else:
    print('❌ Las credenciales de Azure no están configuradas correctamente')
"

echo.
pause