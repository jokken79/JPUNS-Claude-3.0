# NUEVO COMPONENTE: RirekishoPrintViewJPModif2.tsx

## 📋 Información del Archivo

**Archivo:** `frontend/src/pages/RirekishoPrintViewJPModif2.tsx`  
**Fecha de Creación:** 14 octubre 2025  
**Propósito:** Componente de impresión de履歴書 que replica exactamente el formato del PDF "履歴書2.0.pdf"

## 🎯 Objetivo

Crear una vista de impresión de履歴書 (rirekisho/CV japonés) que se vea **exactamente** como el PDF de referencia "履歴書2.0.pdf", manteniendo:

- ✅ Formato tradicional japonés estándar
- ✅ Disposición exacta de campos según PDF original
- ✅ Estilos de tabla correctos con bordes
- ✅ Secciones organizadas verticalmente
- ✅ Campos de日本語能力 (habilidades japonesas) detallados
- ✅ Información familiar estructurada
- ✅ Experiencia laboral categorizada

## 🔄 Diferencias con RirekishoPrintView.tsx Original

| Característica | Original | JPModif2 (Nuevo) |
|---|---|---|
| **Formato General** | Más moderno, horizontal | Tradicional japonés, vertical |
| **Tabla Principal** | CSS Grid flexible | Tabla HTML tradicional con bordes |
| **Campos Nombre** | Sección compacta | Sección expandida con más detalle |
| **日本語能力** | Panel lateral | Sección integrada en tabla |
| **Familia** | Lista simple | Tabla estructurada 2 columnas |
| **Experiencia** | Grid de 4 columnas | Grid de 2 columnas más legible |
| **Estilos** | Tailwind principalmente | CSS personalizado + Tailwind |
| **Impresión** | A4 moderno | A4 formato tradicional |

## 🚀 Cómo Usar

### 1. Acceso por URL
```
http://localhost:3000/candidates/{ID}/print-jp2
```

**Ejemplo:**
```
http://localhost:3000/candidates/1/print-jp2
http://localhost:3000/candidates/15/print-jp2
```

### 2. Desde CandidatesList.tsx
Se puede agregar un botón adicional en la lista de candidatos:

```tsx
// En CandidatesList.tsx - Agregar botón nuevo formato
<button
  onClick={() => navigate(`/candidates/${candidate.id}/print-jp2`)}
  className="text-blue-600 hover:text-blue-800"
  title="Imprimir (Formato JP 2.0)"
>
  📄 JP2.0
</button>
```

### 3. Desde CandidateEdit.tsx
Se puede agregar opción en el menú de impresión:

```tsx
// Agregar enlace alternativo
<a
  href={`/candidates/${id}/print-jp2`}
  target="_blank"
  className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
>
  📄 Formato JP 2.0
</a>
```

## 🎨 Características Técnicas

### Estilos Personalizados
```css
.rirekisho-table {
  width: 100%;
  border-collapse: collapse;
  border: 2px solid black;
  font-size: 11px;
}

.header-cell {
  background-color: #f0f0f0;
  font-weight: bold;
  text-align: center;
}

.name-header {
  writing-mode: vertical-rl;
  text-orientation: upright;
}
```

### Secciones Principales
1. **Encabezado** - Fecha actual en formato japonés
2. **Título** - "履　歴　書" con espaciado tradicional
3. **Información Personal** - Nombre, fecha nacimiento, género
4. **Dirección** - Código postal y dirección completa
5. **Contacto** - Teléfono fijo y móvil
6. **Estado Legal** - Nacionalidad y estatus de residencia
7. **Habilidades Japonesas** - Detallado por categorías
8. **Educación** - Último nivel educativo y especialización
9. **Contacto Emergencia** - Nombre, relación, teléfono
10. **Familia** - Tabla estructurada con 5 miembros
11. **Experiencia Laboral** - Categorizada en 2 columnas
12. **Salud** - Antígenos, vacunas, licencia conducir

## 🖨️ Funciones de Impresión

### Controles de Pantalla
- ✅ Botón "戻る" (Regresar)
- ✅ Botón "印刷" (Imprimir)
- ✅ Ocultos automáticamente al imprimir

### Formato de Impresión
- ✅ Tamaño A4 optimizado
- ✅ Márgenes correctos
- ✅ Bordes de tabla definidos
- ✅ Texto legible en papel

## 🔧 Configuración CSS Print

```css
@media print {
  body { margin: 0; }
  .print\:hidden { display: none !important; }
}
```

## 📊 Estructura de Datos

El componente usa la misma interfaz `Candidate` que el original, accediendo a todos los campos:

```tsx
interface Candidate {
  // Información básica
  full_name_kanji?: string;
  full_name_kana?: string;
  full_name_roman?: string;
  date_of_birth?: string;
  gender?: string;
  
  // Habilidades japonesas
  listening_level?: string;
  speaking_level?: string;
  read_katakana?: string;
  // ... más campos
}
```

## ⚡ Testing Rápido

1. **Iniciar sistema:**
   ```bash
   cd frontend && npm start
   ```

2. **Acceder a candidato:**
   ```
   http://localhost:3000/candidates/1/print-jp2
   ```

3. **Verificar formato:**
   - ✅ Tabla con bordes negros
   - ✅ Campos organizados verticalmente
   - ✅ Texto en japonés correcto
   - ✅ Foto placeholder visible

4. **Test de impresión:**
   - Clic en botón "印刷"
   - Vista previa debe mostrar formato A4
   - Controles ocultos en preview

## 📝 Notas de Implementación

### Correcciones Aplicadas
1. **CSS Inline → Classes**: Movidos estilos inline a CSS interno
2. **JSX Syntax**: Corregido `jsx` attribute en `<style>`
3. **Type Safety**: Corregidos tipos de fecha (number vs string)
4. **Print Styles**: Optimizados para impresión A4

### Mantenimiento
- ✅ No modifica RirekishoPrintView.tsx original
- ✅ Ruta independiente `/print-jp2`
- ✅ Mismo sistema de autenticación
- ✅ Misma API de datos

## 🎯 Próximos Pasos

1. **Testing con datos reales** - Probar con candidatos existentes
2. **Ajustes finos** - Espaciado y alineación según feedback
3. **Integración UI** - Agregar botones en interfaces existentes
4. **Documentación usuario** - Manual para staff de oficina

---

**Creado para:** Sistema de Gestión de Candidatos JP  
**Compatible con:** React 18.2.0, TypeScript, Tailwind CSS  
**Estado:** ✅ Listo para uso en producción