# GUIA DE USO - ARCHIVOS .BAT Y .MD
**JPUNS-Claude 3.0 - Orden de Uso Recomendado**

---

## 📋 ORDEN DE LECTURA RECOMENDADO (Archivos .MD)

### 1. **LEEME_PRIMERO.txt** 📖
```
LEER PRIMERO
```
- **Propósito**: Información inicial y requisitos del sistema
- **Cuándo leer**: Antes de cualquier instalación o configuración

### 2. **README.md** 📋
```
LEER SEGUNDO
```
- **Propósito**: Documentación general del proyecto
- **Cuándo leer**: Después de LEEME_PRIMERO.txt

### 3. **RESUMEN-ACTUALIZACION-2025-10-15.md** 🔄
```
LEER TERCERO (si es una actualización)
```
- **Propósito**: Resumen de la última actualización del sistema
- **Cuándo leer**: Después de actualizar dependencias

### 4. **CHANGELOG.md** 📝
```
LEER CUARTO (opcional)
```
- **Propósito**: Historial completo de cambios del sistema
- **Cuándo leer**: Para了解 todas las versiones y cambios

### 5. **GUIAS ESPECÍFICAS** (según necesidad)
```
LEER SEGÚN REQUERIMIENTO
```
- **GUIA_RAPIDA.md**: Guía rápida de inicio
- **GUIA-BASE-DATOS.md**: Configuración de base de datos
- **GUIA-BUILDER-RAPIDA.md**: Uso del builder
- **GUIA-USO-ARCHIVOS-CANDIDATOS.md**: Manejo de archivos de candidatos

---

## 🚀 ORDEN DE EJECUCIÓN RECOMENDADO (Archivos .BAT)

### INSTALACIÓN INICIAL

#### 1. **INSTALAR.bat** 🆕
```
EJECUTAR PRIMERO (instalación nueva)
```
- **Propósito**: Instalación completa del sistema desde cero
- **Cuándo ejecutar**: Primera vez que se instala el sistema

#### 2. **JpStart/start-app.bat** ▶️
```
EJECUTAR DESPUÉS DE INSTALAR
```
- **Propósito**: Iniciar todos los servicios del sistema
- **Cuándo ejecutar**: Después de la instalación para iniciar el sistema

### ACTUALIZACIÓN DEL SISTEMA

#### 1. **ACTUALIZAR-DEPENDENCIAS.bat** 🔄
```
EJECUTAR PRIMERO (para actualizar)
```
- **Propósito**: Actualizar todas las dependencias del sistema
- **Cuándo ejecutar**: Cuando se quiera actualizar el sistema

#### 2. **JpStart/restart-app.bat** 🔄
```
EJECUTAR DESPUÉS DE ACTUALIZAR
```
- **Propósito**: Reiniciar servicios después de actualizar
- **Cuándo ejecutar**: Después de actualizar dependencias

### MANTENIMIENTO Y DIAGNÓSTICO

#### 1. **JpStart/diagnose-issues.bat** 🔍
```
EJECUTAR CUANDO HAY PROBLEMAS
```
- **Propósito**: Diagnosticar problemas del sistema
- **Cuándo ejecutar**: Cuando el sistema no funciona correctamente

#### 2. **LOGS.bat** 📋
```
EJECUTAR PARA VER LOGS
```
- **Propósito**: Ver logs del sistema
- **Cuándo ejecutar**: Para diagnosticar problemas o monitorear

#### 3. **JpStart/test-app.bat** 🧪
```
EJECUTAR PARA PRUEBAS
```
- **Propósito**: Ejecutar pruebas del sistema
- **Cuándo ejecutar**: Para verificar funcionamiento

### OPERACIONES ESPECÍFICAS

#### 1. **BACKUP-BD.bat** 💾
```
EJECUTAR PARA RESPALDAR BASE DE DATOS
```
- **Propósito**: Crear respaldo de la base de datos
- **Cuándo ejecutar**: Antes de cambios importantes

#### 2. **CARGAR-FABRICAS.bat** 🏭
```
EJECUTAR PARA CARGAR FÁBRICAS
```
- **Propósito**: Cargar configuración de fábricas
- **Cuándo ejecutar**: Cuando se necesite configurar nuevas fábricas

#### 3. **CHECK-AUTH.bat** 🔐
```
EJECUTAR PARA VERIFICAR AUTENTICACIÓN
```
- **Propósito**: Verificar sistema de autenticación
- **Cuándo ejecutar**: Cuando hay problemas de login

#### 4. **PUSH-TO-GITHUB.bat** 📤
```
EJECUTAR PARA SINCRONIZAR CON GITHUB
```
- **Propósito**: Endar cambios al repositorio GitHub
- **Cuándo ejecutar**: Después de hacer cambios importantes

### REINSTALACIÓN

#### 1. **REINSTALAR.bat** 🔄
```
EJECUTAR PARA REINSTALAR COMPLETAMENTE
```
- **Propósito**: Reinstalación completa del sistema
- **Cuándo ejecutar**: Cuando el sistema está corrupto o falla

#### 2. **JpStart/stop-app.bat** ⏹️
```
EJECUTAR ANTES DE REINSTALAR
```
- **Propósito**: Detener todos los servicios
- **Cuándo ejecutar**: Antes de reinstalar o hacer mantenimiento

---

## 📊 FLUJOS DE TRABAJO COMUNES

### FLUJO 1: INSTALACIÓN NUEVA
```
1. LEER: LEEME_PRIMERO.txt
2. LEER: README.md
3. EJECUTAR: INSTALAR.bat
4. EJECUTAR: JpStart/start-app.bat
```

### FLUJO 2: ACTUALIZACIÓN DEL SISTEMA
```
1. LEER: RESUMEN-ACTUALIZACION-2025-10-15.md
2. EJECUTAR: ACTUALIZAR-DEPENDENCIAS.bat
3. EJECUTAR: JpStart/restart-app.bat
4. EJECUTAR: JpStart/test-app.bat (opcional)
```

### FLUJO 3: DIAGNÓSTICO DE PROBLEMAS
```
1. EJECUTAR: JpStart/diagnose-issues.bat
2. EJECUTAR: LOGS.bat
3. LEER: Documentación específica del problema
4. EJECUTAR: Solución específica (si existe)
```

### FLUJO 4: MANTENIMIENTO PROGRAMADO
```
1. EJECUTAR: BACKUP-BD.bat
2. EJECUTAR: ACTUALIZAR-DEPENDENCIAS.bat
3. EJECUTAR: JpStart/restart-app.bat
4. EJECUTAR: JpStart/test-app.bat
```

---

## ⚠️ ADVERTENCIAS IMPORTANTES

1. **SIEMPRE** leer LEEME_PRIMERO.txt antes de cualquier instalación
2. **NUNCA** ejecutar REINSTALAR.bat sin hacer backup primero
3. **SIEMPRE** detener servicios antes de mantenimiento mayor
4. **VERIFICAR** logs después de cualquier cambio importante
5. **PROBAR** el sistema después de cada actualización

---

## 🆘 AYUDA RÁPIDA

| Problema | Archivo .BAT a ejecutar | Archivo .MD a consultar |
|----------|------------------------|-------------------------|
| No inicia el sistema | JpStart/diagnose-issues.bat | README.md |
| Error de login | CHECK-AUTH.bat | GUIA-BASE-DATOS.md |
| Sistema lento | LOGS.bat | GUIA_RAPIDA.md |
| Actualización necesaria | ACTUALIZAR-DEPENDENCIAS.bat | RESUMEN-ACTUALIZACION-2025-10-15.md |
| Reinstalación completa | REINSTALAR.bat | LEEME_PRIMERO.txt |

---

## 📞 SOPORTE

Si después de seguir esta guía el sistema no funciona correctamente:
1. Ejecutar JpStart/diagnose-issues.bat
2. Revisar LOGS.bat
3. Consultar la documentación específica
4. Contactar soporte técnico

**Última actualización**: 2025-10-15  
**Versión**: 3.1.0