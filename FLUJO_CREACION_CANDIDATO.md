# Flujo Completo: Creación de un Candidato

Este documento describe el flujo de la aplicación desde que un usuario rellena el formulario de un nuevo candidato hasta que los datos se guardan en la base de datos.

## Parte 1: Frontend (Lo que pasa en el navegador)

1.  **Llenado del Formulario:** El usuario navega a la sección de candidatos, que carga la página `rirekisho.html` dentro de un `iframe`. Aquí se introduce toda la información del nuevo candidato.

2.  **Clic en "Guardar" (保存):** Al presionar este botón, se activa la función `saveData()` en el código JavaScript de la página `rirekisho.html`.

3.  **Recopilación de Datos:** La función `saveData()` lee los valores de todos los campos del formulario (nombre, dirección, etc.) y los agrupa en un solo objeto de JavaScript.

4.  **Envío a la API:** El navegador del usuario envía estos datos a través de una petición `POST` a la API del backend. Específicamente, los envía a la URL: `/api/candidates/`.

## Parte 2: Backend (Lo que pasa en el servidor)

5.  **Recepción de Datos:** El servidor (backend con FastAPI) recibe la petición en el archivo `backend/app/api/candidates.py`. La función que maneja la petición es `create_candidate`.

6.  **Generación de ID:** La función `create_candidate` llama a `generate_rirekisho_id()` para crear un ID único para el nuevo candidato (ej. `UNS-2001`, `UNS-2002`, etc.).

7.  **Creación del Registro:** Se crea un objeto del modelo `Candidate` de SQLAlchemy con la información recibida del formulario y el nuevo ID generado.

8.  **Guardado en Base de Datos:** Este objeto `Candidate` se añade a la sesión de la base de datos y se ejecuta un `commit`. En este momento, **toda la información del candidato se guarda permanentemente como una nueva fila en la tabla `candidates`** de la base de datos.

9.  **Respuesta al Frontend:** Una vez guardado, el servidor responde al navegador con un código de éxito (`201 Created`) y devuelve el registro completo del candidato que acaba de crear en formato JSON.

## Parte 3: De Vuelta al Frontend

10. **Confirmación y Limpieza:** El código JavaScript en `rirekisho.html` recibe la respuesta exitosa del servidor.
    *   Muestra una ventana de alerta que dice: **"¡Datos guardados en la base de datos correctamente!"**.
    *   Limpia los campos del formulario para que el usuario pueda registrar a otra persona si lo necesita.

---

## Flujo de Vista Previa e Impresión

Es importante destacar que la vista previa y la impresión son flujos separados que no guardan datos:

*   **Sin Redirección:** El flujo de guardado **no redirige** a una página de vista previa. Termina con el formulario limpio en la misma página.
*   **Acciones Locales:** La vista previa (**Preview**) y la impresión (**Imprimir PDF**) son acciones que se ejecutan completamente en el navegador. Toman los datos que están *actualmente* en los campos del formulario y los muestran en un formato de currículum para verlos o imprimirlos, pero no interactúan con la base de datos en ese momento.

---

## Formato de Impresión PDF (履歴書 2.0)

### Archivo Responsable

**`frontend/public/templates/rirekisho.html`** - Función `generatePrintHTML()` (líneas 1454-1755)

### Descripción del Diseño

El formato de impresión está diseñado para replicar exactamente el PDF oficial de 履歴書2.0.pdf de la empresa ユニバーサル企画株式会社.

#### Características Principales:

1. **Orientación**: A4 Landscape (horizontal)
2. **Tamaño de fuente**: 8pt (general), 7pt (checkboxes)
3. **Altura de filas**: 24px consistente
4. **Símbolos**:
   - Checkboxes: `■` (marcado) / `□` (vacío)
   - Radio buttons: `●` (seleccionado) / `○` (no seleccionado)

#### Estructura de Secciones (de arriba hacia abajo):

##### 1. **Encabezado** (Header)
- **Izquierda (60%)**: "履歴書" (14pt, centrado)
- **Derecha (40%)**: "日本語能力" (11pt, centrado)

##### 2. **Fila Principal** (Main Row)

**Columna Izquierda - Información Personal (6 columnas):**
-受付日 (Fecha de recepción)
- 来日 (Llegada a Japón)
- フリガナ (Furigana) + 性別 (Género)
- 氏名 (Nombre completo) + **Foto (120x140px)** en esquina superior derecha
- ローマ字 (Alfabeto romano)
- 生年月日 (Fecha de nacimiento) + 年齢 (Edad)
- 国籍 (Nacionalidad) + 電話番号 (Teléfono)
- 郵便番号 (Código postal) + 携帯電話 (Móvil)
- 住所 (Dirección completa)
- 緊急連絡先 (Contacto de emergencia) + 続柄 (Relación) + 電話番号 (Teléfono)

**Columna Derecha - Habilidades Japonesas (4 columnas):**
- **聞く** (Escuchar): ○ 初級 / ○ 中級 / ○ 上級
- **話す** (Hablar): ○ 初級 / ○ 中級 / ○ 上級
- **読む** (Leer): カナ ひら 漢字
- **書く** (Escribir): カナ ひら 漢字
- 最終学歴 (Última educación) + 専攻 (Especialización)
- 有資格取得 (Calificaciones obtenidas)
- 語学スキル有無 (Habilidades lingüísticas)
- 日本語能力資格 (Calificación de japonés)
- 能力試験受験受験予定 (Examen de aptitud programado)
- 簡易抗原検査結果 (Resultado de test de antígeno) + 実施日 (Fecha)
- コロナワクチン予防接種状態 (Estado de vacunación COVID)

##### 3. **Documentos** (書類関係)
- **Fila 1**: ビザ種類 + 自動車所有 + 運転免許種類及び条件 (rowspan 3)
- **Fila 2**: ビザ期間 + 任意保険加入
- **Fila 3**: 在留カード番号
- **Fila 4**: パスポート番号 + 運転免許番号
- **Fila 5**: パスポート期限 + 運転免許期限

##### 4. **Información Corporal y Salud** (身体情報・寸法)
Esta sección tiene **2 partes lado a lado**:

**Izquierda (6 columnas) - Datos Corporales:**
- **Fila 1**: 身長 (Altura) + 靴サイズ (Talla zapato) + 利き腕 (Mano dominante)
- **Fila 2**: 体重 (Peso) + 服のサイズ (Talla ropa) + 血液型 (Tipo de sangre)
- **Fila 3**: ウエスト (Cintura) + 安全靴 (Zapatos de seguridad) + アレルギー有無 (Alergias)
- **Fila 4**: 眼（メガネ、コンタクト使用）(Uso de lentes)
- **Fila 5**: お弁当（社内食堂）□ 昼/夜 □ 昼のみ □ 夜のみ □ 持参
- **Fila 6**: 通勤片道時間 (Tiempo de viaje) + 分 (minutos)

**Derecha (4 columnas) - Historial Laboral:**
- **職歴** (rowspan 6): Espacio para fechas de inicio~fin de trabajos anteriores

##### 5. **Familia** (家族構成)
- **Encabezado**: "家族構成" (colspan 6) + Labels: 氏名, 続柄, 年齢, 配偶者 (4 columnas)
- **6 filas garantizadas** para miembros de familia (incluso si están vacías)
- Columnas: 氏名 (Nombre) / 続柄 (Relación) / 年齢 (Edad) / 居住 (Residencia) / 配偶者 (Cónyuge)

##### 6. **Experiencia Laboral** (経験作業内容)
Lista horizontal de checkboxes:
- □ NC旋盤 □ 旋盤 □ プレス □ フォークリフト □ 梱包 □ 溶接
- □ 車部品組立 □ 車部品ライン □ 車部品検査 □ 電子部品検査
- □ 食品加工 □ 鋳造 □ 塗装 □ ラインリーダー □ その他

##### 7. **Footer (Pie de página)**
- **Columnas 1-8**: Logo y datos de la empresa
  ```
  ユニバーサル企画株式会社
  TEL　052-938-8840　FAX　052-938-8841
  ```
- **Columnas 9-10**: ID del candidato

### Cómo Modificar el Formato de Impresión

Si necesitas cambiar el diseño del PDF impreso:

1. **Edita el archivo**: `frontend/public/templates/rirekisho.html`
2. **Busca la función**: `generatePrintHTML()` (línea ~1454)
3. **Modifica el HTML** dentro del `return` statement
4. **Copia los cambios** a las carpetas de distribución:
   ```bash
   cp frontend/public/templates/rirekisho.html frontend/dist/templates/rirekisho.html
   cp frontend/public/templates/rirekisho.html frontend/build/templates/rirekisho.html
   ```
5. **Reinicia el contenedor frontend** si es necesario:
   ```bash
   docker-compose restart frontend
   ```

### Estilos CSS para Impresión

Los estilos específicos para impresión están definidos en las líneas 126-217 de `rirekisho.html`:

```css
.new-print-page {
    width: 100%;
    background: #ffffff;
    color: #000000;
    font-family: 'MS Gothic', 'Yu Gothic', sans-serif;
    font-size: 9pt;
    line-height: 1.4;
    border: 1px solid #000;
}

@media print {
    body { margin: 0; padding: 0; }
    #app { display: none !important; }
    #print_container { display: block !important; }
    @page {
        size: A4 landscape;
        margin: 10mm;
    }
}
```

### Botones de Vista Previa e Impresión

- **`showPreview()`**: Abre un modal con vista previa del formato
- **`printPDF()`**: Ejecuta `window.print()` para imprimir directamente
- **`generatePrintHTML(forPrint)`**: Genera el HTML del formato (usado por ambas funciones)

### Actualización: 2025-10-15

**Cambios realizados para coincidir con 履歴書2.0.pdf:**
- ✅ Rediseño completo del layout a formato horizontal A4
- ✅ División en secciones izquierda/derecha (60/40)
- ✅ Símbolos actualizados: ■□ para checkboxes, ●○ para radios
- ✅ Font-size reducido a 8pt para compactar en 1 página
- ✅ 6 filas de familia garantizadas
- ✅ Formato de footer con logo y datos de empresa
- ✅ Experiencia laboral en formato horizontal compacto
- ✅ Archivos sincronizados en public/, dist/ y build/
