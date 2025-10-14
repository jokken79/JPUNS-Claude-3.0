-- ============================================
-- JPUNS-CLAUDE 3.0 - INIT DATABASE
-- Base de Datos Completa con Datos de Prueba
-- ============================================

-- Configurar encoding
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- Función para logging
CREATE OR REPLACE FUNCTION log_message(message TEXT) RETURNS void AS $$
BEGIN
    RAISE NOTICE '%', message;
END;
$$ LANGUAGE plpgsql;

SELECT log_message('========================================');
SELECT log_message('JPUNS-CLAUDE 3.0 - INICIALIZACIÓN BD');
SELECT log_message('========================================');

-- ============================================
-- LIMPIEZA (si es necesario)
-- ============================================
SELECT log_message('Limpiando base de datos existente...');

DROP TABLE IF EXISTS timer_cards CASCADE;
DROP TABLE IF EXISTS salary_records CASCADE;
DROP TABLE IF EXISTS requests CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS apartments CASCADE;
DROP TABLE IF EXISTS candidates CASCADE;
DROP TABLE IF EXISTS factories CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Eliminar tipos ENUM si existen
DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS candidate_status CASCADE;
DROP TYPE IF EXISTS document_type CASCADE;
DROP TYPE IF EXISTS request_type CASCADE;
DROP TYPE IF EXISTS request_status CASCADE;
DROP TYPE IF EXISTS shift_type CASCADE;

SELECT log_message('✓ Base de datos limpiada');

-- ============================================
-- EXTENSIONES
-- ============================================
SELECT log_message('Instalando extensiones...');

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

SELECT log_message('✓ Extensiones instaladas');

-- ============================================
-- TIPOS ENUM
-- ============================================
SELECT log_message('Creando tipos ENUM...');

CREATE TYPE user_role AS ENUM ('SUPER_ADMIN', 'ADMIN', 'COORDINATOR', 'KANRININSHA', 'EMPLOYEE', 'CONTRACT_WORKER');
CREATE TYPE candidate_status AS ENUM ('pending', 'approved', 'rejected', 'hired');
CREATE TYPE document_type AS ENUM ('rirekisho', 'zairyu_card', 'license', 'contract', 'other');
CREATE TYPE request_type AS ENUM ('yukyu', 'hankyu', 'ikkikokoku', 'taisha');
CREATE TYPE request_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE shift_type AS ENUM ('asa', 'hiru', 'yoru', 'other');

SELECT log_message('✓ Tipos ENUM creados');

-- ============================================
-- TABLAS PRINCIPALES
-- ============================================

-- Tabla: users
SELECT log_message('Creando tabla: users');
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'EMPLOYEE',
    full_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla users creada');

-- Tabla: factories
SELECT log_message('Creando tabla: factories');
CREATE TABLE factories (
    id SERIAL PRIMARY KEY,
    factory_id VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    contact_person VARCHAR(100),
    config JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla factories creada');

-- Tabla: apartments
SELECT log_message('Creando tabla: apartments');
CREATE TABLE apartments (
    id SERIAL PRIMARY KEY,
    apartment_code VARCHAR(50) UNIQUE NOT NULL,
    address TEXT NOT NULL,
    monthly_rent INTEGER NOT NULL,
    capacity INTEGER,
    is_available BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla apartments creada');

-- Tabla: candidates
SELECT log_message('Creando tabla: candidates');
CREATE TABLE candidates (
    id SERIAL PRIMARY KEY,
    rirekisho_id VARCHAR(20) UNIQUE NOT NULL,
    full_name_kanji VARCHAR(100),
    full_name_kana VARCHAR(100),
    full_name_roman VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(10),
    nationality VARCHAR(50),
    address TEXT,
    phone VARCHAR(20),
    mobile VARCHAR(20),
    email VARCHAR(100),
    photo_url VARCHAR(255),
    status candidate_status DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    -- Campos adicionales de migración 003
    postal_code VARCHAR(20),
    visa_type VARCHAR(100),
    visa_expiry DATE,
    residence_card_number VARCHAR(100),
    japanese_level VARCHAR(50),
    english_level VARCHAR(50),
    education_level VARCHAR(100),
    work_experience TEXT,
    skills TEXT,
    notes TEXT
);
SELECT log_message('✓ Tabla candidates creada');

-- Tabla: employees
SELECT log_message('Creando tabla: employees');
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    hakenmoto_id INTEGER UNIQUE NOT NULL,
    rirekisho_id VARCHAR(20) REFERENCES candidates(rirekisho_id),
    factory_id VARCHAR(20) REFERENCES factories(factory_id),
    hakensaki_shain_id VARCHAR(50),
    full_name_kanji VARCHAR(100) NOT NULL,
    full_name_kana VARCHAR(100),
    photo_url VARCHAR(255),
    date_of_birth DATE,
    gender VARCHAR(10),
    nationality VARCHAR(50),
    zairyu_card_number VARCHAR(50),
    zairyu_expire_date DATE,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relationship VARCHAR(50),
    hire_date DATE,
    current_hire_date DATE,
    jikyu INTEGER,
    jikyu_revision_date DATE,
    "position" VARCHAR(100),
    contract_type VARCHAR(50),
    assignment_location VARCHAR(200),
    assignment_line VARCHAR(200),
    job_description TEXT,
    hourly_rate_charged INTEGER,
    billing_revision_date DATE,
    profit_difference INTEGER,
    standard_compensation INTEGER,
    health_insurance INTEGER,
    nursing_insurance INTEGER,
    pension_insurance INTEGER,
    social_insurance_date DATE,
    visa_type VARCHAR(50),
    license_type VARCHAR(100),
    license_expire_date DATE,
    commute_method VARCHAR(50),
    optional_insurance_expire DATE,
    japanese_level VARCHAR(50),
    career_up_5years BOOLEAN DEFAULT FALSE,
    entry_request_date DATE,
    notes TEXT,
    postal_code VARCHAR(10),
    apartment_id INTEGER REFERENCES apartments(id),
    apartment_start_date DATE,
    apartment_move_out_date DATE,
    apartment_rent INTEGER,
    yukyu_total INTEGER DEFAULT 0,
    yukyu_used INTEGER DEFAULT 0,
    yukyu_remaining INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    termination_date DATE,
    termination_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla employees creada');

-- Tabla: contract_workers
SELECT log_message('Creando tabla: contract_workers');
CREATE TABLE contract_workers (
    id SERIAL PRIMARY KEY,
    hakenmoto_id INTEGER UNIQUE NOT NULL,
    rirekisho_id VARCHAR(20) REFERENCES candidates(rirekisho_id),
    factory_id VARCHAR(20) REFERENCES factories(factory_id),
    hakensaki_shain_id VARCHAR(50),
    full_name_kanji VARCHAR(100) NOT NULL,
    full_name_kana VARCHAR(100),
    photo_url VARCHAR(255),
    date_of_birth DATE,
    gender VARCHAR(10),
    nationality VARCHAR(50),
    zairyu_card_number VARCHAR(50),
    zairyu_expire_date DATE,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relationship VARCHAR(50),
    hire_date DATE,
    current_hire_date DATE,
    jikyu INTEGER,
    jikyu_revision_date DATE,
    "position" VARCHAR(100),
    contract_type VARCHAR(50),
    assignment_location VARCHAR(200),
    assignment_line VARCHAR(200),
    job_description TEXT,
    hourly_rate_charged INTEGER,
    billing_revision_date DATE,
    profit_difference INTEGER,
    standard_compensation INTEGER,
    health_insurance INTEGER,
    nursing_insurance INTEGER,
    pension_insurance INTEGER,
    social_insurance_date DATE,
    visa_type VARCHAR(50),
    license_type VARCHAR(100),
    license_expire_date DATE,
    commute_method VARCHAR(50),
    optional_insurance_expire DATE,
    japanese_level VARCHAR(50),
    career_up_5years BOOLEAN DEFAULT FALSE,
    entry_request_date DATE,
    notes TEXT,
    postal_code VARCHAR(10),
    apartment_id INTEGER REFERENCES apartments(id),
    apartment_start_date DATE,
    apartment_move_out_date DATE,
    apartment_rent INTEGER,
    yukyu_total INTEGER DEFAULT 0,
    yukyu_used INTEGER DEFAULT 0,
    yukyu_remaining INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    termination_date DATE,
    termination_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla contract_workers creada');

-- Tabla: staff
SELECT log_message('Creando tabla: staff');
CREATE TABLE staff (
    id SERIAL PRIMARY KEY,
    staff_id INTEGER UNIQUE NOT NULL,
    rirekisho_id VARCHAR(20) REFERENCES candidates(rirekisho_id),
    full_name_kanji VARCHAR(100),
    full_name_kana VARCHAR(100),
    photo_url VARCHAR(255),
    date_of_birth DATE,
    gender VARCHAR(10),
    nationality VARCHAR(50),
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relationship VARCHAR(50),
    postal_code VARCHAR(10),
    hire_date DATE,
    "position" VARCHAR(100),
    department VARCHAR(100),
    monthly_salary INTEGER,
    health_insurance INTEGER,
    nursing_insurance INTEGER,
    pension_insurance INTEGER,
    social_insurance_date DATE,
    yukyu_total INTEGER DEFAULT 0,
    yukyu_used INTEGER DEFAULT 0,
    yukyu_remaining INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    termination_date DATE,
    termination_reason TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla staff creada');

-- Tabla: extra_workers (renombrada para evitar duplicidad)
SELECT log_message('Creando tabla: extra_workers');
CREATE TABLE extra_workers (
    id SERIAL PRIMARY KEY,
    hakenmoto_id INTEGER UNIQUE NOT NULL,
    full_name_kanji VARCHAR(100),
    full_name_kana VARCHAR(100),
    gender VARCHAR(10),
    nationality VARCHAR(50),
    hire_date DATE,
    jikyu INTEGER,
    contract_type VARCHAR(50) DEFAULT '請負',
    is_active BOOLEAN DEFAULT TRUE,
    termination_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla extra_workers creada');

-- Tabla: assistants (renombrada para evitar duplicidad)
SELECT log_message('Creando tabla: assistants');
CREATE TABLE assistants (
    id SERIAL PRIMARY KEY,
    staff_id INTEGER UNIQUE NOT NULL,
    full_name_kanji VARCHAR(100),
    full_name_kana VARCHAR(100),
    monthly_salary INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla assistants creada');

-- Tabla: requests
SELECT log_message('Creando tabla: requests');
CREATE TABLE requests (
    id SERIAL PRIMARY KEY,
    hakenmoto_id INTEGER REFERENCES employees(hakenmoto_id),
    request_type request_type NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    reason TEXT,
    status request_status DEFAULT 'pending',
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla requests creada');

-- Tabla: timer_cards
SELECT log_message('Creando tabla: timer_cards');
CREATE TABLE timer_cards (
    id SERIAL PRIMARY KEY,
    hakenmoto_id INTEGER REFERENCES employees(hakenmoto_id),
    work_date DATE NOT NULL,
    shift_type shift_type,
    clock_in TIME,
    clock_out TIME,
    break_minutes INTEGER DEFAULT 0,
    overtime_minutes INTEGER DEFAULT 0,
    notes TEXT,
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(hakenmoto_id, work_date)
);
SELECT log_message('✓ Tabla timer_cards creada');

-- Tabla: salary_records
SELECT log_message('Creando tabla: salary_records');
CREATE TABLE salary_records (
    id SERIAL PRIMARY KEY,
    hakenmoto_id INTEGER REFERENCES employees(hakenmoto_id),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    regular_hours DECIMAL(10, 2) DEFAULT 0,
    overtime_hours DECIMAL(10, 2) DEFAULT 0,
    holiday_hours DECIMAL(10, 2) DEFAULT 0,
    base_salary DECIMAL(10, 2) DEFAULT 0,
    overtime_pay DECIMAL(10, 2) DEFAULT 0,
    holiday_pay DECIMAL(10, 2) DEFAULT 0,
    bonuses DECIMAL(10, 2) DEFAULT 0,
    deductions DECIMAL(10, 2) DEFAULT 0,
    social_insurance DECIMAL(10, 2) DEFAULT 0,
    pension DECIMAL(10, 2) DEFAULT 0,
    employment_insurance DECIMAL(10, 2) DEFAULT 0,
    income_tax DECIMAL(10, 2) DEFAULT 0,
    resident_tax DECIMAL(10, 2) DEFAULT 0,
    net_salary DECIMAL(10, 2) DEFAULT 0,
    payment_date DATE,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla salary_records creada');

-- ============================================
-- ÍNDICES
-- ============================================
SELECT log_message('Creando índices...');

CREATE INDEX idx_employees_factory ON employees(factory_id);
-- CREATE INDEX idx_employees_status ON employees(status); -- Comentado porque la columna no existe
CREATE INDEX idx_employees_is_active ON employees(is_active);
CREATE INDEX idx_employees_hakenmoto ON employees(hakenmoto_id);
CREATE INDEX idx_candidates_status ON candidates(status);
CREATE INDEX idx_candidates_rirekisho ON candidates(rirekisho_id);
CREATE INDEX idx_requests_hakenmoto ON requests(hakenmoto_id);
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_timer_cards_hakenmoto ON timer_cards(hakenmoto_id);
CREATE INDEX idx_timer_cards_date ON timer_cards(work_date);
CREATE INDEX idx_salary_hakenmoto ON salary_records(hakenmoto_id);
CREATE INDEX idx_salary_period ON salary_records(period_start, period_end);

SELECT log_message('✓ Índices creados');

-- ============================================
-- DATOS DE PRUEBA
-- ============================================
SELECT log_message('========================================');
SELECT log_message('Insertando datos de prueba...');
SELECT log_message('========================================');

-- El usuario administrador ahora se crea a través de un script separado para mayor fiabilidad.

-- Fábricas
SELECT log_message('Insertando fábricas...');
INSERT INTO factories (factory_id, name, address, phone, contact_person, is_active) VALUES
('PMI001', 'PMI Otsuka', '東京都豊島区大塚3-1-1', '03-1234-5678', '山田太郎', true),
('NIP001', 'Nippi Corporation', '神奈川県横浜市中区本町1-1', '045-9876-5432', '佐藤花子', true),
('YMH001', 'Yamaha Motors', '静岡県浜松市中区中沢町10-1', '053-1111-2222', '鈴木一郎', true),
('TOY001', 'Toyota Manufacturing', '愛知県豊田市トヨタ町1番地', '0565-3333-4444', '田中次郎', true),
('HON001', 'Honda Factory', '埼玉県和光市本町8-1', '048-5555-6666', '伊藤三郎', true);

SELECT log_message('✓ 5 fábricas insertadas');

-- Apartamentos
SELECT log_message('Insertando apartamentos...');
INSERT INTO apartments (apartment_code, address, monthly_rent, capacity, is_available) VALUES
('APT001', '東京都豊島区大塚2-10-5', 50000, 4, true),
('APT002', '神奈川県横浜市中区本町2-5-3', 45000, 2, true),
('APT003', '静岡県浜松市中区中沢町5-8', 40000, 3, true),
('APT004', '愛知県豊田市トヨタ町5-10', 42000, 2, false),
('APT005', '埼玉県和光市本町12-3', 48000, 4, true);

SELECT log_message('✓ 5 apartamentos insertados');

-- Candidatos de prueba eliminados - solo se importarán los datos reales desde archivos Excel
SELECT log_message('Omitiendo candidatos de prueba - se importarán datos reales desde archivos Excel');
SELECT log_message('✓ Candidatos de prueba omitidos correctamente');

-- Empleados de prueba eliminados - solo se importarán los datos reales desde archivos Excel
SELECT log_message('Omitiendo empleados de prueba - se importarán datos reales desde archivos Excel');
SELECT log_message('✓ Empleados de prueba omitidos correctamente');

-- Timer Cards de prueba eliminados - solo se importarán datos reales desde archivos Excel
SELECT log_message('Omitiendo registros de tiempo de prueba - se importarán datos reales desde archivos Excel');
SELECT log_message('✓ Timer Cards de prueba omitidos correctamente');

-- Solicitudes de prueba eliminadas - solo se importarán datos reales desde archivos Excel
SELECT log_message('Omitiendo solicitudes de prueba - se importarán datos reales desde archivos Excel');
SELECT log_message('✓ Solicitudes de prueba omitidas correctamente');

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================
SELECT log_message('========================================');
SELECT log_message('Verificando datos insertados...');
SELECT log_message('========================================');

DO $$
DECLARE
    users_count INTEGER;
    factories_count INTEGER;
    apartments_count INTEGER;
    candidates_count INTEGER;
    employees_count INTEGER;
    requests_count INTEGER;
    timer_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO users_count FROM users;
    SELECT COUNT(*) INTO factories_count FROM factories;
    SELECT COUNT(*) INTO apartments_count FROM apartments;
    SELECT COUNT(*) INTO candidates_count FROM candidates;
    SELECT COUNT(*) INTO employees_count FROM employees;
    SELECT COUNT(*) INTO requests_count FROM requests;
    SELECT COUNT(*) INTO timer_count FROM timer_cards;
    
    PERFORM log_message('✓ Users: ' || users_count);
    PERFORM log_message('✓ Factories: ' || factories_count);
    PERFORM log_message('✓ Apartments: ' || apartments_count);
    PERFORM log_message('✓ Candidates: ' || candidates_count);
    PERFORM log_message('✓ Employees: ' || employees_count);
    PERFORM log_message('✓ Requests: ' || requests_count);
    PERFORM log_message('✓ Timer Cards: ' || timer_count);
    
    IF factories_count = 0 OR candidates_count = 0 OR employees_count = 0 THEN
        RAISE EXCEPTION 'ERROR: No se insertaron todos los datos correctamente';
    ELSE
        PERFORM log_message('========================================');
        PERFORM log_message('✅ INICIALIZACIÓN COMPLETADA EXITOSAMENTE');
        PERFORM log_message('========================================');
        PERFORM log_message('');
        PERFORM log_message('📝 Nota: Los usuarios se crearán mediante el script create_admin_user.py');
        PERFORM log_message('');
        PERFORM log_message('🎉 Base de datos lista para usar');
    END IF;
END $$;
