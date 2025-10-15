# ÍNDICE MAESTRO - JPUNS-Claude 3.0
**Guía completa y organizada de todos los archivos del sistema**

---

## 🏁 COMENZAR AQUÍ

### 📖 Lectura Obligatoria (Orden Estricto)
1. **[LEEME_PRIMERO.txt](LEEME_PRIMERO.txt)** ⭐ **LEER PRIMERO**
   - Requisitos del sistema
   - Información crítica antes de instalar

2. **[README.md](README.md)** 📋 **LEER SEGUNDO**
   - Documentación general del proyecto
   - Características y funcionalidades

3. **[GUIA-USO-ARCHIVOS.md](GUIA-USO-ARCHIVOS.md)** 📚 **LEER TERCERO**
   - Esta guía completa de uso de archivos
   - Orden correcto de ejecución

---

## 🚀 INSTALACIÓN Y CONFIGURACIÓN

### Scripts de Instalación (Ejecutar en Orden)
1. **[INSTALAR.bat](INSTALAR.bat)** 🆕
   - Instalación completa del sistema
   - Configuración inicial

2. **[JpStart/start-app.bat](JpStart/start-app.bat)** ▶️
   - Iniciar todos los servicios
   - Verificar funcionamiento

### Guías de Configuración
- **[GUIA_RAPIDA.md](GUIA_RAPIDA.md)** - Inicio rápido
- **[GUIA-BASE-DATOS.md](GUIA-BASE-DATOS.md)** - Configuración de BD
- **[GUIA-BUILDER-RAPIDA.md](GUIA-BUILDER-RAPIDA.md)** - Uso del builder

---

## 🔄 ACTUALIZACIONES

### Proceso de Actualización
1. **[RESUMEN-ACTUALIZACION-2025-10-15.md](RESUMEN-ACTUALIZACION-2025-10-15.md)** 📋
   - Leer antes de actualizar
   - Conocer los cambios

2. **[ACTUALIZAR-DEPENDENCIAS.bat](ACTUALIZAR-DEPENDENCIAS.bat)** 🔄
   - Actualizar todas las dependencias
   - Automatizado y seguro

3. **[JpStart/test-app.bat](JpStart/test-app.bat)** 🧪
   - Verificar funcionamiento post-actualización

### Historial de Cambios
- **[CHANGELOG.md](CHANGELOG.md)** - Historial completo de versiones

---

## 🔧 MANTENIMIENTO Y DIAGNÓSTICO

### Scripts de Mantenimiento
| Script | Propósito | Cuándo usar |
|--------|-----------|-------------|
| **[JpStart/diagnose-issues.bat](JpStart/diagnose-issues.bat)** | Diagnosticar problemas | Cuando hay errores |
| **[LOGS.bat](LOGS.bat)** | Ver logs del sistema | Para diagnóstico |
| **[JpStart/restart-app.bat](JpStart/restart-app.bat)** | Reiniciar servicios | Después de cambios |
| **[JpStart/stop-app.bat](JpStart/stop-app.bat)** | Detener servicios | Antes de mantenimiento |

### Operaciones Específicas
| Script | Propósito | Cuándo usar |
|--------|-----------|-------------|
| **[BACKUP-BD.bat](BACKUP-BD.bat)** | Respaldo de base de datos | Antes de cambios importantes |
| **[CARGAR-FABRICAS.bat](CARGAR-FABRICAS.bat)** | Cargar configuración de fábricas | Para configurar nuevas fábricas |
| **[CHECK-AUTH.bat](CHECK-AUTH.bat)** | Verificar autenticación | Cuando hay problemas de login |
| **[PUSH-TO-GITHUB.bat](PUSH-TO-GITHUB.bat)** | Sincronizar con GitHub | Después de hacer cambios |

---

## 🏭 OPERACIONES DE FÁBRICAS

### Gestión de Fábricas
- **[GUIA-USO-ARCHIVOS-CANDIDATOS.md](GUIA-USO-ARCHIVOS-CANDIDATOS.md)** - Manejo de archivos de candidatos
- **[CARGAR-FABRICAS.bat](CARGAR-FABRICAS.bat)** - Cargar datos de fábricas
- **[scripts/check_factory_names.py](scripts/check_factory_names.py)** - Verificar nombres de fábricas
- **[scripts/assign_factory_ids.py](scripts/assign_factory_ids.py)** - Asignar IDs a fábricas

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Diagnóstico y Reparación
1. **[JpStart/diagnose-issues.bat](JpStart/diagnose-issues.bat)** 🔍
   - Primer paso ante cualquier problema

2. **Documentos de Solución** 📋
   - **[DIAGNOSTICO-OCR-Y-FOTO-COMPLETO.md](DIAGNOSTICO-OCR-Y-FOTO-COMPLETO.md)** - Problemas de OCR
   - **[DOCUMENTACION-RIREKISHO-JP-MODIF2.md](DOCUMENTACION-RIREKISHO-JP-MODIF2.md)** - Documentación Rirekisho
   - **[EXPLICACION_TEMAS_COMPLETA.md](EXPLICACION_TEMAS_COMPLETA.md)** - Explicación de temas

3. **Scripts de Reparación** 🔧
   - **[FIX-AUTH-ISSUE.bat](FIX-AUTH-ISSUE.bat)** - Reparar problemas de autenticación
   - **[FIX-CANDIDATE-STATUS-ENUM.bat](FIX-CANDIDATE-STATUS-ENUM.bat)** - Reparar estado de candidatos
   - **[fix-login-correcto.bat](fix-login-correcto.bat)** - Reparar login

---

## 🔄 REINSTALACIÓN

### Proceso Completo de Reinstalación
1. **[BACKUP-BD.bat](BACKUP-BD.bat)** 💾 - Hacer respaldo primero
2. **[JpStart/stop-app.bat](JpStart/stop-app.bat)** ⏹️ - Detener servicios
3. **[REINSTALAR.bat](REINSTALAR.bat)** 🔄 - Reinstalar completamente
4. **[JpStart/start-app.bat](JpStart/start-app.bat)** ▶️ - Iniciar nuevamente

---

## 📋 DOCUMENTACIÓN TÉCNICA

### Base de Datos
- **[base-datos/01_init_database.sql](base-datos/01_init_database.sql)** - Script inicial de BD
- **[base-datos/verify_database.py](base-datos/verify_database.py)** - Verificación de BD
- **[docs/DATABASE-MANAGEMENT.md](docs/DATABASE-MANAGEMENT.md)** - Gestión de BD

### Docker
- **[docker-compose.yml](docker-compose.yml)** - Configuración Docker
- **[docs/technical/docker-readiness.md](docs/technical/docker-readiness.md)** - Documentación Docker

### Desarrollo
- **[scripts/update-dependencies.py](scripts/update-dependencies.py)** - Script Python de actualización
- **[docs/technical/INSTRUCCIONES_COLUMNAS.md](docs/technical/INSTRUCCIONES_COLUMNAS.md)** - Instrucciones de columnas

---

## 🏗️ ESTRUCTURA DEL PROYECTO

### Backend
```
backend/
├── app/main.py              - Aplicación principal FastAPI
├── requirements.txt         - Dependencias de Python
├── init_db.py              - Inicialización de BD
└── scripts/                - Scripts de backend
```

### Frontend
```
frontend/
├── src/App.tsx             - Aplicación principal React
├── package.json            - Dependencias de Node.js
├── public/                 - Archivos públicos
└── src/                    - Código fuente
```

### Configuración
```
config/
├── company.json            - Configuración de empresa
├── factories/              - Configuración de fábricas
└── employee_master.xlsm    - Plantilla de empleados
```

---

## 🆘 FLUJOS DE TRABAJO RÁPIDOS

### FLUJO 1: Instalación Nueva (5 minutos)
```
1️⃣ LEER: LEEME_PRIMERO.txt
2️⃣ LEER: README.md
3️⃣ EJECUTAR: INSTALAR.bat
4️⃣ EJECUTAR: JpStart/start-app.bat
```

### FLUJO 2: Actualización del Sistema (3 minutos)
```
1️⃣ LEER: RESUMEN-ACTUALIZACION-2025-10-15.md
2️⃣ EJECUTAR: ACTUALIZAR-DEPENDENCIAS.bat
3️⃣ EJECUTAR: JpStart/restart-app.bat
```

### FLUJO 3: Diagnosticar Problemas (2 minutos)
```
1️⃣ EJECUTAR: JpStart/diagnose-issues.bat
2️⃣ EJECUTAR: LOGS.bat
3️⃣ SEGUIR: Recomendaciones del diagnóstico
```

---

## 📞 CONTACTO Y SOPORTE

### Autoayuda
1. **Primero**: Ejecutar `JpStart/diagnose-issues.bat`
2. **Segundo**: Revisar `LOGS.bat`
3. **Tercero**: Consultar documentación específica

### Documentación Importante
- **[CLAUDE.md](CLAUDE.md)** - Información del asistente
- **[GEMINI_SUMMARY.md](GEMINI_SUMMARY.md)** - Resumen del sistema

---

**Última actualización**: 2025-10-15  
**Versión**: 3.1.0  
**Estado**: ✅ Sistema actualizado y funcionando

---

> 💡 **CONSEJO**: Guardar este índice como marcador para referencia rápida