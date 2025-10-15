# 🎯 Mejoras OCR en Rirekisho - UNS-ClaudeJP 2.0

## 📋 Resumen de Mejoras Implementadas (15 de Octubre 2025)

### 1. Extracción de Fecha de Nacimiento (生年月日)
- **Problema**: No se detectaba correctamente, mostraba formato 年-月-D vacío
- **Solución**: 
  - Implementada extracción con múltiples patrones de fecha
  - Conversión automática a formato japonés (YYYY年MM月DD日)
  - Detección en todo el texto, no solo cerca de palabras clave
  - Validación automática de fechas

### 2. Detección de Nacionalidad (国籍)
- **Problema**: Siempre seleccionaba "その他" (Otro)
- **Solución**: 
  - Implementado mapeo de nacionalidades (Vietnam → ベトナム)
  - Detección de nombres de países en todo el texto
  - Soporte para errores comunes de OCR (vietnan → ベトナム)
  - Ignora "その他" cuando se detecta una nacionalidad específica

### 3. Extracción de Foto
- **Problema**: Mostraba el documento completo, no la cara recortada
- **Solución**: 
  - Implementado recorte automático de foto para tarjetas de residencia
  - Coordenadas ajustadas para incluir la cara completa
  - Soporte para PIL (Pillow) con fallback si no está disponible
  - Conversión a base64 para mostrar en frontend

### 4. Parsing de Dirección
- **Problema**: Mezclaba "ADDRESS" y "在留資格 技術・人文知識・国際業務"
- **Solución**: 
  - Filtrado automático de información de visa
  - Eliminación de "ADDRESS" extra
  - Separación correcta de componentes (dirección, 番地, edificio)
  - Evita que "番地" aparezca en campo de edificio

## 🔧 Detalles Técnicos

### Backend (azure_ocr_service.py)

#### Extracción de Fecha Mejorada
```python
# Extracción de todas las fechas en el texto
for pattern in date_patterns:
    matches = re.finditer(pattern, line)
    for match in matches:
        # Extraer números según el patrón
        if pattern == r'(\d{4})[年/\-\.](\d{1,2})[月/\-\.](\d{1,2})日?':
            year, month, day = match.groups()
        # ... otros patrones
        
        # Siempre formatear como japonés
        date_str = f"{year}年{month:02d}月{day:02d}日"
        all_dates.append((date_str, match.start(), line))
```

#### Detección de Nacionalidad
```python
# Mapeo de nacionalidades con errores de OCR
nationality_mapping = {
    'VIETNAM': 'ベトナム',
    'VIET NAM': 'ベトナム',
    'Vietnam': 'ベトナム',
    'vietnan': 'ベトナム',  # Error común de OCR
    'VIETNAN': 'ベトナム',
    # ... más mapeos
}

# Búsqueda activa en todo el texto
for line in lines:
    for country, japanese in country_patterns.items():
        if country.lower() in line.lower():
            result['nationality'] = japanese
```

#### Extracción de Foto
```python
def _extract_photo_from_document(self, image_data: bytes, document_type: str):
    # Verificar si PIL está disponible
    try:
        from PIL import Image
        PIL_AVAILABLE = True
    except ImportError:
        PIL_AVAILABLE = False
    
    if document_type == "zairyu_card" and PIL_AVAILABLE:
        # Coordenadas ajustadas para cara completa
        left = int(width * 0.55)   # 55% del ancho
        top = int(height * 0.05)   # 5% del alto
        right = int(width * 0.98)  # 98% del ancho
        bottom = int(height * 0.65) # 65% del alto
        
        photo_image = image.crop((left, top, right, bottom))
        # Convertir a base64
```

#### Limpieza de Dirección
```python
# Limpiar dirección de información no deseada
full_address = ' '.join(address_parts)
if '在留資格' in full_address:
    full_address = full_address.split('在留資格')[0].strip()

# Eliminar "ADDRESS" extra
full_address = full_address.replace(' ADDRESS', '').strip()

# Evitar "番地" en campo de edificio
if building_name != '番地' and building_name != '番地等':
    result['building'] = building_name
```

### Frontend (rirekisho.html)

#### Procesamiento de Fecha
```javascript
// Detectar si ya está en formato japonés
if (textData.birthday.includes('年') && textData.birthday.includes('月')) {
    document.getElementById('birthday').value = textData.birthday;
} else {
    // Convertir de ISO a japonés
    const date = new Date(textData.birthday);
    const japaneseDate = `${year}年${month}月${day}日`;
    document.getElementById('birthday').value = japaneseDate;
}

// Calcular edad con formato japonés
if (textData.birthday.includes('年') && textData.birthday.includes('月')) {
    const match = textData.birthday.match(/(\d{4})年(\d{1,2})月(\d{1,2})日/);
    if (match) {
        dateForCalc = `${match[1]}-${match[2].padStart(2, '0')}-${match[3].padStart(2, '0')}`;
    }
}
```

#### Filtrado de Dirección
```javascript
// Limpiar dirección de información de visa
let cleanAddress = textData.address;
if (cleanAddress.includes('在留資格')) {
    cleanAddress = cleanAddress.split('在留資格')[0].trim();
}
if (cleanAddress.includes('技術') && cleanAddress.includes('人文')) {
    console.log('OCR - Detected visa info in address, skipping');
} else {
    document.getElementById('address').value = cleanAddress;
}
```

## 🚀 Cómo Usar

### Para Extraer Información de Documentos:
1. Sube una imagen de tarjeta de residencia o licencia
2. El sistema extraerá automáticamente:
   - Nombre (kanji y katakana)
   - Fecha de nacimiento (formato japonés)
   - Nacionalidad (específica, no "その他")
   - Dirección (sin información de visa)
   - Foto (recortada a la cara)
   - Información de visa

### Para Instalar Dependencias:
```bash
# Ejecutar para instalar PIL en el contenedor Docker
INSTALL-PIL-DOCKER.bat

# O manualmente:
docker-compose exec backend pip install Pillow>=9.0.0 numpy>=1.21.0
docker-compose restart backend
```

### Para Ver Debug Information:
1. Haz clic en "デバッグモードを切り替え"
2. Sube un documento
3. Revisa la consola del navegador para información detallada

## 📝 Scripts y Herramientas Creadas

1. **INSTALL-PIL-DOCKER.bat**: Instala PIL en el contenedor Docker
2. **backend/test_ocr_debug.py**: Script para depurar resultados del OCR
3. **DEBUG-OCR-INSTRUCCIONES.md**: Guía de depuración

## 🐛 Problemas Conocidos y Soluciones

1. **Fecha muestra 年-月-日 vacío**:
   - Causa: PIL no instalado o patrón no detectado
   - Solución: Ejecutar INSTALL-PIL-DOCKER.bat

2. **Foto muy pequeña o cortada**:
   - Causa: Coordenadas de recorte incorrectas
   - Solución: Coordenadas ajustadas (55%-98% ancho, 5%-65% alto)

3. **Nacionalidad siempre "その他"**:
   - Causa: No se detecta el país en el texto
   - Solución: Búsqueda activa en todo el texto

## 🔮 Mejoras Futuras

1. Implementar Azure Face API para detección precisa de caras
2. Mejorar el parsing de direcciones con IA
3. Soporte para más tipos de documentos
4. Interfaz de corrección manual para datos extraídos