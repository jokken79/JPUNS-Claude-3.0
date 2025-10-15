# UNS-ClaudeJP 3.0 - Sistema de Gestión de Personal

Sistema completo de gestión de recursos humanos para empresas japonesas, desarrollado con FastAPI (Python) y React (TypeScript).

![Version](https://img.shields.io/badge/version-3.0-blue)
![Python](https://img.shields.io/badge/python-3.11-blue)
![React](https://img.shields.io/badge/react-18-blue)
![Docker](https://img.shields.io/badge/docker-ready-green)

---

## 🚀 Inicio Rápido

### Primera Vez en Windows

Si es tu **PRIMERA VEZ**, necesitas instalar Docker Desktop:

```bash
INSTALAR.bat
```

Este script:
- ✅ Verifica si Docker está instalado
- ✅ Te guía para instalarlo si no lo tienes
- ✅ Construye todas las imágenes (tarda 5-10 minutos)
- ✅ Inicia el sistema automáticamente
- ✅ Te abre el navegador cuando está listo

### Si Ya Tienes Docker Desktop

Simplemente ejecuta:
```bash
START.bat
```

¡Listo! El sistema estará disponible en http://localhost:3000

### Requisitos
- **Windows 10/11**
- **8GB RAM** mínimo (16GB recomendado)
- **10GB espacio en disco** libre
- **Docker Desktop** (el script INSTALAR.bat te ayuda con esto)

### Credenciales de Acceso
```
Usuario:  admin
Password: admin123
```

---

## 🚀 Actualización a Vite (Octubre 2025)

El frontend de este proyecto ha sido **migrado de Create React App (`react-scripts`) a Vite**.

### ¿Por qué Vite?

-   **Velocidad Extrema:** El servidor de desarrollo arranca de forma casi instantánea.
-   **Rendimiento:** Las actualizaciones en el código se reflejan en el navegador al instante (Hot Module Replacement).
-   **Seguridad:** La migración ha **eliminado 9 vulnerabilidades de seguridad** que estaban presentes en las dependencias de `react-scripts`.
-   **Moderno:** Vite es la herramienta de construcción preferida por la comunidad de React para nuevos proyectos.

### ¿Qué ha cambiado?

-   El proyecto ya no usa `react-scripts`.
-   Los comandos (`npm start`, `npm run build`) ahora usan Vite, pero se ejecutan de la misma manera.
-   El sistema de testing ahora es **Vitest**, el compañero de testing de Vite.

No necesitas hacer nada diferente para iniciar el proyecto, ¡solo disfrutar de la velocidad!

---

## 📁 Estructura del Proyecto

```
JPUNS-Claude-3.0/
│
├── 🎯 Scripts de Control (.bat)
│   ├── INSTALAR.bat        # Primera vez: Instalar Docker + Sistema
│   ├── START.bat           # Iniciar el sistema
│   ├── STOP.bat            # Detener el sistema
│   ├── LOGS.bat            # Ver logs de servicios
│   ├── BACKUP-BD.bat       # Crear backup de base de datos
│   ├── IMPORTAR-BD-ORIGINAL.bat  # Importar tu base de datos real
│   ├── REINSTALAR.bat      # Reinstalar desde cero
│   └── fix-login-correcto.bat  # Solución de problemas de login
│
├── 📚 Documentación
│   ├── README.md           # Este archivo
│   ├── GUIA_RAPIDA.md      # Comandos esenciales
│   ├── GUIA-BASE-DATOS.md  # Guía completa de base de datos
│   ├── DATABASE-MANAGEMENT.md  # Guía de módulos de base de datos
│   ├── CHANGELOG.md        # Historial de cambios
│   ├── SOLUCION_LOGIN_DEFINITIVA.md    # Guía de solución login
│   └── SOLUCION_ERROR_EMPLEADOS.md     # Guía de solución empleados
│
├── 🐳 Configuración Docker
│   ├── docker-compose.yml  # Configuración de servicios
│   └── docker/             # Dockerfiles
│       ├── Dockerfile.backend
│       └── Dockerfile.frontend
│
├── 🔧 Backend (FastAPI)
│   └── backend/
│       ├── app/
│       │   ├── api/        # Endpoints REST
│       │   │   ├── auth.py     # Autenticación
│       │   │   ├── candidates.py # Gestión de candidatos
│       │   │   ├── employees.py  # Gestión de empleados
│       │   │   ├── factories.py  # Gestión de fábricas
│       │   │   ├── timer_cards.py # Control de asistencia
│       │   │   ├── salary.py      # Gestión de salarios
│       │   │   ├── requests.py    # Gestión de solicitudes
│       │   │   ├── database.py    # Gestión de base de datos
│       │   │   └── ...           # Otros endpoints
│       │   ├── core/       # Configuración y utilidades
│       │   ├── models/     # Modelos SQLAlchemy
│       │   ├── schemas/    # Schemas Pydantic
│       │   └── services/   # Lógica de negocio
│       └── requirements.txt
│
├── 🎨 Frontend (Vite + React)
│   └── frontend/
│       ├── index.html      # Punto de entrada de Vite
│       ├── vite.config.js  # Configuración de Vite
│       ├── src/            # Código fuente de la aplicación
│       │   ├── index.tsx   # Punto de entrada de React
│       │   ├── components/ # Componentes
│       │   ├── pages/      # Páginas
│       │   ├── styles/     # Estilos
│       │   ├── context/    # Contextos
│       │   ├── services/   # Servicios API
│       │   └── utils/      # Utilidades
│       └── package.json
│
├── 💾 Base de Datos
│   └── base-datos/
│       ├── 01_init_database.sql      # Inicialización
│       └── 02_add_missing_columns.sql # Migraciones
│
└── 🗑️ LIXO/                # Archivos obsoletos (ignorar)
```

---

## 🎮 Uso del Sistema

### Iniciar el Sistema
```bash
START.bat
```
- Inicia todos los servicios (BD, Backend, Frontend)
- Verifica que estén funcionando correctamente
- Opción para abrir automáticamente en el navegador

### Detener el Sistema
```bash
STOP.bat
```
- Detiene todos los contenedores Docker
- Mantiene los datos en los volúmenes

### Ver Logs
```bash
LOGS.bat
```
Opciones disponibles:
1. Ver logs de todos los servicios
2. Ver logs solo del Backend
3. Ver logs solo del Frontend
4. Ver logs de la Base de Datos
5. Seguir logs en tiempo real

### Reinstalar el Sistema
```bash
REINSTALAR.bat
```
⚠️ **ADVERTENCIA:** Esto eliminará todos los datos y reinstalará desde cero.

Use esto solo si:
- El sistema está completamente roto
- Necesita datos frescos de prueba
- Quiere empezar desde cero

---

## 🌐 URLs del Sistema

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Frontend** | http://localhost:3000 | Interfaz de usuario principal |
| **Backend API** | http://localhost:8000 | API REST |
| **API Docs** | http://localhost:8000/api/docs | Documentación Swagger |
| **Adminer** | http://localhost:8080 | Administración de base de datos |
| **Base de Datos** | localhost:5432 | PostgreSQL (acceso interno) |

---

## 🔧 Funcionalidades Principales

### 👥 Gestión de Candidatos
- Registro de candidatos con履歴書 (Rirekisho)
- Procesamiento OCR de documentos
- Estado de aprobación/rechazo
- Conversión a empleado

### 👷 Gestión de Empleados
- Registro completo de empleados
- Gestión de contratos y visas
- Asignación a fábricas
- Gestión de apartamentos
- Seguimiento de salarios

### 🏭 Gestión de Fábricas
- Registro de empresas cliente
- Asignación de personal
- Gestión de contratos

### 📅 Control de Asistencia
- Registro de entrada/salida (タイムカード)
- Cálculo de horas trabajadas
- Horas extras y festivos

### 💰 Gestión de Nómina
- Cálculo automático de salarios
- Deducciones y bonificaciones
- Historial de pagos

### 📄 Solicitudes (申請)
- Vacaciones (有給)
- Permisos
- Regreso temporal (一時帰国)
- Renuncias

### 🗄️ Gestión de Base de Datos
- **DateBaseJP**: Gestión integrada de tablas
  - Visualización y edición de datos
  - Importación/Exportación CSV y Excel
  - Búsqueda en tiempo real
  - Paginación de resultados
- **Adminer DBJP**: Administración avanzada
  - Interfaz completa de Adminer
  - Ejecución de consultas SQL personalizadas
  - Gestión de estructura de base de datos
  - Funciones de backup/restore

### 🔐 Sistema de Usuarios
- Roles jerárquicos (SUPER_ADMIN, ADMIN, COORDINATOR, etc.)
- Autenticación JWT
- Permisos por rol
- Visibilidad configurable de páginas

---

## 🛠️ Tecnologías

### Backend
- **FastAPI** - Framework web moderno y rápido
- **SQLAlchemy** - ORM para Python
- **PostgreSQL** - Base de datos relacional
- **Pydantic** - Validación de datos
- **JWT** - Autenticación segura
- **Tesseract OCR** - Procesamiento de documentos
- **Azure Computer Vision** - OCR avanzado

### Frontend
- **Vite** - Herramienta de construcción y servidor de desarrollo ultrarrápido.
- **React 18** - Biblioteca de UI
- **TypeScript** - JavaScript tipado
- **Tailwind CSS** - Framework CSS
- **Vitest** - Framework de testing para Vite.
- **React Router** - Navegación
- **Axios** - Cliente HTTP

### DevOps
- **Docker** - Contenerización
- **Docker Compose** - Orquestación
- **Nginx** - Servidor web (producción)

---

## 🐛 Solución de Problemas

### El login no funciona
Ejecuta:
```bash
fix-login-correcto.bat
```
Este script corrige automáticamente el password del usuario admin.

Consulta: [SOLUCION_LOGIN_DEFINITIVA.md](SOLUCION_LOGIN_DEFINITIVA.md)

### Error al cargar empleados
El sistema ya está corregido, pero si aparece el error consulta:
[SOLUCION_ERROR_EMPLEADOS.md](SOLUCION_ERROR_EMPLEADOS.md)

### Los contenedores no inician
1. Verifica que Docker Desktop esté corriendo
2. Verifica que los puertos estén libres:
```bash
netstat -ano | findstr "3000"
netstat -ano | findstr "8000"
netstat -ano | findstr "5432"
```
3. Reinicia Docker Desktop
4. Ejecuta `REINSTALAR.bat` si el problema persiste

### El frontend no carga
- El frontend puede tardar 1-2 minutos en compilar la primera vez
- Verifica los logs: `LOGS.bat` → opción 3
- Espera un poco más y recarga la página

### Backend devuelve errores 500
1. Verifica los logs: `LOGS.bat` → opción 2
2. Verifica que la base de datos esté funcionando: `LOGS.bat` → opción 4
3. Si el error persiste, ejecuta `REINSTALAR.bat`

---

## 📊 Base de Datos: Demo vs Real

### Datos de Prueba (Por Defecto)

El sistema viene con **datos de demostración** preinstalados:

- **1 usuario admin** (admin / admin123)
- **5 fábricas** (PMI, Nippi, Yamaha, Toyota, Honda)
- **5 apartamentos**
- **5 candidatos** (en diferentes estados)
- **5 empleados** activos
- **Registros de asistencia** y solicitudes de ejemplo

### Usar tu Base de Datos Real

Para cambiar a tus datos reales:

```bash
# Opción 1: Importar desde archivo .sql
IMPORTAR-BD-ORIGINAL.bat

# Opción 2: Hacer backup de BD actual
BACKUP-BD.bat
```

**Guía completa:** [GUIA-BASE-DATOS.md](GUIA-BASE-DATOS.md)

#### 4 Formas de Usar tus Datos:
1. **Archivo .sql** - Backup de PostgreSQL
2. **CSV/Excel** - Importar por interfaz web
3. **Otra PostgreSQL** - Migrar desde otra BD
4. **BD Externa** - Conectar a BD existente

---

## 🔐 Seguridad

### Credenciales por Defecto
⚠️ **IMPORTANTE:** Cambia las credenciales por defecto antes de usar en producción:

1. **Usuario admin:**
   - Cambiar password desde la interfaz de usuario
   - O modificar en la base de datos

2. **Base de datos:**
   - Modificar `POSTGRES_PASSWORD` en `docker-compose.yml`
   - Modificar `SECRET_KEY` para JWT

3. **API Keys:**
   - Configurar variables de entorno para servicios externos
   - No subir archivos `.env` al repositorio

---

## 📝 Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto para configuración personalizada:

```env
# Database
POSTGRES_DB=uns_claudejp
POSTGRES_USER=uns_admin
POSTGRES_PASSWORD=TU_PASSWORD_SEGURO

# JWT
SECRET_KEY=TU_SECRET_KEY_SEGURO
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# OCR Services (opcional)
GEMINI_API_KEY=tu_api_key
AZURE_COMPUTER_VISION_ENDPOINT=tu_endpoint
AZURE_COMPUTER_VISION_KEY=tu_key

# Email (opcional)
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu_email@gmail.com
SMTP_PASSWORD=tu_password
```

---

## 🤝 Contribución

Este es un proyecto privado, pero si necesitas hacer cambios:

1. Crea una rama nueva: `git checkout -b feature/nueva-funcionalidad`
2. Haz tus cambios y commits: `git commit -am 'Agregar nueva funcionalidad'`
3. Push a la rama: `git push origin feature/nueva-funcionalidad`
4. Crea un Pull Request

---

## 📜 Licencia

Propiedad de UNS-Kikaku. Todos los derechos reservados.

---

## 📞 Soporte

Para problemas o preguntas:
1. Revisa la documentación en `/docs`
2. Consulta los archivos `SOLUCION_*.md`
3. Revisa los logs con `LOGS.bat`
4. Contacta al equipo de desarrollo

---

## 🎉 Changelog

Ver [CHANGELOG.md](CHANGELOG.md) para historial detallado de cambios.

### v3.1 - 2025-10-14
- ✨ **Nuevos módulos de gestión de base de datos**
  - DateBaseJP: Gestión integrada de tablas con UI moderna
  - Adminer DBJP: Interfaz completa para Adminer
- 🎨 Mejoras de estilos CSS sin errores
- 📚 Nueva documentación para módulos de base de datos

**Última actualización:** 2025-10-14
**Versión:** 3.1

---

## 🗂️ Carpeta LIXO

La carpeta `LIXO/` contiene scripts y documentación obsoleta que ya no se usan pero se conservan por referencia. **Puedes ignorar completamente esta carpeta.**

Contenido:
- `scripts-viejos/` - Scripts .bat antiguos
- `docs-viejas/` - Documentación obsoleta
- `archivos-temporales/` - Scripts temporales de prueba

Si quieres liberar espacio, puedes eliminar toda la carpeta LIXO sin afectar el sistema.

---

**¡Gracias por usar UNS-ClaudeJP 3.0!** 🚀
