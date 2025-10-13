# Notas de Desarrollo - UNS-ClaudeJP 3.0

Este archivo mantiene un registro de decisiones técnicas, problemas resueltos y contexto importante para el desarrollo continuo.

## 📅 Última Actualización: 2025-10-13

---

## ⚙️ Configuración de Claude Code

### Modelo Seleccionado
- **Modelo actual**: Claude Sonnet 3.7 (`claude-sonnet-3-7-20250219`)
- **Razón**: Balance perfecto entre capacidad y consumo de tokens
- **Ubicación**: `C:\Users\JPUNS\AppData\Roaming\Code\User\settings.json:50`

### Archivos de Contexto
- ✅ `CLAUDE.md` - Documentación principal para Claude Code
- ✅ `.claude/settings.json` - Configuración del proyecto
- ✅ `NOTAS-DESARROLLO.md` - Este archivo (registro de desarrollo)

---

## 🔧 Decisiones Técnicas Recientes

### 2025-10-13: Configuración Inicial de Claude Code
- Creado CLAUDE.md con arquitectura completa del proyecto
- Configurado Sonnet 3.7 como modelo por defecto
- Mejorado `.claude/settings.json` con shortcuts y contexto del proyecto

---

## 🐛 Problemas Conocidos y Soluciones

### Login Issues
- **Problema**: Usuario admin no puede iniciar sesión
- **Solución**: Ejecutar `fix-login-correcto.bat`
- **Documentación**: Ver `SOLUCION_LOGIN_DEFINITIVA.md`

### Error al Cargar Empleados
- **Estado**: ✅ Resuelto
- **Documentación**: Ver `SOLUCION_ERROR_EMPLEADOS.md`

---

## 📋 TODOs y Features Pendientes

### En Proceso
- [ ] Ninguno actualmente

### Backlog
- [ ] (Agregar features pendientes aquí)

---

## 💡 Tips de Desarrollo

### Iniciar Nueva Sesión con Claude
1. Ejecutar `/init` al comenzar
2. Claude leerá automáticamente CLAUDE.md
3. Revisar este archivo (NOTAS-DESARROLLO.md) para contexto reciente

### Comandos Útiles Rápidos
```bash
# Ver logs en tiempo real
docker logs -f uns-claudejp-backend

# Acceso rápido a base de datos
docker exec -it uns-claudejp-db psql -U uns_admin -d uns_claudejp

# Reiniciar un servicio específico
docker-compose restart backend
```

---

## 📝 Log de Sesiones

### Sesión 2025-10-13
- **Objetivo**: Configurar Claude Code para el proyecto
- **Completado**:
  - ✅ Cambiado modelo a Sonnet 3.7
  - ✅ Creado CLAUDE.md
  - ✅ Mejorado .claude/settings.json
  - ✅ Creado NOTAS-DESARROLLO.md
- **Próximos pasos**: Comenzar desarrollo normal del proyecto

---

## 🔗 Links Importantes

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/api/docs
- **Credenciales**: admin / admin123

---

**Nota**: Actualiza este archivo cada vez que hagas cambios importantes o resuelvas problemas significativos.
