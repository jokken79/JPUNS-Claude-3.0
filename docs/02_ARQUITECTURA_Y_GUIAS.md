# Guía Técnica y Arquitectura del Sistema

Este documento proporciona una visión general de la arquitectura del proyecto, la pila tecnológica, y guías detalladas sobre los componentes y flujos de trabajo de desarrollo.

## 1. Arquitectura del Proyecto

El sistema está organizado en una estructura de monorepo con una clara separación entre el backend, el frontend y la configuración.

```
JPUNS-Claude-3.0/
│
├── 🎯 Scripts de Control (.bat)
├── 📚 Documentación (docs/)
├── 🐳 Configuración Docker (docker/)
├── 🔧 Backend (backend/)
├── 🎨 Frontend (frontend/)
├── 💾 Base de Datos (base-datos/)
├── ⚙️ Configuración de la App (config/)
└── 🗑️ LIXO/ (Archivos obsoletos)
```

-   **Scripts de Control (`.bat`):** Contiene todos los scripts para instalar, iniciar, detener, y mantener el sistema.
-   **Documentación (`docs/`):** Contiene toda la documentación consolidada del proyecto (como este mismo archivo).
-   **Backend (`backend/`):** Aplicación escrita en Python con el framework FastAPI. Gestiona toda la lógica de negocio, la API y la comunicación con la base de datos.
-   **Frontend (`frontend/`):** Aplicación de una sola página (SPA) escrita en TypeScript con React y Vite. Se encarga de toda la interfaz de usuario.
-   **Base de Datos (`base-datos/`):** Contiene los scripts SQL para la inicialización y migración de la base de datos.
-   **Configuración de la App (`config/`):** Almacena archivos de configuración de la aplicación, como los datos de las fábricas y el maestro de empleados.

## 2. Pila Tecnológica (Tech Stack)

### Backend
-   **Framework:** FastAPI
-   **Lenguaje:** Python 3.11
-   **Base de Datos:** PostgreSQL
-   **ORM:** SQLAlchemy
-   **Validación de Datos:** Pydantic
-   **Autenticación:** JWT
-   **OCR:** Azure Computer Vision

### Frontend
-   **Framework/Librería:** React 18
-   **Lenguaje:** TypeScript
-   **Herramienta de Construcción:** Vite (previamente Create React App)
-   **Estilos:** Tailwind CSS
-   **Gestión de Estado:** Zustand
-   **Peticiones API:** Axios
-   **Testing:** Vitest

### DevOps
-   **Contenerización:** Docker
-   **Orquestación:** Docker Compose

## 3. Guía de Scripts de Control

Los scripts `.bat` en la raíz del proyecto son la forma principal de interactuar con el sistema.

-   `INSTALAR.bat`: **Usar solo la primera vez.** Instala Docker si es necesario, construye las imágenes y prepara todo el entorno.
-   `START.bat`: **Usar para el día a día.** Inicia todos los servicios (PostgreSQL, Backend, Frontend) en el orden correcto.
-   `STOP.bat`: Detiene todos los servicios de forma segura.
-   `LOGS.bat`: Muestra un menú para ver los logs de cualquier servicio, muy útil para depurar.
-   `BACKUP-BD.bat`: Crea una copia de seguridad de la base de datos en la carpeta `backups/`.
-   `IMPORTAR-BD-ORIGINAL.bat`: Permite restaurar una base de datos desde un archivo `.sql`.
-   `REINSTALAR.bat`: **(Peligroso)** Borra todo, incluyendo la base de datos, y reinstala el sistema desde cero.

## 4. Guía de Módulos Principales

### Gestión de Candidatos (Rirekisho)

Este módulo tiene varios componentes clave:

-   **Formulario de Registro (`/candidates`):**
    -   **Archivo:** `frontend/public/templates/rirekisho.html`
    -   **Propósito:** Es el formulario principal para registrar un nuevo candidato, diseñado para ser simple y con el sistema de OCR automático.

-   **Lista de Candidatos (`/candidates/list`):**
    -   **Archivo:** `frontend/src/pages/CandidatesList.tsx`
    -   **Propósito:** Muestra una vista de todos los candidatos registrados, con filtros, búsqueda y paginación.

-   **Edición de Candidato (`/candidates/:id/edit`):**
    -   **Archivo:** `frontend/src/pages/CandidateEdit.tsx`
    -   **Propósito:** Un formulario avanzado basado en React para editar en detalle la información de un candidato existente.

### Sistema de Temas y Estilos

El sistema permite cambiar la apariencia visual de la aplicación mediante temas.

-   **Cómo Funciona:** La apariencia se controla mediante variables CSS. El archivo `tailwind.config.js` está configurado para usar estas variables.
-   **Aplicación Correcta:** Para que un componente cambie de tema, debe usar las clases de Tailwind que hacen referencia a estas variables. 
    -   **Correcto:** `className="bg-background-base text-text-base"`
    -   **Incorrecto:** `className="bg-white text-slate-900"` (Estos colores son fijos y no cambiarán).

## 5. Notas de Desarrollo

### Comandos Útiles

-   **Ver logs del backend en tiempo real:**
    ```bash
    docker logs -f uns-claudejp-backend
    ```
-   **Acceso rápido a la base de datos:**
    ```bash
    docker exec -it uns-claudejp-db psql -U uns_admin -d uns_claudejp
    ```
-   **Reiniciar un solo servicio (ej. backend):**
    ```bash
    docker-compose restart backend
    ```

### Flujo de Trabajo

1.  Inicia el sistema con `START.bat`.
2.  Realiza los cambios en el código (backend o frontend).
3.  Los servicios de Vite y FastAPI se recargarán automáticamente al guardar los archivos.
4.  Verifica los cambios en el navegador.
5.  Para los cambios en el backend que afecten la base de datos, puede ser necesario reiniciar el contenedor o aplicar migraciones.
