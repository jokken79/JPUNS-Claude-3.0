#!/usr/bin/env python3
"""
Script de verificación e inicialización de base de datos
JPUNS-Claude 3.0
"""

import os
import sys
import time
import psycopg2
from psycopg2 import sql
from datetime import datetime

# Configuración
DB_CONFIG = {
    'host': os.getenv('POSTGRES_HOST', 'db'),
    'port': int(os.getenv('POSTGRES_PORT', 5432)),
    'database': os.getenv('POSTGRES_DB', 'uns_claudejp'),
    'user': os.getenv('POSTGRES_USER', 'uns_admin'),
    'password': os.getenv('POSTGRES_PASSWORD', '57UD10R')
}

REQUIRED_TABLES = [
    'users',
    'factories',
    'candidates',
    'employees',
    'requests',
    'salary_records',
    'timer_cards'
]

MAX_RETRIES = 10
RETRY_DELAY = 3  # segundos

class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def log(message, color=Colors.OKBLUE):
    """Imprime mensaje con color"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"{color}[{timestamp}] {message}{Colors.ENDC}")

def wait_for_db():
    """Espera a que la base de datos esté lista"""
    log("Esperando a que PostgreSQL esté listo...", Colors.OKCYAN)
    
    for attempt in range(MAX_RETRIES):
        try:
            conn = psycopg2.connect(**DB_CONFIG)
            conn.close()
            log("✓ PostgreSQL está listo", Colors.OKGREEN)
            return True
        except psycopg2.OperationalError as e:
            log(f"Intento {attempt + 1}/{MAX_RETRIES}: {str(e)}", Colors.WARNING)
            if attempt < MAX_RETRIES - 1:
                time.sleep(RETRY_DELAY)
            else:
                log("✗ No se pudo conectar a PostgreSQL", Colors.FAIL)
                return False
    return False

def check_tables():
    """Verifica que todas las tablas existan"""
    log("Verificando tablas de la base de datos...", Colors.OKCYAN)
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        
        missing_tables = []
        for table in REQUIRED_TABLES:
            cur.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = %s
                )
            """, (table,))
            exists = cur.fetchone()[0]
            
            if exists:
                log(f"  ✓ Tabla '{table}' existe", Colors.OKGREEN)
            else:
                log(f"  ✗ Tabla '{table}' NO existe", Colors.FAIL)
                missing_tables.append(table)
        
        cur.close()
        conn.close()
        
        return len(missing_tables) == 0, missing_tables
        
    except Exception as e:
        log(f"Error verificando tablas: {str(e)}", Colors.FAIL)
        return False, []

def check_data():
    """Verifica que haya datos en las tablas principales"""
    log("Verificando datos en tablas...", Colors.OKCYAN)
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        
        tables_to_check = ['users', 'factories', 'candidates', 'employees']
        empty_tables = []
        
        for table in tables_to_check:
            cur.execute(f"SELECT COUNT(*) FROM {table}")
            count = cur.fetchone()[0]
            
            if count > 0:
                log(f"  ✓ Tabla '{table}': {count} registros", Colors.OKGREEN)
            else:
                log(f"  ⚠ Tabla '{table}': 0 registros (vacía)", Colors.WARNING)
                empty_tables.append(table)
        
        cur.close()
        conn.close()
        
        return len(empty_tables) == 0, empty_tables
        
    except Exception as e:
        log(f"Error verificando datos: {str(e)}", Colors.FAIL)
        return False, []

def run_migrations():
    """Ejecuta las migraciones SQL"""
    log("Ejecutando migraciones...", Colors.OKCYAN)
    
    migration_file = "/docker-entrypoint-initdb.d/01_init_database.sql"
    
    if not os.path.exists(migration_file):
        log(f"⚠ Archivo de migración no encontrado: {migration_file}", Colors.WARNING)
        return False
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True
        cur = conn.cursor()
        
        with open(migration_file, 'r', encoding='utf-8') as f:
            sql_script = f.read()
        
        log("Ejecutando script SQL...", Colors.OKCYAN)
        cur.execute(sql_script)
        
        cur.close()
        conn.close()
        
        log("✓ Migraciones ejecutadas exitosamente", Colors.OKGREEN)
        return True
        
    except Exception as e:
        log(f"✗ Error ejecutando migraciones: {str(e)}", Colors.FAIL)
        return False

def verify_specific_data():
    """Verifica datos específicos críticos"""
    log("Verificando datos críticos...", Colors.OKCYAN)
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        
        # Verificar usuario admin
        cur.execute("SELECT COUNT(*) FROM users WHERE username = 'admin'")
        admin_count = cur.fetchone()[0]
        
        if admin_count > 0:
            log("  ✓ Usuario admin existe", Colors.OKGREEN)
        else:
            log("  ✗ Usuario admin NO existe", Colors.FAIL)
            return False
        
        # Verificar que haya al menos una fábrica
        cur.execute("SELECT COUNT(*) FROM factories")
        factories_count = cur.fetchone()[0]
        
        if factories_count > 0:
            log(f"  ✓ Fábricas: {factories_count}", Colors.OKGREEN)
        else:
            log("  ✗ No hay fábricas", Colors.FAIL)
            return False
        
        cur.close()
        conn.close()
        
        return True
        
    except Exception as e:
        log(f"Error verificando datos críticos: {str(e)}", Colors.FAIL)
        return False

def main():
    """Función principal"""
    log("="*60, Colors.HEADER)
    log("VERIFICACIÓN E INICIALIZACIÓN DE BASE DE DATOS", Colors.HEADER)
    log("JPUNS-Claude 3.0", Colors.HEADER)
    log("="*60, Colors.HEADER)
    
    # Paso 1: Esperar a que PostgreSQL esté listo
    if not wait_for_db():
        log("✗ FALLO: PostgreSQL no está disponible", Colors.FAIL)
        sys.exit(1)
    
    # Paso 2: Verificar tablas
    tables_ok, missing_tables = check_tables()
    
    if not tables_ok:
        log(f"⚠ Tablas faltantes: {', '.join(missing_tables)}", Colors.WARNING)
        log("Ejecutando migraciones...", Colors.OKCYAN)
        
        if not run_migrations():
            log("✗ FALLO: No se pudieron ejecutar las migraciones", Colors.FAIL)
            sys.exit(1)
        
        # Verificar de nuevo
        time.sleep(2)
        tables_ok, missing_tables = check_tables()
        
        if not tables_ok:
            log("✗ FALLO: Aún faltan tablas después de migración", Colors.FAIL)
            sys.exit(1)
    
    # Paso 3: Verificar datos
    data_ok, empty_tables = check_data()
    
    if not data_ok:
        log(f"⚠ Tablas vacías: {', '.join(empty_tables)}", Colors.WARNING)
        log("Las migraciones deberían haber insertado datos de prueba", Colors.WARNING)
        log("Intentando ejecutar migraciones de nuevo...", Colors.OKCYAN)
        
        if not run_migrations():
            log("✗ FALLO: No se pudieron insertar datos", Colors.FAIL)
            sys.exit(1)
        
        # Verificar de nuevo
        time.sleep(2)
        data_ok, empty_tables = check_data()
    
    # Paso 4: Verificar datos críticos
    if not verify_specific_data():
        log("✗ FALLO: Datos críticos faltantes", Colors.FAIL)
        sys.exit(1)
    
    # Paso 5: Resumen final
    log("="*60, Colors.HEADER)
    log("✅ BASE DE DATOS VERIFICADA Y LISTA", Colors.OKGREEN)
    log("="*60, Colors.HEADER)
    
    # Mostrar resumen
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        
        log("\n📊 RESUMEN DE DATOS:", Colors.OKCYAN)
        for table in REQUIRED_TABLES:
            cur.execute(f"SELECT COUNT(*) FROM {table}")
            count = cur.fetchone()[0]
            log(f"  • {table}: {count} registros", Colors.OKBLUE)
        
        cur.close()
        conn.close()
        
    except Exception as e:
        log(f"Error obteniendo resumen: {str(e)}", Colors.WARNING)
    
    log("\n✓ Sistema listo para iniciar\n", Colors.OKGREEN)
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        log("\n⚠ Proceso interrumpido por el usuario", Colors.WARNING)
        sys.exit(1)
    except Exception as e:
        log(f"\n✗ Error inesperado: {str(e)}", Colors.FAIL)
        sys.exit(1)
