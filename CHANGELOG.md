# CHANGELOG - JPUNS-Claude 3.0

Historial de cambios del Sistema de Gestión de Personal UNS-ClaudeJP.

---

## [3.1.0] - 2025-10-15

### 🔄 Actualización de Dependencias

#### Backend
- ✅ FastAPI actualizado de 0.118.0 a 0.119.0
- ✅ SQLAlchemy actualizado de 2.0.43 a 2.0.44
- ✅ psycopg2-binary actualizado de 2.9.10 a 2.9.11
- ✅ Alembic actualizado de 1.16.5 a 1.17.0
- ✅ bcrypt actualizado de 4.0.1 a 5.0.0
- ✅ Azure Computer Vision actualizado de 0.9.0 a 0.9.1
- ✅ Pydantic actualizado de 2.11.10 a 2.12.2
- ✅ NumPy actualizado a 2.3.x

#### Frontend
- ✅ React actualizado a 18.3.1
- ✅ @headlessui/react actualizado de 1.7.19 a 2.2.9
- ✅ @tanstack/react-query actualizado a 5.90.3
- ✅ date-fns actualizado de 2.30.0 a 4.1.0
- ✅ react-datepicker actualizado de 4.21.0 a 8.7.0
- ✅ react-router-dom actualizado de 6.20.0 a 7.9.4
- ✅ Recharts actualizado de 2.10.3 a 3.2.1
- ✅ tailwind-merge actualizado de 2.1.0 a 3.3.1
- ✅ Zustand actualizado de 4.4.7 a 5.0.8
- ✅ TypeScript actualizado de 4.9.5 a 5.9.3
- ✅ Tailwind CSS actualizado de 3.3.6 a 4.1.14
- ✅ ESLint actualizado a 9.37.0
- ✅ @testing-library/react actualizado a 16.3.0

#### Security
- 🔒 Actualizaciones de seguridad críticas en todas las dependencias
- 🔒 Mejoras en cifrado y autenticación

---

## [3.0.1] - 2025-10-12

### 🧹 Limpieza y Organización Masiva

#### Added
- ✅ Nuevos scripts unificados y profesionales:
  - `START.bat` - Script único para iniciar el sistema con verificaciones
  - `STOP.bat` - Detener todos los servicios de forma segura
  - `LOGS.bat` - Ver logs de forma interactiva
  - `REINSTALAR.bat` - Reinstalación completa desde cero
- ✅ README.md completamente reescrito y consolidado
- ✅ Documentación clara de solución de problemas:
  - `SOLUCION_LOGIN_DEFINITIVA.md`
  - `SOLUCION_ERROR_EMPLEADOS.md`
- ✅ Carpeta `LIXO/` para archivos obsoletos (organizados para referencia)

#### Changed
- 🔄 Estructura del proyecto completamente reorganizada
- 🔄 Reducción de 17 scripts .bat → 5 scripts esenciales
- 🔄 Consolidación de 12 archivos .md → 3 documentos principales
- 🔄 Eliminación de archivos temporales y duplicados

#### Fixed
- 🐛 Problema de login resuelto definitivamente (hash de password incorrecto)
- 🐛 Error al cargar empleados solucionado (campos faltantes en BD)
- 🐛 Sincronización modelo SQLAlchemy con estructura de BD PostgreSQL
- 🐛 Campos `emergency_contact*` corregidos en modelos
- 🐛 30+ columnas agregadas a tabla `employees`

#### Removed
- 🗑️ 12 scripts .bat obsoletos movidos a LIXO/
- 🗑️ 11 archivos .md redundantes movidos a LIXO/
- 🗑️ 4 archivos .py temporales movidos a LIXO/
- 🗑️ Eliminación de documentación fragmentada

### 📊 Estadísticas de Limpieza
- **Scripts:** 17 → 5 (70% reducción)
- **Documentación:** 12 → 3 (75% reducción)
- **Archivos en raíz:** 35 → 12 (66% reducción)
- **Organización:** Todo categorizado en carpeta LIXO/

---

## [3.0.0] - 2025-10-12

### Added
- 🎨 Diseño moderno con gradientes y animaciones
- 🎨 Dependencias actualizadas (React 18.2, Tailwind 3.3)
- 🎨 Nueva estructura de carpetas (services, store, types)
- 🎨 Scripts BAT profesionales mantenidos de 2.25
- 🎨 Logo UNS integrado en toda la aplicación
- 🎨 Sistema de temas y colores mejorado
- 🎨 Componentes animados con Framer Motion

### Changed
- 🔄 Frontend completamente rediseñado con UI moderna
- 🔄 Mejora en organización de componentes
- 🔄 Documentación consolidada y limpia
- 🔄 Performance optimizado

### Fixed
- 🐛 Problema de cache del navegador resuelto
- 🐛 Conexión BD al 100% (credenciales unificadas)
- 🐛 Eliminados archivos temporales y duplicados

### Removed
- 🗑️ Archivos obsoletos y redundantes (82% reducción)
- 🗑️ Documentación fragmentada de "problemas"
- 🗑️ Carpeta /back duplicada de 2.5.o
- 🗑️ Archivos temporales sin usar

---

## [2.5.0] - 2025-10-12 (2.5.o)

### Added
- Diseño actualizado con gradientes
- Scripts de limpieza de cache

---

## [2.0.0] - 2025-10-10 (2.25)

### Added
- Scripts BAT profesionales
- Documentación consolidada
- Logo UNS integrado
- Configuración Docker optimizada

---

## Convenciones de Versiones

El proyecto usa [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH**
- **MAJOR**: Cambios incompatibles en la API
- **MINOR**: Nueva funcionalidad compatible con versiones anteriores
- **PATCH**: Correcciones de bugs

### Tipos de Cambios
- 🎨 **Added**: Nueva funcionalidad
- 🔄 **Changed**: Cambios en funcionalidad existente
- 🐛 **Fixed**: Corrección de bugs
- 🗑️ **Removed**: Funcionalidad eliminada
- ⚠️ **Deprecated**: Funcionalidad que será eliminada
- 🔒 **Security**: Correcciones de seguridad

---

**Última actualización:** 2025-10-12
