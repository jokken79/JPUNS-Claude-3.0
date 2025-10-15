# Guía de Gestión de la Base de Datos

Este documento centraliza toda la información sobre la arquitectura, gestión y mantenimiento de la base de datos PostgreSQL del sistema UNS-ClaudeJP 3.0.

## 1. Arquitectura y Configuración

### Core Technology
- **Sistema:** PostgreSQL (Versión 15)
- **Entorno:** Se ejecuta dentro de un contenedor Docker para consistencia y portabilidad.
- **Imagen Docker:** `postgres:15-alpine`

### Credenciales de Acceso

| Parámetro | Valor | Descripción |
|---|---|---|
| **Host (local)** | `localhost:5432` | Para conectar desde herramientas en tu PC |
| **Host (Docker)** | `db:5432` | Para conectar desde otros contenedores |
| **Database** | `uns_claudejp` | Nombre de la base de datos |
| **Username** | `uns_admin` | Usuario con permisos de administrador |
| **Password** | `57UD10R` | Contraseña por defecto (cambiar en producción) |

### Proceso de Creación e Inicialización

La base de datos se crea y se puebla automáticamente al iniciar el sistema por primera vez, siguiendo estos pasos:

1.  **Creación de Estructura (SQL):** El archivo `base-datos/01_init_database.sql` se ejecuta automáticamente para crear todas las tablas, tipos `ENUM` y relaciones iniciales. Incluye datos básicos como fábricas y apartamentos de demostración.
2.  **Creación de Usuarios (Python):** El script `backend/scripts/create_admin_user.py` crea los usuarios iniciales del sistema (ej. `admin` y `coordinator`).
3.  **Importación de Datos Reales (Python):** El script `backend/scripts/import_data.py` lee los archivos de configuración en la carpeta `config/` (como `employee_master.xlsm` y los JSON de las fábricas) para poblar la base de datos con datos de empleados y fábricas reales.

## 2. Herramientas de Gestión

El sistema ofrece dos interfaces para gestionar la base de datos, accesibles desde el menú lateral.

### DateBaseJP (Gestión Integrada)

- **Ruta:** `/database`
- **Descripción:** Una interfaz web simple e integrada en la aplicación, ideal para operaciones diarias y seguras.
- **Funcionalidades:**
    - Visualizar tablas y datos con paginación.
    - Edición rápida de celdas individuales.
    - Búsqueda de texto simple en todas las columnas.
    - Importación y exportación de datos en formato CSV.
- **Limitaciones:** No permite edición masiva, consultas SQL complejas ni cambios en la estructura de la base de datos.

### AdminerDBJP (Administración Avanzada)

- **Ruta:** `/adminer`
- **Descripción:** Una instancia completa de **Adminer**, una potente herramienta de gestión de bases de datos. Proporciona acceso total y sin restricciones.
- **Funcionalidades:**
    - Ejecutar cualquier consulta SQL.
    - Crear, modificar y eliminar tablas, índices y vistas.
    - Gestión de usuarios y permisos de la base de datos.
    - Visión completa de las tablas sin paginación.
    - Importación y exportación en múltiples formatos (SQL, CSV, etc.).
- **⚠️ Advertencia:** Usar con precaución. Al ser una herramienta con acceso completo, es posible realizar cambios destructivos en la base de datos.

### Comparación Rápida

| Característica | DateBaseJP (Simple) | AdminerDBJP (Avanzado) |
|---|---|---|
| Vista completa | ❌ (Paginado) | ✅ |
| Edición masiva | ❌ | ✅ |
| Ejecutar SQL | ❌ | ✅ |
| Modificar estructura | ❌ | ✅ |
| Interfaz integrada | ✅ | ❌ (Interfaz estándar de Adminer) |
| Seguridad | ✅ (Operaciones limitadas) | ❌ (Requiere conocimiento) |

**Recomendación:** Usa **DateBaseJP** para el día a día y **AdminerDBJP** solo cuando necesites realizar tareas administrativas complejas.

## 3. Flujos de Trabajo Comunes

### Iniciar por Primera Vez
- **Con datos de demo:** Simplemente ejecuta `INSTALAR.bat` y luego `START.bat`. El sistema se iniciará con datos de prueba.
- **Con datos reales:** Después de `INSTALAR.bat`, usa `IMPORTAR-BD-ORIGINAL.bat` para cargar tu archivo `.sql` antes de iniciar el sistema.

### Backups (Copias de Seguridad)
- **Crear un backup:** Ejecuta `BACKUP-BD.bat`. El archivo se guardará en la carpeta `backups/` con la fecha y hora actual.
- **Restaurar un backup:** Ejecuta `IMPORTAR-BD-ORIGINAL.bat` y selecciona el archivo de backup que deseas restaurar.

### Volver a los Datos de Demostración
- Si quieres empezar de cero con los datos de prueba, la forma más segura es ejecutar `REINSTALAR.bat`. Esto borrará todo (incluida la base de datos) y reinstalará el sistema desde el principio.

## 4. Estructura de Tablas Principales

| Tabla | Descripción |
|---|---|
| `users` | Almacena los usuarios que pueden iniciar sesión en el sistema. |
| `factories` | Contiene la información de las fábricas o empresas cliente. |
| `candidates` | Registra a los candidatos antes de ser contratados. |
| `employees` | El maestro de empleados (派遣社員). Contiene toda su información personal y laboral. |
| `contract_workers` | Empleados contratistas (請負社員). |
| `staff` | Personal interno de la oficina (スタッフ). |
| `timer_cards` | Guarda los registros de entrada y salida de los empleados. |
| `requests` | Almacena solicitudes como vacaciones, días libres, etc. |
| `salary_records` | Guarda los registros de nómina para el cálculo de salarios. |

## 5. Acceso Directo y Comandos Útiles

Para usuarios avanzados, es posible acceder directamente a la base de datos a través de la línea de comandos.

1.  **Acceder a psql:**
    ```bash
    docker exec -it uns-claudejp-db psql -U uns_admin -d uns_claudejp
    ```

2.  **Comandos `psql` útiles:**
    - `\dt`: Listar todas las tablas.
    - `\d employees`: Describir la estructura de la tabla `employees`.
    - `SELECT * FROM users;`: Ver todos los registros de la tabla `users`.
    - `SELECT COUNT(*) FROM employees;`: Contar el número de empleados.
    - `\q`: Salir de psql.
