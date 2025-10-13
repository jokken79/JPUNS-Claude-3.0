-- ============================================
-- JPUNS-CLAUDE 3.0 - FIX CANDIDATE STATUS ENUM COMPLETE
-- Solución completa para el enum candidate_status
-- ============================================

-- Verificar que estamos en la BD correcta
\c uns_claudejp

-- Primero eliminar la dependencia del valor por defecto
ALTER TABLE candidates ALTER COLUMN status DROP DEFAULT;

-- Convertir a text para poder cambiar el tipo
ALTER TABLE candidates ALTER COLUMN status TYPE text;

-- Actualizar todos los valores a mayúsculas
UPDATE candidates SET status = UPPER(status);

-- Eliminar el tipo enum antiguo
DROP TYPE IF EXISTS candidate_status CASCADE;

-- Crear el nuevo tipo enum con valores en mayúsculas
CREATE TYPE candidate_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'HIRED');

-- Convertir la columna al nuevo tipo enum
ALTER TABLE candidates ALTER COLUMN status TYPE candidate_status USING status::candidate_status_new;

-- Establecer el valor por defecto
ALTER TABLE candidates ALTER COLUMN status SET DEFAULT 'PENDING';

-- Verificar los cambios
SELECT 'Enum candidate_status corregido exitosamente' AS resultado;

-- Mostrar los valores del enum
SELECT unnest(enum_range(NULL::candidate_status)) AS enum_values;

-- Verificar los datos en la tabla
SELECT status, COUNT(*) FROM candidates GROUP BY status;