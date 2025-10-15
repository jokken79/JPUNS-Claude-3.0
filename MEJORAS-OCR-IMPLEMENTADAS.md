# Mejoras OCR Implementadas - 15 de Octubre 2025

## Problemas Identificados
1. **Dirección mezclada con información de visa**: El OCR extraía "岐阜県中津川市坂下908番地1の2 ADDRESS 在留資格 技術・人文知識・国際業務"
2. **Fecha de nacimiento no detectada**: No se extraía correctamente
3. **Nacionalidad no detectada**: Campo vacío
4. **Foto no extraída**: No se procesaba la foto del documento
5. **Parsing de dirección incorrecto**: No se separaban correctamente los campos

## Soluciones Implementadas

### Actualización 2025-10-?? · Precisión mejorada para 在留カード y 免許証
- ✅ **Detección de 在留資格 más agresiva**: se analizan líneas completas, texto limpio y saltos posteriores para capturar estados de residencia aun cuando el OCR los separe del rótulo.
- ✅ **Alias automáticos para el formulario**: los valores extraídos (氏名, フリガナ, 在留期限, カード番号, etc.) se propagan a los campos del formulario (`full_name_*`, `residence_*`, `license_*`).
- ✅ **OCR de 免許証 reforzado**: se reconocen フリガナ, direcciones multi-línea, fechas de expedición y vencimiento, además de normalizar números de licencia.
- ✅ **Recorte inteligente de foto**: se incorpora detección facial con OpenCV; si no se encuentra rostro se aplica un recorte heurístico optimizado tanto para 在留カード como para 免許証.
- ✅ **Direcciones enriquecidas**: se reusa el parser japonés para poblar 番地 y 建物 cuando estén disponibles.

### 1. Mejoras en `backend/app/services/azure_ocr_service.py`

#### A. Extracción de Fecha de Nacimiento (生年月日)
- **Nuevos patrones de reconocimiento**:
  - `(\d{4})[年/\-\.](\d{1,2})[月/\-\.](\d{1,2})日?` - Formato japonés
  - `(\d{2})[年/\-\.](\d{1,2})[月/\-\.](\d{1,2})日?` - Era japonesa
  - `(\d{4})[/\-\.](\d{1,2})[/\-\.](\d{1,2})` - ISO
  - `(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})` - MM/DD/YYYY
  - `(\d{1,2})[\.](\d{1,2})[\.](\d{4})` - DD.MM.YYYY (europeo)

- **Búsqueda en múltiples líneas**: Si no encuentra en la misma línea, busca en las siguientes 2 líneas
- **Validación de fechas**: Verifica que el mes (1-12) y día (1-31) sean válidos

#### B. Detección de Nacionalidad (国籍)
- **Nueva función `_normalize_nationality`**:
  - Mapeo de variaciones comunes (Vietnam, VIETNAM, Viet Nam, vIETNAN → ベトナム)
  - Soporte para errores comunes de OCR (vietnan → ベトナム)
  - Búsqueda insensible a mayúsculas/minúsculas
  - Soporte para coincidencias parciales

- **Palabras clave mejoradas**: Busca '国籍', 'Nationality', '地域'
- **Búsqueda en línea siguiente**: Si no encuentra en la misma línea, busca en la siguiente

#### C. Extracción de Foto
- **Nueva función `_extract_photo_from_document`**:
  - Convierte la imagen a base64 para uso en frontend
  - Retorna como data URI (`data:image/jpeg;base64,...`)
  - Implementación básica (retorna imagen completa)
  - Preparado para implementación con Face API o Computer Vision

#### D. Parsing de Dirección Mejorado
- **Nuevos patrones para 番地**:
  - `(\d+)番地(\d+)の(\d+)` - 908番地1の2
  - `(\d+)[−\-\s](\d+)[−\-\s](\d+)` - 908-1-2
  - Formateo automático a XXX-X-X

- **Detección de edificios**:
  - `(\d+[−\-\s]*\d+[−\-\s]*\d*\s*)([^0-9]+号室[^0-9]*)` - Con número de habitación
  - `(\d+[−\-\s]*\d+[−\-\s]*\d*\s*)([^0-9]+)` - Solo nombre del edificio

#### E. Filtrado de Información de Visa
- **Detección y separación**: Si la dirección contiene información de visa, la filtra
- **Palabras clave de visa**: '在留資格', '技術', '人文', '国際業務'
- **Limpieza automática**: Divide la dirección antes de '在留資格'

### 2. Mejoras en `frontend/public/templates/rirekisho.html`

#### A. Procesamiento de Dirección
- **Limpieza de dirección**: Filtra información de visa automáticamente
- **Detección de visa**: Si contiene '技術' y '人文', ignora como dirección
- **Búsqueda automática**: Si hay código postal pero no dirección, ejecuta lookupAddress()

#### B. Logging Mejorado
- **Mensajes de depuración**: Registra todas las extracciones del OCR
- **Consola del navegador**: Muestra información detallada del proceso

## Flujo de Mejorado

### Para Direcciones:
1. OCR extrae texto crudo
2. Sistema filtra información de visa
3. Parsea componentes: prefectura, ciudad, banchi, edificio
4. Llena campos correspondientes
5. Si hay código postal, busca dirección automáticamente

### Para Nacionalidad:
1. OCR busca '国籍', 'Nationality', '地域'
2. Extrae texto de la misma o siguiente línea
3. Normaliza a formato japonés (ベトナム, 中国, etc.)
4. Si no encuentra mapeo, usa texto original

### Para Fecha de Nacimiento:
1. OCR busca '生年月日', 'Date of birth', '誕生日', '誕生', '生年'
2. Prueba múltiples patrones de fecha
3. Valida día y mes
4. Formatea a YYYY-MM-DD

### Para Foto:
1. OCR procesa imagen completa
2. Convierte a base64
3. Retorna como data URI
4. Frontend muestra en campo de foto

## Pruebas Recomendadas

1. **Probar con documento real**: Subir una tarjeta de residencia
2. **Verificar logs**: Revisar consola del navegador para mensajes de depuración
3. **Comprobar campos**: Asegurar que todos los campos se llenen correctamente
4. **Test de dirección**: Probar con direcciones complejas como "岐阜県中津川市坂下908番地1の2メゾン徳川101号室"

## Próximos Pasos

1. **Implementar Face API**: Para extracción precisa de fotos
2. **Mejorar patrones**: Agregar más variaciones de fechas y direcciones
3. **Testing extensivo**: Probar con diferentes tipos de documentos
4. **Optimización**: Mejorar velocidad de procesamiento

## Notas Importantes

- Los errores de Pylance en el archivo son esperados (relacionados con tipos de Azure SDK)
- El sistema ahora es más robusto y maneja errores comunes de OCR
- Los logs están habilitados para facilitar depuración
- El frontend filtra automáticamente información no deseada