-- ============================================
-- JPUNS-CLAUDE 3.0 - ADD MISSING COLUMNS
-- Agregar columnas faltantes en la tabla employees
-- ============================================

-- Verificar que estamos en la BD correcta
\c uns_claudejp

-- Agregar columnas faltantes en employees
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
ADD COLUMN IF NOT EXISTS apartment_id INTEGER REFERENCES apartments(id),
ADD COLUMN IF NOT EXISTS apartment_start_date DATE,
ADD COLUMN IF NOT EXISTS apartment_move_out_date DATE,
ADD COLUMN IF NOT EXISTS apartment_rent INTEGER,
ADD COLUMN IF NOT EXISTS yukyu_total INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS yukyu_used INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS yukyu_remaining INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS termination_date DATE,
ADD COLUMN IF NOT EXISTS termination_reason TEXT;

-- Actualizar status para que use is_active
UPDATE employees SET is_active = TRUE WHERE status = 'active';
UPDATE employees SET is_active = FALSE WHERE status != 'active';

-- Copiar contract_start_date a current_hire_date si existe
UPDATE employees SET current_hire_date = contract_start_date WHERE current_hire_date IS NULL;

-- Copiar hourly_wage a jikyu si existe
UPDATE employees SET jikyu = hourly_wage WHERE jikyu IS NULL AND hourly_wage IS NOT NULL;

-- Mensaje de éxito
SELECT 'Columnas agregadas exitosamente a la tabla employees' AS resultado;

-- Verificar estructura actualizada
\d employees
