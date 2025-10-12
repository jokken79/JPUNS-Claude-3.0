# Solución: Error al Cargar Empleados

## 🔍 Problema

Al intentar cargar la lista de empleados en el frontend, aparecía un error 500 (Internal Server Error) con el mensaje:

```
column employees.emergency_contact does not exist
column employees.current_hire_date does not exist
```

## 🐛 Causa Raíz

Había **discrepancias entre el modelo SQLAlchemy y la estructura real de la tabla `employees` en PostgreSQL**:

### Campos Incorrectos en el Modelo
1. **emergency_contact** → Debería ser **emergency_contact_name**
2. **emergency_phone** → Debería ser **emergency_contact_phone**
3. Faltaba el campo **emergency_contact_relationship**

### Campos Faltantes en la Base de Datos
La tabla `employees` no tenía muchos campos que el modelo estaba intentando usar:
- `current_hire_date`
- `jikyu` (salario por hora)
- `jikyu_revision_date`
- `assignment_location`
- `assignment_line`
- `job_description`
- `hourly_rate_charged`
- Y muchos más...

## ✅ Solución Aplicada

### 1. Corrección del Modelo (`backend/app/models/models.py`)

Se corrigieron los nombres de los campos de contacto de emergencia en las clases:
- `Employee`
- `ContractWorker`
- `Staff`

**Antes:**
```python
emergency_contact = Column(String(100))
emergency_phone = Column(String(20))
```

**Después:**
```python
emergency_contact_name = Column(String(100))
emergency_contact_phone = Column(String(20))
emergency_contact_relationship = Column(String(50))
```

También se cambió `jikyu` de `nullable=False` a nullable para permitir datos históricos.

### 2. Migración de Base de Datos

Se agregaron las columnas faltantes a la tabla `employees`:

```sql
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS current_hire_date DATE,
ADD COLUMN IF NOT EXISTS jikyu INTEGER,
ADD COLUMN IF NOT EXISTS jikyu_revision_date DATE,
ADD COLUMN IF NOT EXISTS assignment_location VARCHAR(200),
ADD COLUMN IF NOT EXISTS assignment_line VARCHAR(200),
ADD COLUMN IF NOT EXISTS job_description TEXT,
ADD COLUMN IF NOT EXISTS hourly_rate_charged INTEGER,
ADD COLUMN IF NOT EXISTS billing_revision_date DATE,
ADD COLUMN IF NOT EXISTS profit_difference INTEGER,
ADD COLUMN IF NOT EXISTS standard_compensation INTEGER,
ADD COLUMN IF NOT EXISTS health_insurance INTEGER,
ADD COLUMN IF NOT EXISTS nursing_insurance INTEGER,
ADD COLUMN IF NOT EXISTS pension_insurance INTEGER,
ADD COLUMN IF NOT EXISTS social_insurance_date DATE,
ADD COLUMN IF NOT EXISTS license_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS license_expire_date DATE,
ADD COLUMN IF NOT EXISTS commute_method VARCHAR(50),
ADD COLUMN IF NOT EXISTS optional_insurance_expire DATE,
ADD COLUMN IF NOT EXISTS japanese_level VARCHAR(50),
ADD COLUMN IF NOT EXISTS career_up_5years BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS entry_request_date DATE,
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS apartment_id INTEGER,
ADD COLUMN IF NOT EXISTS apartment_start_date DATE,
ADD COLUMN IF NOT EXISTS apartment_move_out_date DATE,
ADD COLUMN IF NOT EXISTS apartment_rent INTEGER,
ADD COLUMN IF NOT EXISTS yukyu_total INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS yukyu_used INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS yukyu_remaining INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS termination_date DATE,
ADD COLUMN IF NOT EXISTS termination_reason TEXT;
```

### 3. Migración de Datos

Se copiaron datos de campos antiguos a los nuevos:

```sql
-- Actualizar estado activo
UPDATE employees SET is_active = TRUE WHERE status = 'active';
UPDATE employees SET is_active = FALSE WHERE status <> 'active';

-- Copiar fechas de contrato a current_hire_date
UPDATE employees SET current_hire_date = contract_start_date WHERE current_hire_date IS NULL;

-- Copiar salario por hora
UPDATE employees SET jikyu = hourly_wage WHERE jikyu IS NULL AND hourly_wage IS NOT NULL;
```

## 📁 Archivos Modificados

1. **[backend/app/models/models.py](backend/app/models/models.py)** - Corregidos nombres de campos
2. **[base-datos/02_add_missing_columns.sql](base-datos/02_add_missing_columns.sql)** - Script de migración creado

## ✅ Resultado

### Antes
```
ERROR 500: column employees.emergency_contact does not exist
```

### Después
```
Status Code: 200
SUCCESS! Found 5 employees
```

## 🧪 Verificación

```bash
# 1. Probar el endpoint de empleados
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"

# Usar el token obtenido
curl -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/employees
```

O simplemente:
1. Abre http://localhost:3000
2. Login con: `admin` / `admin123`
3. Ve a la sección "Empleados" (従業員)
4. Deberías ver la lista de 5 empleados sin errores

## 📊 Estado Actual

| Componente | Estado | Detalles |
|------------|--------|----------|
| Base de Datos | ✅ OK | Todas las columnas necesarias agregadas |
| Modelo Backend | ✅ OK | Campos corregidos y sincronizados |
| API Employees | ✅ OK | Devuelve 200 con lista de empleados |
| Frontend | ✅ OK | Puede cargar y mostrar empleados |

## 🔧 Mantenimiento Futuro

### Si el error vuelve a aparecer:

1. **Verificar estructura de tabla:**
   ```bash
   docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "\d employees"
   ```

2. **Verificar modelo:**
   Revisar [backend/app/models/models.py](backend/app/models/models.py) líneas 140-230

3. **Reaplicar migración si es necesario:**
   ```bash
   docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -f /app/base-datos/02_add_missing_columns.sql
   docker-compose restart backend
   ```

## 📝 Notas Técnicas

### Problema de Sincronización Modelo-Base de Datos

Este tipo de error es común cuando:
- Se usa un ORM (SQLAlchemy) sin migraciones automáticas
- El modelo evoluciona independientemente de la base de datos
- No se usa Alembic u otra herramienta de migración

### Recomendaciones:

1. **Usar Alembic** para gestionar migraciones de forma automática
2. **Sincronizar modelo con BD** siempre que se hagan cambios
3. **Documentar la estructura** esperada en ambos lados
4. **Usar tests de integración** que verifiquen la estructura

## 🎉 Solución Completada

- ✅ Error identificado y corregido
- ✅ Modelo sincronizado con base de datos
- ✅ Migración aplicada exitosamente
- ✅ API funcionando correctamente
- ✅ Frontend cargando empleados sin errores
- ✅ Script de migración guardado para referencia futura

---

**Fecha de solución:** 2025-10-12
**Tiempo de resolución:** ~20 minutos
**Problema:** Discrepancia modelo-base de datos
**Impacto:** Módulo de empleados completamente funcional
