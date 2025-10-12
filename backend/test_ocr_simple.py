#!/usr/bin/env python
"""
Simple OCR Test Script
Prueba el OCR con una imagen de prueba
"""
import requests
import os
from pathlib import Path

# Configuración
API_URL = "http://localhost:8000"
ENDPOINT = "/api/azure-ocr/process"

def test_health():
    """Verificar health check"""
    print("🔍 Verificando health check...")
    response = requests.get(f"{API_URL}/api/azure-ocr/health")
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.json()}")
    return response.status_code == 200

def test_with_sample_image():
    """Probar con una imagen de muestra"""
    # Buscar una imagen de prueba
    test_images = [
        "uploads/zairyu_card_sample.jpg",
        "uploads/test.jpg",
        "uploads/sample.png",
    ]

    image_path = None
    for img in test_images:
        if os.path.exists(img):
            image_path = img
            break

    if not image_path:
        print("⚠️  No se encontró imagen de prueba")
        print("   Puedes poner una imagen en: uploads/test.jpg")
        return False

    print(f"\n📸 Probando OCR con: {image_path}")

    with open(image_path, 'rb') as f:
        files = {'file': ('test.jpg', f, 'image/jpeg')}
        data = {'document_type': 'zairyu_card'}

        response = requests.post(f"{API_URL}{ENDPOINT}", files=files, data=data)

        print(f"   Status: {response.status_code}")

        if response.status_code == 200:
            result = response.json()
            print(f"   Success: {result.get('success')}")

            if result.get('data'):
                data = result['data']
                print(f"\n📋 Datos extraídos:")
                print(f"   - Tipo: {data.get('document_type')}")
                print(f"   - Nombre: {data.get('name_kanji', 'N/A')}")
                print(f"   - Fecha nacimiento: {data.get('birthday', 'N/A')}")
                print(f"   - Nacionalidad: {data.get('nationality', 'N/A')}")
                print(f"   - Dirección: {data.get('address', 'N/A')}")

                if data.get('extracted_text'):
                    print(f"\n📝 Texto extraído (primeras 200 caracteres):")
                    print(f"   {data['extracted_text'][:200]}...")
            return True
        else:
            print(f"   Error: {response.text}")
            return False

def main():
    print("=" * 60)
    print("🚀 TEST DE OCR - JPUNS-CLAUDE2.0")
    print("=" * 60)

    # Test 1: Health Check
    if not test_health():
        print("\n❌ Health check falló - verifica que el backend esté corriendo")
        return

    print("\n✅ Health check exitoso\n")

    # Test 2: OCR con imagen
    if test_with_sample_image():
        print("\n✅ Test de OCR completado exitosamente")
    else:
        print("\n⚠️  Test de OCR no pudo completarse")

    print("\n" + "=" * 60)
    print("📊 RESUMEN:")
    print("   - Backend: ✅ Funcionando")
    print("   - Endpoint: /api/azure-ocr/process")
    print("   - Método: POST")
    print("   - Parámetros: file (imagen), document_type (zairyu_card|license)")
    print("=" * 60)

if __name__ == "__main__":
    main()
