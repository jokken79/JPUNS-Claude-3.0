# 🔍 Detección de Rostros Mejorada - UNS-ClaudeJP 3.0

## 📅 Fecha: 2025-10-16

---

## ⚠️ PROBLEMA REPORTADO

**Usuario**: "NO estás reconociendo el rostro de la persona! Ahora cambié de documento y solo me sale otra parte del documento. ¿Estás reconociendo el rostro? ¿Qué tipo de OCR estás usando?"

**Síntoma**:
- La extracción de foto NO detecta el rostro
- Extrae partes incorrectas del documento
- La foto extraída no muestra la cara de la persona

---

## 🔬 DIAGNÓSTICO

### Sistema de Detección Actual:

El sistema usa **2 métodos** para extraer la foto:

#### **Método 1: OpenCV Face Detection (Haar Cascade)** ⭐ PREFERIDO
- Usa algoritmo de detección de rostros de OpenCV
- Detecta automáticamente dónde está la cara
- Extrae la región del rostro con margen

#### **Método 2: Fallback Heurístico** (coordenadas fijas)
- Si OpenCV NO detecta rostro, usa coordenadas predefinidas
- **Zairyu Card**: 22-80% altura, 62-93% ancho (esquina superior derecha)
- **License**: 20-78% altura, 5-35% ancho (esquina superior izquierda)

### El Problema:
- OpenCV probablemente NO está detectando rostros
- El sistema cae en el **fallback heurístico**
- Las coordenadas fijas NO coinciden con tu documento

---

## ✅ SOLUCIÓN IMPLEMENTADA

### 1. **Parámetros de Detección Más Sensibles**

**ANTES:**
```python
faces = face_cascade.detectMultiScale(
    gray,
    scaleFactor=1.1,      # Menos sensible
    minNeighbors=5,       # Más estricto
    minSize=(80, 80)      # Rostros más grandes
)
```

**AHORA:**
```python
faces = face_cascade.detectMultiScale(
    gray,
    scaleFactor=1.05,     # MÁS SENSIBLE (detecta mejor)
    minNeighbors=3,       # MENOS ESTRICTO (más permisivo)
    minSize=(50, 50)      # ROSTROS MÁS PEQUEÑOS
)
```

**Beneficios:**
- ✅ Detecta rostros más pequeños
- ✅ Más tolerante con la calidad de imagen
- ✅ Mayor probabilidad de encontrar el rostro

---

### 2. **Logs Detallados para Debugging**

Ahora el sistema genera logs completos:

```python
logger.info(f"OCR - Attempting face detection with OpenCV for {document_type}")
logger.info(f"OCR - Cascade path: {cascade_path}, exists: {cascade_path.exists()}")
logger.info(f"OCR - Face detection found {len(faces)} faces")
logger.info(f"OCR - Selected face: x={x}, y={y}, w={w}, h={h}")
logger.info(f"OCR - ✅ FACE DETECTED for {document_type} (x1={x1}, y1={y1}, x2={x2}, y2={y2})")
logger.warning(f"OCR - ⚠️ NO FACES DETECTED by OpenCV, will use fallback")
logger.warning(f"OCR - ⚠️ OpenCV (cv2) not available")
```

---

## 🔍 CÓMO VERIFICAR SI FUNCIONA

### Paso 1: Ver Logs del Backend

```bash
docker logs uns-claudejp-backend -f
```

### Paso 2: Subir un Documento con Foto

1. Ve a http://localhost:3000
2. Crea un candidato
3. Sube una Zairyu Card o License con foto

### Paso 3: Buscar en los Logs

#### ✅ SI DETECTA ROSTRO:
```
OCR - Attempting face detection with OpenCV for zairyu_card
OCR - Cascade path: /usr/local/lib/.../haarcascade_frontalface_default.xml, exists: True
OCR - Face detection found 1 faces
OCR - Selected face: x=500, y=200, w=150, h=180
OCR - ✅ FACE DETECTED for zairyu_card (x1=440, y1=128, x2=710, y2=452)
```
**Resultado**: ✅ La foto extraída será del ROSTRO con margen de 40%

#### ⚠️ SI NO DETECTA ROSTRO:
```
OCR - Attempting face detection with OpenCV for zairyu_card
OCR - Cascade path: /usr/local/lib/.../haarcascade_frontalface_default.xml, exists: True
OCR - Face detection found 0 faces
OCR - ⚠️ NO FACES DETECTED by OpenCV for zairyu_card, will use fallback
OCR - Fallback zairyu photo crop applied
```
**Resultado**: ⚠️ Usará coordenadas fijas (puede extraer la parte incorrecta)

---

## 🛠️ QUÉ TIPO DE OCR ESTAMOS USANDO

### Para TEXTO (datos del documento):
**Azure Computer Vision API**
- Servicio de Microsoft Azure
- OCR profesional con IA
- Extrae texto en japonés, inglés, números
- Muy preciso para documentos oficiales

### Para ROSTROS (detección facial):
**OpenCV Haar Cascade Classifier**
- Algoritmo de detección de rostros
- Open source, no requiere API externa
- Detecta rostros frontales en imágenes
- Versión instalada: **OpenCV 4.12.0** ✅

---

## 📊 Parámetros de Detección Explicados

### `scaleFactor=1.05`
- **Qué hace**: Escala la imagen en cada paso de detección
- **1.05**: Más sensible, detecta mejor rostros pequeños
- **1.1**: Menos sensible, más rápido pero puede fallar

### `minNeighbors=3`
- **Qué hace**: Cuántas detecciones vecinas debe haber para confirmar un rostro
- **3**: Menos estricto, acepta más fácilmente
- **5**: Más estricto, solo rostros muy claros

### `minSize=(50, 50)`
- **Qué hace**: Tamaño mínimo del rostro a detectar (en píxeles)
- **(50, 50)**: Detecta rostros pequeños
- **(80, 80)**: Solo rostros más grandes

---

## 🔧 TROUBLESHOOTING

### Problema 1: Sigue sin detectar rostro

**Posibles causas:**
1. **Calidad de imagen baja**: Foto borrosa, muy oscura, o pixelada
2. **Rostro de perfil**: Haar Cascade solo detecta rostros frontales
3. **Tamaño muy pequeño**: Rostro menor a 50x50 píxeles
4. **Oclusión**: Rostro parcialmente cubierto

**Soluciones:**
```python
# Hacer aún MÁS sensible (línea 829):
faces = face_cascade.detectMultiScale(
    gray,
    scaleFactor=1.03,     # MUY sensible
    minNeighbors=2,       # MUY permisivo
    minSize=(40, 40)      # Rostros muy pequeños
)
```

---

### Problema 2: Detecta múltiples rostros

**Síntoma**: Log muestra "Face detection found 3 faces"

**Solución**: El sistema ya toma el rostro MÁS GRANDE automáticamente
```python
# Ya implementado (línea 833):
x, y, w, h = max(faces, key=lambda rect: rect[2] * rect[3])
```

---

### Problema 3: Extrae área incorrecta

**Si sigue usando fallback**, ajustar coordenadas heurísticas:

#### Para Zairyu Card (líneas 849-854):
```python
# Valores actuales (esquina superior derecha):
y1 = int(height * 0.22)  # 22% desde arriba
y2 = int(height * 0.80)  # 80% desde arriba
x1 = int(width * 0.62)   # 62% desde izquierda
x2 = int(width * 0.93)   # 93% desde izquierda
```

**Ajustar según tu documento:**
- Si la foto está más arriba: reducir `y1` (ej: 0.15)
- Si está más abajo: aumentar `y1` (ej: 0.30)
- Si está más a la izquierda: reducir `x1` (ej: 0.50)
- Si está más a la derecha: aumentar `x1` (ej: 0.70)

---

## 📈 MEJORAS IMPLEMENTADAS

### Cambio 1: Parámetros Más Sensibles
- **Ubicación**: `backend/app/services/azure_ocr_service.py` línea 829
- **Antes**: `scaleFactor=1.1, minNeighbors=5, minSize=(80, 80)`
- **Ahora**: `scaleFactor=1.05, minNeighbors=3, minSize=(50, 50)`

### Cambio 2: Logs Detallados
- **Ubicación**: `backend/app/services/azure_ocr_service.py` líneas 819-853
- **Nuevo**: 7 mensajes de log para debugging
- **Beneficio**: Saber exactamente si detecta rostro o usa fallback

### Cambio 3: Backend Reiniciado
- ✅ Cambios aplicados
- ✅ OpenCV verificado (versión 4.12.0)

---

## 🎯 PRÓXIMOS PASOS

### 1. Probar con tu Documento
1. Subir Zairyu Card o License
2. Revisar logs del backend
3. Ver si dice "✅ FACE DETECTED" o "⚠️ NO FACES DETECTED"

### 2. Si Sigue Fallando
**Envíame los logs con:**
```bash
docker logs uns-claudejp-backend | grep "OCR -"
```

**Y dime:**
- ¿Qué tipo de documento? (Zairyu Card / License)
- ¿La foto está de frente o de perfil?
- ¿Es una foto clara o borrosa?
- ¿Qué parte del documento extrae?

### 3. Ajustes Adicionales
Si necesario, puedo:
- Hacer parámetros AÚN más sensibles
- Agregar detección de rostros de perfil
- Usar un modelo de detección diferente (DNN)
- Ajustar coordenadas fallback para tu documento específico

---

## 📋 RESUMEN TÉCNICO

### OCR de Texto:
- **Servicio**: Azure Computer Vision Read API
- **Función**: Extraer texto del documento
- **Precisión**: Alta para documentos oficiales japoneses

### Detección de Rostro:
- **Librería**: OpenCV 4.12.0
- **Algoritmo**: Haar Cascade (haarcascade_frontalface_default.xml)
- **Función**: Detectar y extraer foto del rostro
- **Mejoras**: Parámetros más sensibles + logs detallados

### Fallback:
- **Trigger**: Si OpenCV no detecta rostro
- **Método**: Coordenadas fijas por tipo de documento
- **Limitación**: Puede extraer área incorrecta si documento tiene layout diferente

---

## ✅ CHECKLIST DE VERIFICACIÓN

- [x] OpenCV instalado (versión 4.12.0)
- [x] Parámetros de detección mejorados (scaleFactor=1.05, minNeighbors=3, minSize=(50,50))
- [x] Logs detallados agregados
- [x] Backend reiniciado
- [ ] **PENDIENTE**: Probar con documento real
- [ ] **PENDIENTE**: Verificar logs de detección
- [ ] **PENDIENTE**: Confirmar que extrae rostro correctamente

---

## 📞 CÓMO REPORTAR RESULTADOS

**Si funciona:**
✅ "Ahora SÍ detecta el rostro correctamente"

**Si no funciona, compartir:**
1. Logs de detección (buscar "OCR - Face detection")
2. Tipo de documento (Zairyu Card / License)
3. Descripción de qué parte extrae
4. Si es posible, características de la foto (frontal/perfil, clara/borrosa)

---

**Implementado por**: Claude Code
**Fecha**: 2025-10-16
**Versión**: UNS-ClaudeJP 3.0
**Estado**: ✅ Desplegado, esperando pruebas
