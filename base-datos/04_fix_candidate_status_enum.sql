-- ============================================
-- JPUNS-CLAUDE 3.0 - FIX CANDIDATE STATUS ENUM
-- Actualizar los valores del enum candidate_status a mayúsculas
-- ============================================

-- Verificar que estamos en la BD correcta
\c uns_claudejp

-- Crear el nuevo tipo enum con valores en mayúsculas
CREATE TYPE candidate_status_new AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'HIRED');

-- Actualizar la tabla candidates para usar el nuevo tipo
-- Primero convertimos la columna a text, luego al nuevo enum
ALTER TABLE candidates ALTER COLUMN status TYPE text USING status::text;
ALTER TABLE candidates ALTER COLUMN status TYPE candidate_status_new USING status::candidate_status_new;

-- Actualizar los valores existentes a mayúsculas
UPDATE candidates SET status = 'PENDING' WHERE status = 'pending';
UPDATE candidates SET status = 'APPROVED' WHERE status = 'approved';
UPDATE candidates SET status = 'REJECTED' WHERE status = 'rejected';
UPDATE candidates SET status = 'HIRED' WHERE status = 'hired';

-- Eliminar el viejo tipo enum
DROP TYPE IF EXISTS candidate_status;

-- Renombrar el nuevo tipo
ALTER TYPE candidate_status_new RENAME TO candidate_status;

-- Establecer el valor por defecto
ALTER TABLE candidates ALTER COLUMN status SET DEFAULT 'PENDING';

-- Verificar los cambios
SELECT 'Enum candidate_status actualizado exitosamente' AS resultado;

-- Mostrar los valores del enum
SELECT unnest(enum_range(NULL::candidate_status)) AS enum_values;

-- Verificar los datos en la tabla
SELECT status, COUNT(*) FROM candidates GROUP BY status;