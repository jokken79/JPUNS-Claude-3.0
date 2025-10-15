# 📊 EXPLICACIÓN COMPLETA DE LA BASE DE DATOS
**JPUNS-Claude 3.0 - Origen y Creación de la Base de Datos**

---

## 🗄️ ¿DE DÓNDE VIENE LA BASE DE DATOS?

### 1. **Base de Datos Principal: PostgreSQL**
- **Origen**: Imagen Docker `postgres:15-alpine`
- **Nombre**: `uns_claudejp`
- **Usuario**: `uns_admin`
- **Contraseña**: `57UD10R` (configurada en docker-compose.yml)

### 2. **Estructura y Datos Iniciales**
La base de datos se crea a través de un proceso automatizado con múltiples fuentes:

---

## 🏗️ PROCESO DE CREACIÓN (Paso a Paso)

### **Paso 1: Inicialización de PostgreSQL**
```yaml
# docker-compose.yml (líneas 11-13)
volumes:
  - ./base-datos/01_init_database.sql:/docker-entrypoint-initdb.d/01_init_database.sql:ro
```
- PostgreSQL automáticamente ejecuta todos los archivos `.sql` en `/docker-entrypoint-initdb.d/`
- El archivo `01_init_database.sql` crea toda la estructura inicial

### **Paso 2: Creación de Estructura**
**Archivo**: [`base-datos/01_init_database.sql`](base-datos/01_init_database.sql)

#### ¿Qué crea este archivo?
1. **Tablas Principales**:
   - `users` - Usuarios del sistema
   - `factories` - Fábricas/clientes
   - `candidates` - Candidatos a empleo
   - `employees` - Empleados (派遣社員)
   - `contract_workers` - Contratistas (請負社員)
   - `staff` - Personal interno (スタッフ)
   - `requests` - Solicitudes (vacaciones, etc.)
   - `timer_cards` - Registros de tiempo
   - `salary_records` - Registros salariales

2. **Datos de Prueba Iniciales**:
   - 5 fábricas predefinidas (PMI Otsuka, Nippi, Yamaha, Toyota, Honda)
   - 5 apartamentos disponibles
   - Estructura completa sin datos personales

### **Paso 3: Creación de Usuarios**
**Script**: [`backend/scripts/create_admin_user.py`](backend/scripts/create_admin_user.py)

#### Usuarios Creados:
1. **Administrador Principal**:
   - Username: `admin`
   - Password: `admin123`
   - Email: `admin@uns-kikaku.com`
   - Rol: `SUPER_ADMIN`

2. **Coordinador de Prueba**:
   - Username: `coordinator`
   - Password: `coord123`
   - Email: `coordinator@uns-kikaku.com`
   - Rol: `COORDINATOR`

### **Paso 4: Importación de Datos Reales**
**Script**: [`backend/scripts/import_data.py`](backend/scripts/import_data.py)

#### Fuentes de Datos:
1. **Fábricas**: Archivos JSON en `config/factories/`
   - Ejemplo: `Factory-01_瑞陵精機株式会社_恵那工場.json`
   - Contiene configuración completa de cada fábrica

2. **Empleados**: Archivo Excel `config/employee_master.xlsm`
   - Hoja `派遣社員` - Empleados dispatch
   - Hoja `請負社員` - Empleados contratistas
   - Hoja `スタッフ` - Personal interno

---

## 📋 ORIGEN DE LOS DATOS POR CATEGORÍA

### 👥 **Usuarios**
- **Fuente**: Script `create_admin_user.py`
- **Datos**: Creados automáticamente (admin, coordinator)
- **Propósito**: Acceso inicial al sistema

### 🏭 **Fábricas**
- **Fuente**: Múltiple
  1. **Datos Iniciales**: `01_init_database.sql` (5 fábricas de prueba)
  2. **Datos Reales**: Archivos JSON en `config/factories/`
- **Ejemplo de Archivo**: `Factory-01_瑞陵精機株式会社_恵那工場.json`
- **Contenido**: Nombre, dirección, teléfono, configuración completa

### 👤 **Empleados**
- **Fuente**: `config/employee_master.xlsm`
- **Tipos**:
  - **派遣社員**: Empleados en modo dispatch
  - **請負社員**: Empleados contratistas
  - **スタッフ**: Personal interno
- **Datos Importados**: Todos los campos del Excel (nombre, salario, visa, etc.)

### 🏠 **Apartamentos**
- **Fuente**: `01_init_database.sql`
- **Datos**: 5 apartamentos de prueba
- **Propósito**: Sistema de alojamiento de empleados

---

## 🔄 FLUJO COMPLETO DE INICIALIZACIÓN

### **En START-UNICO.bat**:
```batch
1. Iniciar contenedor PostgreSQL
2. Esperar a que BD esté lista (pg_isready)
3. Ejecutar 01_init_database.sql (automático)
4. Ejecutar create_admin_user.py
5. Ejecutar import_data.py
6. Sistema listo para usar
```

### **En docker-compose.yml**:
```yaml
# El servicio 'importer' se ejecuta primero
importer:
  depends_on:
    db:
      condition: service_healthy
  command: >
    sh -c "
      python scripts/create_admin_user.py &&
      python scripts/import_data.py
    "

# El backend espera a que el importer termine
backend:
  depends_on:
    db:
      condition: service_healthy
    importer:
      condition: service_completed_successfully
```

---

## 📁 ARCHIVOS CLAVE

### **Base de Datos**:
- [`base-datos/01_init_database.sql`](base-datos/01_init_database.sql) - Estructura inicial
- [`base-datos/verify_database.py`](base-datos/verify_database.py) - Verificación

### **Scripts de Inicialización**:
- [`backend/scripts/create_admin_user.py`](backend/scripts/create_admin_user.py) - Usuarios
- [`backend/scripts/import_data.py`](backend/scripts/import_data.py) - Datos reales

### **Fuentes de Datos**:
- [`config/factories/`](config/factories/) - Configuración de fábricas
- [`config/employee_master.xlsm`](config/employee_master.xlsm) - Maestro de empleados
- [`config/factories_index.json`](config/factories_index.json) - Índice de fábricas

---

## 🔐 CREDENCIALES DE ACCESO

### **Base de Datos**:
- **Host**: `localhost:5432` (fuera de Docker)
- **Host**: `db:5432` (dentro de Docker)
- **Database**: `uns_claudejp`
- **Username**: `uns_admin`
- **Password**: `57UD10R`

### **Sistema Web**:
- **Admin**: `admin` / `admin123`
- **Coordinator**: `coordinator` / `coord123`

---

## 🛠️ PERSONALIZACIÓN

### **Cambiar Contraseñas**:
1. Editar `.env` para cambiar `POSTGRES_PASSWORD`
2. Editar `docker-compose.yml` para cambiar valores por defecto
3. Modificar `create_admin_user.py` para cambiar usuarios iniciales

### **Agregar Nuevas Fábricas**:
1. Crear archivo JSON en `config/factories/`
2. Actualizar `factories_index.json`
3. Reiniciar servicios

### **Importar Nuevos Empleados**:
1. Actualizar `employee_master.xlsm`
2. Ejecutar script de importación manualmente

---

## 🚨 IMPORTANTE

### **Persistencia de Datos**:
- Los datos persisten en volumen Docker `postgres_data`
- Solo se recrea la estructura si se elimina el volumen
- Los datos reales NO se sobrescriben automáticamente

### **Seguridad**:
- Cambiar contraseñas por defecto en producción
- El archivo `.env` no está incluido en Git
- Usar variables de entorno para datos sensibles

### **Respaldo**:
- Usar `BACKUP-BD.bat` para crear respaldos
- Los respaldos se guardan en `backups/`

---

## 📊 RESUMEN

| Componente | Fuente | ¿Cuándo se crea? | ¿Qué contiene? |
|------------|--------|------------------|----------------|
| **Estructura BD** | `01_init_database.sql` | Al iniciar PostgreSQL | Tablas, índices, datos básicos |
| **Usuarios** | `create_admin_user.py` | Después de estructura BD | Admin, coordinator |
| **Fábricas** | JSON en `config/factories/` | Después de usuarios | Configuración real de fábricas |
| **Empleados** | `employee_master.xlsm` | Después de fábricas | Todos los empleados reales |

**La base de datos es una combinación de estructura predefinida + datos reales importados de archivos Excel y JSON.**

---

**Última actualización**: 2025-10-15  
**Versión**: 3.1.0