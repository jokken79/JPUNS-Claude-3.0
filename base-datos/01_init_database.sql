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
    apartment_code VARCHAR(50) REFERENCES apartments(apartment_code),
    hakensaki_shain_id VARCHAR(50),
    full_name_kanji VARCHAR(100) NOT NULL,
    full_name_kana VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(10),
    nationality VARCHAR(50),
    zairyu_card_number VARCHAR(50),
    zairyu_expire_date DATE,
    address TEXT,
    phone VARCHAR(20),
    mobile VARCHAR(20),
    email VARCHAR(100),
    photo_url VARCHAR(255),
    hire_date DATE,
    current_hire_date DATE,
    contract_start_date DATE,
    contract_end_date DATE,
    jikyu INTEGER,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Campos adicionales de migración 002
    emergency_contact_name VARCHAR(255),
    emergency_contact_phone VARCHAR(50),
    emergency_contact_relationship VARCHAR(100),
    bank_name VARCHAR(255),
    bank_branch VARCHAR(255),
    bank_account_number VARCHAR(100),
    social_insurance_number VARCHAR(100),
    pension_number VARCHAR(100),
    -- Campos adicionales de migración 003
    employee_number VARCHAR(50) UNIQUE,
    furigana VARCHAR(255),
    postal_code VARCHAR(20),
    position VARCHAR(100),
    department VARCHAR(100),
    contract_type VARCHAR(50),
    monthly_salary DECIMAL(10, 2),
    visa_type VARCHAR(100),
    driver_license_number VARCHAR(100),
    bank_account_holder VARCHAR(255),
    employment_insurance_number VARCHAR(100),
    documents_url TEXT
);
SELECT log_message('✓ Tabla employees creada');

-- Tabla: contract_workers
SELECT log_message('Creando tabla: contract_workers');
CREATE TABLE contract_workers (
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
SELECT log_message('✓ Tabla contract_workers creada');

-- Tabla: staff
SELECT log_message('Creando tabla: staff');
CREATE TABLE staff (
    id SERIAL PRIMARY KEY,
    staff_id INTEGER UNIQUE NOT NULL,
    full_name_kanji VARCHAR(100),
    full_name_kana VARCHAR(100),
    monthly_salary INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT log_message('✓ Tabla staff creada');

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
CREATE INDEX idx_employees_status ON employees(status);
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

-- Usuario Admin
SELECT log_message('Insertando usuario admin...');
-- NOTA: Este hash fue generado con bcrypt y corresponde al password: admin123
-- Generado con: from passlib.context import CryptContext; CryptContext(schemes=["bcrypt"]).hash("admin123")
INSERT INTO users (username, email, password_hash, role, full_name) VALUES
('admin', 'admin@uns-kikaku.com', '$2b$12$svu9jskq/HZgJoL6BmVBW.LS9uILn3Z.7fJmaE17mctNtpVb2jjhi', 'SUPER_ADMIN', 'Administrator');
-- Password: admin123

SELECT log_message('✓ Usuario admin creado (username: admin, password: admin123)');

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

-- Candidatos
SELECT log_message('Insertando candidatos...');
INSERT INTO candidates (
    rirekisho_id, full_name_kanji, full_name_kana, full_name_roman,
    date_of_birth, gender, nationality, phone, mobile, email,
    status, postal_code, visa_type, japanese_level
) VALUES
('R2025001', 'グエン・バン・アン', 'ぐえん・ばん・あん', 'Nguyen Van An', '1995-03-15', 'male', 'Vietnam', '03-1111-1111', '090-1234-5678', 'nguyen.a@example.com', 'pending', '170-0013', '技能実習', 'N3'),
('R2025002', 'マリア・サントス', 'まりあ・さんとす', 'Maria Santos', '1992-07-20', 'female', 'Philippines', '045-2222-2222', '080-9876-5432', 'maria.s@example.com', 'approved', '231-0001', '特定技能', 'N4'),
('R2025003', 'リウ・ウェイ', 'りう・うぇい', 'Liu Wei', '1998-11-08', 'male', 'China', '053-3333-3333', '070-1111-2222', 'liu.w@example.com', 'pending', '430-0928', '技術・人文知識', 'N2'),
('R2025004', 'パテル・クマール', 'ぱてる・くまーる', 'Patel Kumar', '1994-05-25', 'male', 'India', '0565-4444-4444', '090-3333-4444', 'patel.k@example.com', 'pending', '471-0001', '技能実習', 'N4'),
('R2025005', 'アナ・ロドリゲス', 'あな・ろどりげす', 'Ana Rodriguez', '1996-09-12', 'female', 'Brazil', '048-5555-5555', '080-5555-6666', 'ana.r@example.com', 'approved', '351-0033', '特定技能', 'N3');

SELECT log_message('✓ 5 candidatos insertados');

-- Empleados
SELECT log_message('Insertando empleados...');
INSERT INTO employees (
    hakenmoto_id, rirekisho_id, factory_id, apartment_code,
    full_name_kanji, full_name_kana, employee_number,
    date_of_birth, gender, nationality,
    phone, mobile, email,
    hire_date, contract_start_date, contract_end_date,
    hourly_wage, monthly_salary, status,
    visa_type, position, department, contract_type
) VALUES
(1001, 'R2025002', 'PMI001', 'APT001', 'カルロス・メンデス', 'かるろす・めんです', 'EMP001', '1990-01-15', 'male', 'Peru', '03-1111-1111', '090-1111-1111', 'carlos.m@company.com', '2024-01-10', '2024-01-10', '2026-12-31', 1500, 240000, 'active', '特定技能', '製造作業員', '製造部', 'full-time'),
(1002, NULL, 'NIP001', 'APT002', 'ソフィア・キム', 'そふぃあ・きむ', 'EMP002', '1993-05-20', 'female', 'South Korea', '045-2222-2222', '090-2222-2222', 'sofia.k@company.com', '2024-02-15', '2024-02-15', '2027-06-30', 1800, 288000, 'active', '技術・人文知識', '品質管理', '品質管理部', 'full-time'),
(1003, NULL, 'YMH001', 'APT003', 'チャン・バン・ビー', 'ちゃん・ばん・びー', 'EMP003', '1995-09-10', 'male', 'Vietnam', '053-3333-3333', '090-3333-3333', 'tran.b@company.com', '2024-03-20', '2024-03-20', '2026-03-31', 1400, 224000, 'active', '技能実習', '製造作業員', '製造部', 'contract'),
(1004, NULL, 'TOY001', 'APT004', 'ジェシカ・シルバ', 'じぇしか・しるば', 'EMP004', '1992-11-25', 'female', 'Brazil', '0565-4444-4444', '090-4444-4444', 'jessica.s@company.com', '2024-04-01', '2024-04-01', '2027-12-31', 1600, 256000, 'active', '特定技能', 'ライン作業', '製造部', 'full-time'),
(1005, 'R2025005', 'HON001', 'APT005', 'アハメド・ハッサン', 'あはめど・はっさん', 'EMP005', '1991-07-30', 'male', 'Egypt', '048-5555-5555', '090-5555-5555', 'ahmed.h@company.com', '2024-05-10', '2024-05-10', '2026-09-30', 1700, 272000, 'active', '技能実習', '組立作業', '組立部', 'full-time');

SELECT log_message('✓ 5 empleados insertados');

-- Timer Cards (últimos 7 días)
SELECT log_message('Insertando registros de tiempo...');
INSERT INTO timer_cards (hakenmoto_id, work_date, shift_type, clock_in, clock_out, break_minutes, overtime_minutes) VALUES
(1001, CURRENT_DATE - INTERVAL '6 days', 'asa', '09:00', '18:00', 60, 0),
(1001, CURRENT_DATE - INTERVAL '5 days', 'asa', '09:00', '18:00', 60, 0),
(1001, CURRENT_DATE - INTERVAL '4 days', 'asa', '09:00', '18:00', 60, 0),
(1002, CURRENT_DATE - INTERVAL '6 days', 'asa', '08:30', '17:30', 60, 0),
(1002, CURRENT_DATE - INTERVAL '5 days', 'asa', '08:30', '17:30', 60, 0),
(1003, CURRENT_DATE - INTERVAL '6 days', 'asa', '09:00', '19:00', 60, 60),
(1003, CURRENT_DATE - INTERVAL '5 days', 'asa', '09:00', '18:30', 60, 30);

SELECT log_message('✓ 7 registros de tiempo insertados');

-- Solicitudes
SELECT log_message('Insertando solicitudes...');
INSERT INTO requests (hakenmoto_id, request_type, start_date, end_date, reason, status) VALUES
(1001, 'yukyu', CURRENT_DATE + INTERVAL '10 days', CURRENT_DATE + INTERVAL '12 days', '家族旅行', 'pending'),
(1002, 'hankyu', CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE - INTERVAL '1 day', '体調不良', 'approved'),
(1003, 'yukyu', CURRENT_DATE + INTERVAL '5 days', CURRENT_DATE + INTERVAL '5 days', '私用', 'pending');

SELECT log_message('✓ 3 solicitudes insertadas');

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
    
    IF users_count = 0 OR factories_count = 0 OR candidates_count = 0 OR employees_count = 0 THEN
        RAISE EXCEPTION 'ERROR: No se insertaron todos los datos correctamente';
    ELSE
        PERFORM log_message('========================================');
        PERFORM log_message('✅ INICIALIZACIÓN COMPLETADA EXITOSAMENTE');
        PERFORM log_message('========================================');
        PERFORM log_message('');
        PERFORM log_message('Credenciales de acceso:');
        PERFORM log_message('  Usuario: admin@uns-kikaku.com');
        PERFORM log_message('  Password: admin123');
        PERFORM log_message('');
        PERFORM log_message('🎉 Base de datos lista para usar');
    END IF;
END $$;
