-- Add missing columns to employees table
-- These columns exist in the Python model but not in the database

-- Add current_hire_date (現入社 - Fecha de entrada a fábrica actual)
ALTER TABLE employees ADD COLUMN current_hire_date DATE;

-- Add jikyu_revision_date (時給改定 - Fecha de revisión de salario)
ALTER TABLE employees ADD COLUMN jikyu_revision_date DATE;

-- Add assignment_location (配属先 - Ubicación de asignación)
ALTER TABLE employees ADD COLUMN assignment_location VARCHAR(200);

-- Add assignment_line (配属ライン - Línea de asignación)
ALTER TABLE employees ADD COLUMN assignment_line VARCHAR(200);

-- Add job_description (仕事内容 - Descripción del trabajo)
ALTER TABLE employees ADD COLUMN job_description TEXT;

-- Add billing_revision_date (請求改定 - Fecha de revisión de facturación)
ALTER TABLE employees ADD COLUMN billing_revision_date DATE;

-- Add assignment_location, assignment_line, job_description (already added above)

-- Add timer_cards, salary_calculations, requests, contracts relationships
-- These are handled by SQLAlchemy relationships, no DB changes needed

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_employees_current_hire_date ON employees(current_hire_date);
CREATE INDEX IF NOT EXISTS idx_employees_assignment_location ON employees(assignment_location);
CREATE INDEX IF NOT EXISTS idx_employees_assignment_line ON employees(assignment_line);