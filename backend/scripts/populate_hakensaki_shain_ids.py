
import sys
import pandas as pd
from pathlib import Path

# Add parent directory to path for module resolution
sys.path.append(str(Path(__file__).resolve().parents[1]))

from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.models import Employee

def populate_ids(db: Session):
    """
    Reads the employee master Excel file and updates the 'hakensaki_shain_id'
    for existing employees in the database.
    """
    print("="*50)
    print("Iniciando actualización de 'hakensaki_shain_id'...")
    print("="*50)

    try:
        # Path inside the Docker container
        excel_path = '/app/config/employee_master.xlsm'
        df = pd.read_excel(excel_path, sheet_name='派遣社員', header=1)
        print(f"✓ Se leyó el archivo Excel '{excel_path}' correctamente.")
    except FileNotFoundError:
        print(f"✗ ERROR: No se pudo encontrar el archivo Excel en la ruta: {excel_path}")
        print("  Asegúrate de que el archivo existe y la ruta es correcta dentro del contenedor.")
        return
    except Exception as e:
        print(f"✗ ERROR: Ocurrió un error al leer el archivo Excel: {e}")
        return

    updated_count = 0
    skipped_count = 0
    not_found_count = 0

    for index, row in df.iterrows():
        # Get employee ID (hakenmoto_id) and the target ID from Excel
        hakenmoto_id = row.get('社員№')
        hakensaki_shain_id_from_excel = row.get('派遣先ID')

        # Skip rows without a main employee ID
        if pd.isna(hakenmoto_id):
            continue

        try:
            hakenmoto_id = int(hakenmoto_id)
        except (ValueError, TypeError):
            print(f"  - OMITIDO: '社員№' inválido en la fila {index + 2} del Excel.")
            continue

        # Find the employee in the database
        employee = db.query(Employee).filter(Employee.hakenmoto_id == hakenmoto_id).first()

        if not employee:
            not_found_count += 1
            # Optional: print if you want to see which ones are not found
            # print(f"  - ADVERTENCIA: Empleado con ID {hakenmoto_id} no encontrado en la base de datos.")
            continue

        # Check if the value from Excel is valid and if an update is needed
        if pd.notna(hakensaki_shain_id_from_excel) and str(hakensaki_shain_id_from_excel).strip():
            id_to_set = str(hakensaki_shain_id_from_excel).strip()
            
            # Update only if it's different from the current value
            if employee.hakensaki_shain_id != id_to_set:
                employee.hakensaki_shain_id = id_to_set
                updated_count += 1
                print(f"  - ACTUALIZADO: Empleado ID {hakenmoto_id} -> hakensaki_shain_id = '{id_to_set}'")
            else:
                # Value is already correct, no update needed
                skipped_count += 1
        else:
            # Value in Excel is empty, nothing to update
            skipped_count += 1
            
    if updated_count > 0:
        db.commit()
        print(f"\n✓ Se actualizaron {updated_count} registros de empleados.")
    else:
        print("\n✓ No se necesitaron actualizaciones en la base de datos.")

    if not_found_count > 0:
        print(f"  ⚠ {not_found_count} empleados del archivo Excel no fueron encontrados en la base de datos.")
    if skipped_count > 0:
        print(f"  ℹ {skipped_count} empleados ya tenían el dato correcto o no tenían dato en el Excel.")
        
    print("="*50)
    print("Script finalizado.")
    print("="*50)


def main():
    db = SessionLocal()
    try:
        populate_ids(db)
    except Exception as e:
        print(f"\n✗ Ocurrió un error inesperado: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    main()
