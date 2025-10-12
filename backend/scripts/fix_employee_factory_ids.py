
import sys
from pathlib import Path
import os

# Adjust the path to include the app directory
# This assumes the script is run from the 'backend' directory
sys.path.append(str(Path(__file__).resolve().parents[1]))

from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.models import Employee, Factory
from sqlalchemy import and_

def fix_employee_data(db: Session):
    """
    Finds employees with incorrect factory_id data from the old import script
    and moves the incorrect ID to the 'hakensaki_shain_id' field.
    """
    print("="*50)
    print("Iniciando corrección de datos de empleados...")
    print("="*50)

    # Find employees that were likely imported with the old script.
    # The key indicators are:
    # 1. hakensaki_shain_id is NULL (the old script didn't populate it).
    # 2. factory_id is NOT NULL (the old script put the wrong value here).
    employees_to_fix = db.query(Employee).filter(
        and_(
            Employee.hakensaki_shain_id == None,
            Employee.factory_id != None
        )
    ).all()

    if not employees_to_fix:
        print("✓ No se encontraron empleados con datos incorrectos para corregir.")
        return

    print(f"Se encontraron {len(employees_to_fix)} empleados para procesar...")
    
    fixed_count = 0
    for employee in employees_to_fix:
        incorrect_factory_id = employee.factory_id
        
        # Check if the value in factory_id looks like a hakensaki_shain_id and not a real factory_id
        # A real factory_id would exist in the factories table.
        is_a_real_factory_id = db.query(Factory).filter(Factory.factory_id == incorrect_factory_id).first()

        if not is_a_real_factory_id:
            # This is a broken record.
            # 1. Move the incorrect value to the correct field.
            employee.hakensaki_shain_id = incorrect_factory_id
            
            # 2. Nullify the factory_id, as it was wrong.
            employee.factory_id = None
            
            print(f"  - Empleado ID {employee.hakenmoto_id}:")
            print(f"    - Movido '{incorrect_factory_id}' de 'factory_id' a 'hakensaki_shain_id'.")
            print(f"    - 'factory_id' se ha establecido a NULL. Necesita ser asignado manualmente.")
            fixed_count += 1
        else:
            # This employee's factory_id points to a real factory.
            # It might be correct, or it might be a coincidence.
            # It's safer to leave it alone and report it.
            print(f"  - Empleado ID {employee.hakenmoto_id}:")
            print(f"    - OMITIDO: El valor en 'factory_id' ('{incorrect_factory_id}') coincide con una fábrica real.")
            print(f"    - Por seguridad, este registro no se ha modificado. Revisar manualmente.")


    if fixed_count > 0:
        db.commit()
        print(f"\n✓ Se corrigieron {fixed_count} registros de empleados.")
    else:
        print("\n✓ No se realizaron cambios en la base de datos.")

    print("="*50)
    print("Script de corrección finalizado.")
    print("="*50)


def main():
    db = SessionLocal()
    try:
        fix_employee_data(db)
    except Exception as e:
        print(f"\n✗ Ocurrió un error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    main()
