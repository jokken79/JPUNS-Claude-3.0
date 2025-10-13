# Resumen del Proyecto: UNS-ClaudeJP 3.0 (Generado por Gemini)

Este documento proporciona un resumen rápido del sistema de gestión de personal `UNS-ClaudeJP 3.0`.

---

## 🚀 Descripción General

**UNS-ClaudeJP 3.0** es un sistema completo de gestión de recursos humanos diseñado para empresas japonesas. Permite administrar candidatos, empleados, fábricas, asistencia, nóminas y más.

- **Versión del Proyecto:** 3.0.1 (según `CHANGELOG.md`)
- **Repositorio:** `https://github.com/jokken79/JPUNS-Claude-3.0`

---

## 🛠️ Tecnologías Principales

| Categoría | Tecnología |
|-----------|-------------------------------------------------|
| **Backend** | Python, FastAPI, SQLAlchemy, Pydantic, PostgreSQL |
| **Frontend** | React 18, TypeScript, Tailwind CSS, Zustand |
| **DevOps** | Docker, Docker Compose |
| **Testing** | Pytest (backend), React Testing Library (frontend) |
| **OCR** | Azure Computer Vision, Tesseract |

---

## 🏁 Cómo Empezar

El proyecto se gestiona completamente a través de scripts `.bat` en el directorio raíz.

1.  **Instalación por primera vez:**
    ```bash
    INSTALAR.bat
    ```
    *(Este script instala Docker si es necesario, construye las imágenes e inicia el sistema).*

2.  **Uso diario:**
    ```bash
    # Para iniciar todos los servicios (DB, Backend, Frontend)
    START.bat

    # Para detener todos los servicios
    STOP.bat
    ```

---

## 👤 Credenciales de Acceso

| Servicio | Usuario | Contraseña |
|----------|---------|------------|
| **Aplicación** | `admin` | `admin123` |
| **Base de Datos**| `uns_admin`| `57UD10R` |

**Nota:** Se recomienda cambiar estas credenciales en un entorno de producción.

---

## 🌐 URLs del Sistema

| Servicio | URL | Descripción |
|---------------|----------------------------------|-----------------------------|
| **Frontend** | `http://localhost:3000` | Interfaz de usuario principal |
| **Backend API** | `http://localhost:8000` | API REST |
| **API Docs** | `http://localhost:8000/api/docs` | Documentación Swagger/OpenAPI |
| **Base de Datos** | `localhost:5432` | Acceso directo a PostgreSQL |

---

## 📁 Estructura y Scripts Clave

- **`docker-compose.yml`**: Orquesta los servicios `db`, `backend`, y `frontend`.
- **`backend/`**: Contiene la lógica de la API de FastAPI.
    - `requirements.txt`: Dependencias de Python.
- **`frontend/`**: Contiene la aplicación de React.
    - `package.json`: Dependencias de Node.js.
- **`base-datos/`**: Scripts de inicialización de la base de datos.
- **`*.bat`**: Scripts para controlar el ciclo de vida de la aplicación.
    - `LOGS.bat`: Para visualizar logs de los servicios.
    - `REINSTALAR.bat`: Para borrar todo y empezar de cero.
    - `BACKUP-BD.bat`: Para crear copias de seguridad de la base de datos.
    - `IMPORTAR-BD-ORIGINAL.bat`: Para restaurar una base de datos desde un archivo.

---

Este resumen fue generado después de analizar los siguientes archivos: `README.md`, `CLAUDE.md`, `NOTAS-DESARROLLO.md`, `GUIA_RAPIDA.md`, `GUIA-BASE-DATOS.md`, `CHANGELOG.md`, `package.json`, `docker-compose.yml`, `backend/requirements.txt`, y `LEEME_PRIMERO.txt`.
