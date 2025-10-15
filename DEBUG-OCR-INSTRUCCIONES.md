# Instrucciones para Depurar OCR - 15 de Octubre 2025

## Problema Reportado
El usuario subió una captura de pantalla mostrando los resultados del OCR. Como no puedo ver la imagen directamente, he implementado herramientas adicionales para depurar.

## Herramientas de Depuración Implementadas

### 1. Script de Depuración (`backend/test_ocr_debug.py`)
Este script permite analizar los resultados del OCR en detalle:

```bash
# Ejecutar desde el directorio backend
cd backend
python test_ocr_debug.py
```

El script mostrará:
- Todos los campos extraídos por el OCR
- El texto completo reconocido
- Los componentes de la dirección parseada
- Cualquier error encontrado

### 2. Logging Mejorado en el Servicio OCR
- Se agregaron logs detallados para cada paso del parsing
- Se muestra el texto crudo de cada línea
- Se registran todas las fechas encontradas
- Se registra la información de dirección extraída

## Pasos para Depurar

### Paso 1: Ejecutar el Script de Depuración
1. Abre una terminal en el directorio del proyecto
2. Navega al directorio backend
3. Ejecuta el script:
   ```bash
   cd backend
   python test_ocr_debug.py
   ```

### Paso 2: Analizar los Resultados
El script mostrará:
```
=== RESULTADO OCR ===
Success: True/False

--- CAMPOS EXTRAÍDOS ---
name_kanji: [valor o NO ENCONTRADO]
name_kana: [valor o NO ENCONTRADO]
birthday: [valor o NO ENCONTRADO]
age: [valor o NO ENCONTRADO]
gender: [valor o NO ENCONTRADO]
nationality: [valor o NO ENCONTRADO]
address: [valor o NO ENCONTRADO]
postal_code: [valor o NO ENCONTRADO]
banchi: [valor o NO ENCONTRADO]
building: [valor o NO ENCONTRADO]
visa_status: [valor o NO ENCONTRADO]
zairyu_card_number: [valor o NO ENCONTRADO]
zairyu_expire_date: [valor o NO ENCONTRADO]

--- TEXTO COMPLETO OCR ---
[texto completo extraído por el OCR]

--- DIRECCIÓN PARSEADA ---
postal_code: [valor]
prefecture: [valor]
city: [valor]
ward: [valor]
district: [valor]
banchi: [valor]
building: [valor]
```

### Paso 3: Identificar Problemas
Busca en la salida:
1. **Campos con "NO ENCONTRADO"**: Estos campos no se extrajeron correctamente
2. **Texto completo OCR**: Revisa si el texto fue reconocido correctamente
3. **Dirección parseada**: Verifica si los componentes se separaron correctamente

## Problemas Comunes y Soluciones

### Problema 1: Fecha no encontrada
**Síntoma**: `birthday: NO ENCONTRADO`
**Causa**: El OCR no reconoció el patrón de fecha
**Solución**: 
- Revisa el texto completo para ver si la fecha está presente
- Si está presente pero en formato diferente, agrega el patrón a `date_patterns`

### Problema 2: Nacionalidad no encontrada
**Síntoma**: `nationality: NO ENCONTRADO`
**Causa**: La palabra "国籍" no fue encontrada o el texto está en una línea diferente
**Solución**:
- Revisa si la nacionalidad aparece en el texto completo
- Si está pero no se detectó, podría necesitar ajustar los patrones de búsqueda

### Problema 3: Dirección mezclada con visa
**Síntoma**: `address: 岐阜県中津川市坂下908番地1の2 ADDRESS 在留資格 技術・人文知識・国際業務`
**Causa**: El OCR extrajo too mucho texto
**Solución**: Ya implementamos filtrado automático, pero si persiste:
- Revisa los logs para ver si el filtrado está funcionando
- Podría necesitar ajustar las palabras clave de filtrado

## Si los Problemas Persisten

### Opción 1: Ver Logs del Servidor
```bash
# Ver logs del backend mientras procesas un documento
docker-compose logs -f backend
```

### Opción 2: Probar con Imagen Específica
Si tienes una imagen específica que quieres probar:
```bash
# Copia la imagen al directorio uploads
cp "ruta/a/tu/imagen.png" backend/uploads/

# Ejecuta el script de depuración
cd backend
python test_ocr_debug.py
```

### Opción 3: Modo Debug en Frontend
1. Abre el formulario rirekisho en el navegador
2. Presiona F12 para abrir DevTools
3. Ve a la pestaña Console
4. Activa el debug mode: Haz clic en "デバッグモードを切り替え"
5. Sube el documento y revisa los logs en la consola

## Información a Proporcionar

Si necesitas ayuda adicional, por favor proporciona:
1. La salida completa del script `test_ocr_debug.py`
2. El texto completo que muestra el OCR
3. Una descripción de qué campos deberían tener valores pero no los tienen
4. Si es posible, la imagen original (puedes subirla a un servicio como imgur y compartir el enlace)

## Mejoras Recientes Implementadas

1. **Extracción de fechas mejorada**: Ahora busca fechas en todo el texto, no solo cerca de palabras clave
2. **Filtrado de dirección**: Elimina automáticamente información de visa de la dirección
3. **Logging detallado**: Cada paso del proceso es registrado
4. **Script de depuración**: Herramienta independiente para analizar resultados