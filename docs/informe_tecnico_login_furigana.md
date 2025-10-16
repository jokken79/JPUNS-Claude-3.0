# Informe Técnico: Login temporal y autocompletado de フリガナ

## 1. Resumen ejecutivo
- Se analizó el flujo de autenticación completo (frontend React, servicio Axios y backend FastAPI) que admite el login temporal `admin / admin123` utilizado únicamente en entornos de prueba.
- Se revisó la plantilla `rirekisho.html` (formulario 履歴書) y sus scripts asociados para diagnosticar la conversión automática de romaji a katakana mediante `wanakana.js`.
- Se identificaron buenas prácticas ya implementadas (hash bcrypt en backend, JWT, control de autollenado) y se documentaron riesgos, motivos por los que el login funciona en testing, así como mejoras prioritarias para endurecer la seguridad y robustecer la conversión de フリガナ.

## 2. Login temporal `admin / admin123`

### 2.1 Implementación actual
- **Frontend React**: El componente `Login.tsx` envía las credenciales al servicio `authService.login`, y al autenticar almacena el JWT en `localStorage` para reutilizarlo en el resto de la aplicación.【F:frontend/src/pages/Login.tsx†L7-L94】
- **Capa de servicios**: `frontend/src/services/api.ts` crea una instancia de Axios con interceptores que adjuntan el token y, ante un 401, intentan un auto-login con las credenciales de demo (`admin/admin123`). Esto explica por qué el flujo "funciona" incluso si el usuario no introduce las credenciales manualmente tras expirar el token.【F:frontend/src/services/api.ts†L1-L83】
- **Backend FastAPI**: el endpoint `/api/auth/login` delega la autenticación en `AuthService.authenticate_user`, que compara la contraseña recibida con el hash almacenado mediante `passlib` (bcrypt). Si es válida, genera un JWT con la clave de configuración y lo retorna al frontend.【F:backend/app/api/auth.py†L45-L80】【F:backend/app/services/auth_service.py†L16-L72】
- **Creación del usuario admin**: el script `backend/init_db.py` se ejecuta al iniciar la API y garantiza que exista el usuario `admin`. Si no existe o para sincronizar el estado, vuelve a generar el hash bcrypt de `admin123` y lo guarda en la tabla `users`. Esto mantiene operativas las credenciales durante pruebas aunque se restablezca la base de datos.【F:backend/init_db.py†L1-L61】

### 2.2 Por qué funciona en entornos de prueba
- El login combina **hashing bcrypt** en base de datos, **validación** mediante `AuthService` y **tokens JWT** con expiración de 8 horas, suficientes para sesiones de QA. Aunque la contraseña sea simple, el hash evita que se exponga en la base de datos y la sesión funciona porque el token se genera correctamente.【F:backend/app/services/auth_service.py†L16-L56】
- El interceptor de Axios fuerza un **re-login automático** cada vez que el backend devuelve 401, reutilizando las credenciales de prueba. Esto oculta los errores y proporciona continuidad a los testers sin pedir intervención manual.【F:frontend/src/services/api.ts†L28-L68】
- `init_db.py` repuebla el usuario admin en cada arranque del backend, por lo que el entorno siempre cuenta con las credenciales de desarrollo listas sin pasos extra.【F:backend/init_db.py†L20-L52】

### 2.3 Riesgos y plan de endurecimiento
1. **Exposición de credenciales estáticas**: las credenciales aparecen en múltiples archivos y en el repositorio, lo que supone un riesgo si el código se despliega sin modificaciones.
   - **Acción**: moverlas a variables de entorno (`.env`) y borrar referencias directas en código/ documentación pública.
2. **Interceptors con auto-login**: si se deja en producción, permitiría a cualquier cliente recuperar un token válido sólo con interceptar el 401.
   - **Acción**: eliminar el auto-login en entornos productivos o condicionarlo con `NODE_ENV`, forzando logout y limpieza del token caducado.【F:frontend/src/services/api.ts†L28-L68】
3. **Fortalecer el almacenamiento de contraseñas**:
   - `AuthService` ya usa bcrypt, pero se recomienda añadir un "pepper" externo (`settings.PEPPER`) y rotarlo periódicamente.【F:backend/app/services/auth_service.py†L16-L47】
4. **Gestión de tokens JWT**:
   - Rotar `SECRET_KEY` mediante variables de entorno y acortar la vigencia del token en producción (ej. 30 minutos).【F:backend/app/core/config.py†L17-L40】
   - Añadir **refresh tokens** y almacenamiento en cookies HttpOnly para reducir exposición en `localStorage`.
5. **End-to-end hardening**:
   - Añadir endpoint `/api/auth/logout` para invalidar tokens en backend (lista negra/rotación) y limpiar sesión.
   - Implementar control de intentos fallidos y MFA opcional.

## 3. Formulario 履歴書 (`rirekisho.html`)

### 3.1 Ubicación y estructura
- El formulario está en `frontend/public/templates/rirekisho.html` y se carga dentro de un `<iframe>` en la página de candidatos del frontend. La plantilla incluye Tailwind, `wanakana.js` y un script grande al final con lógica de OCR, autocompletado y generación de PDF.【F:frontend/public/templates/rirekisho.html†L1-L125】【F:frontend/src/pages/Candidates.tsx†L13-L18】

### 3.2 Campo 氏名 y フリガナ
- Campo de nombre (kanji/romaji): `<input type="text" id="name_kanji">`.
- Campo フリガナ: `<input type="text" id="name_furigana">`. Ambos están en la sección "基本情報" y comparten contenedor de grid.【F:frontend/public/templates/rirekisho.html†L300-L338】

### 3.3 Conversión automática romaji → katakana
1. **Carga de la librería**: `wanakana.min.js` se incluye desde CDN jsDelivr en la cabecera. Si la descarga falla, la función `convertRomajiToFurigana` detecta `wanakana` `undefined`, escribe un mensaje de depuración y evita lanzar excepciones.【F:frontend/public/templates/rirekisho.html†L7-L9】【F:frontend/public/templates/rirekisho.html†L770-L779】
2. **Función de conversión**: `convertRomajiToFurigana` normaliza el texto (NFKC), filtra caracteres no latinos, aplica un mapa manual para sílabas especiales y utiliza `wanakana.toKatakana` palabra por palabra. Luego une los resultados con espacio japonés (`　`).【F:frontend/public/templates/rirekisho.html†L780-L819】
3. **Actualización inteligente**: `smartAutoUpdateFurigana` calcula el ratio de caracteres latinos y decide si convertir, copiar kana existentes o mantener kanji, respetando ediciones manuales mediante `dataset.autoFilled`.【F:frontend/public/templates/rirekisho.html†L853-L903】
4. **Eventos**:
   - En `DOMContentLoaded` se añade un `input` listener sobre `#name_kanji` para ejecutar `smartAutoUpdateFurigana` en cada cambio manual.【F:frontend/public/templates/rirekisho.html†L699-L736】【F:frontend/public/templates/rirekisho.html†L920-L930】
   - El campo フリガナ marca `data-auto-filled="false"` cuando el usuario lo edita, evitando sobreescrituras posteriores.【F:frontend/public/templates/rirekisho.html†L932-L945】
   - Tras el OCR de tarjeta de residencia (`type === 'zairyu'`), si no llega `name_kana`, se invoca `autoUpdateFurigana` para convertir el nombre detectado.【F:frontend/public/templates/rirekisho.html†L1300-L1330】

### 3.4 Posibles puntos de fallo
- **ID correctos**: los IDs `name_kanji` y `name_furigana` son coherentes con los selectores del script, por lo que no hay conflicto de nombres.【F:frontend/public/templates/rirekisho.html†L300-L338】【F:frontend/public/templates/rirekisho.html†L920-L930】
- **Eventos**: la vinculación se realiza tras `DOMContentLoaded`, garantizando que los elementos existan cuando se agregan los listeners.【F:frontend/public/templates/rirekisho.html†L699-L736】
- **Dependencia de CDN**: si `wanakana` no carga (offline, CSP, error CDN) la conversión se desactiva silenciosamente. Se sugiere empaquetar la librería en el build local o implementar un fallback para avisar al usuario.
- **OCR y autollenado**: cuando el OCR completa el nombre mediante script, la conversión sólo se ejecuta para la tarjeta `zairyu`. Si se incorporan otras fuentes (p.ej. carnet de conducir) conviene llamar también a `autoUpdateFurigana` tras asignar `name_kanji` para asegurar la sincronización.
- **Normalización**: el filtro `/[^A-Za-z\s\-']+/g` elimina números y diacríticos. Para nombres como "José" se recomienda ampliar el mapa manual o usar `wanakana.toKatakana` directamente sobre la cadena normalizada con reemplazo de caracteres acentuados.

### 3.5 Recomendaciones
- **Distribución de la librería**: incluir `wanakana` en el bundle del frontend o alojarlo en el backend para entornos sin Internet.
- **Observabilidad**: mostrar un toast/badge si la librería no carga o si el campo フリガナ se vacía tras conversión fallida.
- **Pruebas unitarias**: añadir pruebas automatizadas (p. ej. Jest + jsdom) para validar la conversión de casos comunes (romaji, kana, kanji) y garantizar regresiones cero.
- **Extender triggers**: llamar a `smartAutoUpdateFurigana` también cuando se importan datos desde la base (por ejemplo al editar un candidato) para refrescar フリガナ si viene vacío.

## 4. Checklist de mejoras prioritarias
1. **Seguridad del login**
   - Migrar credenciales a variables de entorno y usar `python-dotenv`/`pydantic-settings` ya presente para leerlas.【F:backend/app/core/config.py†L17-L39】
   - Reemplazar auto-login en Axios por un flujo de refresh token.
   - Implementar endpoint de logout en backend y revocación básica.
2. **フリガナ UX**
   - Empaquetar `wanakana` localmente y añadir feedback visual cuando la conversión se realice.
   - Completar la tabla de transliteración manual con casos como `cha`, `shi`, `kyo`, vocales largas (`ā -> アー`).
3. **Documentación**
   - Añadir a la wiki interna un apartado de "Credenciales de QA" con advertencias y enlaces a scripts de reseteo (`init_db.py`, `scripts/create_admin_user.py`).
   - Documentar en README el requisito de acceso a Internet o indicar cómo servir `wanakana` desde `frontend/public/vendor`.

---
**Conclusión**: El proyecto dispone de una base sólida para QA (hashing bcrypt, JWT, autocompletados avanzados). El login temporal funciona por la combinación de `init_db.py`, `AuthService` y el interceptor de Axios. Para un despliegue real se recomienda endurecer la autenticación (contraseñas gestionadas via `.env`, tokens rotatorios, logout explícito) y reducir dependencias externas (`wanakana`). El formulario `rirekisho.html` implementa correctamente la conversión romaji→フリガナ; cualquier fallo detectado proviene generalmente de la carga del CDN o de datos OCR no normalizados. Priorizar las acciones listadas mitigará estos riesgos y mantendrá la experiencia de usuario estable tanto en QA como en producción.
