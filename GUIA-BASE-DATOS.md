# 💾 Guía de Base de Datos - UNS-ClaudeJP 3.0

## 🔍 Base de Datos Demo vs Original

### Estado Actual: Base de Datos DEMO

Por defecto, el sistema viene con **datos de demostración** para que puedas probar todas las funcionalidades inmediatamente.

#### Datos de Demo Incluidos:
- ✅ 1 usuario admin (admin / admin123)
- ✅ 5 fábricas de ejemplo
- ✅ 5 apartamentos
- ✅ 5 candidatos
- ✅ 5 empleados
- ✅ Registros de asistencia
- ✅ Solicitudes de ejemplo

**Archivo:** [`base-datos/01_init_database.sql`](base-datos/01_init_database.sql)

---

## 🎯 Opciones para tu Base de Datos Original

Tienes **4 opciones** para usar tus datos reales:

### Opción 1: Importar desde archivo .sql ⭐ RECOMENDADO

Si tienes un backup de PostgreSQL:

```bash
IMPORTAR-BD-ORIGINAL.bat
```

**Pasos:**
1. Coloca tu archivo `.sql` en `base-datos/`
2. Ejecuta `IMPORTAR-BD-ORIGINAL.bat`
3. Selecciona opción [1]
4. Ingresa el nombre del archivo
5. Confirma la importación

**Ejemplo:**
```
base-datos/
├── 01_init_database.sql  (demo)
└── mi_backup_real.sql    (tu BD original)
```

### Opción 2: Importar desde CSV/Excel

Si tienes archivos CSV o Excel:

**Método A - Por interfaz web:**
1. Inicia el sistema: `START.bat`
2. Abre: http://localhost:3000
3. Login: admin / admin123
4. Ve a cada sección (Empleados, Candidatos, etc.)
5. Usa el botón "Importar" o "Agregar"

**Método B - Script Python:**
```bash
# Coloca tus archivos .csv en base-datos/csv/
python scripts/import_csv.py
```

### Opción 3: Migrar desde otra PostgreSQL

Si tienes otra base de datos PostgreSQL corriendo:

**Paso 1 - Hacer backup de tu BD original:**
```bash
pg_dump -U usuario -d nombre_base_datos > backup.sql
```

**Paso 2 - Importar el backup:**
```bash
# Copia backup.sql a base-datos/
IMPORTAR-BD-ORIGINAL.bat
```

### Opción 4: Conectar a BD Externa

Si quieres usar una base de datos externa (no Docker):

**Edita `docker-compose.yml`:**

```yaml
backend:
  environment:
    DATABASE_URL: postgresql://usuario:password@host:5432/database
```

**Ejemplo:**
```yaml
DATABASE_URL: postgresql://uns_admin:mi_password@192.168.1.100:5432/uns_claudejp
```

Luego comenta o elimina el servicio `db` del `docker-compose.yml`.

---

## 📦 Backup de Base de Datos

### Crear Backup

```bash
BACKUP-BD.bat
```

**Qué hace:**
- ✅ Verifica que la BD esté corriendo
- ✅ Crea backup con fecha/hora
- ✅ Guarda en carpeta `backups/`
- ✅ Opción de comprimir (.tar.gz)
- ✅ Muestra lista de todos los backups

**Ejemplo de backup generado:**
```
backups/backup_2025-10-12_19-30-45.sql
```

### Restaurar Backup

```bash
IMPORTAR-BD-ORIGINAL.bat
# Selecciona opción [1]
# Ingresa: backups\backup_2025-10-12_19-30-45.sql
```

---

## 🔄 Flujos de Trabajo Comunes

### Caso 1: Primera vez - Probar con datos demo

```bash
# Instalar
INSTALAR.bat

# Usar datos demo (ya incluidos)
# Login: admin / admin123
```

### Caso 2: Primera vez - Usar datos reales desde inicio

```bash
# Instalar
INSTALAR.bat

# Importar datos reales
IMPORTAR-BD-ORIGINAL.bat
```

### Caso 3: Cambiar de demo a datos reales

```bash
# Hacer backup de datos demo (opcional)
BACKUP-BD.bat

# Importar datos reales
IMPORTAR-BD-ORIGINAL.bat
```

### Caso 4: Backup regular de producción

```bash
# Crear backup diario
BACKUP-BD.bat

# Guardar en otra ubicación
# Ejemplo: Copiar a USB, OneDrive, Google Drive
```

### Caso 5: Volver a datos demo

```bash
# Opción A - Reinstalar todo
REINSTALAR.bat

# Opción B - Solo resetear BD
IMPORTAR-BD-ORIGINAL.bat
# Selecciona: base-datos/01_init_database.sql
```

---

## 📊 Estructura de la Base de Datos

### Tablas Principales

| Tabla | Descripción | Registros Demo |
|-------|-------------|----------------|
| **users** | Usuarios del sistema | 1 admin |
| **factories** | Fábricas cliente | 5 ejemplos |
| **apartments** | Apartamentos | 5 ejemplos |
| **candidates** | Candidatos | 5 ejemplos |
| **employees** | Empleados | 5 ejemplos |
| **timer_cards** | Asistencia | 7 registros |
| **requests** | Solicitudes | 3 ejemplos |
| **salary_records** | Nómina | 0 (vacío) |

### Ver Datos Actuales

**Opción 1 - Por interfaz:**
```
http://localhost:3000
```

**Opción 2 - Por línea de comandos:**
```bash
docker exec -it uns-claudejp-db psql -U uns_admin -d uns_claudejp

# Ver tablas
\dt

# Ver datos
SELECT * FROM employees;
SELECT * FROM users;
```

---

## 🔒 Seguridad y Buenas Prácticas

### Credenciales por Defecto

⚠️ **IMPORTANTE:** Las credenciales demo son públicas:
```
Usuario BD: uns_admin
Password BD: 57UD10R
```

**Para producción:**
1. Cambia las credenciales en `docker-compose.yml`
2. Cambia el `SECRET_KEY` para JWT
3. Cambia el password del usuario admin

### Backups Recomendados

- **Diario:** Para producción activa
- **Semanal:** Para desarrollo
- **Antes de actualizaciones:** Siempre

### Almacenamiento de Backups

```
backups/
├── diarios/
│   ├── backup_2025-10-12.sql
│   └── backup_2025-10-13.sql
├── semanales/
│   └── backup_semana_41.sql
└── mensuales/
    └── backup_octubre_2025.sql
```

---

## 🛠️ Comandos Útiles

### Acceder a la Base de Datos

```bash
# Entrar a psql
docker exec -it uns-claudejp-db psql -U uns_admin -d uns_claudejp
```

### Comandos psql comunes

```sql
-- Ver todas las tablas
\dt

-- Describir estructura de tabla
\d employees

-- Ver cantidad de registros
SELECT COUNT(*) FROM employees;

-- Ver usuarios del sistema
SELECT id, username, email, role FROM users;

-- Salir
\q
```

### Ver logs de la BD

```bash
LOGS.bat
# Selecciona opción 4 (Base de Datos)
```

---

## 🐛 Solución de Problemas

### La importación falla

**Causa común:** El esquema del backup no coincide con el actual.

**Solución:**
1. Verifica que el backup sea de PostgreSQL
2. Verifica que las tablas existan: `\dt`
3. Revisa logs: `LOGS.bat` → opción 4

### Los datos no aparecen después de importar

**Solución:**
```bash
# Reiniciar backend para refrescar conexión
docker-compose restart backend
```

### Error "tabla no existe"

**Solución:**
```bash
# Reiniciar todo el sistema
STOP.bat
START.bat
```

### Quiero empezar de cero

**Opción 1 - Solo BD:**
```bash
IMPORTAR-BD-ORIGINAL.bat
# Selecciona: base-datos/01_init_database.sql
```

**Opción 2 - Todo el sistema:**
```bash
REINSTALAR.bat
```

---

## 📝 Scripts Relacionados

| Script | Propósito |
|--------|-----------|
| **BACKUP-BD.bat** | Crear backup de BD actual |
| **IMPORTAR-BD-ORIGINAL.bat** | Importar datos de archivo .sql |
| **REINSTALAR.bat** | Borrar todo y reinstalar con demo |
| **LOGS.bat** | Ver logs de la BD |

---

## 🔗 Archivos Importantes

- **`base-datos/01_init_database.sql`** - Script de datos demo
- **`base-datos/02_add_missing_columns.sql`** - Migraciones
- **`docker-compose.yml`** - Configuración de BD
- **`backups/`** - Carpeta de backups (se crea automáticamente)

---

## 📞 Necesitas Ayuda?

1. **Ver esta guía:** `GUIA-BASE-DATOS.md`
2. **Ver logs:** `LOGS.bat` → opción 4
3. **Documentación principal:** `README.md`
4. **Guía rápida:** `GUIA_RAPIDA.md`

---

## ✅ Resumen Rápido

```bash
# Crear backup
BACKUP-BD.bat

# Importar datos reales
IMPORTAR-BD-ORIGINAL.bat

# Volver a demo
REINSTALAR.bat
```

**Base de datos demo está en:**
- 📁 Archivo: `base-datos/01_init_database.sql`
- 🐳 Volumen Docker: `postgres_data`
- 🌐 Puerto: `localhost:5432`

**Tu base de datos original puede estar en:**
- 📁 Archivo `.sql` para importar
- 📊 CSV/Excel para importar por interfaz
- 🔗 BD externa para conectar
- 💾 Otro PostgreSQL para migrar

---

**¿Listo para usar tus datos reales?**
```bash
IMPORTAR-BD-ORIGINAL.bat
```
