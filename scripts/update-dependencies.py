#!/usr/bin/env python3
"""
Script para actualizar automáticamente las dependencias del proyecto JPUNS-Claude 3.0
"""

import subprocess
import sys
import json
import os
from datetime import datetime
from pathlib import Path


def run_command(command, cwd=None):
    """Ejecuta un comando y devuelve el resultado"""
    try:
        result = subprocess.run(
            command, 
            shell=True, 
            cwd=cwd, 
            capture_output=True, 
            text=True
        )
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)


def update_backend_dependencies():
    """Actualiza las dependencias del backend"""
    print("🔄 Actualizando dependencias del backend...")
    
    # Verificar dependencias desactualizadas
    success, stdout, stderr = run_command("pip list --outdated", cwd="backend")
    if not success:
        print(f"❌ Error al verificar dependencias del backend: {stderr}")
        return False
    
    print("📋 Dependencias desactualizadas del backend:")
    print(stdout)
    
    # Actualizar dependencias
    success, stdout, stderr = run_command("pip install -r requirements.txt --upgrade", cwd="backend")
    if not success:
        print(f"❌ Error al actualizar dependencias del backend: {stderr}")
        return False
    
    print("✅ Dependencias del backend actualizadas correctamente")
    return True


def update_frontend_dependencies():
    """Actualiza las dependencias del frontend"""
    print("🔄 Actualizando dependencias del frontend...")
    
    # Verificar dependencias desactualizadas
    success, stdout, stderr = run_command("npm outdated", cwd="frontend")
    if not success:
        print("📋 No hay dependencias desactualizadas o error al verificar")
    
    print("📋 Dependencias desactualizadas del frontend:")
    print(stdout)
    
    # Actualizar dependencias
    success, stdout, stderr = run_command("npm update", cwd="frontend")
    if not success:
        print(f"❌ Error al actualizar dependencias del frontend: {stderr}")
        return False
    
    # Arreglar vulnerabilidades de seguridad
    success, stdout, stderr = run_command("npm audit fix", cwd="frontend")
    if not success:
        print(f"⚠️ Advertencia al arreglar vulnerabilidades: {stderr}")
    
    print("✅ Dependencias del frontend actualizadas correctamente")
    return True


def check_compatibility():
    """Verifica la compatibilidad de las dependencias"""
    print("🔍 Verificando compatibilidad de dependencias...")
    
    # Verificar compatibilidad del backend
    success, stdout, stderr = run_command("python -m pip check", cwd="backend")
    if not success:
        print(f"❌ Problemas de compatibilidad en el backend: {stderr}")
        return False
    
    print("✅ Compatibilidad del backend verificada")
    
    # Verificar compatibilidad del frontend
    success, stdout, stderr = run_command("npm audit --audit-level=moderate", cwd="frontend")
    if not success:
        print(f"⚠️ Advertencias de seguridad en el frontend: {stderr}")
    
    print("✅ Compatibilidad del frontend verificada")
    return True


def update_changelog():
    """Actualiza el changelog con la fecha actual"""
    changelog_path = Path("CHANGELOG.md")
    
    if not changelog_path.exists():
        print("❌ No se encontró el archivo CHANGELOG.md")
        return False
    
    # Leer el changelog actual
    with open(changelog_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Crear nueva entrada de actualización
    today = datetime.now().strftime("%Y-%m-%d")
    new_entry = f"""

## [3.1.1] - {today}

### 🔄 Actualización Automática de Dependencias

#### Backend
- ✅ Actualización automática de dependencias de Python
- ✅ Verificación de compatibilidad

#### Frontend
- ✅ Actualización automática de dependencias de npm
- ✅ Corrección de vulnerabilidades de seguridad

#### Security
- 🔒 Actualizaciones de seguridad automáticas

---

"""
    
    # Insertar la nueva entrada después del encabezado principal
    lines = content.split('\n')
    insert_index = 0
    for i, line in enumerate(lines):
        if line.startswith('## [3.1.0]'):
            insert_index = i
            break
    
    lines.insert(insert_index, new_entry)
    
    # Escribir el changelog actualizado
    with open(changelog_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print("✅ Changelog actualizado")
    return True


def main():
    """Función principal"""
    print("🚀 Iniciando actualización de dependencias de JPUNS-Claude 3.0")
    print("=" * 60)
    
    # Actualizar backend
    if not update_backend_dependencies():
        print("❌ Falló la actualización del backend")
        sys.exit(1)
    
    # Actualizar frontend
    if not update_frontend_dependencies():
        print("❌ Falló la actualización del frontend")
        sys.exit(1)
    
    # Verificar compatibilidad
    if not check_compatibility():
        print("❌ Problemas de compatibilidad detectados")
        sys.exit(1)
    
    # Actualizar changelog
    update_changelog()
    
    print("=" * 60)
    print("✅ Actualización completada exitosamente")
    print("📝 Se ha actualizado el CHANGELOG.md con los detalles")


if __name__ == "__main__":
    main()