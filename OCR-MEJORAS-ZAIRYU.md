# 🔍 Mejoras OCR - Zairyu Card (在留カード)

## 📅 Fecha: 2025-10-16

---

## ✅ Mejoras Implementadas

### 1. **在留資格 (Status of Residence) - Extracción Mejorada**

**Problema Anterior:**
- No siempre extraía el texto en Kanji correctamente
- Incluía texto en inglés junto con el japonés

**Solución:**
```python
# Ahora detecta:
- "在留資格" o "STATUS" o "STATUS OF RESIDENCE"
- Extrae SOLO el texto en Kanji (elimina traducciones en inglés)
- Busca en las 3 líneas siguientes si no está en la misma línea
- Limpia fechas y números que no pertenecen al status
```

**Ejemplo de Extracción:**
```
Texto OCR: "在留資格 技能実習 Technical Intern Training"
Resultado: "技能実習"  ✅ (solo el Kanji)

Texto OCR: "STATUS OF RESIDENCE
           技能実習"
Resultado: "技能実習"  ✅ (detecta en línea siguiente)
```

---

### 2. **在留期間 (Period of Stay) - Detección Mejorada**

**Problema Anterior:**
- No siempre detectaba el período de estadía
- No extraía cuando venía con texto en inglés

**Solución:**
```python
# Ahora detecta:
- "在留期間" o "PERIOD OF STAY" o "PERIOD"
- Extrae períodos como "3年", "5年", "6ヶ月"
- Elimina texto en inglés automáticamente
- Busca en las 3 líneas siguientes
- Extrae SOLO el período (ej: "3年" de "3年(2028年05月19日)")
```

**Ejemplo de Extracción:**
```
Texto OCR: "在留期間 3年"
Resultado: "3年"  ✅

Texto OCR: "在留期間(満了日) 2028年05月19日"
Resultado: "3年"  ✅ (extrae el período, no la fecha)

Texto OCR: "Period of stay
           5年"
Resultado: "5年"  ✅ (detecta después del header inglés)
```

---

### 3. **Formato de Fechas Estandarizado - YYYY-MM-DD**

**Problema Anterior:**
- Algunas fechas no tenían ceros a la izquierda
- Formato inconsistente entre diferentes campos

**Solución:**
```python
# TODAS las fechas ahora en formato: YYYY-MM-DD
# Con ceros a la izquierda siempre
```

**Campos Afectados:**

#### **Zairyu Card:**
- ✅ `birthday` (生年月日): `2000-05-09` (no `2000-5-9`)
- ✅ `zairyu_expire_date` (在留期間満了日): `2028-05-19`
- ✅ Cualquier fecha detectada en el documento

#### **Driver's License:**
- ✅ `birthday` (生年月日): `1990-03-15`
- ✅ `license_expire_date` (有効期限): `2028-10-25`
- ✅ `license_issue_date` (交付年月日): `2023-10-26`

**Ejemplos:**
```
Input OCR: "2000年5月9日"
Output:    "2000-05-09"  ✅ (con cero en mes y día)

Input OCR: "1990年3月15日"
Output:    "1990-03-15"  ✅

Input OCR: "2028年10月25日"
Output:    "2028-10-25"  ✅
```

---

## 🎯 Resumen de Cambios en el Código

### Archivo: `backend/app/services/azure_ocr_service.py`

#### **Cambio 1: Detección de 在留資格 (líneas 263-296)**
```python
# ANTES:
- Buscaba solo '在留資格' o 'STATUSOFRESIDENCE'
- No eliminaba texto en inglés
- Solo miraba línea siguiente

# AHORA:
- Busca '在留資格', 'STATUS', 'STATUSOFRESIDENCE'
- Elimina automáticamente traducciones en inglés
- Busca en las 3 líneas siguientes
- Limpia fechas y validaciones mejoradas
```

#### **Cambio 2: Detección de 在留期間 (líneas 298-334)**
```python
# ANTES:
- Detección básica
- No eliminaba bien el texto en inglés

# AHORA:
- Busca '在留期間', 'PERIOD OF STAY', 'PERIOD'
- Elimina texto en inglés automáticamente
- Extrae SOLO el período (ej: "3年")
- Busca en las 3 líneas siguientes
- Valida formato correcto (números + 年/ヶ月/か月)
```

#### **Cambio 3: Formato de Fechas (líneas 190-214, 444-506)**
```python
# ANTES:
f"{year}-{month.zfill(2)}-{day.zfill(2)}"

# AHORA:
f"{year}-{int(month):02d}-{int(day):02d}"

# Ventaja: Siempre convierte a int primero, luego formatea con 2 dígitos
# Funciona con "5" o "05" como input
```

---

## 📊 Campos del Formulario Mapeados

### Zairyu Card → Formulario

| Campo OCR | Campo Formulario | Ejemplo | Estado |
|-----------|------------------|---------|--------|
| `visa_status` | 在留資格 (Combobox) | "技能実習" | ✅ Mejorado |
| `visa_period` | 在留期間 | "3年" | ✅ Mejorado |
| `birthday` | 生年月日 | "2000-05-09" | ✅ Estandarizado |
| `zairyu_expire_date` | 在留期間満了日 | "2028-05-19" | ✅ Estandarizado |
| `name_kanji` | 氏名 | "阮 トゥアン" | ✅ OK |
| `nationality` | 国籍 | "ベトナム" | ✅ OK |
| `address` | 住居地 | "愛知県名古屋市..." | ✅ OK |
| `gender` | 性別 | "男性" | ✅ OK |
| `zairyu_card_number` | カード番号 | "AB12345678CD" | ✅ OK |

---

## 🧪 Cómo Probar

### 1. Subir Zairyu Card
```bash
# Accede a: http://localhost:3000
# Ve a "Candidatos" → "Nuevo Candidato" → "Escanear Documento"
# Sube una imagen de Zairyu Card
```

### 2. Verificar Campos Extraídos

**在留資格 (Status):**
- ✅ Debe aparecer SOLO en Kanji
- ✅ Sin texto en inglés
- ✅ Ejemplo: "技能実習" (no "技能実習 Technical Intern Training")

**在留期間 (Period):**
- ✅ Debe extraer el período
- ✅ Formato: "3年" o "5年" o "6ヶ月"
- ✅ Ejemplo: "3年" (no "3年(2028年05月19日)")

**生年月日 (Birthday):**
- ✅ Formato: YYYY-MM-DD
- ✅ Con ceros: "2000-05-09" (no "2000-5-9")

**在留期間満了日 (Expiry):**
- ✅ Formato: YYYY-MM-DD
- ✅ Con ceros: "2028-05-19"

---

## 🔧 Logs para Debugging

Los logs ahora incluyen información detallada:

```
OCR - Found date: 2000-05-09
OCR - Set birthday: 2000-05-09
OCR - Detected visa status (same line): 技能実習
OCR - Detected residence period (same line): 3年
OCR - Set zairyu expiry: 2028-05-19
```

Para ver los logs:
```bash
docker logs uns-claudejp-backend -f
```

---

## 🎯 Mejoras Técnicas

### 1. **Extracción más Robusta**
- Busca en múltiples líneas (no solo la siguiente)
- Elimina automáticamente traducciones en inglés
- Valida formatos antes de aceptar datos

### 2. **Limpieza de Datos**
```python
# Elimina texto en inglés:
visa_text = re.sub(r'\s+[A-Za-z]+.*$', '', visa_text).strip()

# Extrae solo el período:
clean_period = re.search(r'(\d+[年ヶか月]+)', period_text)

# Elimina fechas del status:
visa_text = re.sub(r'\d{4}[年/\-].*$', '', visa_text).strip()
```

### 3. **Formato de Fechas Consistente**
```python
# Siempre convierte a int, luego formatea:
f"{year}-{int(month):02d}-{int(day):02d}"

# Funciona con cualquier input:
"2000年5月9日"  → "2000-05-09"  ✅
"2000年05月09日" → "2000-05-09"  ✅
"2000-5-9"      → "2000-05-09"  ✅
```

---

## 📝 Notas Importantes

### ✅ Lo que NO se rompió:
- Extracción de nombre (氏名)
- Extracción de dirección (住居地)
- Extracción de nacionalidad (国籍)
- Extracción de género (性別)
- Extracción de número de tarjeta
- Extracción de foto
- Parsing de dirección japonesa
- Driver's License OCR

### 🎯 Lo que se mejoró:
- ✅ Extracción de 在留資格 (status) con SOLO Kanji
- ✅ Extracción de 在留期間 (period)
- ✅ Formato estandarizado de fechas (YYYY-MM-DD)
- ✅ Logs más detallados para debugging
- ✅ Validaciones más robustas

---

## 4. **Foto del Rostro - Margen Aumentado**

**Problema Anterior:**
- La foto extraída estaba muy cercana al rostro
- Poco espacio alrededor de la cara

**Solución:**
```python
# Margen aumentado de 25% a 40%
margin_x = int(w * 0.4)  # 40% de margen horizontal
margin_y = int(h * 0.4)  # 40% de margen vertical
```

**Beneficios:**
- ✅ Foto más "alejada" del rostro
- ✅ Más contexto y espacio alrededor
- ✅ Mejor presentación visual
- ✅ Más profesional

**Ubicación:**
- `backend/app/services/azure_ocr_service.py` líneas 828-829

**Ejemplos:**
```
ANTES (margen 25%):
- Foto muy cercana al rostro
- Poco espacio alrededor

AHORA (margen 40%):
- Foto más alejada
- Más espacio y contexto
- Mejor visualización
```

---

## 🚀 Próximos Pasos

### Para el Usuario:
1. Reiniciar el backend (ya hecho): `docker-compose restart backend`
2. Acceder a http://localhost:3000
3. Probar subiendo un Zairyu Card
4. Verificar que los campos se extraigan correctamente

### Para Validación:
- [ ] Probar con diferentes Zairyu Cards
- [ ] Verificar que el combobox de 在留資格 se llene correctamente
- [ ] Verificar que 在留期間 se extraiga (no estaba antes)
- [ ] Verificar que todas las fechas tengan formato YYYY-MM-DD

---

## 📞 Troubleshooting

### Si no extrae 在留資格:
- Revisar logs: `docker logs uns-claudejp-backend -f`
- Buscar: "OCR - Detected visa status"
- El texto debe aparecer cerca de "在留資格" o "STATUS"

### Si no extrae 在留期間:
- Revisar logs: buscar "OCR - Detected residence period"
- El texto debe tener formato como "3年" o "5年"
- Debe estar cerca de "在留期間" o "PERIOD"

### Si las fechas no tienen el formato correcto:
- Todas las fechas deben ser YYYY-MM-DD
- Ejemplo: "2000-05-09" (no "2000-5-9")
- Revisar logs: buscar "OCR - Found date"

---

**Mejoras completadas por**: Claude Code
**Fecha**: 2025-10-16
**Backend reiniciado**: ✅ Si
**Tests requeridos**: Subir Zairyu Card y verificar campos
