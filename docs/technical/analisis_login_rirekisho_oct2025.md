# Informe técnico: Login temporal y formulario 履歴書

## 1. Alcance y metodología
Se revisó el repositorio `JPUNS-Claude-3.0` de forma integral, cubriendo frontend (React + Vite), el formulario HTML `rirekisho.html` y el backend FastAPI. El objetivo fue documentar el flujo de autenticación temporal (`admin / admin123`), validar el autocompletado de フリガナ mediante `wanakana.js` y verificar el estado de la interfaz de base de datos interna. El análisis se apoyó en lectura estática de código y trazabilidad entre capas.

## 2. Flujo actual de login temporal
### 2.1 Frontend React
- La pantalla `Login.tsx` muestra explícitamente las credenciales de demo `admin / admin123` dentro del bloque "デモアカウント" para facilitar pruebas manuales.【F:frontend/src/pages/Login.tsx†L95-L202】
- La función `authService.login` encapsula la llamada `POST /api/auth/login`, guarda el `access_token` en `localStorage` y redirige al dashboard al recibir respuesta satisfactoria.【F:frontend/src/pages/Login.tsx†L19-L33】【F:frontend/src/services/api.ts†L69-L93】
- Existe un interceptor global de Axios que, ante un `401`, intenta un auto-login silencioso enviando `username=admin&password=admin123` y reintenta la petición original si obtiene un token válido.【F:frontend/src/services/api.ts†L27-L66】 Esto explica que el sistema permanezca utilizable incluso cuando el usuario no introduce las credenciales manualmente tras expirar la sesión.

### 2.2 Backend FastAPI
- El endpoint `POST /api/auth/login` delega en `AuthService.authenticate_user`, que compara la contraseña recibida contra el hash almacenado y genera un JWT con la configuración global (`SECRET_KEY`, algoritmo HS256, expiración de 8 horas).【F:backend/app/api/auth.py†L62-L92】【F:backend/app/services/auth_service.py†L16-L61】
- Durante el arranque, `backend/init_db.py` garantiza la existencia del usuario `admin`: si no existe lo inserta, y si existe actualiza su hash a partir de la cadena literal `admin123`, regenerándolo con bcrypt en cada inicio.【F:backend/init_db.py†L17-L70】 Este mecanismo de "auto-curación" mantiene operativas las credenciales de prueba incluso tras restauraciones de base de datos.

### 2.3 Evaluación de seguridad actual
- **Credenciales hardcodeadas**: aparecen tanto en el frontend (interceptor Axios) como en el script de inicialización. Aunque es intencional para entornos de QA, supone un riesgo grave si se despliega sin aislar entornos o sin rotación de claves.
- **Auto-login silencioso**: el interceptor reactiva sesiones caducadas sin interacción del usuario, dificultando detectar fugas de token y exponiendo la contraseña en claro en los registros de red del navegador.
- **Secretos en repositorio**: `SECRET_KEY` tiene un valor por defecto en `config.py`, y no hay verificación de que se provea un `.env` seguro antes de arrancar en producción.【F:backend/app/core/config.py†L20-L47】

## 3. Razones por las que el login funciona a pesar de ser inseguro
1. **Hash válido disponible**: la contraseña se reescribe automáticamente con bcrypt (`passlib`) en cada arranque del backend, por lo que siempre coincide con `admin123` aunque se modifique manualmente en la base de datos.【F:backend/init_db.py†L48-L65】
2. **Reintentos automáticos desde el frontend**: aun si el token expira o se borra, el interceptor lanza un login con las credenciales de demo y actualiza el `Bearer` sin intervención del usuario.【F:frontend/src/services/api.ts†L36-L56】
3. **JWT persistente**: el token se guarda en `localStorage` y se reusa en cada petición, evitando que el usuario deba iniciar sesión mientras no cierre navegador.【F:frontend/src/services/api.ts†L11-L19】【F:frontend/src/pages/Login.tsx†L24-L33】

Este comportamiento es aceptable como "llave maestra" para QA, pero debe deshabilitarse antes de producción para cumplir con prácticas básicas de seguridad.

## 4. Plan de endurecimiento recomendado
1. **Gestión de secretos**: mover `SECRET_KEY`, credenciales temporales y URLs sensibles a variables de entorno, con carga a través de `.env` no versionado y soporte para `docker secrets`.
2. **Usuarios de prueba segregados**: crear un usuario `qa_admin` en entornos de staging y bloquear su creación en `init_db.py` cuando `ENVIRONMENT=production`.
3. **Autenticación reforzada**:
   - El backend ya usa bcrypt (`passlib`), pero conviene habilitar rotación de contraseñas y MFA opcional para roles críticos.
   - Reemplazar el auto-login del interceptor por un flujo de refresh token (almacenado como HttpOnly cookie) o, al menos, pedir re-autenticación explícita.
4. **Gestión de sesión**: implementar cierre de sesión backend (`POST /logout`) que invalide tokens mediante lista de revocación o cambio de `token_version` almacenado en base de datos.
5. **Trazabilidad y alertas**: registrar intentos fallidos y configurar bloqueo temporal tras N fallos.
6. **Hardening frontend**: retirar las credenciales impresas en la UI y mostrar un banner condicional sólo en builds de QA.

## 5. Formulario 履歴書 (`rirekisho.html`)
### 5.1 Integración de `wanakana.js`
- El CDN `https://cdn.jsdelivr.net/npm/wanakana@5.3.0/umd/wanakana.min.js` se carga en la cabecera antes de cualquier script, asegurando la disponibilidad global de `wanakana` cuando se ejecutan los manejadores personalizados.【F:frontend/public/templates/rirekisho.html†L1-L58】

### 5.2 Campo フリガナ y eventos asociados
- El input objetivo tiene `id="name_furigana"`, ubicado junto al campo 氏名 (`id="name_kanji"`).【F:frontend/public/templates/rirekisho.html†L309-L320】
- Las funciones `convertRomajiToFurigana`, `autoUpdateFurigana` y `smartAutoUpdateFurigana` normalizan la cadena, aplican reglas especiales para sílabas no estándar y delegan en `wanakana.toKatakana`. La segunda función se usa para conversiones básicas; la tercera decide si convertir basándose en el porcentaje de caracteres latinos e impide sobrescribir ediciones manuales utilizando `dataset.autoFilled`.【F:frontend/public/templates/rirekisho.html†L782-L921】
- Se agregan listeners `input` sobre `name_kanji` para disparar la conversión y sobre `name_furigana` para marcar entradas manuales; el evento `blur` cancela la autoedición cuando el usuario termina de escribir.【F:frontend/public/templates/rirekisho.html†L924-L946】

### 5.3 Diagnóstico
- **IDs correctos**: no hay duplicados y los `getElementById` apuntan al campo correcto.
- **Eventos activos**: los listeners se registran en `DOMContentLoaded` gracias a la inserción en el script global (el código se ejecuta al final del body, cuando el DOM ya está disponible). No se detectan errores de sintaxis.
- **Carga de librería**: al estar en CDN público y sin `integrity`, la única vulnerabilidad potencial es falta de fallback; conviene añadir verificación `if (typeof wanakana === 'undefined')` para mostrar mensaje en modo debug.
- **Conversión**: la función maneja casos como guiones (`-` → `・`) y sufijos `nh`, por lo que se espera que "Yamada Taro" se convierta automáticamente a `ヤマダ　タロウ`. Si el campo フリガナ ya contiene texto personalizado, la bandera `dataset.autoFilled` evita sobreescritura.

## 6. Página de base de datos (DatabaseJP)
- El servicio `frontend/src/services/databaseApi.ts` crea un cliente Axios con `baseURL = 'http://localhost:8000'`, pero concatena las rutas sin barra inicial (`apiClient.get(`${table}`)`), generando URLs inválidas (`http://localhost:8000candidates`). Además, omite el prefijo `/api/database` requerido por el backend.【F:frontend/src/services/databaseApi.ts†L3-L44】【F:backend/app/api/database.py†L18-L200】【F:backend/app/main.py†L116-L146】
- A consecuencia de ello, la interfaz `DatabaseJP.tsx` no puede recuperar ni mutar datos; las operaciones CRUD terminarán en errores de red o 404. Es necesario actualizar el servicio para apuntar a `/api/database/tables`, `/api/database/tables/{table}/data`, etc., y añadir el slash inicial.
- La página `AdminerDBJP.tsx` está pensada como acceso directo a Adminer (puerto 8080) y opera de forma independiente, únicamente comprobando conectividad básica con `fetch` en modo `no-cors`.

## 7. Plan de acción sugerido
1. **Refactor del servicio de base de datos**: ajustar `BASE_URL` a `http://localhost:8000/api/database` y normalizar rutas con slashes. Considerar parametrización vía `VITE_API_URL`.
2. **Fallback para `wanakana`**: envolver la conversión en `try/catch` o añadir comprobación para registrar un error visible si el CDN falla.
3. **Desactivar auto-login en producción**: parametrizar el interceptor según `import.meta.env.MODE` para que sólo funcione en QA.
4. **Script de inicialización consciente de entorno**: condicionar la escritura de la contraseña demo según `settings.ENVIRONMENT`.

## 8. Próximos pasos y pruebas
- **Pruebas unitarias/e2e**: ejecutar `pytest` para el backend y `npm run test` en frontend una vez actualizados los entornos.
- **Smoke test manual**: validar que el formulario convierte "Maria-Anh" → `マリア・アン` y que la edición manual de フリガナ no se sobrescribe.
- **Verificación de seguridad**: tras retirar el auto-login, confirmar que el token expira correctamente y obliga a reautenticación.

> Nota: Este informe se centra en el análisis estático. Se recomienda ejecutar los entornos dockerizados (`docker-compose up`) para corroborar las rutas API y reproducir los flujos descritos antes de publicar en producción.
