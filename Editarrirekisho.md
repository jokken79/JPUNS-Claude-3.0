# 🎯 Soluciones Disponibles para Editar Visualmente el Layout de Rirekisho.html

## 1. Live Server + DevTools (RECOMENDADO)
Esta es la mejor opción para ver cambios en tiempo real:

### Pasos:
1. **Instala Live Server en VS Code:**
   - Abre VS Code
   - Ve a Extensions (Ctrl+Shift+X)
   - Busca "Live Server" de Ritwick Dey
   - Instala

2. **Abre el archivo HTML:**
   - `frontend/public/templates/rirekisho.html`

3. **Inicia Live Server:**
   - Click derecho en el archivo → "Open with Live Server"
   - O click en "Go Live" en la barra inferior de VS Code

4. **Usa Chrome DevTools:**
   - Abre Chrome DevTools (F12)
   - Click derecho en cualquier elemento → "Inspect"
   - Edita el HTML en tiempo real en la pestaña "Elements"
   - Arrastra elementos dentro del DOM tree
   - Los cambios se ven instantáneamente en el navegador

5. **Copia el código resultante:**
   - Una vez que tengas el diseño que quieres
   - Click derecho en el elemento padre → "Copy" → "Copy outerHTML"
   - Pega en VS Code

## 2. Extensiones VS Code Útiles (no son drag-and-drop, pero ayudan)

### HTML Preview (para vista previa básica)
- **Buscar en Extensions**
- Nombre: HTML Preview
- ID: tht13.html-preview-vscode
- Muestra preview del HTML dentro de VS Code
- No es interactivo, pero ves cambios al guardar

### HTML Table Generator (para crear/editar tablas)
- Nombre: Table Formatter
- ID: shuworks.vscode-table-formatter
- Te ayuda a formatear tablas automáticamente
- No es visual, pero mantiene el código organizado

## 3. Editor WYSIWYG Externo (Más Visual)
Si necesitas algo más visual, puedes usar editores online:

### CodePen
- Ve a https://codepen.io/pen/
- Pega tu código HTML en la sección HTML
- Pega los estilos CSS en la sección CSS
- Edita visualmente viendo los cambios en tiempo real
- Copia el código final de vuelta a VS Code

### JSFiddle
- Similar a CodePen: https://jsfiddle.net/

## 4. Método Manual (El que yo uso)
Para tablas complejas como la tuya, te recomiendo este flujo de trabajo:

1. **Abre el archivo HTML en VS Code**

2. **Dibuja primero en papel o en una herramienta de diseño:**
   - Sketch
   - Figma
   - O simplemente Excel (para ver la estructura de la tabla)

3. **Usa comentarios HTML para organizar:**
```html
<!-- ========== FILA 1: INFORMACIÓN PERSONAL ========== -->
<tr>
    <!-- Columna 1: Nombre -->
    <td>...</td>
    <!-- Columna 2: Foto -->
    <td>...</td>
</tr>

<!-- ========== FILA 2: DOCUMENTOS ========== -->
<tr>
    ...
</tr>
```

4. **Edita el código con VS Code con estas extensiones útiles:**
   - Better Comments (hace que los comentarios se vean con colores)
   - Bracket Pair Colorizer (colorea las etiquetas HTML)
   - Auto Rename Tag (renombra automáticamente etiquetas de cierre)

## 🎨 Ejemplo Práctico: Cómo Mover una Columna
Si quieres mover, por ejemplo, la foto de un lado a otro:

**Antes (Foto a la derecha):**
```html
<tr>
    <td class="label-th">氏名</td>
    <td class="value-td">${data.name_kanji}</td>
    <td rowspan="3" class="photo-cell">
        <img src="${data.photo}">
    </td>
</tr>
```

**Después (Foto a la izquierda):**
```html
<tr>
    <td rowspan="3" class="photo-cell">
        <img src="${data.photo}">
    </td>
    <td class="label-th">氏名</td>
    <td class="value-td">${data.name_kanji}</td>
</tr>
```

Solo cortas y pegas el bloque `<td>` de la foto antes de los demás.

## 📋 Mi Recomendación Personal
Para tu caso específico con rirekisho.html:
1. Usa Live Server + Chrome DevTools (opción 1)
2. Llena el formulario con datos de prueba primero
3. Click en "プレビュー" para ver el PDF
4. Inspecciona con DevTools (F12)
5. Mueve elementos arrastrando en el DOM tree de DevTools
6. Copia el HTML resultante cuando te guste el resultado
7. Pega en VS Code en la función `generatePrintHTML()`

## 🚀 ¿Quieres que te ayude a mover algo específico?
Dime qué columnas o secciones quieres reordenar y te muestro exactamente qué código copiar/pegar. Por ejemplo:
- "Quiero la foto a la izquierda en lugar de la derecha"
- "Quiero que 'Familia' aparezca antes de 'Experiencia Laboral'"
- "Quiero cambiar el orden de los campos en la sección de documentos"

¿Qué columnas o campos quieres mover?
