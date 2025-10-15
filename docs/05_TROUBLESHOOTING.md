# Guía de Solución de Problemas (Troubleshooting)

Esta guía centraliza los problemas más comunes y sus soluciones definitivas para el sistema UNS-ClaudeJP 3.0.

## 1. Pasos de Diagnóstico General

Ante cualquier problema, sigue siempre estos tres pasos primero:

1.  **Verifica Docker:** Asegúrate de que Docker Desktop esté corriendo.
2.  **Revisa los Logs:** Ejecuta `LOGS.bat` y selecciona el servicio que está fallando (generalmente `backend` o `frontend`) para ver el mensaje de error específico.
3.  **Revisa la Consola del Navegador:** Abre la aplicación en Chrome, presiona `F12` y ve a la pestaña "Consola" para buscar errores de JavaScript.

## 2. Problemas Comunes y Soluciones

### Problema: No se puede iniciar sesión (Login Falla)

-   **Síntoma:** Ingresas `admin` / `admin123` y recibes un error de "Credenciales incorrectas" o "401 Unauthorized".
-   **Causa:** El hash de la contraseña en la base de datos es incorrecto.
-   **Solución Rápida:** Ejecuta el script `fix-login-correcto.bat`. Este script regenera el hash correcto para el usuario `admin` y lo actualiza en la base de datos automáticamente.

### Problema: Error 500 al cargar la lista de Empleados

-   **Síntoma:** La página de empleados muestra un error de servidor.
-   **Causa:** Discrepancia entre el modelo de datos del backend (SQLAlchemy) y la estructura real de la tabla `employees` en la base de datos. Faltan columnas.
-   **Solución:** Este problema ya ha sido corregido mediante un script de migración (`base-datos/02_add_missing_columns.sql`). Si el problema reaparece en una instalación nueva, asegúrate de que los scripts de inicialización se ejecuten correctamente.

### Problema: El Formulario de Candidatos no guarda o da error

-   **Síntoma:** Al intentar guardar un nuevo candidato desde el formulario de `rirekisho.html`, aparece un error.
-   **Causa:** Similar al problema de los empleados, la tabla `candidates` no tenía todas las columnas necesarias para el formulario completo.
-   **Solución:** Este problema fue resuelto con el script `base-datos/03_add_candidates_rirekisho_columns.sql`. Para solucionarlo en una instalación existente, ejecuta `UPDATE-CANDIDATES-COLUMNS.bat`.

### Problema: La apariencia (tema) de la aplicación no cambia

-   **Síntoma:** Al cambiar el tema (ej. a modo oscuro), solo una parte de la interfaz cambia de color.
-   **Causa:** El componente que no cambia está usando clases de Tailwind con colores fijos (ej. `bg-white`, `text-slate-900`) en lugar de las clases basadas en variables CSS del tema (ej. `bg-background-base`, `text-text-base`).
-   **Solución para Desarrolladores:** Al modificar o crear componentes, utiliza siempre las clases de Tailwind configuradas con variables para asegurar que el componente sea compatible con los temas. Por ejemplo, en lugar de `bg-white`, usa `bg-background-base`.

### Problema: Pantalla en Blanco después de la migración a Vite

-   **Síntoma:** El frontend en `http://localhost:3000` no carga y muestra una página en blanco.
-   **Causa:** Conflicto de archivos en `frontend/src/components/skeletons/`. Existían un `index.ts` y un `index.tsx` en el mismo directorio, lo cual no es soportado por Vite.
-   **Solución:** El archivo duplicado `index.tsx` fue eliminado. Si este problema vuelve a ocurrir, busca archivos `index.ts` y `index.tsx` en el mismo directorio y elimina el incorrecto.

### Problema: Warning de Git en VS Code (`git config failed`)

-   **Síntoma:** Aparece un warning persistente sobre la configuración de Git en la terminal de VS Code.
-   **Causa:** Configuración incorrecta de los finales de línea (CRLF/LF) en Windows.
-   **Solución:** Ejecuta el siguiente comando en tu terminal para configurar Git globalmente de la manera correcta para Windows:
    ```bash
    git config --global core.autocrlf true
    ```

### Problema: Los contenedores de Docker no inician

-   **Síntoma:** `START.bat` falla con un error sobre puertos en uso (`port is already allocated`).
-   **Causa:** Otro programa en tu PC está usando un puerto que Docker necesita (generalmente 3000, 8000, 5432 u 8080).
-   **Solución:**
    1.  Abre una terminal de PowerShell y busca qué proceso está usando el puerto, por ejemplo, para el puerto 3000:
        ```powershell
        netstat -ano | findstr ":3000"
        ```
    2.  Identifica el ID del proceso (PID) en la última columna y ciérralo desde el Administrador de Tareas, o cambia el puerto en el archivo `docker-compose.yml`.
