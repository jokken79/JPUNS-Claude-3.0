# 📝 GUÍA RÁPIDA - USO DE ARCHIVOS CANDIDATOS

## 🎯 ¿QUÉ ARCHIVO USAR CUANDO?

### **🆕 QUIERO REGISTRAR UN CANDIDATO NUEVO**
**USAR:** `Candidates.tsx`  
**RUTA:** http://localhost:3000/candidates  
**CARACTERÍSTICAS:**
- Formulario HTML completo japonés
- Sistema OCR automático
- Conversión Romaji → Katakana
- Perfecto para registro desde cero

### **📋 QUIERO VER TODOS LOS CANDIDATOS**
**USAR:** `CandidatesList.tsx`  
**RUTA:** http://localhost:3000/candidates/list  
**CARACTERÍSTICAS:**
- Vista grid con fotos
- Búsqueda inteligente
- Filtros por status
- Paginación
- Botones Ver/Editar/Imprimir

### **✏️ QUIERO EDITAR UN CANDIDATO EXISTENTE**
**USAR:** `CandidateEdit.tsx`  
**RUTA:** http://localhost:3000/candidates/123/edit  
**CARACTERÍSTICAS:**
- Formulario React moderno
- Campo por campo editable
- OCR opcional
- Validación completa

### **🖨️ QUIERO IMPRIMIR RIREKISHO**
**USAR:** `RirekishoPrintView.tsx`  
**RUTA:** http://localhost:3000/candidates/123/print  
**CARACTERÍSTICAS:**
- Formato japonés oficial
- Optimizado para impresión
- Vista previa completa

---

## 🔄 NAVEGACIÓN TÍPICA

```
1. 🏠 Dashboard 
   ↓ [Click "候補者管理"]
2. 🆕 /candidates (Registro)
   ↓ [Después de registrar]
3. 📋 /candidates/list (Lista)
   ↓ [Click "編集" en candidato]  
4. ✏️ /candidates/123/edit (Editar)
   ↓ [Click "印刷"]
5. 🖨️ /candidates/123/print (Imprimir)
```

---

## 🛠️ BUILDER EXTENSION - ¿QUÉ MODIFICAR?

### **MODIFICAR FORMULARIO DE REGISTRO:**
- **Archivo:** `Candidates.tsx`
- **Método:** Builder Extension
- **Pasos:** `Ctrl+Shift+P` → "Builder: Open File" → `Candidates.tsx`

### **MODIFICAR LISTA DE CANDIDATOS:**
- **Archivo:** `CandidatesList.tsx`  
- **Método:** Builder Extension o código directo
- **Componentes:** Tarjetas, búsqueda, filtros

### **MODIFICAR FORMULARIO DE EDICIÓN:**
- **Archivo:** `CandidateEdit.tsx`
- **Método:** Código directo (formulario React)
- **Componentes:** Campos, validación, OCR

---

## ⚡ ACCESO RÁPIDO

```bash
# Ver estructura actual:
ls frontend/src/pages/Candidate*

# Archivos importantes:
- Candidates.tsx      (🆕 Registro)
- CandidatesList.tsx  (📋 Lista) 
- CandidateEdit.tsx   (✏️ Editar)
```

**✅ TODO ORGANIZADO Y DOCUMENTADO**